//
//  CGRGraph_API.h
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

#import <CGRCore/CGRCommonTypes.h>
#import <CGRCore/CGRVector.h>
#import <CGRCore/CGRCircularVector.h>
#import <CGRCore/CGRGraph_Notifications.h>

@protocol CGRGraph_API <NSObject>

#pragma mark Graph Creation
-(id)init;
-(id)initWithVerticesCapacity:(uint32_t)verticesInitialCapacity;

#pragma mark -
#pragma mark Vertices Basics
//Adds a vertex
-(uint32_t)addVertex;
//Returns the number of vertices in the graph
-(uint32_t)vertexSetSize;
//Returns the neighbors for a vertex
-(CGRCircularVector<uint32_t> *)neighborsForVertex:(uint32_t)vertex;
//Returns the degree for the given vertex
-(uint32_t)vertexDegree:(uint32_t)vertex;
//Returns true if both vertices are neighbors, false otherwise
-(BOOL) vertex:(uint32_t)vertex1 isNeighborOf:(uint32_t)vertex2;
//Removes a vertex
-(void)removeVertex:(uint32_t)vertex;
//Removes all neighbors of a vertex
-(void)removeAllVertexNeighbors:(uint32_t)vertex;
//Removes all vertices
-(void)removeAllVertices;
#pragma mark -
#pragma mark Edges Basics

//Adds an edge
-(void) addEdge:(CGREdge)edge;
//Removes an Edge
-(void)removeEdge:(CGREdge)edge;
#pragma mark -

#pragma mark Edges Custom Data
-(void)addCustomData:(void *)data toEdge:(CGREdge)edge withNumber:(uint32_t)number;
-(void *)customDataForEdge:(CGREdge)edge withNumber:(uint32_t)number;
-(void *)removeCustomDataForEdge:(CGREdge)edge withNumber:(uint32_t)number;
#pragma mark -

#pragma mark Vertices Custom Data
-(void)addCustomData:(void *)data toVertex:(uint32_t)vertex withNumber:(uint32_t)number;
-(void *)customDataForVertex:(uint32_t)vertex withNumber:(uint32_t)number;
-(void *)removeCustomDataForVertex:(uint32_t)vertex withNumber:(uint32_t)number;
#pragma mark -

#pragma mark Notifications
-(void)addNotifiy:(id <CGRGraph_Notifications>) newNotifyObj;
-(void)removeNotify:(id <CGRGraph_Notifications>) newNotifyObj;
#pragma mark -
/*
#pragma mark -
#pragma mark Vertices Advanced
//Returns the mark for the vertex and locks it to the thread..
//and remains locked until it is released by releaseVertex or by setMark:ForVertexWithLock
-(CGRMarkColor)markForVertexWithLock:(uint32_t)vertex;
//Sets the mark for the vertex only if the calling thread holds the lock for vertex. After compleating
//the vertex's lock is released
-(void)setMark:(unsigned int)mark forVertexWithLock:(uint32_t)vertex;

//Releases the vertex holded by the calling thread..
-(void)releaseVertex:(uint32_t)vertex;
 */
@end
