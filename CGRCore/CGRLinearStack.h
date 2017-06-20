//
//  CGRLinearStack.h
//  CGRCore
//
//  Created by Alfredo Cruz on 12/15/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

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
