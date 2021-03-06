//
//  CGRSimplePolygon.h
//  CGRCore
//
//  Created by Alfredo Cruz on 3/3/15.
//  Copyright (c) 2015 Alfredo Cruz. All rights reserved.
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
#import "CGRPolygonCommon.h"
#import "CGRCircularVector.h"

@interface CGRSimplePolygon : NSObject
{
    CGRCircularVector<CGRPolygonVertex *> *vertices;
}
//Creates an empty simple polygon
-(id)init;
//Creates a simple polygon with verticesList as its vertices
-(id)initWithVertices:(CGRCircularVector<NSPoint> *)verticesList;

//Add, insert and deletion of vertices
//Adds a vertex at the end of the vertices list
-(void)addVertex:(NSPoint)coordinates;
//Inserts a vertex at the index
-(void)insertVertex:(NSPoint)coordinates atIndex:(uint32_t) index;
//Removes a vertex at index
-(void)removeVertex:(uint32_t)index;
//Returns the number of vertices in the polygon
-(uint32_t)vertexSetSize;
//Returns the coordinates of the query vertex
-(NSPoint)coordinatesForVertex:(uint32_t)vertex;
//Returns the neighbors of the vertex
-(CGRCircularVector<uint32_t> *)neighborsForVertex:(uint32_t)vertex;

//Vertices information
//Adds custom data to the vertex at index, the data key is number
-(void)addCustomData:(void *)data toVertex:(uint32_t)index withNumber:(uint32_t)number;
//Returns the custom data for the vertex at index with key number
-(void *)customDataForVertex:(uint32_t)index withNumber:(uint32_t)number;
//Removes the custom data fro the vertex at index with key number
-(void *)removeCustomDataForVertex:(uint32_t)index withNumber:(uint32_t)number;

//Vertices list
-(CGRCircularVector<NSPoint> *)verticesList;

#pragma mark used in 'buffer' mode
-(void)adjustVertexSetSizeToSize:(uint32_t)newSize;
-(void)setCoordinatesForVertex:(uint32_t)vertex coordinates:(NSPoint)coordinates;
@end
