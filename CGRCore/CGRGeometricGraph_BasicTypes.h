//
//  CGRGeometricGraph_BasicTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/12/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#import "CGRAVLTree.h"

struct _CGRGeometricEdge;

typedef struct CGRGeometricVertex
{
    uint32_t vertexIdent; //Identification for the vertex
    NSPoint coordinates;
    int32_t vertexDegree;
    CGRAVLTree<uint32_t, _CGRGeometricEdge > *adjacencyList;
    uint32_t *colors;
    uint32_t numberOfColors;
    CGRAVLTree<uint32_t, void> *extraInformation;
    
    CGRGeometricVertex(NSPoint coord) : adjacencyList(NULL), colors(NULL),extraInformation(NULL)
    {
        vertexIdent = -1;
        coordinates = coord;
        vertexDegree = 0;
        //adjacencyList = NULL;
        //colors = NULL;
        //extraInformation = NULL;
        numberOfColors = 0;
    }
    
    
} CGRGeometricVertex;


//Definition of an edge
typedef struct _CGRGeometricEdge
{
    uint32_t vertex1,vertex2;
    uint32_t *colors;
    uint32_t numberOfColors;
    CGRAVLTree<uint32_t, void> *extraInformation;
    _CGRGeometricEdge(uint32_t v1, uint32_t v2){
        vertex1 = v1;
        vertex2 = v2;
        colors = NULL;
        numberOfColors = 0;
        extraInformation = NULL;
    }
    ~_CGRGeometricEdge()
    {
        if(colors != NULL)
            delete colors;
        if(extraInformation != NULL)
            delete extraInformation;
    }
}_CGRGeometricEdge;
