//
//  CGRSimplePolygon.m
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

#import "CGRSimplePolygon.h"
#import "CGRCommonTypes.h"

@implementation CGRSimplePolygon
//Creates an empty simple polygon
-(id)init
{
    if(![super init])
        return nil;
    vertices = new CGRCircularVector<CGRPolygonVertex *>();
    return self;
}
//Creates a simple polygon with verticesList as its vertices
-(id)initWithVertices:(CGRCircularVector<NSPoint> *)verticesList
{
    if(![super init])
        return nil;
    vertices = new CGRCircularVector<CGRPolygonVertex *>(verticesList ->count());
    uint32_t size = verticesList ->count();
    for(uint32_t i=0; i != size; i++){
        CGRPolygonVertex *newVertex = new CGRPolygonVertex(verticesList ->elementAtIndex(i));
        newVertex ->vertexIdent = i;
        vertices ->add(newVertex);
    }
    return self;
}
-(void)dealloc
{
    uint32_t size = vertices ->count();
    for(uint32_t i=0; i != size; i++){
        CGRPolygonVertex *vertex = vertices ->elementAtIndex(i);
        delete vertex;
    }
    delete vertices;
}
//Add, insert and deletion of vertices
//Adds a vertex at the end of the vertices list
-(void)addVertex:(NSPoint)coordinates
{
    CGRPolygonVertex *newVertex = new CGRPolygonVertex(coordinates);
    newVertex ->vertexIdent = vertices ->count();
    vertices ->add(newVertex);
}
//Inserts a vertex at the index
-(void)insertVertex:(NSPoint)coordinates atIndex:(uint32_t) index
{
    if(index > vertices ->count())
        return;
    CGRPolygonVertex *newVertex = new CGRPolygonVertex(coordinates);
    newVertex ->vertexIdent = index;
    vertices ->insertAtIndex(newVertex, index);
    uint32_t size = vertices ->count();
    for(uint32_t i=index+1; i < size; i++){
        vertices ->elementAtIndex(i) ->vertexIdent = i;
    }
}
//Removes a vertex at index
-(void)removeVertex:(uint32_t)index
{
    if(index >= vertices ->count())
        return;
    CGRPolygonVertex *vertex = vertices ->elementAtIndex(index);
    uint32_t size = vertices ->count();
    for (uint32_t i=index+1; i < size; i++) {
        vertices ->elementAtIndex(i) ->vertexIdent = i-1;
    }
    delete vertex;
}
-(uint32_t)vertexSetSize
{
    return vertices ->count();
}
-(NSPoint)coordinatesForVertex:(uint32_t)vertex
{
    if(vertex < vertices ->count())
        return vertices ->elementAtIndex(vertex)->coordinates;
    @throw [NSException exceptionWithName:@"No such vertex" reason:@"There is no vertex with such ident" userInfo:nil];
}
-(CGRCircularVector<uint32_t> *)neighborsForVertex:(uint32_t)vertex
{
    if(vertex < vertices ->count()){
        CGRCircularVector<uint32_t> *neighbors = new CGRCircularVector<uint32_t>(2);
        if (vertex == 0) {
            neighbors ->add(vertices ->count() - 1);
        }else{
            neighbors ->add(vertex - 1);
        }
        neighbors -> add((vertex + 1) % vertices ->count());
        return neighbors;
    }
    return NULL;
}
//Vertices information
//Adds custom data to the vertex at index, the data key is number
-(void)addCustomData:(void *)data toVertex:(uint32_t)index withNumber:(uint32_t)number
{
    if(index >= vertices ->count())
        return;
    CGRPolygonVertex *vertex = vertices ->elementAtIndex(index);
    if (vertex ->extraInformation) {
        if (vertex ->extraInformation ->containsKey(number)) {
            vertex ->extraInformation ->remove(number);
        }
        vertex ->extraInformation ->add(number, data);
    }else{
        vertex ->extraInformation = new CGRAVLTree<uint32_t, void>(edgeComparison);
    }
}
//Returns the custom data for the vertex at index with key number
-(void *)customDataForVertex:(uint32_t)index withNumber:(uint32_t)number
{
    if(index >= vertices ->count())
        return NULL;
    CGRPolygonVertex *vertex = vertices ->elementAtIndex(index);
    if (vertex ->extraInformation) {
        if (vertex ->extraInformation ->containsKey(number)) {
            return vertex ->extraInformation ->dataForKey(number);
        }
    }
    return NULL;
}
//Removes the custom data fro the vertex at index with key number
-(void *)removeCustomDataForVertex:(uint32_t)index withNumber:(uint32_t)number
{
    if(index >= vertices ->count())
        return NULL;
    CGRPolygonVertex *vertex = vertices ->elementAtIndex(index);
    if (vertex ->extraInformation) {
        void *data_ptr = vertex ->extraInformation ->remove(number);
        return data_ptr;
    }
    return NULL;
}

//Vertices list
-(CGRCircularVector<NSPoint> *)verticesList
{
    CGRCircularVector<NSPoint> *verticesList = new CGRCircularVector<NSPoint>(vertices ->count());
    uint32_t size = vertices ->count();
    for(uint32_t i=0; i != size; i++){
        CGRPolygonVertex *vertex = vertices ->elementAtIndex(i);
        verticesList ->add(vertex ->coordinates);
    }
    return verticesList;
}
#pragma mark used in 'buffer' mode
-(void)adjustVertexSetSizeToSize:(uint32_t)newSize
{
    uint32_t size = vertices ->count();
    for(uint32_t i=0; i != size; i++){
        CGRPolygonVertex *vertex = vertices ->elementAtIndex(i);
        delete vertex;
    }
    delete vertices;
    vertices = new CGRCircularVector<CGRPolygonVertex *>(newSize);
    for(uint32_t i=0; i != newSize; i++){
        CGRPolygonVertex *newVertex = new CGRPolygonVertex(NSMakePoint(0, 0));
        newVertex ->vertexIdent = i;
        vertices ->add(newVertex);
    }
}
-(void)setCoordinatesForVertex:(uint32_t)vertex coordinates:(NSPoint)coordinates
{
    if(!(vertex < vertices ->count()))
        return;
    vertices ->elementAtIndex(vertex)->coordinates = coordinates;
}
@end
