//
//  CGRMemoryManager.cpp
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



#include "CGRMemoryManager.h"
#include <libkern/OSAtomic.h>

CGRMemoryManager::CGRMemoryManager()
{
    logActions = false;
    userMemory = 0;
    verticesMemory = 0;
    edgesMemory = 0;
    houseKeepingMemory = 0;
    
}


CGRMemoryManager::CGRMemoryManager(bool log)
{
    logActions = log;
    userMemory = 0;
    verticesMemory = 0;
    edgesMemory = 0;
    houseKeepingMemory = 0;
    
}

void *genericAlloc(size_t memorySize, volatile int64_t *memoryAccount)
{
    void *memoryChunk = malloc(memorySize);
    if(memoryChunk == NULL){
        return NULL;
    }
    int64_t amount = memorySize;
    OSAtomicAdd64(amount, (volatile int64_t *)&memoryAccount);
    return memoryChunk;
}


void * CGRMemoryManager::allocUserMemory(size_t memorySize)
{
    void *memoryChunk = genericAlloc(memorySize, (volatile int64_t *)&userMemory);
    if(memoryChunk == NULL){
        //We couldn't alloc the chunk so we throw an exception
        NSException *outOfMemoryException = [NSException exceptionWithName:@"CGRMemoryManagerMemoryNotAllocated" reason:[NSString stringWithFormat:@"Couldn't allocate USER memory of size %ld",memorySize] userInfo:nil];
        @throw outOfMemoryException;
    }
    return  memoryChunk;
}


void *CGRMemoryManager::allocVerticesMemory(size_t memorySize)
{
    void *memoryChunk = genericAlloc(memorySize, (volatile int64_t *)&verticesMemory);
    if(memoryChunk == NULL){
        //We couldn't alloc the chunk so we throw an exception
        NSException *outOfMemoryException = [NSException exceptionWithName:@"CGRMemoryManagerMemoryNotAllocated" reason:[NSString stringWithFormat:@"Couldn't allocate VERTICES memory of size %ld",memorySize] userInfo:nil];
        @throw outOfMemoryException;
    }
    return  memoryChunk;
}

void *CGRMemoryManager::allocEdgesMemory(size_t memorySize)
{
    void *memoryChunk = genericAlloc(memorySize, (volatile int64_t *)&edgesMemory);
    if(memoryChunk == NULL){
        //We couldn't alloc the chunk so we throw an exception
        NSException *outOfMemoryException = [NSException exceptionWithName:@"CGRMemoryManagerMemoryNotAllocated" reason:[NSString stringWithFormat:@"Couldn't allocate EDGES memory of size %ld",memorySize] userInfo:nil];
        @throw outOfMemoryException;
    }
    return  memoryChunk;
}

void *CGRMemoryManager::allocHousekeepingMemory(size_t memorySize)
{
    void *memoryChunk = genericAlloc(memorySize, (volatile int64_t *)&houseKeepingMemory);
    if(memoryChunk == NULL){
        //We couldn't alloc the chunk so we throw an exception
        NSException *outOfMemoryException = [NSException exceptionWithName:@"CGRMemoryManagerMemoryNotAllocated" reason:[NSString stringWithFormat:@"Couldn't allocate HOUSE KEEPING memory of size %ld",memorySize] userInfo:nil];
        @throw outOfMemoryException;
    }
    return  memoryChunk;
}


uint64_t CGRMemoryManager::getUserMemory()
{
    return OSAtomicAdd64(0,(volatile int64_t *)&userMemory);
}
uint64_t CGRMemoryManager::getVerticesMemory()
{
    return OSAtomicAdd64(0,(volatile int64_t *)&verticesMemory);
}
uint64_t CGRMemoryManager::getEdgesMemory()
{
    return OSAtomicAdd64(0,(volatile int64_t *)&edgesMemory);
}
uint64_t CGRMemoryManager::getHouseKeepingMemory()
{
    return OSAtomicAdd64(0,(volatile int64_t *)&houseKeepingMemory);
}

void CGRMemoryManager::deallocUserMemory(void *address)
{
    //For now just free
    free(address);
}
void CGRMemoryManager::deallocVerticesMemory(void *address)
{
    //For now just free
    free(address);
}
void CGRMemoryManager::deallocEdgesMemory(void *address)
{
    //For now just free
    free(address);
}
void CGRMemoryManager::deallocHousekeepingMemory(void *address)
{
    //For now just free
    free(address);
}

