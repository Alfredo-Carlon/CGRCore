//
//  CGR2DGraphDrawing_BasicTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/23/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

struct CGRGeoGraphDrawingVertex;
struct CGRGeoGraphDrawingEdge;

struct CGRGeoGraphDrawBasicVertex
{
    NSPoint location;
    uint32_t ident;
};


struct CGRGeoGraphDrawingVertex{
    NSPoint location;
    uint32_t ident;
    GLfloat *renderPoints;
    GLubyte *indices;
    uint8_t displayAttribs;
    short numberOfSides;
    short arraysCapacity;
};

struct CGRGeoGraphDrawingEdge {
    //Definition of the drawing
    //_CGRGeometricEdge *edge;
    uint32_t vertex1, vertex2;
    GLfloat color[4];
};

struct CGRGeoGraphDrawingColor
{
    GLfloat red;
    GLfloat green;
    GLfloat blue;
    GLfloat alpha;
};


