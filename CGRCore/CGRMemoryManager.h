//
//  CGRMemoryManager.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/5/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#ifndef __CGRCore__CGRMemoryManager__
#define __CGRCore__CGRMemoryManager__

//#include <iostream>
#include "CGRConcurrentSortedVector.h"

class CGRMemoryManager {

private:
    bool logActions;
    struct memoryChunk
    {
        void *address;
        size_t size;
    };
    uint64_t userMemory;
    uint64_t verticesMemory;
    uint64_t edgesMemory;
    uint64_t houseKeepingMemory;
    
    //CGRConcurrentSortedVector<struct memoryChunk> *logChunkList;
public:
    CGRMemoryManager();
    CGRMemoryManager(bool log);
    
    void *allocUserMemory(size_t memorySize);
    void *allocVerticesMemory(size_t memorySize);
    void *allocEdgesMemory(size_t memorySize);
    void *allocHousekeepingMemory(size_t memorySize);
    
    uint64_t getUserMemory();
    uint64_t getVerticesMemory();
    uint64_t getEdgesMemory();
    uint64_t getHouseKeepingMemory();
    
    void deallocUserMemory(void *address);
    void deallocVerticesMemory(void *address);
    void deallocEdgesMemory(void *address);
    void deallocHousekeepingMemory(void *address);
    
    ~CGRMemoryManager();
};



#endif /* defined(__CGRCore__CGRMemoryManager__) */
