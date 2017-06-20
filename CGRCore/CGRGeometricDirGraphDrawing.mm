//
//  CGRGeometricDirGraphDrawing.m
//  CGRCore
//
//  Created by Alfredo Cruz on 10/23/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

#import "CGRGeometricDirGraphDrawing.h"
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLContext.h>
#import <stdlib.h>
#include <iostream>
#include <fstream>
#import "CGRGeometricDirectedGraph.h"
#import <CGRCore/CGRDirectedGraph.h>
#import <CGRCore/CGRDirectedGraph_API.h>
#import "CGRVector.h"


@implementation CGRGeometricDirGraphDrawing
@synthesize graphRectangle;
@synthesize screenRectangle;


-(void)drawWithScreenRect:(NSRect)screenRectangle andGeometricRect:(NSRect)graphRectangle
{
    /*glEnableClientState(GL_VERTEX_ARRAY);
     glVertexPointer(3, GL_FLOAT, 0, renderPoints);
     glColor4f(0, 0,0, 1.0);
     glDrawElements(GL_LINE_LOOP, numberOfSides, GL_UNSIGNED_BYTE, indices);
     
     glDrawElements(GL_TRIANGLE_FAN, numberOfSides, GL_UNSIGNED_BYTE, indices);
     glDisableClientState(GL_VERTEX_ARRAY);*/
    NSLog(@"Hello");
}

-(void)drawInrect:(NSRect) drawingRectangle
{
    
}



-(void)draw
{
    if(dirtyScreenRectangle)
    {
        //Update the drawing points..
        [self updateGraphDrawing];
        dirtyScreenRectangle = NO;
    }
    
    double screenYUnit = screenRectangle.size.height / graphRectangle.size.height;
    double screenXUnit = screenRectangle.size.width / graphRectangle.size.width;
    
    uint32_t numberOfVertices = drawVertices ->count();
    
    for(int i=0; i != numberOfVertices; i++){
        
        struct CGRGeoGraphDrawingVertex *vertex = drawVertices ->elementAtIndex(i);
        if(vertexSelector){
            if(!vertexSelector(vertex ->ident,associatedGraph,vertexSelectorArg))
                continue;
        }
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(3, GL_FLOAT, 0, vertex ->renderPoints);
        if(vertexColorPick4f){
            struct CGRGeoGraphDrawingColor vertColor = vertexColorPick4f(vertex -> ident,associatedGraph,vertexColorPickArg4f);
            glColor4f(vertColor.red, vertColor.green, vertColor.blue, vertColor.alpha);
        }else if(vertexColorPick3f){
            struct CGRGeoGraphDrawingColor vertColor = vertexColorPick3f(vertex -> ident,associatedGraph,vertexColorPickArg3f);
            glColor4f(vertColor.red, vertColor.green, vertColor.blue, 0.2);
        }else{
            glColor4f(0, 0,0, 0.2);
        }
        glDrawElements(GL_LINE_LOOP, vertex -> numberOfSides, GL_UNSIGNED_BYTE, vertex -> indices);
        
        glDrawElements(GL_TRIANGLE_FAN, vertex -> numberOfSides, GL_UNSIGNED_BYTE, vertex -> indices);
        glDisableClientState(GL_VERTEX_ARRAY);
        
        
        //Test for edge drawing...
        
        NSPoint vertexDrawingLoc = vertex -> location;
        //Translate the vertex cordinates to screen coordinates
        vertexDrawingLoc.x -= graphRectangle.origin.x;
        vertexDrawingLoc.y -= graphRectangle.origin.y;
        vertexDrawingLoc.x *= screenXUnit;
        vertexDrawingLoc.y *= screenYUnit;
        
        
        CGRCircularVector<uint32_t> *neighbors = [associatedGraph neighborsForVertex:vertex -> ident];
        uint32_t numberOfNeighbors = neighbors ->count();
        for(uint32_t j=0; j != numberOfNeighbors; j++){
            uint32_t neighbor = neighbors ->elementAtIndex(j);
            if(edgeSelector){
                if(!edgeSelector(makeEdge(vertex -> ident, neighbor),associatedGraph,edgeSelectorArg))
                    continue;
            }
            
            //if(neighbor > drawingVertices[i].ident)
            //    continue;
            
            NSPoint neighLocation = [associatedGraph coordinatesForVertex:neighbor];
            
            
            
            //Translate the coordinates to see if we are displaying it..
            neighLocation.x -= graphRectangle.origin.x;
            neighLocation.y -= graphRectangle.origin.y;
            neighLocation.x *= screenXUnit;
            neighLocation.y *= screenYUnit;
            if(neighLocation.x > 0 && neighLocation.x < screenRectangle.size.width &&
               neighLocation.y > 0 && neighLocation.y < screenRectangle.size.height){
                
                
                //Draw the edge
                GLfloat renderPoints[6];
                GLubyte indices[2];
                
                NSPoint minus;
                
                minus.x = neighLocation.x - vertexDrawingLoc.x;
                minus.y = neighLocation.y - vertexDrawingLoc.y;
                float norm = sqrt(minus.x*minus.x + minus.y*minus.y);
                float cosine = minus.x/norm;
                float sin = minus.y/norm;
                //x,y coordinates in the circle with center in the origin
                float x = (radius + 4) * cosine;
                float y = (radius +4) * sin;
                //Translation
                //edgePoint1.x = curnPoint1.x + x;
                //edgePoint1.y = curnPoint1.y + y;
                renderPoints[0] = (GLfloat) (vertexDrawingLoc.x + x);
                renderPoints[1] = (GLfloat) (vertexDrawingLoc.y + y);
                renderPoints[2] = 0.0;
                //Second point
                minus.x = -minus.x;
                minus.y = -minus.y;
                cosine = -cosine;
                sin = -sin;
                x = (radius + 4) * cosine;
                y = (radius + 4) * sin;
                //Translation
                //edgePoint2.x = curnPoint2.x + x;
                //edgePoint2.y = curnPoint2.y + y;
                renderPoints[3] = (GLfloat) (neighLocation.x + x);
                renderPoints[4] = (GLfloat) (neighLocation.y + y);
                renderPoints[5] = 0.0;
                
                indices[0] = 0;
                indices[1] = 1;
                
                GLfloat lineWitdh = 0;
                
                if(edgeColorPick4f){
                    struct CGRGeoGraphDrawingColor edgeColor = edgeColorPick4f(makeEdge(i, neighbor),associatedGraph,edgeColorPickArg4f);
                    glColor4f(edgeColor.red, edgeColor.green, edgeColor.blue, edgeColor.alpha);
                }else if(edgeColorPick3f){
                    struct CGRGeoGraphDrawingColor edgeColor = edgeColorPick3f(makeEdge(i, neighbor),associatedGraph,edgeColorPickArg3f);
                    glColor4f(edgeColor.red, edgeColor.green, edgeColor.blue, 0.5);
                }else{
                    glColor4f(0, 0, 0,0.5);
                }
                glGetFloatv(GL_LINE_WIDTH, &lineWitdh);
                glLineWidth(0.2);
                
                glEnableClientState(GL_VERTEX_ARRAY);
                glVertexPointer(3, GL_FLOAT, 0, renderPoints);
                
                glDrawElements(GL_LINES, 2, GL_UNSIGNED_BYTE, indices);
                glDisableClientState(GL_VERTEX_ARRAY);
                glLineWidth(lineWitdh);
                
                //Draw the arrow heads with norm 2 and angle of pi/4 from the edge.
                NSPoint perpVec1, perpVec2;
                
                minus.x = renderPoints[3] - renderPoints[0];
                minus.y = renderPoints[4] - renderPoints[1];
                
                perpVec1.x = -1*minus.y;
                perpVec1.y = minus.x;
                
                perpVec2.x = minus.y;
                perpVec2.y = -1*minus.x;
                
                //perpVec1.x *= norm; perpVec1.y *= norm;
                
                //perpVec2.x *= norm; perpVec2.y *= norm;
                
                perpVec1.x += renderPoints[0];
                perpVec1.y += renderPoints[1];
                
                perpVec2.x += renderPoints[0];
                perpVec2.y += renderPoints[1];
                
                NSPoint arrowDirVec1, arrowDirVec2;
                
                arrowDirVec1.x = perpVec1.x - renderPoints[3];
                arrowDirVec1.y = perpVec1.y - renderPoints[4];
                
                arrowDirVec2.x = perpVec2.x - renderPoints[3];
                arrowDirVec2.y = perpVec2.y - renderPoints[4];
                
                norm = sqrt(arrowDirVec1.x * arrowDirVec1.x + arrowDirVec1.y * arrowDirVec1.y);
                arrowDirVec1.x /= norm;
                arrowDirVec1.y /= norm;
                arrowDirVec1.x *= 6;
                arrowDirVec1.y *= 6;
                
                arrowDirVec2.x /= norm;
                arrowDirVec2.y /= norm;
                arrowDirVec2.x *= 6;
                arrowDirVec2.y *= 6;
                
                neighLocation.x = renderPoints[3];
                neighLocation.y = renderPoints[4];
                
                //Draw the arrow heads
                renderPoints[0] = neighLocation.x;
                renderPoints[1] = neighLocation.y;
                renderPoints[2] = 0;
                renderPoints[3] = arrowDirVec1.x + neighLocation.x;
                renderPoints[4] = arrowDirVec1.y + neighLocation.y;
                renderPoints[5] = 0;
                glColor4f(0, 0, 0,0.7);
                glGetFloatv(GL_LINE_WIDTH, &lineWitdh);
                glLineWidth(0.1);
                
                glEnableClientState(GL_VERTEX_ARRAY);
                glVertexPointer(3, GL_FLOAT, 0, renderPoints);
                glDrawElements(GL_LINES, 2, GL_UNSIGNED_BYTE, indices);
                
                glDisableClientState(GL_VERTEX_ARRAY);
                
                renderPoints[0] = neighLocation.x;
                renderPoints[1] = neighLocation.y;
                renderPoints[2] = 0;
                renderPoints[3] = arrowDirVec2.x + neighLocation.x;
                renderPoints[4] = arrowDirVec2.y + neighLocation.y;
                renderPoints[5] = 0;
                
                glEnableClientState(GL_VERTEX_ARRAY);
                glVertexPointer(3, GL_FLOAT, 0, renderPoints);
                glDrawElements(GL_LINES, 2, GL_UNSIGNED_BYTE, indices);
                
                glDisableClientState(GL_VERTEX_ARRAY);
                
                glLineWidth(lineWitdh);
                
                
            }
            
        }
        delete neighbors;
    }
    
}

-(void)drawSpanningGraph:(CGRCircularVector<uint32_t> *)vertexSet
{
    CGRAVLTree<uint32_t, void> *verticesTree = new CGRAVLTree<uint32_t, void>(edgeComparison);
    uint32_t numVerts = vertexSet ->count();
    for(uint32_t i=0; i != numVerts; i++){
        verticesTree ->add(vertexSet ->elementAtIndex(i), (void *)0x1);
    }
    if(dirtyScreenRectangle)
    {
        //Update the drawing points..
        [self updateGraphDrawing];
        dirtyScreenRectangle = NO;
    }
    
    double screenYUnit = screenRectangle.size.height / graphRectangle.size.height;
    double screenXUnit = screenRectangle.size.width / graphRectangle.size.width;
    uint32_t numberOfVertices = drawVertices ->count();
    
    for(int i=0; i != numberOfVertices; i++){
        struct CGRGeoGraphDrawingVertex *drawVertex = drawVertices ->elementAtIndex(i);
        if (!verticesTree ->containsKey(drawVertex ->ident)) {
            continue;
        }
        
        if(vertexSelector){
            if(!vertexSelector(drawVertex ->ident,associatedGraph,vertexSelectorArg))
                continue;
        }
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(3, GL_FLOAT, 0, drawVertex ->renderPoints);
        if(vertexColorPick4f){
            struct CGRGeoGraphDrawingColor vertColor = vertexColorPick4f(drawVertex ->ident,associatedGraph,vertexColorPickArg4f);
            glColor4f(vertColor.red, vertColor.green, vertColor.blue, vertColor.alpha);
        }else if(vertexColorPick3f){
            struct CGRGeoGraphDrawingColor vertColor = vertexColorPick3f(drawVertex ->ident,associatedGraph,vertexColorPickArg3f);
            glColor4f(vertColor.red, vertColor.green, vertColor.blue, 0.2);
        }else{
            glColor4f(0, 0,0, 0.2);
        }
        glDrawElements(GL_LINE_LOOP, drawVertex ->numberOfSides, GL_UNSIGNED_BYTE, drawVertex ->indices);
        
        glDrawElements(GL_TRIANGLE_FAN, drawVertex ->numberOfSides, GL_UNSIGNED_BYTE, drawVertex ->indices);
        glDisableClientState(GL_VERTEX_ARRAY);
        
        
        //Test for edge drawing...
        
        NSPoint vertexDrawingLoc = drawVertex ->location;
        //Translate the vertex cordinates to screen coordinates
        vertexDrawingLoc.x -= graphRectangle.origin.x;
        vertexDrawingLoc.y -= graphRectangle.origin.y;
        vertexDrawingLoc.x *= screenXUnit;
        vertexDrawingLoc.y *= screenYUnit;
        
        
        CGRCircularVector<uint32_t> *neighbors = [associatedGraph neighborsForVertex:drawVertex ->ident];
        uint32_t numberOfNeighbors = neighbors ->count();
        for(uint32_t j=0; j != numberOfNeighbors; j++){
            uint32_t neighbor = neighbors ->elementAtIndex(j);
            
            
            //if(neighbor > drawingVertices[i].ident)
            //    continue;
            if(!verticesTree ->containsKey(neighbor))
                continue;
            
            if(edgeSelector){
                if(!edgeSelector(makeEdge(drawVertex ->ident, neighbor),associatedGraph,edgeSelectorArg))
                    continue;
            }
            NSPoint neighLocation = [associatedGraph coordinatesForVertex:neighbor];
            
            
            
            //Translate the coordinates to see if we are displaying it..
            neighLocation.x -= graphRectangle.origin.x;
            neighLocation.y -= graphRectangle.origin.y;
            neighLocation.x *= screenXUnit;
            neighLocation.y *= screenYUnit;
            if(neighLocation.x > 0 && neighLocation.x < screenRectangle.size.width &&
               neighLocation.y > 0 && neighLocation.y < screenRectangle.size.height){
                
                
                //Draw the edge
                GLfloat renderPoints[6];
                GLubyte indices[2];
                
                NSPoint minus;
                
                minus.x = neighLocation.x - vertexDrawingLoc.x;
                minus.y = neighLocation.y - vertexDrawingLoc.y;
                float norm = sqrt(minus.x*minus.x + minus.y*minus.y);
                float cosine = minus.x/norm;
                float sin = minus.y/norm;
                //x,y coordinates in the circle with center in the origin
                float x = (radius + 4) * cosine;
                float y = (radius +4) * sin;
                //Translation
                //edgePoint1.x = curnPoint1.x + x;
                //edgePoint1.y = curnPoint1.y + y;
                renderPoints[0] = (GLfloat) (vertexDrawingLoc.x + x);
                renderPoints[1] = (GLfloat) (vertexDrawingLoc.y + y);
                renderPoints[2] = 0.0;
                //Second point
                minus.x = -minus.x;
                minus.y = -minus.y;
                cosine = -cosine;
                sin = -sin;
                x = (radius + 4) * cosine;
                y = (radius + 4) * sin;
                //Translation
                //edgePoint2.x = curnPoint2.x + x;
                //edgePoint2.y = curnPoint2.y + y;
                renderPoints[3] = (GLfloat) (neighLocation.x + x);
                renderPoints[4] = (GLfloat) (neighLocation.y + y);
                renderPoints[5] = 0.0;
                
                indices[0] = 0;
                indices[1] = 1;
                
                GLfloat lineWitdh = 0;
                
                if(edgeColorPick4f){
                    struct CGRGeoGraphDrawingColor edgeColor = edgeColorPick4f(makeEdge(i, neighbor),associatedGraph,edgeColorPickArg4f);
                    glColor4f(edgeColor.red, edgeColor.green, edgeColor.blue, edgeColor.alpha);
                }else if(edgeColorPick3f){
                    struct CGRGeoGraphDrawingColor edgeColor = edgeColorPick3f(makeEdge(i, neighbor),associatedGraph,edgeColorPickArg3f);
                    glColor4f(edgeColor.red, edgeColor.green, edgeColor.blue, 0.5);
                }else{
                    glColor4f(0, 0, 0,0.5);
                }
                glGetFloatv(GL_LINE_WIDTH, &lineWitdh);
                glLineWidth(0.2);
                
                glEnableClientState(GL_VERTEX_ARRAY);
                glVertexPointer(3, GL_FLOAT, 0, renderPoints);
                
                glDrawElements(GL_LINES, 2, GL_UNSIGNED_BYTE, indices);
                glDisableClientState(GL_VERTEX_ARRAY);
                glLineWidth(lineWitdh);
                
                //Draw the arrow heads with norm 2 and angle of pi/4 from the edge.
                NSPoint perpVec1, perpVec2;
                
                minus.x = renderPoints[3] - renderPoints[0];
                minus.y = renderPoints[4] - renderPoints[1];
                
                perpVec1.x = -1*minus.y;
                perpVec1.y = minus.x;
                
                perpVec2.x = minus.y;
                perpVec2.y = -1*minus.x;
                
                //perpVec1.x *= norm; perpVec1.y *= norm;
                
                //perpVec2.x *= norm; perpVec2.y *= norm;
                
                perpVec1.x += renderPoints[0];
                perpVec1.y += renderPoints[1];
                
                perpVec2.x += renderPoints[0];
                perpVec2.y += renderPoints[1];
                
                NSPoint arrowDirVec1, arrowDirVec2;
                
                arrowDirVec1.x = perpVec1.x - renderPoints[3];
                arrowDirVec1.y = perpVec1.y - renderPoints[4];
                
                arrowDirVec2.x = perpVec2.x - renderPoints[3];
                arrowDirVec2.y = perpVec2.y - renderPoints[4];
                
                norm = sqrt(arrowDirVec1.x * arrowDirVec1.x + arrowDirVec1.y * arrowDirVec1.y);
                arrowDirVec1.x /= norm;
                arrowDirVec1.y /= norm;
                arrowDirVec1.x *= 6;
                arrowDirVec1.y *= 6;
                
                arrowDirVec2.x /= norm;
                arrowDirVec2.y /= norm;
                arrowDirVec2.x *= 6;
                arrowDirVec2.y *= 6;
                
                neighLocation.x = renderPoints[3];
                neighLocation.y = renderPoints[4];
                
                //Draw the arrow heads
                renderPoints[0] = neighLocation.x;
                renderPoints[1] = neighLocation.y;
                renderPoints[2] = 0;
                renderPoints[3] = arrowDirVec1.x + neighLocation.x;
                renderPoints[4] = arrowDirVec1.y + neighLocation.y;
                renderPoints[5] = 0;
                glColor4f(0, 0, 0,0.7);
                glGetFloatv(GL_LINE_WIDTH, &lineWitdh);
                glLineWidth(0.1);
                
                glEnableClientState(GL_VERTEX_ARRAY);
                glVertexPointer(3, GL_FLOAT, 0, renderPoints);
                glDrawElements(GL_LINES, 2, GL_UNSIGNED_BYTE, indices);
                
                glDisableClientState(GL_VERTEX_ARRAY);
                
                renderPoints[0] = neighLocation.x;
                renderPoints[1] = neighLocation.y;
                renderPoints[2] = 0;
                renderPoints[3] = arrowDirVec2.x + neighLocation.x;
                renderPoints[4] = arrowDirVec2.y + neighLocation.y;
                renderPoints[5] = 0;
                
                glEnableClientState(GL_VERTEX_ARRAY);
                glVertexPointer(3, GL_FLOAT, 0, renderPoints);
                glDrawElements(GL_LINES, 2, GL_UNSIGNED_BYTE, indices);
                
                glDisableClientState(GL_VERTEX_ARRAY);
                
                glLineWidth(lineWitdh);

            }
            
        }
        delete neighbors;
    }
    delete verticesTree;
}

-(void)setUpVars
{
    dirtyScreenRectangle = NO;
}

-(void)setUpGraph: (CGRGeometricDirectedGraph *)graph andGraphRectangle:(NSRect)gr
{
    [self setUpVars];
    associatedGraph = graph;
    mapTree = NULL;
    vertexColorPick4f = NULL;
    edgeColorPick4f = NULL;
    vertexColorPickArg4f = nil;
    edgeColorPickArg4f = nil;
    ////////////////////First test version....
    graphRectangle = gr;
    //Read all the vertices from the graph and sort them by x and by y
    uint32_t numberOfVertices = [graph vertexSetSize];
    
    drawVertices = new CGRCircularVector<struct CGRGeoGraphDrawingVertex *>();
    drawVertices ->setComparator(_compareByIndet);
    for(uint32_t i=0; i != numberOfVertices; i++){
        NSPoint loc = [graph coordinatesForVertex:i];
        //verticesByX[i].ident = i;
        //verticesByX[i].location = loc;
        if(loc.x >= gr.origin.x && loc.x <= gr.origin.x + gr.size.width)
            if(loc.y >= gr.origin.y && loc.y <= gr.origin.y + gr.size.height){
                struct CGRGeoGraphDrawingVertex *newDraw = new struct CGRGeoGraphDrawingVertex();
                initDrawingVertex(newDraw, i, loc);
                drawVertices ->add(newDraw);
            }
        
    }
    
    /*verticesByX = (struct CGRGeoGraphDrawBasicVertex *)malloc(sizeof(struct CGRGeoGraphDrawBasicVertex)*numberOfVertices);
    if(verticesByX == NULL){
        //We don't have enough space so we throw the exception
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphDrawingNotEnoughMemory" reason:@"Not enough memory to hold the vertices sorted by X" userInfo:nil];
        @throw e;
    }
    
    for(uint32_t i=0; i != numberOfVertices; i++){
        NSPoint loc = [graph coordinatesForVertex:i];
        verticesByX[i].ident = i;
        verticesByX[i].location = loc;
    }
    qsort(verticesByX, numberOfVertices, sizeof(struct CGRGeoGraphDrawBasicVertex), sortByXVertices);
    
    uint32_t leftLimit = positionForXLeft(verticesByX, numberOfVertices, gr.origin.x);
    uint32_t rightLimit = positionForXRight(verticesByX, numberOfVertices, gr.origin.x + gr.size.width);
    
    verticesByY = (struct CGRGeoGraphDrawBasicVertex *)malloc(sizeof(struct CGRGeoGraphDrawBasicVertex)*(rightLimit - leftLimit + 1));
    
    if(verticesByY == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphDrawingNotEnoughMemory" reason:@"Not enough memory to hold the vertices sorted by Y" userInfo:nil];
        @throw e;
    }
    
    verticesByYCapacity = rightLimit - leftLimit + 1;
    
    for(int i=leftLimit; i != rightLimit + 1; i++){
        verticesByY[i - leftLimit] = verticesByX[i];
    }
    
    qsort(verticesByY, rightLimit - leftLimit + 1, sizeof(struct CGRGeoGraphDrawBasicVertex), sortByYVertices);
    
    uint32_t leftYLimit = positionForYLeft(verticesByY, rightLimit - leftLimit + 1, gr.origin.y);
    uint32_t rightYLimit = positionForYRight(verticesByY, rightLimit - leftLimit + 1, gr.origin.y + gr.size.height);
    
    
    if(rightYLimit - leftYLimit + 1 > 100000){
        drawingVertices = (struct CGRGeoGraphDrawingVertex *)malloc(sizeof(struct CGRGeoGraphDrawingVertex)*(rightYLimit - leftYLimit + 1));
        
        if (drawingVertices == NULL) {
            NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphDrawingNotEnoughMemory" reason:@"Not enough memory to hold drawingVertices" userInfo:nil];
            @throw e;
        }
        
        drawingVerticesCapacity =(rightYLimit - leftYLimit + 1);
    }else{
        drawingVertices = (struct CGRGeoGraphDrawingVertex *)malloc(sizeof(struct CGRGeoGraphDrawingVertex)*100000);
        if (drawingVertices == NULL) {
            NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphDrawingNotEnoughMemory" reason:@"Not enough memory to hold drawingVertices" userInfo:nil];
            @throw e;
        }
        drawingVerticesCapacity = 100000;
    }
    for(uint32_t i=leftYLimit; i != rightYLimit+1; i++){
        initDrawingVertex(drawingVertices + (i-leftYLimit), verticesByY[i].ident, verticesByY[i].location);
    }
    
    for(uint32_t i = rightYLimit - leftYLimit + 1; i != drawingVerticesCapacity; i++){
        drawingVertices[i].indices = NULL;
        drawingVertices[i].renderPoints = NULL;
    }
    
    lastDrawingVertex = (rightYLimit - leftYLimit);
    */
}

-(NSPoint)graphPointForScreenPoint:(NSPoint)p
{
    double screenYUnit = graphRectangle.size.height / screenRectangle.size.height;
    double screenXUnit = graphRectangle.size.width / screenRectangle.size.width;
    NSPoint ret;
    ret.x = graphRectangle.origin.x + p.x * screenXUnit;
    ret.y = graphRectangle.origin.y + p.y *screenYUnit;
    return ret;
}

-(void) setUpScreenRectangle:(NSRect) gr
{
    
    screenRectangle = gr;
    
    //Calculate the size of each vertex so they can `fit` inside the screen rectangle
    double screenArea = gr.size.height * gr.size.width;
    
    //So we use, at most, 7/10 of the total area for vertices and the rest for `edges`
    double vertexUsableArea = 0.1*screenArea;
    
    //double radius;
    
    if(PI*lastDrawingVertex <= vertexUsableArea)
        radius = 1;
    else{
        double surface = vertexUsableArea/(double)lastDrawingVertex;
        radius = sqrt(surface/PI);
    }
    
    //NSLog(@"Radius: %f",radius);
    
    //double screenYUnit = screenRectangle.size.height / (graphRectangle.size.height - graphRectangle.origin.y);
    //double screenXUnit = screenRectangle.size.width / (graphRectangle.size.width - graphRectangle.origin.x);
    double screenYUnit = screenRectangle.size.height / graphRectangle.size.height;
    double screenXUnit = screenRectangle.size.width / graphRectangle.size.width;
    
    short numberOfSides = 12;
    
    double sinRad[numberOfSides];
    double cosRad[numberOfSides];
    double radStep = 2*PI/(double)numberOfSides;
    for(short i=0; i != 12; i++){
        sinRad[i] = sin((double)i*radStep)*radius;
        cosRad[i] = cos((double)i*radStep)*radius;
    }
    
    //For that radius initialize all drawable vertices..
    uint32_t numberOfVertices = drawVertices ->count();
    for(uint32_t i = 0; i != numberOfVertices; i++)
    {
        struct CGRGeoGraphDrawingVertex *drawVertex = drawVertices ->elementAtIndex(i);
        drawVertex -> numberOfSides = 12;
        if(drawVertex -> renderPoints == NULL){
            drawVertex -> renderPoints = (GLfloat *)calloc(drawVertex -> numberOfSides*3, sizeof(GLfloat));
        }
        if(drawVertex -> indices == NULL){
            drawVertex -> indices = (GLubyte *)calloc(drawVertex -> numberOfSides,sizeof(GLubyte));
        }
        short renderCord = 0;
        
        NSPoint drawingPoint;
        drawingPoint.x = drawVertex -> location.x - graphRectangle.origin.x;
        drawingPoint.y = drawVertex -> location.y - graphRectangle.origin.y;
        drawingPoint.x *= screenXUnit;
        drawingPoint.y *= screenYUnit;
        for(short k=0; k !=drawVertex -> numberOfSides; k++){
            drawVertex -> indices[k] = k;
            drawVertex -> renderPoints[renderCord++] = (GLfloat)(drawingPoint.x + cosRad[k]);
            drawVertex -> renderPoints[renderCord++] = (GLfloat)(drawingPoint.y + sinRad[k]);
            drawVertex -> renderPoints[renderCord++] = 0.0;
        }
    }
    
    
}



#pragma mark Retangles Update

-(void) updateGraphRectangle:(NSRect) gr
{
    graphRectangle = gr;
    uint32_t numberOfVertices = [associatedGraph vertexSetSize];
    
    uint32_t curntDrawIndex = 0;
    struct CGRGeoGraphDrawingVertex *curntDrawVertex = (drawVertices ->count())?drawVertices ->elementAtIndex(0):NULL;
    
    for(uint32_t i=0; i != numberOfVertices; i++){
        if(curntDrawVertex && curntDrawVertex ->ident == i){
            if (curntDrawVertex ->location.x < gr.origin.x || curntDrawVertex ->location.x > gr.origin.x + gr.size.width ||
                curntDrawVertex ->location.y < gr.origin.y || curntDrawVertex ->location.y > gr.origin.y + gr.size.height) {
                //Remove the vertex from the list
                drawVertices ->removeAtIndex(curntDrawIndex--);
                delete curntDrawVertex;
            }
            curntDrawVertex = (++curntDrawIndex < drawVertices ->count())?drawVertices ->elementAtIndex(curntDrawIndex):NULL;
            continue;
        }
        NSPoint loc = [associatedGraph coordinatesForVertex:i];
        //verticesByX[i].ident = i;
        //verticesByX[i].location = loc;
        if(loc.x >= gr.origin.x && loc.x <= gr.origin.x + gr.size.width)
            if(loc.y >= gr.origin.y && loc.y <= gr.origin.y + gr.size.height){
                struct CGRGeoGraphDrawingVertex *newDraw = new struct CGRGeoGraphDrawingVertex();
                initDrawingVertex(newDraw, i, loc);
                drawVertices ->insertAtIndex(newDraw, curntDrawIndex++);
            }
    }
    
    /*uint32_t leftLimit = positionForXLeft(verticesByX, numberOfVertices, graphRectangle.origin.x);
    uint32_t rightLimit = positionForXRight(verticesByX, numberOfVertices, graphRectangle.origin.x + graphRectangle.size.width);
    
    if(rightLimit - leftLimit + 1 > verticesByYCapacity){
        //We don't have enough space in the array.. so we free it and create another
        free(verticesByY);
        verticesByY = (struct CGRGeoGraphDrawBasicVertex *)malloc(sizeof(struct CGRGeoGraphDrawBasicVertex)*(rightLimit - leftLimit + 1));
        
        if(verticesByY == NULL){
            NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphDrawingNotEnoughMemory" reason:@"Not enough memory to hold the vertices sorted by Y" userInfo:nil];
            @throw e;
        }
        
        verticesByYCapacity = rightLimit - leftLimit + 1;
    }
    //when we get here we have enough space...
    for(int i=leftLimit; i != rightLimit + 1; i++){
        verticesByY[i - leftLimit] = verticesByX[i];
    }
    
    lastVerticesByYVertex = rightLimit - leftLimit;
    
    qsort(verticesByY, rightLimit - leftLimit + 1, sizeof(struct CGRGeoGraphDrawBasicVertex), sortByYVertices);
    
    uint32_t leftYLimit = positionForYLeft(verticesByY, rightLimit - leftLimit + 1, gr.origin.y);
    uint32_t rightYLimit = positionForYRight(verticesByY, rightLimit - leftLimit + 1, gr.origin.y + gr.size.height);
    
    if(rightYLimit - leftYLimit + 1 > drawingVerticesCapacity){
        for(uint32_t i = 0; i != drawingVerticesCapacity; i++){
            if(drawingVertices[i].renderPoints != NULL){
                free(drawingVertices[i].renderPoints);
                free(drawingVertices[i].indices);
            }
        }
        free(drawingVertices);
        drawingVertices = (struct CGRGeoGraphDrawingVertex *)malloc(sizeof(struct CGRGeoGraphDrawingVertex)*(rightYLimit - leftYLimit + 1));
        
        if (drawingVertices == NULL) {
            NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphDrawingNotEnoughMemory" reason:@"Not enough memory to hold drawingVertices" userInfo:nil];
            @throw e;
        }
        
        drawingVerticesCapacity =(rightYLimit - leftYLimit + 1);
        for(uint32_t i=leftYLimit; i != rightYLimit+1; i++){
            initDrawingVertex(drawingVertices + (i-leftYLimit), verticesByY[i].ident, verticesByY[i].location);
        }
        lastDrawingVertex = (rightYLimit - leftYLimit);
    }else{
        for(uint32_t i=leftYLimit; i != rightYLimit+1; i++){
            updateDrawingVertex(drawingVertices + (i-leftYLimit), verticesByY[i].ident, verticesByY[i].location);
        }
        lastDrawingVertex = (rightYLimit - leftYLimit);
    }*/
    
    dirtyScreenRectangle = YES;
}

//Updates the opengl code for the drawing of the graph...
-(void) updateGraphDrawing
{
    //Calculate the size of each vertex so they can `fit` inside the screen rectangle
    double screenArea = screenRectangle.size.height * screenRectangle.size.width;
    
    //So we use, at most, 7/10 of the total area for vertices and the rest for `edges`
    double vertexUsableArea = 0.1*screenArea;
    
    if(PI*lastDrawingVertex <= vertexUsableArea)
        radius = 1;
    else{
        double surface = vertexUsableArea/(double)lastDrawingVertex;
        radius = sqrt(surface/PI);
    }
    
    //NSLog(@"Radius: %f",radius);
    
    double screenYUnit = screenRectangle.size.height / graphRectangle.size.height;
    double screenXUnit = screenRectangle.size.width / graphRectangle.size.width;
    
    
    short numberOfSides = 12;
    
    double sinRad[numberOfSides];
    double cosRad[numberOfSides];
    double radStep = 2*PI/(double)numberOfSides;
    for(short i=0; i != 12; i++){
        sinRad[i] = sin((double)i*radStep)*radius;
        cosRad[i] = cos((double)i*radStep)*radius;
    }
    
    //For that radius initialize all drawable vertices..
    uint32_t numberOfVertices = drawVertices ->count();
    for(uint32_t i = 0; i != numberOfVertices; i++)
    {
        struct CGRGeoGraphDrawingVertex *drawVertex = drawVertices -> elementAtIndex(i);
        if(drawVertex -> renderPoints == NULL){
            drawVertex ->numberOfSides = 12;
            if(drawVertex ->renderPoints == NULL){
                drawVertex ->renderPoints = (GLfloat *)calloc(drawVertex ->numberOfSides*3, sizeof(GLfloat));
            }
            if(drawVertex ->indices == NULL){
                drawVertex ->indices = (GLubyte *)calloc(drawVertex ->numberOfSides,sizeof(GLubyte));
            }
        }
        short renderCord = 0;
        
        NSPoint drawingPoint;
        drawingPoint.x = drawVertex ->location.x - graphRectangle.origin.x;
        drawingPoint.y = drawVertex ->location.y - graphRectangle.origin.y;
        drawingPoint.x *= screenXUnit;
        drawingPoint.y *= screenYUnit;
        for(short k=0; k !=drawVertex ->numberOfSides; k++){
            drawVertex ->indices[k] = k;
            drawVertex ->renderPoints[renderCord++] = (GLfloat)(drawingPoint.x + sinRad[k]);
            drawVertex ->renderPoints[renderCord++] = (GLfloat)(drawingPoint.y + cosRad[k]);
            drawVertex ->renderPoints[renderCord++] = 0.0;
        }
    }
}

-(void)drawToEPSFile:(const char *)path
{
    std::ofstream epsFile;
    epsFile.open(path);
    
    epsFile << "%!PS-Adobe-3.0 EPSF-3.0" << std::endl;
    epsFile << "%%Creator: CGR (Computational Geometry Rover)" << std::endl;
    epsFile << "%%BoundingBox: " << 0 << " " << 0 << " "<< screenRectangle.size.width << " " << screenRectangle.size.height << std::endl;
    
    double screenYUnit = screenRectangle.size.height / graphRectangle.size.height;
    double screenXUnit = screenRectangle.size.width / graphRectangle.size.width;
    
    epsFile << "1 setlinejoin" << std::endl;
    epsFile << "2 setlinecap" << std::endl;
    
    uint32_t numberOfVertices = drawVertices ->count();
    
    for(int i=0; i != numberOfVertices; i++){
        //Draw the vertex
        
        //Test for edge drawing...
        struct CGRGeoGraphDrawingVertex *drawVertex = drawVertices -> elementAtIndex(i);
        
        NSPoint vertexDrawingLoc = drawVertex ->location;
        //Translate the vertex cordinates to screen coordinates
        vertexDrawingLoc.x -= graphRectangle.origin.x;
        vertexDrawingLoc.y -= graphRectangle.origin.y;
        vertexDrawingLoc.x *= screenXUnit;
        vertexDrawingLoc.y *= screenYUnit;
        
        
        CGRCircularVector<uint32_t> *neighbors = [associatedGraph outNeighborsForVertex:drawVertex ->ident];
        uint32_t numberOfNeighbors = neighbors ->count();
        for(uint32_t j=0; j != numberOfNeighbors; j++){
            uint32_t neighbor = neighbors ->elementAtIndex(j);
            
            BOOL drawArrow = YES;
            
            if([associatedGraph vertex:drawVertex->ident isOutNeighborOf:neighbor]){
               if(drawVertex ->ident < neighbor){
                   drawArrow = NO;
               }else{
                   continue;
               }
            }
            //if(neighbor > drawingVertices[i].ident)
              //  continue;
            
            NSPoint neighLocation = [associatedGraph coordinatesForVertex:neighbor];
            
            
            
            //Translate the coordinates to see if we are displaying it..
            neighLocation.x -= graphRectangle.origin.x;
            neighLocation.y -= graphRectangle.origin.y;
            neighLocation.x *= screenXUnit;
            neighLocation.y *= screenYUnit;
            if(neighLocation.x > 0 && neighLocation.x < screenRectangle.size.width &&
               neighLocation.y > 0 && neighLocation.y < screenRectangle.size.height){
                
                
                //Draw the edge
                GLfloat renderPoints[6];
                
                NSPoint minus;
                
                minus.x = neighLocation.x - vertexDrawingLoc.x;
                minus.y = neighLocation.y - vertexDrawingLoc.y;
                float norm = (sqrt(minus.x*minus.x + minus.y*minus.y));
                float cosine = minus.x/norm;
                float sin = minus.y/norm;
                //x,y coordinates in the circle with center in the origin
                float x = radius * cosine;
                float y = radius * sin;
                //Translation
                //edgePoint1.x = curnPoint1.x + x;
                //edgePoint1.y = curnPoint1.y + y;
                renderPoints[0] = (GLfloat) (vertexDrawingLoc.x + x);
                renderPoints[1] = (GLfloat) (vertexDrawingLoc.y + y);
                renderPoints[2] = 0.0;
                //Second point
                minus.x = -minus.x;
                minus.y = -minus.y;
                cosine = -cosine;
                sin = -sin;
                x = radius * cosine;
                y = radius * sin;
                //Translation
                //edgePoint2.x = curnPoint2.x + x;
                //edgePoint2.y = curnPoint2.y + y;
                renderPoints[3] = (GLfloat) (neighLocation.x + x);
                renderPoints[4] = (GLfloat) (neighLocation.y + y);
                renderPoints[5] = 0.0;
                
                epsFile << "0.5 setgray" << std::endl;
                epsFile << "0.3 setlinewidth" << std::endl;
                
                epsFile << "newpath" << std::endl;
                epsFile << "\t" << renderPoints[0] << " " << renderPoints[1] << " moveto" << std::endl;
                epsFile << "\t" << renderPoints[3] << " " << renderPoints[4] << " lineto" << std::endl;
                epsFile << "stroke" << std::endl;
                
                if(!drawArrow)
                    continue;
                
                //Draw the arrow heads with norm 2 and angle of pi/4 from the edge.
                NSPoint perpVec1, perpVec2;
                
                minus.x = renderPoints[3] - renderPoints[0];
                minus.y = renderPoints[4] - renderPoints[1];
                
                perpVec1.x = -1*minus.y;
                perpVec1.y = minus.x;
                
                perpVec2.x = minus.y;
                perpVec2.y = -1*minus.x;
                
                //perpVec1.x *= norm; perpVec1.y *= norm;
                
                //perpVec2.x *= norm; perpVec2.y *= norm;
                
                perpVec1.x += renderPoints[0];
                perpVec1.y += renderPoints[1];
                
                perpVec2.x += renderPoints[0];
                perpVec2.y += renderPoints[1];
                
                NSPoint arrowDirVec1, arrowDirVec2;
                
                arrowDirVec1.x = perpVec1.x - renderPoints[3];
                arrowDirVec1.y = perpVec1.y - renderPoints[4];
                
                arrowDirVec2.x = perpVec2.x - renderPoints[3];
                arrowDirVec2.y = perpVec2.y - renderPoints[4];
                
                norm = sqrt(arrowDirVec1.x * arrowDirVec1.x + arrowDirVec1.y * arrowDirVec1.y);
                arrowDirVec1.x /= norm;
                arrowDirVec1.y /= norm;
                arrowDirVec1.x *= 6;
                arrowDirVec1.y *= 6;
                
                arrowDirVec2.x /= norm;
                arrowDirVec2.y /= norm;
                arrowDirVec2.x *= 6;
                arrowDirVec2.y *= 6;
                
                neighLocation.x = renderPoints[3];
                neighLocation.y = renderPoints[4];
                
                //Draw the arrow heads
                renderPoints[0] = neighLocation.x;
                renderPoints[1] = neighLocation.y;
                renderPoints[2] = 0;
                renderPoints[3] = arrowDirVec1.x + neighLocation.x;
                renderPoints[4] = arrowDirVec1.y + neighLocation.y;
                renderPoints[5] = 0;
                
                
                epsFile << "newpath" << std::endl;
                epsFile << "\t" << renderPoints[0] << " " << renderPoints[1] << " moveto" << std::endl;
                epsFile << "\t" << renderPoints[3] << " " << renderPoints[4] << " lineto" << std::endl;
                epsFile << "stroke" << std::endl;
                
                renderPoints[0] = neighLocation.x;
                renderPoints[1] = neighLocation.y;
                renderPoints[2] = 0;
                renderPoints[3] = arrowDirVec2.x + neighLocation.x;
                renderPoints[4] = arrowDirVec2.y + neighLocation.y;
                renderPoints[5] = 0;
                
                epsFile << "newpath" << std::endl;
                epsFile << "\t" << renderPoints[0] << " " << renderPoints[1] << " moveto" << std::endl;
                epsFile << "\t" << renderPoints[3] << " " << renderPoints[4] << " lineto" << std::endl;
                epsFile << "stroke" << std::endl;
                
                
                
            }
            
        }
        delete neighbors;
        
        
    }
    //Draw the vertices themselves
    for(uint32_t i=0; i != numberOfVertices; i++){
        struct CGRGeoGraphDrawingVertex *drawVertex = drawVertices -> elementAtIndex(i);
        
        //Draw the vertex
        epsFile << "0.3 setlinewidth" << std::endl;
        epsFile << "\t0.0 setgray" << std::endl;
        epsFile << "\t\t" << screenXUnit*(drawVertex -> location.x - graphRectangle.origin.x) << " ";
        epsFile << screenYUnit*(drawVertex ->location.y - graphRectangle.origin.y) << " " ;
        epsFile << radius << " 0 360 arc stroke" <<std::endl;
        epsFile << "\t0.2 setgray" << std::endl;
        epsFile << "\t\t" << screenXUnit*(drawVertex ->location.x - graphRectangle.origin.x) << " ";
        epsFile << screenYUnit*(drawVertex ->location.y - graphRectangle.origin.y) << " ";
        epsFile << radius << " 0 360 arc fill" <<std::endl;
        
    }
    
    epsFile << "showpage" << std::endl;
    epsFile.close();
    
    
}

-(void)setVertexDrawingColorFunction4f:(struct CGRGeoGraphDrawingColor (*)(uint32_t,id,id))funcPtr withArgument:(id)arg
{
    vertexColorPick4f = funcPtr;
    vertexColorPickArg4f = arg;
}
-(void)setEdgeDrawingColorFunction4f:(struct CGRGeoGraphDrawingColor (*)(CGREdge,id,id))funcPtr withArgument:(id)arg
{
    edgeColorPick4f = funcPtr;
    edgeColorPickArg4f = arg;
}
-(void)setVertexDrawingColorFunction3f:(struct CGRGeoGraphDrawingColor (*)(uint32_t,id,id))funcPtr withArgument:(id)arg
{
    vertexColorPick3f = funcPtr;
    vertexColorPickArg3f = arg;
}
-(void)setEdgeDrawingColorFunction3f:(struct CGRGeoGraphDrawingColor (*)(CGREdge,id,id))funcPtr withArgument:(id)arg
{
    edgeColorPick3f = funcPtr;
    edgeColorPickArg3f = arg;
}
-(void)setEdgeSelectorFunction:(BOOL (*)(CGREdge, id,id))funcPtr withArgument:(id)arg
{
    edgeSelector = funcPtr;
    edgeSelectorArg = arg;
}
-(void)setVertexSelectorFunction:(BOOL(*)(uint32_t,id,id))funcPtr withArgument:(id)arg
{
    vertexSelector = funcPtr;
    vertexSelectorArg = arg;
}

-(void) calculateMapTree:(uint32_t)rows columns:(uint32_t)columns andCapacity:(uint32_t)capacity
{
    if(mapTree != NULL){
        delete mapTree;
    }
    mapTree = new CGRMapTree(rows,columns,capacity);
    if(mapTree == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphDrawingNotEnoughMemory" reason:@"Not enough memory for mapTree" userInfo:nil];
        @throw e;
    }
    //mapTree ->constructTree(verticesByX, [associatedGraph vertexSetSize]);
}
-(void) drawMapTree:(NSRect)bounds
{
    if(mapTree != NULL)
        mapTree ->drawFromRoot(bounds);
}
@end
