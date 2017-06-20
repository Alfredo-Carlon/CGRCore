//
//  CGRGeometricGraph_Constrains.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/9/15.
//  Copyright © 2015 Alfredo Cruz. All rights reserved.
//

#import <CGRCore/CGRCommonTypes.h>

@class CGRGeometricGraph;
@protocol CGRGeometricGraph_Constrains <NSObject>
@optional
#pragma mark Configuration
-(void)setUp:(CGRGeometricGraph *)graph;

#pragma mark -
#pragma mark Vertices Constrains
-(BOOL)canAddVertex:(NSPoint)location;
-(BOOL)canRemoveVertex:(uint32_t)vertexId;
-(BOOL)canMoveVertex:(uint32_t)vertexId to:(NSPoint)newLocation;
-(BOOL)canAddData:(void *)data withId:(uint32_t)dataId toVertex:(uint32_t)vertexId;
-(BOOL)canRemoveDataWithKey:(uint32_t)key forVertex:(uint32_t)vertexId;
#pragma mark -
#pragma mark Edges Constrains
-(BOOL)canAddEdge:(CGREdge)edge;
-(BOOL)canRemoveEdge:(CGREdge)edge;
-(BOOL)canAddData:(void *)data withId:(uint32_t)dataId toEdge:(CGREdge)edge;
-(BOOL)canRemoveDataWithKey:(uint32_t)key forEdge:(uint32_t)vertexId;
@end
