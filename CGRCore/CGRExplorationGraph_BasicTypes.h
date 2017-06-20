//
//  CGRExplorationGraph_BasicTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/7/13.
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


