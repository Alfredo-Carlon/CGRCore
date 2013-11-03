//
//  CGRVector.m
//  CGRCore
//
//  Created by Alfredo Cruz on 10/17/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#import "CGRVector.h"

@implementation CGRVector
{
    struct CGRVectorChunk *startChunk;
    uint32_t numberOfElements;
}

-(id)init
{
    if(![super init])
        return nil;
    
    startChunk = new struct CGRVectorChunk;
    numberOfElements = 0;
    return self;
}


-(void)addObject:(id)object
{
    //Find the last chunk and add it to the back
    
    
}

@end
