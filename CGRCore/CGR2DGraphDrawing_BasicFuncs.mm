//
//  CGR2DGraphDrawing_BasicFuncs.m
//  CGRCore
//
//  Created by Alfredo Cruz on 10/23/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

#import "CGR2DGraphDrawing_BasicFuncs.h"

////////////////////First test version....

int sortByXVertices(const void *p1, const void *p2)
{
    struct CGRGeoGraphDrawingVertex *v1,*v2;
    v1 = (struct CGRGeoGraphDrawingVertex *)p1;
    v2 = (struct CGRGeoGraphDrawingVertex *)p2;
    if(v1 ->location.x == v2 ->location.x){
        return v1 ->location.y - v2 ->location.y;
    }
    return v1 ->location.x - v2 ->location.x;
}


int sortByYVertices(const void *p1, const void *p2)
{
    struct CGRGeoGraphDrawingVertex *v1,*v2;
    v1 = (struct CGRGeoGraphDrawingVertex *)p1;
    v2 = (struct CGRGeoGraphDrawingVertex *)p2;
    if(v1 ->location.y == v2 ->location.y){
        return v1 ->location.x - v2 ->location.x;
    }
    return v1 ->location.y - v2 ->location.y;
}


int positionForXLeft(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double x)
{
    uint32_t base = 0;
    uint32_t limit = numberOfVertices;
    uint32_t curnt = numberOfVertices >> 1;
    
    while(base+1 != limit)
    {
        
        if(vertices[curnt].location.x < x){
            base = curnt;
            curnt = base + ((limit-base)>>1);
            continue;
        }
        limit = curnt;
        curnt = base + ((limit-base)>>1);
    }
    return base;
}

int positionForXRight(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double x)
{
    uint32_t base = 0;
    uint32_t limit = numberOfVertices;
    uint32_t curnt = numberOfVertices >> 1;
    
    while(base+1 != limit)
    {
        
        if(vertices[curnt].location.x > x){
            limit = curnt;
            curnt = base + ((limit-base)>>1);
            continue;
        }
        base = curnt;
        curnt = base + ((limit-base)>>1);
    }
    return base;
}

int positionForYLeft(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double y)
{
    uint32_t base = 0;
    uint32_t limit = numberOfVertices;
    uint32_t curnt = numberOfVertices >> 1;
    
    while(base+1 != limit)
    {
        
        if(vertices[curnt].location.y < y){
            base = curnt;
            curnt = base + ((limit-base)>>1);
            continue;
        }
        limit = curnt;
        curnt = base + ((limit-base)>>1);
    }
    return base;
}

int positionForYRight(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double y)
{
    uint32_t base = 0;
    uint32_t limit = numberOfVertices;
    uint32_t curnt = numberOfVertices >> 1;
    
    while(base+1 != limit)
    {
        
        if(vertices[curnt].location.y > y){
            limit = curnt;
            curnt = base + ((limit-base)>>1);
            continue;
        }
        base = curnt;
        curnt = base + ((limit-base)>>1);
    }
    return base;
}

void initDrawingVertex(struct CGRGeoGraphDrawingVertex *vertex, uint32_t ident, NSPoint location)
{
    vertex ->ident = ident;
    vertex ->location = location;
    vertex ->indices = NULL;
    vertex ->numberOfSides = 0;
    vertex ->renderPoints = NULL;
    vertex ->displayAttribs = 0;
}

void updateDrawingVertex(struct CGRGeoGraphDrawingVertex *vertex, uint32_t ident, NSPoint location)
{
    vertex ->ident = ident;
    vertex ->location = location;
}

NSComparisonResult ggd_vertices_cord(double *i, double *j)
{
    if(*i < *j)
        return NSOrderedAscending;
    if(*i > *j)
        return NSOrderedDescending;
    return NSOrderedSame;
}

int _compareByIndet(struct CGRGeoGraphDrawingVertex *vertex1, struct CGRGeoGraphDrawingVertex *vertex2)
{
    if (vertex1 ->ident < vertex2 ->ident)
        return -1;
    if(vertex1 ->ident > vertex2 ->ident)
        return 1;
    return 0;
}


//////////////////// END: First test version....