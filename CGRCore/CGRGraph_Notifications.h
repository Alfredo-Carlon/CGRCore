//
//  CGRGraph_Notification.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/11/15.
//  Copyright © 2015 Alfredo Cruz. All rights reserved.
//


@protocol CGRGraph_Notifications <NSObject>
@optional
#pragma mark Vertices Notifications
//Notifies the receiver when a new vertex is added with ident vertexId;
-(void)vertexAdded:(uint32_t)vertexId;
//Notifies the receiver when a vertex with ident vertexId was removed
-(void)vertexRemoved:(uint32_t)vertexId;
#pragma mark -
#pragma mark Edge Notifications
//Notifies the receiver when a new edge was added, newEdge
-(void)edgeAdded:(CGREdge)newEdge;
//Notifies the receiver when an edge was removed
-(void)edgeRemoved:(CGREdge)oldEdge;
#pragma mark -
#pragma mark Data Notifications
//Notifies the receiver that an edge was marked with new data
-(void)newDataAddedToEdge:(CGREdge)edge dataIdent:(uint32_t)dataId;
//Notifies the receiver that an edge was unmarked with data
-(void)deletedDataForEdge:(CGREdge)edge dataIdent:(uint32_t)dataId;

//Notifies the receiver that a vertex was marked with new data
-(void)newDataAddedToVertex:(uint32_t)vertex dataIdent:(uint32_t)dataId;
//Notifies the receiver that a vertex was unmarked with data
-(void)deletedDataForVertex:(uint32_t)vertex dataIdent:(uint32_t)dataId;

@end