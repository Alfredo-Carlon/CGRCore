//
//  CGRSimplePolygonDrawer.h
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
#import "CGR2DGraphDrawing_BasicFuncs.h"
#import "CGRDrawableGraph_API.h"


@class CGRSimplePolygon;
@interface CGRSimplePolygonDrawer : NSObject <CGRDrawable_API>
{
    NSRect screenRectangle;
    NSRect graphRectangle;
    CGRSimplePolygon *associatedPolygon;
    
    bool dirtyScreenRectangle;
    
    
    //CGRAVLTree<double, struct CGRGeoGraphDrawingVertex> verticesByX;
    
    
    
    ////////////////////First test version....
    struct CGRGeoGraphDrawBasicVertex *verticesByX;
    struct CGRGeoGraphDrawBasicVertex *verticesByY;
    uint32_t verticesByYCapacity;
    uint32_t lastVerticesByYVertex;
    
    struct CGRGeoGraphDrawingVertex *drawingVertices;
    uint32_t drawingVerticesCapacity;
    uint32_t lastDrawingVertex;
    
    double radius;
    //////////////////// End: First test version....
    
    
    
    
    ////////////// Color pickers
    struct CGRGeoGraphDrawingColor (*vertexColorPick4f)(uint32_t,id,id);
    id vertexColorPickArg4f;
    struct CGRGeoGraphDrawingColor (*edgeColorPick4f)(CGREdge,id,id);
    id edgeColorPickArg4f;
    
    struct CGRGeoGraphDrawingColor (*vertexColorPick3f)(uint32_t,id,id);
    id vertexColorPickArg3f;
    struct CGRGeoGraphDrawingColor (*edgeColorPick3f)(CGREdge,id,id);
    id edgeColorPickArg3f;
    ////////////// End: Color pickers
    
    ///////////// Vertices and Edges selector
    
    BOOL (*edgeSelector)(CGREdge, id, id);
    id edgeSelectorArg;
    BOOL (*vertexSelector)(uint32_t, id, id);
    id vertexSelectorArg;
    
    ///////////// End: Vertices and Edges selector
}

@property (readonly) NSRect graphRectangle;
@property (readonly) NSRect screenRectangle;

-(void) setUpPolygon: (CGRSimplePolygon *)polygon andPolygonRectangle:(NSRect)gr;



@end
