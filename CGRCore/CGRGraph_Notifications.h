//
//  CGRGraph_Notification.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/11/15.
//  Copyright © 2015 Alfredo Cruz. All rights reserved.
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