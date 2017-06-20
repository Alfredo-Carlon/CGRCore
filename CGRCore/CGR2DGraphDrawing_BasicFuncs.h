//
//  CGR2DGraphDrawing_BasicFuncs.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/23/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CGRCore/CGR2DGraphDrawing_BasicTypes.h>

int sortByXVertices(const void *p1, const void *p2);

int sortByYVertices(const void *p1, const void *p2);

int positionForXLeft(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double x);

int positionForXRight(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double x);

int positionForYLeft(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double y);

int positionForYRight(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double y);

void initDrawingVertex(struct CGRGeoGraphDrawingVertex *vertex, uint32_t ident, NSPoint location);

void updateDrawingVertex(struct CGRGeoGraphDrawingVertex *vertex, uint32_t ident, NSPoint location);

NSComparisonResult ggd_vertices_cord(double *i, double *j);

int _compareByIndet(struct CGRGeoGraphDrawingVertex *vertex1, struct CGRGeoGraphDrawingVertex *vertex2);
