//
//  CGRConcurrentStaticVector.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/7/13.
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

#ifndef CGRCore_CGRConcurrentStaticVector_h
#define CGRCore_CGRConcurrentStaticVector_h
#define DEFAULT_CHUNK_SIZE 64
#define DEFAULT_MIDDLE_LAYER_SIZE 128
#define DEFAULT_CHUNK_LIST_SIZE 123
#include "CGRMemoryManager.h"

template <class VECTOR_DATA>
class CGRConcurrentVector
{
private:
    uint32_t chunkListSize;
    VECTOR_DATA ***chunkList;
    
    
    
    
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
        
    }
    
public:
    CGRConcurrentStaticVector(){
        
        return;
    }
    
    CGRConcurrentStaticVector(uint32_t vectorSize){
        
    }
    
    ~CGRConcurrentStaticVector()
    {
        
    }
    
    void addAtIndex(VECTOR_DATA *data,uint32_t index)
    {
        //First register as local thread
        startLocal();
        
    }
    
    VECTOR_DATA *dataAtIndex(uint32_t index){
        //First register as local thread
        startLocal();
        //Get the chunk number for the data
        uint32_t holdingChunk = index/chunkSize;
        
        NSException *outOfBoundsException = [NSException exceptionWithName:@"CGRIndexOutOfBoundsException" reason:@"The argument index for dataAtIndex is out of bounds" userInfo:nil];
        @throw outOfBoundsException;
        
        return NULL;
        
    }
    
};


#endif
