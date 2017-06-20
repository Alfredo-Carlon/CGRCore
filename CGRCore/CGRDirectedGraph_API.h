//
//  CGRDirectedGraph_API.h
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

#import <Foundation/Foundation.h>
#import <CGRCore/CGRVector.h>
#import <CGRCore/CGRCircularVector.h>

@protocol CGRDirectedGraph_API <NSObject>

#pragma mark Basic Operations and Queries

-(CGRCircularVector<uint32_t> *)inNeighborsForVertex:(uint32_t)vertex;
-(CGRCircularVector<uint32_t> *)outNeighborsForVertex:(uint32_t)vertex;

-(uint32_t)inDegreeForVertex:(uint32_t)vertex;
-(uint32_t)outDegreeForVertex:(uint32_t)vertex;

-(BOOL) vertex:(uint32_t)vertex1 isInNeighborOf:(uint32_t)vertex2;
-(BOOL) vertex:(uint32_t)vertex1 isOutNeighborOf:(uint32_t)vertex2;

-(void)removeAllInNeighborsForVertex:(uint32_t)vertex;
-(void)removeAllOutNeighborsForVertex:(uint32_t)vertex;

#pragma mark -



@end