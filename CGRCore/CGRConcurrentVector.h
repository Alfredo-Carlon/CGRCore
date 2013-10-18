//
//  CGRConcurrentVector.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/14/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#ifndef CGRCore_CGRConcurrentVector_h
#define CGRCore_CGRConcurrentVector_h

#define DEFAULT_CHUNK_SIZE 10000
#define DEFAULT_CHUNKS_LIST_SIZE 1000
#include "CGRDoubleQueue.h"

template <class VECTOR_DATA>
class CGRConcurrentVector
{
private:
    uint32_t chunkSize; //Size, in number of elements of each chunk
    int32_t numberOfChunks;
    int32_t vectorSize;
    VECTOR_DATA **firstChunk;
    void **chunksList; //The list of chunks
    uint32_t maxNumberOfChunks; //The max number of chunks that chunksList can hold...
    
    //Holder of free indices.. this indices are of already freed elements
    //A thread that is going it add a vertex to the vector is expected to
    //First check this queue since its space that is already in memory
    DoubleQueue<uint32_t> freeSlots = DoubleQueue<uint32_t>(-1);
    //The next index at the end of the vector that is "avaible".
    //The space may not be present. The thread is expected to find out and
    //alloc memory for a new chunk.
    int32_t nextIndex;
    
    
    //For adding and global reading
    int32_t nowServing; //Flag for the curnt kind of threads the vector is serving...
    //0 - Serving local
    //1 - Serving global
    //2 - Purging  (the vector is purging either locals or globals)
    int32_t activeLocals; // The number of active locals and wanna be...
    int32_t activeGlobals; //The number of active globals and wanna be...
    
    //Each thread that executes a method that intends to access the vector locally execute
    //this in order to do so..
    //When this method returns the thread is safe to "make" "local" modifications
    void startLocal(){
        //First step is to register as a "wanna be" local
        OSAtomicIncrement32((volatile int32_t *)&activeLocals);
        //Now check the state of the serving flag.. if the vector is serving locals then return..
        if (OSAtomicCompareAndSwap32(0, 0, (volatile int32_t *)&nowServing)) {
            //The vector is serving locals so we return
            return;
        }
        //Check if the vector is purging
        if (OSAtomicCompareAndSwap32(2, 2, (volatile int32_t *)&nowServing)) {
            //The vector is purging so we have to wait till we find out what kind of threads its going to
            //serve..
            OSAtomicDecrement32((volatile int32_t *)&activeLocals);
            while(1){
                while(OSAtomicCompareAndSwap32(2, 2, (volatile int32_t *)&nowServing))
                    [NSThread sleepForTimeInterval:0.001];
                
                //try to see if its local
                if(OSAtomicCompareAndSwap32(0, 0, (volatile int32_t *)&nowServing))
                    return;
                //If we are serving globals try to set it to purge
                if(OSAtomicCompareAndSwap32(1, 2, (volatile int32_t *)&nowServing)){
                    //We set the purge so now we have to wait for activeGlobals to reach 0
                    //Any new active globals are now holding since the vector is purging..
                    //Any new active local is holding to find out what is the outcome of the purge
                    while(!OSAtomicCompareAndSwap32(0, 0, (volatile int32_t *)&activeGlobals));
                    //activeGlobals reached a value of 0 which means that all new active globals are just cheking
                    //the vector's state
                    //Secure our place in the vector, i.e. that we are going to get served..
                    OSAtomicIncrement32((volatile int32_t *)&activeLocals);
                    OSAtomicCompareAndSwap32(2, 0, (volatile int32_t *)&nowServing);
                    return;
                }
                
            }
        }
        //Check if we are serving globals
        if(OSAtomicCompareAndSwap32(1, 1, (volatile int32_t *)&nowServing)){
            //Our place is already secured since we incremented activeLocals
            while(1){
                //try setting it to purge...
                if(OSAtomicCompareAndSwap32(1, 2, (volatile int32_t *)&nowServing)){
                    //We successfully changed the flag from global to purge so now we have to wait till
                    //activeGlobals is 0
                    //Any new active globals are now holding since the vector is purging..
                    //Any new active local is holding to find out what is the outcome of the purge
                    while(!OSAtomicCompareAndSwap32(0, 0, (volatile int32_t *)&activeGlobals));
                    //activeGlobals reached a value of 0 which means that all new active globals are just cheking
                    //the vector's state
                    //Secure our place in the vector, i.e. that we are going to get served..
                    //OSAtomicIncrement32((volatile int32_t *)activeLocals);
                    OSAtomicCompareAndSwap32(2, 0, (volatile int32_t *)&nowServing);
                    return;
                }
                //Try to see if the vector is serving locals
                if(OSAtomicCompareAndSwap32(0, 0, (volatile int32_t *)&nowServing)){
                    return;
                }
                //if the vector is purging then we can't return.. there is no point in checking it..
            }
        }
    }
    
    //After a local thread is finished doing "local modifications" then call this method to release
    //the resources
    void endLocal(){
        //We check-out from the vector
        OSAtomicDecrement32((volatile int32_t *)&activeLocals);
    }
    
    
    //Each thread that executes a method that intends to access the vector as a "whole" i.e. globally (sorting)
    //must first execute this in order to do so...
    //When this method returns the thread is safe to access the vector globally.
    
    void startGlobal()
    {
        //First step is to register as a "wanna be" global
        OSAtomicIncrement32((volatile int32_t *)&activeGlobals);
        //Now check the state of the serving flag.. if the vector is serving globals then return..
        if (OSAtomicCompareAndSwap32(1, 1, (volatile int32_t *)&nowServing)) {
            //The vector is serving locals so we return
            return;
        }
        //Check if the vector is purging
        if (OSAtomicCompareAndSwap32(2, 2, (volatile int32_t *)&nowServing)) {
            //The vector is purging so we have to wait till we find out what kind of threads its going to
            //serve..
            OSAtomicDecrement32((volatile int32_t *)&activeGlobals);
            while(1){
                while(OSAtomicCompareAndSwap32(2, 2, (volatile int32_t *)&nowServing))
                    [NSThread sleepForTimeInterval:0.001];
                
                //try to see if its globals
                if(OSAtomicCompareAndSwap32(1, 1, (volatile int32_t *)&nowServing))
                    return;
                //If we are serving locals try to set it to purge
                if(OSAtomicCompareAndSwap32(0, 2, (volatile int32_t *)&nowServing)){
                    //We successfully changed the flag from local to purge so now we have to wait till
                    //activeLocals is 0
                    //Any new active locals are now holding since the vector is purging..
                    //Any new active globals is holding to find out what is the outcome of the purge
                    while(!OSAtomicCompareAndSwap32(0, 0, (volatile int32_t *)&activeLocals));
                    //activeLocals reached a value of 0 which means that all new active locals are just cheking
                    //the vector's state
                    //Secure our place in the vector, i.e. that we are going to get served..
                    OSAtomicIncrement32((volatile int32_t *)&activeGlobals);
                    OSAtomicCompareAndSwap32(2, 1, (volatile int32_t *)&nowServing);
                    return;
                }
                
            }
        }
        //Check if we are serving Locals
        if(OSAtomicCompareAndSwap32(0, 0, (volatile int32_t *)&nowServing)){
            //Our place is already secured since we incremented activeLocals
            while(1){
                //try setting it to purge...
                if(OSAtomicCompareAndSwap32(0, 2, (volatile int32_t *)&nowServing)){
                    //We successfully changed the flag from local to purge so now we have to wait till
                    //activeLocals is 0
                    //Any new active locals are now holding since the vector is purging..
                    //Any new active globals is holding to find out what is the outcome of the purge
                    while(!OSAtomicCompareAndSwap32(0, 0, (volatile int32_t *)&activeLocals));
                    //activeLocals reached a value of 0 which means that all new active locals are just cheking
                    //the vector's state
                    OSAtomicCompareAndSwap32(2, 1, (volatile int32_t *)&nowServing);
                    return;
                }
                //Try to see if the vector is serving globals
                if(OSAtomicCompareAndSwap32(1, 1, (volatile int32_t *)&nowServing)){
                    return;
                }
                //if the vector is purging then we can't return.. there is no point in checking it..
            }
        }
    }
    
    
    //After a global thread is finished.. then call this method to release the resources
    void endGlobal()
    {
        OSAtomicDecrement32((volatile int32_t *)&activeGlobals);
    }
    
    void initVector()
    {
        uint32_t numberOfChunks = vectorSize / chunkSize + 1;
        if(numberOfChunks > DEFAULT_CHUNKS_LIST_SIZE){
            maxNumberOfChunks = numberOfChunks;
        }else{
            maxNumberOfChunks = DEFAULT_CHUNKS_LIST_SIZE;
        }
        
        chunksList = (void **)malloc(sizeof(VECTOR_DATA **)*maxNumberOfChunks);
        if(!chunksList){
            //We may have not enough memory so we "report" it.. TO DO
            return;
        }
        for(unsigned int i=0; i != maxNumberOfChunks; i++){
            chunksList[i] = NULL;
        }
        //Alloc the chunks
        firstChunk = (VECTOR_DATA **)malloc((sizeof(VECTOR_DATA *)*(chunkSize)));
        if(!firstChunk){
            //We may have not enough memory so we "report" it.. TO DO
            return;
        }
        for(unsigned int i=0; i != chunkSize; i++){
            firstChunk[i] = NULL; //Try on demand alloc
        }
        chunksList[0] = firstChunk;
        for(unsigned int i=1; i != numberOfChunks; i++){
            VECTOR_DATA **lastChunk = (VECTOR_DATA **)malloc((sizeof(VECTOR_DATA *)*(chunkSize)));
            chunksList[i] = lastChunk;
            for(unsigned int j=0; j != chunkSize; j++){
                lastChunk[j] = NULL;
            }
        }
    }
    
public:
    ConcurrentVector(){
        maxNumberOfChunks = DEFAULT_CHUNKS_LIST_SIZE;
        chunksList = (void **)malloc(sizeof(VECTOR_DATA **)*maxNumberOfChunks);
        if(!chunksList){
            //We may have not enough memory so we "report" it.. TO DO
            return;
        }
        for(unsigned int i=0; i != maxNumberOfChunks; i++){
            chunksList[i] = NULL;
        }
        firstChunk = NULL;
        firstChunk = (VECTOR_DATA **)malloc(sizeof(VECTOR_DATA *)*DEFAULT_CHUNK_SIZE);
        chunkSize = DEFAULT_CHUNK_SIZE;
        if(!firstChunk){
            //We may have not enough memory so we "report" it.. TO DO
            return;
        }
        for(unsigned int i=0; i != chunkSize; i++){
            firstChunk[i] = NULL; //Try on demand alloc
        }
        chunksList[0] = firstChunk;
        numberOfChunks = 1;
        vectorSize = DEFAULT_CHUNK_SIZE;
        activeGlobals = 0;
        activeLocals = 0;
        nowServing = 0;
        //freeSlots = new DoubleQueue<uint32_t>(-1);
        return;
    }
    
    ConcurrentVector(uint32_t vectorSize){
        chunkSize = DEFAULT_CHUNK_SIZE;
        this ->vectorSize = vectorSize;
        initVector();
        activeGlobals = 0;
        activeLocals = 0;
        nowServing = 0;
    }
    
    ConcurrentVector(uint32_t vectorSize, uint32_t chunkSize){
        this ->chunkSize = chunkSize;
        this ->vectorSize = vectorSize;
        initVector();
        activeGlobals = 0;
        activeLocals = 0;
        nowServing = 0;
    }
    
    ~ConcurrentVector()
    {
        
    }
    
    uint32_t add(VECTOR_DATA *data)
    {
        //First register as local thread
        startLocal();
        //Now check the queue for a free space
        uint32_t nextSpace = freeSlots.get();
        if(nextSpace == (uint32_t)-1){
            nextSpace = OSAtomicIncrement32((volatile int32_t *)&nextSpace);
        }
        //Now we have a space avaible... check in which chunk the space is..
        uint32_t holdingChunk = nextSpace/chunkSize;
        
        //For now assume that we have enough space... so holdingChunk always points to a valid chunk
        //First try to check if its null.. if so try to change it to 0x1 so we reserve memory..
        
        if(OSAtomicCompareAndSwapPtr(NULL, (void *)0x1, (void * volatile *)(chunksList[holdingChunk]))){
            //If we got here then we are the first ones to reserve memory..
            //We do it and then set it up..
            VECTOR_DATA **newChunk = (VECTOR_DATA **)malloc((sizeof(VECTOR_DATA *)*(chunkSize)));
            if(!newChunk){
                //We may have not enough memory so we "report" it.. TO DO
                return -1;
            }
            for(unsigned int i=0; i != chunkSize; i++){
                newChunk[i] = NULL; //Try on demand alloc
            }
            //Set the new chunk in the list so other threads can also use it
            OSAtomicCompareAndSwapPtr((void *)0x1, (void *)newChunk, (void * volatile *)(chunksList[holdingChunk]));
            uint32_t localIndex = nextSpace % chunkSize;
            newChunk[localIndex] = data;
            return nextSpace;
        }
        //If we didn't reserve memory then try to get the add
        while(OSAtomicCompareAndSwapPtr((void *)0x1, (void *)0x1, (void * volatile *)(chunksList[holdingChunk])));
        //After just read the add and update the data
        VECTOR_DATA **chunk = (VECTOR_DATA **)chunksList[holdingChunk];
        uint32_t localIndex = nextSpace % chunkSize;
        chunk[localIndex] = data;
        return nextSpace;
    }
    
    VECTOR_DATA *dataAtIndex(uint32_t index){
        //First register as local thread
        startLocal();
        //Get the chunk number for the data
        uint32_t holdingChunk = index/chunkSize;
        
        if(holdingChunk > maxNumberOfChunks){
            //Throw an exception
            NSException *outOfBoundsException = [NSException exceptionWithName:@"CGRIndexOutOfBoundsException" reason:@"The argument index for dataAtIndex is out of bounds" userInfo:nil];
            @throw outOfBoundsException;
        }
        //Now check if the chunk is valid..
        //To check it first look if chunksList[holdingChunk] is not null or 0x1
        if(OSAtomicCompareAndSwapPtr(NULL, NULL, (void * volatile *)(chunksList[holdingChunk]))){
            //Chunk is empty so we throw an out of bounds exception
            NSException *outOfBoundsException = [NSException exceptionWithName:@"CGRIndexOutOfBoundsException" reason:@"The argument index for dataAtIndex is out of bounds" userInfo:nil];
            @throw outOfBoundsException;
        }
        if(OSAtomicCompareAndSwapPtr((void *)0x1, (void *)0x1, (void * volatile *)(chunksList[holdingChunk]))){
            //Chunk is empty so we throw an out of bounds exception
            NSException *outOfBoundsException = [NSException exceptionWithName:@"CGRIndexOutOfBoundsException" reason:@"The argument index for dataAtIndex is out of bounds" userInfo:nil];
            @throw outOfBoundsException;
        }
        //Now check if chunksList[holdingChunk][localIndex] is not null
        uint32_t localIndex = index % chunkSize;
        if(((VECTOR_DATA **)(chunksList[holdingChunk]))[localIndex] != NULL){
            return ((VECTOR_DATA **)(chunksList[holdingChunk]))[localIndex];
        }else{
            //Container is empty so we throw an out of bounds exception
            NSException *outOfBoundsException = [NSException exceptionWithName:@"CGRIndexOutOfBoundsException" reason:@"The argument index for dataAtIndex is out of bounds" userInfo:nil];
            @throw outOfBoundsException;
        }
        
    }
    
};

#endif
