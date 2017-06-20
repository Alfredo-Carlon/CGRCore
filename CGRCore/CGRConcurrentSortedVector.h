//
//  CGRConcurrentSortedVector.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/14/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//
// This file is part of CGRCore.

// CGRCore is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// CGRCore is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with CGRCore.  If not, see <http://www.gnu.org/licenses/>.


#ifndef CGRCore_CGRConcurrentSortedVector_h
#define CGRCore_CGRConcurrentSortedVector_h

#define DEFAULT_CSV_CHUNK_SIZE 10000
#define DEFAULT_CSV_CHUNKS_LIST_SIZE 1000
#define DEFAULT_CSV_ADITIONAL_SIZE 20


#include <libkern/OSAtomic.h>
#include <stdlib.h>


template <class VECTOR_DATA>
class CGRConcurrentSortedVector
{
private:
    struct vector_element
    {
        int32_t elementLock;
        VECTOR_DATA *element;
        VECTOR_DATA **aditionalElements; //If in sorting we have elements that "would" go in this element's place
    };
    uint32_t chunkSize; //Size, in number of elements of each chunk
    int32_t numberOfChunks;
    int32_t overlappingTolerance; //Tolerance of overlapping elements before we are forced to copy the array
    int32_t vectorSize;
    struct vector_element **firstChunk;
    void **chunksList; //The list of chunks
    uint32_t maxNumberOfChunks; //The max number of chunks that chunksList can hold...
    
    int32_t ticketDispenser;
    
    typedef int (*comparator)(VECTOR_DATA *element1, VECTOR_DATA *element2);
    
    comparator elementComparator;
    
    /*
     At least for the momment we are not going to support "global" lock of an adjacency list
     
     //For adding and global reading
     int32_t nowServing; //Flag for the curnt kind of threads the vector is serving...
     //0 - Serving local
     //1 - Serving global
     //2 - Purging  (the vector is purging either locals or globals)
     int32_t activeLocals; // The number of active locals and wanna be...
     int32_t activeGlobals; //The number of active globals and wanna be...
     
     */
    /*
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
     
     */
    
public:
    
    //Inits a sorted vector without the comparator
    CGRConcurrentSortedVector(){
        maxNumberOfChunks = DEFAULT_CSV_CHUNKS_LIST_SIZE;
        chunksList = (void **)malloc(sizeof(struct vector_element **)*maxNumberOfChunks);
        if(!chunksList){
            //We may have not enough memory so we "report" it.. TO DO
            return;
        }
        for(unsigned int i=0; i != maxNumberOfChunks; i++){
            chunksList[i] = NULL;
        }
        firstChunk = NULL;
        firstChunk = (struct vector_element **)malloc(sizeof(struct vector_element *)*DEFAULT_CSV_CHUNK_SIZE);
        chunkSize = DEFAULT_CSV_CHUNK_SIZE;
        if(!firstChunk){
            //We may have not enough memory so we "report" it.. TO DO
            return;
        }
        for(unsigned int i=0; i != chunkSize; i++){
            firstChunk[i] = NULL; //Try on demand alloc
        }
        chunksList[0] = firstChunk;
        numberOfChunks = 1;
        vectorSize = DEFAULT_CSV_CHUNK_SIZE;
        ticketDispenser = 0;
        elementComparator = NULL;
        //freeSlots = new DoubleQueue<uint32_t>(-1);
        return;
    }
    
    //Inits the sorted vector with a comparator
    
    CGRConcurrentSortedVector(int (*comp)(VECTOR_DATA *element1, VECTOR_DATA *element2)){
        maxNumberOfChunks = DEFAULT_CSV_CHUNKS_LIST_SIZE;
        chunksList = (void **)malloc(sizeof(struct vector_element **)*maxNumberOfChunks);
        if(!chunksList){
            //We may have not enough memory so we "report" it.. TO DO
            return;
        }
        for(unsigned int i=0; i != maxNumberOfChunks; i++){
            chunksList[i] = NULL;
        }
        firstChunk = NULL;
        firstChunk = (struct vector_element **)malloc(sizeof(struct vector_element *)*DEFAULT_CSV_CHUNK_SIZE);
        chunkSize = DEFAULT_CSV_CHUNK_SIZE;
        if(!firstChunk){
            //We may have not enough memory so we "report" it.. TO DO
            return;
        }
        for(unsigned int i=0; i != chunkSize; i++){
            firstChunk[i] = NULL; //Try on demand alloc
        }
        chunksList[0] = firstChunk;
        numberOfChunks = 1;
        vectorSize = DEFAULT_CSV_CHUNK_SIZE;
        ticketDispenser = 0;
        elementComparator = NULL;
        elementComparator = comp;
        //freeSlots = new DoubleQueue<uint32_t>(-1);
        return;
    }
    
    void setComparator(int (*comp)(VECTOR_DATA *element1, VECTOR_DATA *element2)){
        elementComparator = comp;
    }
    
    struct vector_element *newElement()
    {
        struct vector_element *newOne = (struct vector_element *)malloc(sizeof(struct vector_element));
        if(newOne == NULL){
            return NULL;
        }
        newOne ->elementLock = 0;
        newOne ->aditionalElements = NULL;
        newOne ->element = NULL;
        return newOne;
    }
    
    void add(VECTOR_DATA *element)
    {
        if(elementComparator == NULL)
            return;
        //First get a ticket
        int32_t ticket = OSAtomicIncrement32((volatile int32_t *)&ticketDispenser);
        while(ticket == 0){
            ticket = OSAtomicIncrement32((volatile int32_t *)&ticketDispenser);
        }
        //Get the number of chunks allocated
        uint32_t mask = 0xFFFFFFFF;
        int32_t chunks = OSAtomicAnd32(mask, (volatile uint32_t *)numberOfChunks);
        //Now do a binary search in the vector
        int32_t min = 0;
        int32_t max = chunks;
        int32_t curnt = (max-min) >>1;
        while (curnt != min) {
            struct vector_element **curntChunk = (struct vector_element **)(chunksList[curnt]);
            //Now lets do a binary search inside the chunk
            int32_t localMin,localMax,localCurnt;
            localMin = 0; localMax = chunkSize; localCurnt = chunkSize >> 1;
            while (localMin != localCurnt) {
                //Lock the localCurnt
                while(!OSAtomicCompareAndSwap32(0, ticket, &(curntChunk[localCurnt] ->elementLock)));
                if(curntChunk[localCurnt] ->element == NULL){
                    OSAtomicCompareAndSwap32(ticket, 0, &(curntChunk[localCurnt] ->elementLock));
                    localMax = localCurnt;
                    localCurnt = localMin + ((localMax - localMin)>>1);
                    continue;
                }
                //We hold the lock and then compare
                int compRes = elementComparator(curntChunk[localCurnt] ->element,element);
                if(compRes == 0){
                    //We add this to the data
                    
                }
                if(compRes == -1){
                    OSAtomicCompareAndSwap32(ticket, 0, &(curntChunk[localCurnt] ->elementLock));
                    //The first element is less than the second
                    localMin = localCurnt;
                    localCurnt = localMin + (localMax - localMin) > 1;
                    continue;
                }
                OSAtomicCompareAndSwap32(ticket, 0, &(curntChunk[localCurnt] ->elementLock));
                localMax = localCurnt;
                localCurnt = localMin + ((localMax - localMin)>>1);
            }
        }
        
    }
    
    
};


#endif
