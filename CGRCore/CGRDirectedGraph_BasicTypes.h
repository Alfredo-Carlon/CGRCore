//
//  CGRDirectedGraph_BasicTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/20/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

#import "CGRAVLTree.h"

struct _CGRDirectedEdge;

typedef struct CGRDirectedVertex
{
    uint32_t vertexIdent; //Identification for the vertex
    uint32_t *colors;
    uint32_t numberOfColors;
    CGRAVLTree<unsigned int, _CGRDirectedEdge> *inAdjacencyList; //The adjacency list for the vertex in neighbors
    CGRAVLTree<unsigned int, _CGRDirectedEdge> *outAdjacencyList; //The adjacency list for the vertex out neighbors
    CGRAVLTree<uint32_t, void > *extraInformation;
    CGRDirectedVertex()
    {
        vertexIdent = 0;
        colors = NULL;
        numberOfColors = 0;
        inAdjacencyList = NULL;
        outAdjacencyList = NULL;
        extraInformation = NULL;
    }
    CGRDirectedVertex(uint32_t ident){
        vertexIdent = ident;
        colors = NULL;
        numberOfColors = 0;
        inAdjacencyList = NULL;
        outAdjacencyList = NULL;
        extraInformation = NULL;
    }
} CGRDirectedVertex;


//Definition of an edge
typedef struct _CGRDirectedEdge
{
    //vertex1 is the source
    uint32_t vertex1, vertex2;
    uint32_t *colors;
    uint32_t numberOfColors;
    CGRAVLTree<uint32_t, void> *extraInformation;
    _CGRDirectedEdge(uint32 v1, uint32_t v2){
        vertex1 = v1;
        vertex2 = v2;
        colors = NULL;
        numberOfColors = 0;
        extraInformation = NULL;
    }
    ~_CGRDirectedEdge()
    {
        if(colors != NULL)
            delete colors;
        if(extraInformation != NULL)
            delete extraInformation;
    }
}_CGRDirectedEdge;
