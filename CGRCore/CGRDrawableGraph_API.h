//
//  CGRDrawable_API.h
//  CGRCore
//
//  Created by Alfredo Cruz on 12/26/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
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
#import <CGRCore/CGRCommonTypes.h>
#import <CGRCore/CGRCircularVector.h>

@protocol CGRDrawable_API <NSObject>

@required
-(void) setUpScreenRectangle:(NSRect) gr;
-(void) updateGraphRectangle:(NSRect) gr;
-(NSRect) graphRectangle;
-(NSRect) screenRectangle;
-(NSPoint)graphPointForScreenPoint:(NSPoint)p;
-(void) draw;
#pragma mark -
#pragma mark Restricted drawings
-(void)drawSpanningGraph:(CGRCircularVector<uint32_t> *)vertexSet;
#pragma mark -
#pragma mark Global Properties
-(void) setGlobalAlpha:(double)value;
#pragma mark Settings
#pragma mark -
-(void) hideVertex: (uint32_t)vertex hide:(BOOL)hide;
-(void) hideVertexAndEdges:(uint32_t)vertex hide:(BOOL)hide;
-(void) hideAllVertices;
-(void) hideAllEdges;
-(void) hideAll;

@optional
-(void)drawToEPSFile:(const char *)path;
-(void)setVertexDrawingColorFunction4f:(struct CGRGeoGraphDrawingColor (*)(uint32_t,id,id))funcPtr withArgument:(id)arg;
-(void)setEdgeDrawingColorFunction4f:(struct CGRGeoGraphDrawingColor (*)(CGREdge,id,id))funcPtr withArgument:(id)arg;
-(void)setVertexDrawingColorFunction3f:(struct CGRGeoGraphDrawingColor (*)(uint32_t,id,id))funcPtr withArgument:(id)arg;
-(void)setEdgeDrawingColorFunction3f:(struct CGRGeoGraphDrawingColor (*)(CGREdge,id,id))funcPtr withArgument:(id)arg;

//Sets the function to select which edges and vertices shall be displayed
//the arguments are (theEdge(vertex),theGraph,userDefinedArgument)
-(void)setEdgeSelectorFunction:(BOOL (*)(CGREdge, id,id))funcPtr withArgument:(id)arg;
-(void)setVertexSelectorFunction:(BOOL(*)(uint32_t,id,id))funcPtr withArgument:(id)arg;

@end
