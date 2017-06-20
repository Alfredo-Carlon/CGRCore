//
//  CGRSimplePolygonDrawer.h
//  CGRCore
//
//  Created by Alfredo Cruz on 3/3/15.
//  Copyright (c) 2015 Alfredo Cruz. All rights reserved.
//

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
