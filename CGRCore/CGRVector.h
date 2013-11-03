//
//  CGRVector.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/17/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#define CHUNK_SIZE 10


@interface CGRVector : NSObject


struct CGRVectorHolder
{
    struct CGRVectorHolder *up, *down;
    void *data;
};

struct CGRVectorChunk
{
    struct CGRVectorHolder chunk[CHUNK_SIZE];
    uint32_t endIndex; //End index of the chunk
    struct CGRVectorChunk *next,*prev;
    CGRVectorChunk()
    {
        next = NULL;
        prev = NULL;
        endIndex = 0;
    }
};


-(void)addObject:(id)object;
@end
