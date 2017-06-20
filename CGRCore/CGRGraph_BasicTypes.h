//
//  CGRGraph_BasicTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/15/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#import "CGRAVLTree.h"

struct _CGREdge;

typedef struct CGRVertex
{
    uint32_t vertexIdent; //Identification for the vertex
    uint32_t *colors;
    uint32_t numberOfColors;
    CGRAVLTree<unsigned int, _CGREdge> *vertexAdjacencyList; //The adjacency list for the vertex
    CGRAVLTree<uint32_t, void> *extraInformation;
    CGRVertex()
    {
        vertexIdent = 0;
        colors = NULL;
        numberOfColors = 0;
        vertexAdjacencyList = NULL;
        extraInformation = NULL;
    }
    CGRVertex(uint32_t ident){
        vertexIdent = ident;
        colors = NULL;
        numberOfColors = 0;
        vertexAdjacencyList = NULL;
        extraInformation = NULL;
    }
} CGRVertex;


//Definition of an edge
typedef struct _CGREdge
{
    uint32_t vertex1, vertex2;
    uint32_t *colors;
    uint32_t numberOfColors;
    CGRAVLTree<uint32_t, void> *extraInformation;
    _CGREdge(uint32 v1, uint32_t v2){
        vertex1 = v1;
        vertex2 = v2;
        colors = NULL;
        numberOfColors = 0;
        extraInformation = NULL;
    }
    ~_CGREdge()
    {
        if(colors != NULL)
            delete colors;
        if(extraInformation != NULL)
            delete extraInformation;
    }
}_CGREdge;


