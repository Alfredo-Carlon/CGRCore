//
//  CGRExplorationGraph_BasicTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/7/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//



typedef struct CGRExplorationVertex
{
    volatile uint32_t vertexIdent; //Identification for the vertex
    volatile uint32_t vertexDegree;
} CGRExplorationVertex;


//Definition of an edge
typedef struct _CGRExplorationEdge
{
    volatile uint32_t vertex1,vertex2;
    
}_CGRExplorationEdge;


