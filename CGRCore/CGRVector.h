//
//  CGRVector.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/13/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#ifndef CGRCore_CGRVector_h
#define CGRCore_CGRVector_h


//Simple implementation of a vector.
//Not thread safe


#define DEFAULT_CHUNK_SIZE 10000000



template <class VECTOR_DATA>
class CGRVector {
    
private:
    uint32_t chunkSize;
    uint32_t numberOfChunks;
    uint32_t vectorSize;
    uint32_t vectorCapacity;
    uint32_t nextFreeIndex;
    VECTOR_DATA **headChunk;
    
    void _init(uint32_t chunkSize,uint32_t capacity){
        this ->chunkSize = chunkSize;
        vectorCapacity = capacity;
        if(chunkSize == 0 || capacity == 0){
            vectorSize = 0;
            headChunk = NULL;
            return;
        }
        numberOfChunks = vectorCapacity/chunkSize + 1;
        vectorSize = 0;
        vectorCapacity = capacity;
        headChunk = (VECTOR_DATA **)malloc(sizeof(VECTOR_DATA *)*(chunkSize + 1));
        if(headChunk == NULL){
            NSException *e = [NSException exceptionWithName:@"CGRVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
            @throw e;
        }
        for(uint32_t i=0; i != chunkSize+1; i++)
            headChunk[i] = NULL;
        
        VECTOR_DATA **curnt = headChunk;
        
        for(uint32_t i=1; i != numberOfChunks; i++){
            VECTOR_DATA **newChunk = (VECTOR_DATA **)malloc(sizeof(VECTOR_DATA *)*(chunkSize + 1));
            if(newChunk == NULL){
                NSException *e = [NSException exceptionWithName:@"CGRVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
                //Deallocate the memory
                VECTOR_DATA **curnt = (VECTOR_DATA **)headChunk[chunkSize];
                for(uint32_t i=1; i != numberOfChunks; i++){
                    VECTOR_DATA **tmp = curnt;
                    curnt = (VECTOR_DATA **)curnt[chunkSize];
                    free(tmp);
                }
                @throw e;
            }
            curnt[chunkSize] = (VECTOR_DATA *)newChunk;
            curnt = newChunk;
            for(uint32_t i=0; i != chunkSize+1; i++)
                newChunk[i] = NULL;
        }
        nextFreeIndex = 0;
    }
    
    void _newChunk()
    {
        VECTOR_DATA **newChunk = (VECTOR_DATA **)malloc(sizeof(VECTOR_DATA *)*(chunkSize + 1));
        if(newChunk == NULL){
            NSException *e = [NSException exceptionWithName:@"CGRVectorOutOfMemoryException" reason:@"Couldn't allocate memory for vector chunk" userInfo:nil];
            @throw e;
        }
        VECTOR_DATA **curnt = headChunk;
        while(curnt[chunkSize] != NULL)
            curnt = (VECTOR_DATA **)curnt[chunkSize];
        curnt[chunkSize] = (VECTOR_DATA *)newChunk;
        for(uint32_t i=0; i != chunkSize+1; i++)
            newChunk[i] = NULL;
    }
    
public:
    CGRVector()
    {
        _init(DEFAULT_CHUNK_SIZE, DEFAULT_CHUNK_SIZE);
    }
    CGRVector(uint32_t capacity)
    {
        _init(DEFAULT_CHUNK_SIZE, capacity);
    }
    CGRVector(uint32_t capacity,uint32_t chunkSize)
    {
        _init(chunkSize,capacity);
    }
    ~CGRVector()
    {
        VECTOR_DATA **curnt = headChunk;
        while(curnt != NULL){
            VECTOR_DATA **tmp = curnt;
            curnt = (VECTOR_DATA **)curnt[chunkSize];
            free(tmp);
        }
    }
    
    uint32_t add(VECTOR_DATA *data)
    {
        //Check if the nextFreeIndex is a valid index
        if(nextFreeIndex == vectorCapacity){
            //We need to allocate a new chunk
            @try {
                _newChunk();
                vectorCapacity += chunkSize;
            }
            @catch (NSException *exception) {
                @throw exception;
            }
            @finally {
                
            }
        }
        
        //Find the chunk where the new data will go in
        uint32_t chunk = nextFreeIndex/chunkSize;
        //Get the chunk
        VECTOR_DATA **curntChunk = headChunk;
        for(uint32_t i=0; i != chunk; i++){
            curntChunk = (VECTOR_DATA **)curntChunk[chunkSize];
        }
        //Now add the data
        curntChunk[nextFreeIndex%chunkSize] = data;
        vectorSize++;
        nextFreeIndex++;
        return nextFreeIndex-1;
    }
    
    bool insertAtIndex(VECTOR_DATA *data, uint32_t index)
    {
        //first check if the vector is big enough
        if(vectorCapacity < index)
            return false;
        //Find the chunk
        uint32_t chunk = index/chunkSize;
        VECTOR_DATA **curntChunk = headChunk;
        for(uint32_t i=0; i != chunk; i++){
            curntChunk = (VECTOR_DATA **)curntChunk[chunkSize];
            if(curntChunk == NULL)
                return false; //should not happen
        }
        //if(curntChunk[index %chunkSize] == NULL)
            vectorSize++;
        curntChunk[index % chunkSize] = data;
        return true;
        
    }
    
    VECTOR_DATA *elementAtIndex(uint32_t index)
    {
        if(index > vectorCapacity)
            return NULL;
        //Find the chunk
        uint32_t chunk = index/chunkSize;
        VECTOR_DATA **curntChunk = headChunk;
        for(uint32_t i=0; i != chunk; i++){
            curntChunk = (VECTOR_DATA **)curntChunk[chunkSize];
            if(curntChunk == NULL)
                return NULL;
        }
        return curntChunk[index % chunkSize];
    }
    
    uint32_t size()
    {
        return vectorSize;
    }
    
    uint32_t capacity()
    {
        return vectorCapacity;
    }
    
    bool increaseCapacity(uint32_t targetCapacity)
    {
        //tries to increase the vector capacity to "targetCapacity"
        
    }
    
    
};

#endif
