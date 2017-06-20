//
//  CGRLinearStack.h
//  CGRCore
//
//  Created by Alfredo Cruz on 12/15/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
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


#ifndef CGRCore_CGRLinearStack_h
#define CGRCore_CGRLinearStack_h

#include <stdlib.h>

template <class DATA>
class CGRLinearStack {
private:
    DATA *linearStack;
    uint32_t stackSize;
    uint32_t stackIndex;
    uint32_t stackIncrement;
    
    void _increaseStack(){
        DATA *tmp = linearStack;
        linearStack = (DATA *)malloc(sizeof(DATA)*(stackSize + stackIncrement));
        memcpy(linearStack, tmp, sizeof(DATA)*(stackSize));
        free(tmp);
        stackSize += stackIncrement;
    }
public:
    CGRLinearStack()
    {
        linearStack = (DATA *)malloc(sizeof(DATA)*20);
        stackSize = 20;
        stackIndex = 0;
        stackIncrement = 10;
    }
    ~CGRLinearStack()
    {
        free(linearStack);
    }
    CGRLinearStack(uint32_t initSize)
    {
        linearStack = (DATA *)malloc(sizeof(DATA)*initSize);
        stackSize = initSize;
        stackIndex = 0;
        stackIncrement = 10;
    }
    CGRLinearStack(uint32_t initSize, uint32_t increment)
    {
        linearStack = (DATA *)malloc(sizeof(DATA)*initSize);
        stackSize = initSize;
        stackIndex = 0;
        stackIncrement = increment;
    }
    
    void push(DATA item)
    {
        if (stackIndex != stackSize) {
            linearStack[stackIndex++] = item;
        }else{
            _increaseStack();
            linearStack[stackIndex++] = item;
        }
    }
    DATA pop()
    {
        stackIndex--;
        if(stackIndex == -1){
            throw -1;
        }
        return linearStack[stackIndex];
        
    }
    DATA top()
    {
        if(stackIndex == 0){
            throw -1;
        }
        return linearStack[stackIndex-1];
    }
    
    uint32_t count()
    {
        return stackIndex;
    }
    
    void reset()
    {
        stackIndex = 0;
    }
    
};

#endif
