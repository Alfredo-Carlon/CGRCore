//
//  CGRCommonTypes.cpp
//  CGRCore
//
//  Created by Alfredo Cruz on 11/7/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#include "CGRCommonTypes.h"


CGREdge makeEdge(unsigned int p, unsigned int q)
{
    CGREdge newEdge;
    newEdge.vertex1 = p;
    newEdge.vertex2 = q;
    return newEdge;
}

int edgeComparison(unsigned int *i, unsigned int *j){
    if(*i < *j)
        return -1;
    if(*i > *j)
        return 1;
    return 0;
}

