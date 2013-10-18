//
//  CGRGraph_BasicTypes.m
//  CGRCore
//
//  Created by Alfredo Cruz on 10/15/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#import "CGRGraph_BasicTypes.h"


_CGREdge makeEdge(unsigned int p, unsigned int q)
{
    _CGREdge newEdge;
    newEdge.v0 = p;
    newEdge.v1 = q;
    return newEdge;
}
