//
//  CGRGeometricGraph_API.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/19/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CGRCore/CGRGeometricCommon.h>
#import <CGRCore/CGRGeometricGraph_Notifications.h>
#import <CGRCore/CGRGeometricGraph_Constrains.h>
@protocol CGRGeometricGraph_API <NSObject>


#pragma mark Vertices operations
-(uint32_t) addVertex:(NSPoint)coordinates;
-(NSPoint)coordinatesForVertex:(uint32_t)vertex;
-(void)setCoordinatesForVertex:(uint32_t)vertex coordinates:(NSPoint)cords;
#pragma mark -

#pragma mark Vertices operations (polar)
//The center of the polar plane
-(void) setPolarCenter:(NSPoint)center;
//The direction of the polar plane
-(void) setPolarDirection:(NSPoint)base;
//Add a new vertex 'with' polar coordinates
-(uint32_t) addVertexPolar:(double)radius angle:(double)angle;
//Returns the polar coordinates of the vertex
-(struct polarCoord)polarCoordinatesForVertex:(uint32_t)vertex;
//Sets the coordinates of the vertex
-(void)setCoordinatesForVertexPolar:(uint32_t)vertex coordinates:(struct polarCoord)cords;

#pragma mark -

#pragma mark Basic Operations and Queries

-(enum CGRTurn) segmentFrom:(unsigned int)v0 turnsLeftRightOn:(unsigned int)v1 to:(unsigned int)v2;
-(enum CGRTurn) segmentFrom:(unsigned int)v0 turnsLeftRightOnPoint:(NSPoint)p1 to:(unsigned int)v2;
-(enum CGRTurn) segmentFromPoint:(NSPoint)p0 turnsLeftRightOn:(NSPoint)p1 to:(NSPoint)p2;
-(BOOL)segmentFrom:(unsigned int)v0 to:(unsigned int)v1 intersectsSegmentFrom:(unsigned int)v2 to:(unsigned int)v3;
-(BOOL)segmentFromPoint:(NSPoint)p0 to:(NSPoint)p1 intersectsSegmentFrom:(NSPoint)p2 to:(NSPoint)p3;
-(BOOL)segmentFromPoint:(NSPoint)p0 to:(NSPoint)p1 intersectsEdge:(CGREdge)edge;
-(BOOL)edge:(CGREdge)edge1 intersectsEdge:(CGREdge)edge2;
-(NSPoint)intersectionPointOfSegmentFromPoint:(NSPoint)p0 to:(NSPoint)p1 andSegmentFrom:(NSPoint)p2 to:(NSPoint)p3;
-(NSPoint)intersectionPointOfSegmentFromPoint:(NSPoint)p0 to:(NSPoint)p1 withEdge:(CGREdge)edge;
-(NSPoint)intersectionPointOfEdge:(CGREdge)edge1 withEdge:(CGREdge)edge2;


-(double)angleBetweenVertex:(uint32_t)v1 andVertex2:(uint32_t)v2 withReference:(uint32_t)ref;
-(double)angleBetweenVertex:(uint32_t)v1 andVertex2:(uint32_t)v2 withReferencePoint:(NSPoint)ref;

-(double)distanceFromPoint:(NSPoint)p1 toVertex:(uint32_t)v1;
-(double)distanceFromPoint:(NSPoint)p1 to:(NSPoint)p2;
-(double)lengthOfEdge:(CGREdge)edge;
#pragma mark -
#pragma mark Sorting
//Sorts the vertices of the graph using the function compare. The variable context is passed to compare.
//-(void)sortVerticesUsingFunction:(int (*)(uint32_t, uint32_t, void *))compare withContext:(void *)context;
//Returns the order of the vertices usign compare. The variable context is passed to compare
//-(CGRCircularVector<uint32_t> *)sortedVerticesUsingFunction:(int (*)(uint32_t, uint32_t, void *))compare withContext:(void *)context;
#pragma mark -
#pragma mark Constrains
-(void)addConstrain:(id <CGRGeometricGraph_Constrains>)newConstrain;
-(void)removeConstrain:(id <CGRGeometricGraph_Constrains>)constrain;
#pragma mark -
#pragma mark Notifications
-(void)addGeometricNotifiy:(id <CGRGeometricGraph_Notifications>) newNotifyObj;
-(void)removeGeometricNotify:(id <CGRGeometricGraph_Notifications>) newNotifyObj;
#pragma mark -
@end
