//
//  CGRGraph_API.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/15/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "CGRGraph_BasicTypes.h"

@protocol CGRGraph_API <NSObject>
#pragma mark -
#pragma mark Vertices Basics
//Adds a vertex
-(uint32_t)addVertex;
//Returns the neighbors for a vertex


//Adds an edge
-(_CGREdge) addEdge:(_CGREdge)edge;
//Removes a vertex
-(void)removeVertex:(uint32_t)vertex;
//Removes an Edge
-(void)removeEdge:(_CGREdge)edge;

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
