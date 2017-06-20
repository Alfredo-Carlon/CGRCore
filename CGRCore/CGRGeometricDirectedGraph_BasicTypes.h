//
//  CGRGeometricDirectedGraph_BasicTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/22/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

#import "CGRAVLTree.h"

struct _CGRGeometricDirectedEdge;

typedef struct CGRGeometricDirectedVertex
{
    uint32_t vertexIdent; //Identification for the vertex
    NSPoint coordinates;
    int32_t vertexDegree;
    CGRAVLTree<uint32_t, _CGRGeometricDirectedEdge > *inAdjacencyList;
    CGRAVLTree<uint32_t, _CGRGeometricDirectedEdge > *outAdjacencyList;
    uint32_t *colors;
    uint32_t numberOfColors;
    CGRAVLTree<uint32_t, void> *extraInformation;
    
    CGRGeometricDirectedVertex(NSPoint coord)
    {
        vertexIdent = -1;
        coordinates = coord;
        vertexDegree = 0;
        inAdjacencyList = NULL;
        outAdjacencyList = NULL;
        colors = NULL;
        numberOfColors = 0;
        extraInformation = NULL;
    }
    
    
} CGRGeometricDirectedVertex;


//Definition of an edge
typedef struct _CGRGeometricDirectedEdge
{
    uint32_t vertex1,vertex2;
    uint32_t *colors;
    uint32_t numberOfColors;
    CGRAVLTree<uint32_t, void> *extraInformation;
    _CGRGeometricDirectedEdge(uint32_t v1, uint32_t v2){
        vertex1 = v1;
        vertex2 = v2;
        colors = NULL;
        numberOfColors = 0;
        extraInformation = NULL;
    }
    ~_CGRGeometricDirectedEdge()
    {
        if(colors != NULL)
            delete colors;
        if(extraInformation != NULL)
            delete extraInformation;
    }
}_CGRGeometricDirectedEdge;
