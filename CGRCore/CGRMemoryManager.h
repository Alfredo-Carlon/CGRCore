//
//  CGRMemoryManager.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/5/13.
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
