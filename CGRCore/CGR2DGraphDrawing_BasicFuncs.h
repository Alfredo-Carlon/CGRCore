//
//  CGR2DGraphDrawing_BasicFuncs.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/23/14.
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
