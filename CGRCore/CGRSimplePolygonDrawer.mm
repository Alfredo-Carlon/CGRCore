//
//  CGRSimplePolygonDrawer.m
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


#import "CGRSimplePolygonDrawer.h"
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLContext.h>
#import <stdlib.h>
#include <iostream>
#include <fstream>
#import "CGRAVLTree.h"
#import "CGRVector.h"
#import "CGRSimplePolygon.h"
#import "CGRGeometricCommon.h"


@implementation CGRSimplePolygonDrawer
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
    
    for(int i=0; i != lastDrawingVertex+1; i++){
        
        BOOL showVertices = NO;
        
        if(vertexSelector){
            showVertices = vertexSelector(drawingVertices[i].ident,associatedPolygon,vertexSelectorArg);
        }
        if(showVertices){
            glEnableClientState(GL_VERTEX_ARRAY);
            glVertexPointer(3, GL_FLOAT, 0, drawingVertices[i].renderPoints);
            if(vertexColorPick4f){
                struct CGRGeoGraphDrawingColor vertColor = vertexColorPick4f(drawingVertices[i].ident,associatedPolygon,vertexColorPickArg4f);
                glColor4f(vertColor.red, vertColor.green, vertColor.blue, vertColor.alpha);
            }else if(vertexColorPick3f){
                struct CGRGeoGraphDrawingColor vertColor = vertexColorPick3f(drawingVertices[i].ident,associatedPolygon,vertexColorPickArg3f);
                glColor4f(vertColor.red, vertColor.green, vertColor.blue, 0.2);
            }else{
                glColor4f(0, 0,0, 0.2);
            }
            glDrawElements(GL_LINE_LOOP, drawingVertices[i].numberOfSides, GL_UNSIGNED_BYTE, drawingVertices[i].indices);
            
            glDrawElements(GL_TRIANGLE_FAN, drawingVertices[i].numberOfSides, GL_UNSIGNED_BYTE, drawingVertices[i].indices);
            glDisableClientState(GL_VERTEX_ARRAY);
        }
        
        
        //Test for edge drawing...
        
        NSPoint vertexDrawingLoc = drawingVertices[i].location;
        //Translate the vertex cordinates to screen coordinates
        vertexDrawingLoc.x -= graphRectangle.origin.x;
        vertexDrawingLoc.y -= graphRectangle.origin.y;
        vertexDrawingLoc.x *= screenXUnit;
        vertexDrawingLoc.y *= screenYUnit;
        
        
        CGRCircularVector<uint32_t> *neighbors = [associatedPolygon neighborsForVertex:drawingVertices[i].ident];
        uint32_t numberOfNeighbors = neighbors ->count();
        for(uint32_t j=0; j != numberOfNeighbors; j++){
            uint32_t neighbor = neighbors ->elementAtIndex(j);
            
            if(neighbor > drawingVertices[i].ident)
                continue;
            
            if(edgeSelector){
                if(!edgeSelector(makeEdge(drawingVertices[i].ident, neighbor),associatedPolygon,edgeSelectorArg))
                    continue;
            }
            
            NSPoint neighLocation = [associatedPolygon coordinatesForVertex:neighbor];
            
            
            
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
                
                if (!showVertices) {
                    renderPoints[0] = (GLfloat)vertexDrawingLoc.x;
                    renderPoints[1] = (GLfloat)vertexDrawingLoc.y;
                    renderPoints[2] = 0;
                    
                    renderPoints[3] = (GLfloat)neighLocation.x;
                    renderPoints[4] = (GLfloat)neighLocation.y;
                    renderPoints[5] = 0;
                    
                }else{
                
                    
                    NSPoint minus;
                    
                    minus.x = neighLocation.x - vertexDrawingLoc.x;
                    minus.y = neighLocation.y - vertexDrawingLoc.y;
                    float norm = (sqrt(minus.x*minus.x + minus.y*minus.y));
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
                }
                
                indices[0] = 0;
                indices[1] = 1;
                
                GLfloat lineWitdh = 0;
                if(edgeColorPick4f){
                    struct CGRGeoGraphDrawingColor edgeColor = edgeColorPick4f(makeEdge(i, neighbor),associatedPolygon,edgeColorPickArg4f);
                    glColor4f(edgeColor.red, edgeColor.green, edgeColor.blue, edgeColor.alpha);
                }else if(edgeColorPick3f){
                    struct CGRGeoGraphDrawingColor edgeColor = edgeColorPick3f(makeEdge(i, neighbor),associatedPolygon,edgeColorPickArg3f);
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
        uint32_t vertex = vertexSet ->elementAtIndex(i);
        verticesTree ->add(vertex, NULL);
    }
    
    if(dirtyScreenRectangle)
    {
        //Update the drawing points..
        [self updateGraphDrawing];
        dirtyScreenRectangle = NO;
    }
    
    double screenYUnit = screenRectangle.size.height / graphRectangle.size.height;
    double screenXUnit = screenRectangle.size.width / graphRectangle.size.width;
    
    for(int i=0; i != lastDrawingVertex+1; i++){
        if (!verticesTree ->containsKey(drawingVertices[i].ident)) {
            continue;
        }
        
        if(vertexSelector){
            if(!vertexSelector(drawingVertices[i].ident,associatedPolygon,vertexSelectorArg))
                continue;
        }
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(3, GL_FLOAT, 0, drawingVertices[i].renderPoints);
        if(vertexColorPick4f){
            struct CGRGeoGraphDrawingColor vertColor = vertexColorPick4f(drawingVertices[i].ident,associatedPolygon,vertexColorPickArg4f);
            glColor4f(vertColor.red, vertColor.green, vertColor.blue, vertColor.alpha);
        }else if(vertexColorPick3f){
            struct CGRGeoGraphDrawingColor vertColor = vertexColorPick3f(drawingVertices[i].ident,associatedPolygon,vertexColorPickArg3f);
            glColor4f(vertColor.red, vertColor.green, vertColor.blue, 0.2);
        }else{
            glColor4f(0, 0,0, 0.2);
        }
        glDrawElements(GL_LINE_LOOP, drawingVertices[i].numberOfSides, GL_UNSIGNED_BYTE, drawingVertices[i].indices);
        
        glDrawElements(GL_TRIANGLE_FAN, drawingVertices[i].numberOfSides, GL_UNSIGNED_BYTE, drawingVertices[i].indices);
        glDisableClientState(GL_VERTEX_ARRAY);
        
        
        //Test for edge drawing...
        
        NSPoint vertexDrawingLoc = drawingVertices[i].location;
        //Translate the vertex cordinates to screen coordinates
        vertexDrawingLoc.x -= graphRectangle.origin.x;
        vertexDrawingLoc.y -= graphRectangle.origin.y;
        vertexDrawingLoc.x *= screenXUnit;
        vertexDrawingLoc.y *= screenYUnit;
        
        
        CGRCircularVector<uint32_t> *neighbors = [associatedPolygon neighborsForVertex:drawingVertices[i].ident];
        uint32_t numberOfNeighbors = neighbors ->count();
        for(uint32_t j=0; j != numberOfNeighbors; j++){
            uint32_t neighbor = neighbors ->elementAtIndex(j);
            
            
            if(neighbor > drawingVertices[i].ident || !verticesTree ->containsKey(neighbor))
                continue;
            
            if(edgeSelector){
                if(!edgeSelector(makeEdge(drawingVertices[i].ident, neighbor),associatedPolygon,edgeSelectorArg))
                    continue;
            }
            
            NSPoint neighLocation = [associatedPolygon coordinatesForVertex:neighbor];
            
            
            
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
                float norm = (sqrt(minus.x*minus.x + minus.y*minus.y));
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
                    struct CGRGeoGraphDrawingColor edgeColor = edgeColorPick4f(makeEdge(i, neighbor),associatedPolygon,edgeColorPickArg4f);
                    glColor4f(edgeColor.red, edgeColor.green, edgeColor.blue, edgeColor.alpha);
                }else if(edgeColorPick3f){
                    struct CGRGeoGraphDrawingColor edgeColor = edgeColorPick3f(makeEdge(i, neighbor),associatedPolygon,edgeColorPickArg3f);
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

-(void)setUpPolygon: (CGRSimplePolygon *)polygon andPolygonRectangle:(NSRect)gr
{
    [self setUpVars];
    associatedPolygon = polygon;
    ////////////////////First test version....
    graphRectangle = gr;
    //Read all the vertices from the graph and sort them by x and by y
    uint32_t numberOfVertices = [polygon vertexSetSize];
    
    verticesByX = (struct CGRGeoGraphDrawBasicVertex *)malloc(sizeof(struct CGRGeoGraphDrawBasicVertex)*numberOfVertices);
    if(verticesByX == NULL){
        //We don't have enough space so we throw the exception
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphDrawingNotEnoughMemory" reason:@"Not enough memory to hold the vertices sorted by X" userInfo:nil];
        @throw e;
    }
    
    for(uint32_t i=0; i != numberOfVertices; i++){
        NSPoint loc = [polygon coordinatesForVertex:i];
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
    
    for(uint32_t i = 0; i != lastDrawingVertex + 1; i++)
    {
        drawingVertices[i].numberOfSides = 12;
        if(drawingVertices[i].renderPoints == NULL){
            drawingVertices[i].renderPoints = (GLfloat *)calloc(drawingVertices[i].numberOfSides*3, sizeof(GLfloat));
        }
        if(drawingVertices[i].indices == NULL){
            drawingVertices[i].indices = (GLubyte *)calloc(drawingVertices[i].numberOfSides,sizeof(GLubyte));
        }
        short renderCord = 0;
        
        NSPoint drawingPoint;
        drawingPoint.x = drawingVertices[i].location.x - graphRectangle.origin.x;
        drawingPoint.y = drawingVertices[i].location.y - graphRectangle.origin.y;
        drawingPoint.x *= screenXUnit;
        drawingPoint.y *= screenYUnit;
        for(short k=0; k !=drawingVertices[i].numberOfSides; k++){
            drawingVertices[i].indices[k] = k;
            drawingVertices[i].renderPoints[renderCord++] = (GLfloat)(drawingPoint.x + cosRad[k]);
            drawingVertices[i].renderPoints[renderCord++] = (GLfloat)(drawingPoint.y + sinRad[k]);
            drawingVertices[i].renderPoints[renderCord++] = 0.0;
        }
    }
    
    
}



#pragma mark Retangles Update

-(void) updateGraphRectangle:(NSRect) gr
{
    graphRectangle = gr;
    uint32_t numberOfVertices = [associatedPolygon vertexSetSize];
    
    uint32_t leftLimit = positionForXLeft(verticesByX, numberOfVertices, graphRectangle.origin.x);
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
    }
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
    
    for(uint32_t i = 0; i != lastDrawingVertex+1; i++)
    {
        if(drawingVertices[i].renderPoints == NULL){
            drawingVertices[i].numberOfSides = 12;
            if(drawingVertices[i].renderPoints == NULL){
                drawingVertices[i].renderPoints = (GLfloat *)calloc(drawingVertices[i].numberOfSides*3, sizeof(GLfloat));
            }
            if(drawingVertices[i].indices == NULL){
                drawingVertices[i].indices = (GLubyte *)calloc(drawingVertices[i].numberOfSides,sizeof(GLubyte));
            }
        }
        short renderCord = 0;
        
        NSPoint drawingPoint;
        drawingPoint.x = drawingVertices[i].location.x - graphRectangle.origin.x;
        drawingPoint.y = drawingVertices[i].location.y - graphRectangle.origin.y;
        drawingPoint.x *= screenXUnit;
        drawingPoint.y *= screenYUnit;
        for(short k=0; k !=drawingVertices[i].numberOfSides; k++){
            drawingVertices[i].indices[k] = k;
            drawingVertices[i].renderPoints[renderCord++] = (GLfloat)(drawingPoint.x + sinRad[k]);
            drawingVertices[i].renderPoints[renderCord++] = (GLfloat)(drawingPoint.y + cosRad[k]);
            drawingVertices[i].renderPoints[renderCord++] = 0.0;
        }
    }
}

-(void)drawToEPSFile:(const char *)path
{
    std::ofstream epsFile;
    epsFile.open(path);
    
    epsFile << "%!PS-Adobe-2.0" << std::endl;
    epsFile << "%%BoundingBox " << 0 << " " << 0 << " "<< screenRectangle.size.width << " " << screenRectangle.size.height << std::endl;
    
    double screenYUnit = screenRectangle.size.height / graphRectangle.size.height;
    double screenXUnit = screenRectangle.size.width / graphRectangle.size.width;
    
    epsFile << "1 setlinejoin" << std::endl;
    epsFile << "2 setlinecap" << std::endl;
    
    for(int i=0; i != lastDrawingVertex+1; i++){
        //Draw the vertex
        epsFile << "0.3 setlinewidth" << std::endl;
        epsFile << "\t0.0 setgray" << std::endl;
        epsFile << "\t\t" << screenXUnit*(drawingVertices[i].location.x - graphRectangle.origin.x) << " ";
        epsFile << screenYUnit*(drawingVertices[i].location.y - graphRectangle.origin.y) << " " ;
        epsFile << radius << " 0 360 arc stroke" <<std::endl;
        epsFile << "\t0.5 setgray" << std::endl;
        epsFile << "\t\t" << screenXUnit*(drawingVertices[i].location.x - graphRectangle.origin.x) << " ";
        epsFile << screenYUnit*(drawingVertices[i].location.y - graphRectangle.origin.y) << " ";
        epsFile << radius << " 0 360 arc fill" <<std::endl;
        
        epsFile << "0.3 setgray" << std::endl;
        epsFile << "0.4 setlinewidth" << std::endl;
        
        
        //Test for edge drawing...
        
        NSPoint vertexDrawingLoc = drawingVertices[i].location;
        //Translate the vertex cordinates to screen coordinates
        vertexDrawingLoc.x -= graphRectangle.origin.x;
        vertexDrawingLoc.y -= graphRectangle.origin.y;
        vertexDrawingLoc.x *= screenXUnit;
        vertexDrawingLoc.y *= screenYUnit;
        
        
        CGRCircularVector<uint32_t> *neighbors = [associatedPolygon neighborsForVertex:drawingVertices[i].ident];
        uint32_t numberOfNeighbors = neighbors ->count();
        for(uint32_t j=0; j != numberOfNeighbors; j++){
            uint32_t neighbor = neighbors ->elementAtIndex(j);
            
            
            if(neighbor > drawingVertices[i].ident)
                continue;
            
            NSPoint neighLocation = [associatedPolygon coordinatesForVertex:neighbor];
            
            
            
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
                
                epsFile << "newpath" << std::endl;
                epsFile << "\t" << renderPoints[0] << " " << renderPoints[1] << " moveto" << std::endl;
                epsFile << "\t" << renderPoints[3] << " " << renderPoints[4] << " lineto" << std::endl;
                epsFile << "stroke" << std::endl;
                
                
            }
            
        }
        delete neighbors;
        
        
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


@end
