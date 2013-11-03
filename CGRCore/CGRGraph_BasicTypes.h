//
//  CGRGraph_BasicTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/15/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

//#import "CGRConcurrentSortedVector.h"
#import "CGRConcurrentBST.h"
//#import <Foundation/Foundation.h>

struct CGREdge;

typedef struct CGRVertex
{
    uint32_t vertexIdent; //Identification for the vertex
    int32_t vertexLock;
    bool validVertex;
    unsigned int color,mark; //A couple of markers for the vertex
    //NSMutableDictionary *vetexInfo; //A pointer for extra data
    int32_t ticketDispenser;
    CGRConcurrentBST<CGREdge> *vertexAdjacencyList; //The adjacency list for the vertex
} CGRVertex;


//Definition of an edge
typedef struct CGREdge
{
    CGRVertex *vertex1,*vertex2;
    unsigned int color,mark; //A couple of markers for the vertex
    id edgeInfo; //Pointer for extra information
}CGREdge;

typedef struct _CGREdge
{
    unsigned int v0;
    unsigned int v1;
}_CGREdge;

_CGREdge makeEdge(unsigned int p, unsigned int q);

