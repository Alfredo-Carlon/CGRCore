//
//  CGRGeometricDirGraphDrawing.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/23/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CGRCore/CGR2DGraphDrawing_BasicTypes.h>
#import <CGRCore/CGR2DGraphDrawing_BasicFuncs.h>
#import <CGRCore/CGRDrawableGraph_API.h>
#import <CGRCore/CGRAVLTree.h>
#import <CGRCore/CGRMapTree.h>

@class CGRGeometricDirectedGraph;
@interface CGRGeometricDirGraphDrawing : NSObject <CGRDrawable_API>
{
    NSRect screenRectangle;
    NSRect graphRectangle;
    CGRGeometricDirectedGraph *associatedGraph;
    
    bool dirtyScreenRectangle;
    
    
    //CGRAVLTree<double, struct CGRGeoGraphDrawingVertex> verticesByX;
    
    
    
    ////////////////////First test version....
    //struct CGRGeoGraphDrawBasicVertex *verticesByX;
    //struct CGRGeoGraphDrawBasicVertex *verticesByY;
    uint32_t verticesByYCapacity;
    uint32_t lastVerticesByYVertex;
    
    //struct CGRGeoGraphDrawingVertex *drawingVertices;
    uint32_t drawingVerticesCapacity;
    uint32_t lastDrawingVertex;
    
    double radius;
    
    CGRCircularVector<struct CGRGeoGraphDrawingVertex *> *drawVertices;
    
    //////////////////// End: First test version....
    
    
    
    ///////////////////Map tree test
    CGRMapTree *mapTree;
    ///////////////////End: Map tree test
    
    
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

-(void) setUpGraph: (CGRGeometricDirectedGraph *)graph andGraphRectangle:(NSRect)gr;
#pragma mark Map Tree
-(void) calculateMapTree:(uint32_t)rows columns:(uint32_t)columns andCapacity:(uint32_t)capacity;
-(void) drawMapTree:(NSRect)bounds;


@end
