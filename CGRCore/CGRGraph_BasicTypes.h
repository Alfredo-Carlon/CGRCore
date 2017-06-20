//
//  CGRGraph_BasicTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/15/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
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


