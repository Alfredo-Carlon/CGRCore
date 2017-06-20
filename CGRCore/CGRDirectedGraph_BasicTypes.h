//
//  CGRDirectedGraph_BasicTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/20/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//
// This file is part of CGRCore.

// CGRCore is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// CGRCore is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with CGRCore.  If not, see <http://www.gnu.org/licenses/>.

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
