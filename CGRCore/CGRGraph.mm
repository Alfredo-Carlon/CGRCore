//
//  CGRGraph.m
//  CGRCore
//
//  Created by Alfredo Cruz on 10/15/13.
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

#import "CGRGraph.h"
#import "CGRCommonTypes.h"

@implementation CGRGraph


-(void)initCommonVariables
{
    
}


-(id)init
{
    if(![super init])
        return nil;
    
    vertices = new CGRCircularVector<CGRVertex *>();
    notifyList = NULL;
    notifyChanges = NO;

    return self;
}
-(id)initWithVerticesCapacity:(uint32_t)verticesInitialCapacity
{
    if(![super init])
        return nil;
    
    vertices = new CGRCircularVector<CGRVertex *>(verticesInitialCapacity);
    CGRCircularVector<CGRVertex *> vertices1 = *vertices;
    notifyList = NULL;
    notifyChanges = NO;
    return self;
}


#pragma mark -
#pragma mark Vertices Basics
//Adds a vertex
-(uint32_t)addVertex
{
    CGRVertex *nv = new CGRVertex();
    uint32_t ident = vertices ->add(nv);
    nv ->vertexIdent = ident;
    //numberOfVertices++;
    
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGraph_Notifications> notifyObj =
            (__bridge id <CGRGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(vertexAdded:)]){
                [notifyObj vertexAdded:ident];
            }
        }
    }
    return ident;
}

-(uint32_t)vertexSetSize
{
    return vertices ->count();
}

//Removes a vertex
-(void)removeVertex:(uint32_t)vertex
{
    CGRCircularVector<uint32_t> *neighbors = [self neighborsForVertex:vertex];
    for(uint32_t i=0; i != neighbors ->count(); i++){
        [self removeEdge:makeEdge(vertex, neighbors ->elementAtIndex(i))];
    }
    delete neighbors;
    
    ////////TEMPORAL REMOVAL!!!!!!!!!!
    ///////    // Could be replaced for a 'registered pointer' version for tracking propourses!!!!!!!!!
    
    CGRVertex *v = vertices ->removeAtIndex(vertex);
    free(v);
    uint32_t vsize = vertices ->count();
    for(uint32_t i=vertex; i != vsize; i++){
        vertices ->elementAtIndex(i)->vertexIdent--;
    }
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGraph_Notifications> notifyObj =
            (__bridge id <CGRGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(vertexRemoved:)]){
                [notifyObj vertexRemoved:vertex];
            }
        }
    }
}

-(uint32_t)vertexDegree:(uint32_t)vertex
{
    CGRVertex *vertex_ptr = vertices ->elementAtIndex(vertex);
    if(vertex_ptr == NULL)
        return 0;
    if(vertex_ptr ->vertexAdjacencyList == NULL)
        return 0;
    return vertex_ptr ->vertexAdjacencyList ->numberOfNodes();
    
}

//Returns the neighbors for a vertex
-(CGRCircularVector<uint32_t> *)neighborsForVertex:(uint32_t)vertex;
{
    struct CGRVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    
    CGRCircularVector<uint32_t> *neighbors;
    
    if(vert ->vertexAdjacencyList == NULL){
        neighbors = new CGRCircularVector<uint32_t>(0,0);
        return neighbors;
    }
    
    @try {
        CGRAVLTreeKeys<uint32_t> neigh = vert ->vertexAdjacencyList ->keySet();
        neighbors = new CGRCircularVector<uint32_t>(neigh.size, neigh.size);
        for(uint32_t i=0; i != neigh.size; i++){
            neighbors ->add(neigh.keys[i]);
        }
        free(neigh.keys);
        return neighbors;
    }
    @catch (NSException *exception) {
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNotEnoughMemory" reason:@"No enough memory for vertex's adjacencyList" userInfo:nil];
        @throw e;
    }
    @finally {
        
    }
    
    
    return neighbors;
}

//Removes all vertices
-(void)removeAllVertices
{
    uint32_t noV = [self vertexSetSize];
    for(uint32_t i = noV-1; i != -1; i--)
    {
        [self removeVertex:i];
    }
}

-(BOOL) vertex:(uint32_t)vertex1 isNeighborOf:(uint32_t)vertex2
{
    struct CGRVertex *vert = vertices ->elementAtIndex(vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(vert ->vertexAdjacencyList == NULL){
        return NO;
    }
    return vert ->vertexAdjacencyList ->containsKey(vertex2);
}
#pragma mark -
#pragma mark Edges Basics
//Adds an edge
-(void) addEdge:(CGREdge)edge
{
    //First check if the vertices vector is big enough to hold both vertices
    //uint32_t maxVertex = (edge.vertex1 > edge.vertex2)? edge.vertex1:edge.vertex2;
    /*if(vertices ->capacity() < maxVertex){
        //Increase the vertex capacity
        
        ///////////////////////// TO DO /////////////////////////////
    }*/
    //check if the vertices exist
    CGRVertex *vertex1_ptr = NULL;
    try {
        vertex1_ptr = vertices ->elementAtIndex(edge.vertex1);
        if(!vertex1_ptr ->vertexAdjacencyList)
        {
            vertex1_ptr ->vertexAdjacencyList = new CGRAVLTree<unsigned int, _CGREdge>(edgeComparison);
        }
    } catch (CGRCircularVectorIndexException e) {
        
    }
    CGRVertex *vertex2_ptr = NULL;
    try {
        vertex2_ptr = vertices ->elementAtIndex(edge.vertex2);
        if(!vertex2_ptr -> vertexAdjacencyList)
        {
            vertex2_ptr ->vertexAdjacencyList = new CGRAVLTree<unsigned int, _CGREdge>(edgeComparison);
        }
    } catch (CGRCircularVectorIndexException e) {
        
    }
    if(vertex1_ptr ->vertexAdjacencyList ->containsKey(edge.vertex2))
    {
        //The edge already exists so we just return
        return;
    }
    /*if(vertex1_ptr == NULL){
        //Create the vertex
        vertex1_ptr = new CGRVertex(edge.vertex1);
        vertex1_ptr ->vertexAdjacencyList = new CGRAVLTree<unsigned int, _CGREdge>(edgeComparison);
        vertices ->insertAtIndex(vertex1_ptr, edge.vertex1);
        if(notifyChanges){
            uint32_t vertNotifyCount = notifyList ->count();
            for(uint32_t i=0; i != vertNotifyCount; i++){
                id <CGRGraph_Notifications> notifyObj =
                (__bridge id <CGRGraph_Notifications>) notifyList ->elementAtIndex(i);
                
                if([notifyObj respondsToSelector:@selector(vertexAdded:)]){
                    [notifyObj vertexAdded:edge.vertex1];
                }
            }
        }
    }else if(vertex1_ptr ->vertexAdjacencyList ->containsKey(edge.vertex2))
    {
        //The edge already exists so we just return
        return;
    }
    if(vertex2_ptr == NULL){
        //Create the vertex
        vertex2_ptr = new CGRVertex(edge.vertex2);
        vertex2_ptr ->vertexAdjacencyList = new CGRAVLTree<unsigned int, _CGREdge>(edgeComparison);
        vertices ->insertAtIndex(vertex1_ptr, edge.vertex2);
        if(notifyChanges){
            uint32_t vertNotifyCount = notifyList ->count();
            for(uint32_t i=0; i != vertNotifyCount; i++){
                id <CGRGraph_Notifications> notifyObj =
                (__bridge id <CGRGraph_Notifications>) notifyList ->elementAtIndex(i);
                
                if([notifyObj respondsToSelector:@selector(vertexAdded:)]){
                    [notifyObj vertexAdded:edge.vertex2];
                }
            }
        }
    }*/
    //Now create the edge
    _CGREdge *newEdge = new _CGREdge(edge.vertex1,edge.vertex2);
    vertex1_ptr ->vertexAdjacencyList ->add(edge.vertex2, newEdge);
    vertex2_ptr ->vertexAdjacencyList ->add(edge.vertex1, newEdge);
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGraph_Notifications> notifyObj =
            (__bridge id <CGRGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(edgeAdded:)]){
                [notifyObj edgeAdded:edge];
            }
        }
    }
}
//Removes an Edge
-(void)removeEdge:(CGREdge)edge
{
    //check if the vertices exist
    CGRVertex *vertex1_ptr = vertices ->elementAtIndex(edge.vertex1);
    CGRVertex *vertex2_ptr = vertices ->elementAtIndex(edge.vertex2);
    
    if(vertex1_ptr == NULL || vertex2_ptr == NULL)
        return;
    
    _CGREdge *edge_ptr = vertex1_ptr ->vertexAdjacencyList ->dataForKey(edge.vertex2);
    if(edge_ptr == NULL){
        //try the reverse..
        edge_ptr = vertex1_ptr ->vertexAdjacencyList ->dataForKey(edge.vertex1);
        if(edge_ptr == NULL){
            //the vertices aren't neighbors
            return;
        }
        vertex1_ptr ->vertexAdjacencyList ->remove(edge.vertex1);
        vertex2_ptr ->vertexAdjacencyList ->remove(edge.vertex2);
        delete edge_ptr;
        
    }else{
        vertex1_ptr ->vertexAdjacencyList ->remove(edge.vertex2);
        vertex2_ptr ->vertexAdjacencyList ->remove(edge.vertex1);
        delete edge_ptr;
    }
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGraph_Notifications> notifyObj =
            (__bridge id <CGRGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(edgeRemoved:)]){
                [notifyObj edgeRemoved:edge];
            }
        }
    }
}

-(void)removeAllVertexNeighbors:(uint32_t)vertex
{
    CGRCircularVector<uint32_t> *neighbors = [self neighborsForVertex:vertex];
    for(uint32_t i=0; i != neighbors ->count(); i++){
        [self removeEdge:makeEdge(vertex, neighbors ->elementAtIndex(i))];
    }
    delete neighbors;
    
}
#pragma mark -
#pragma mark Vertices Custom Data
-(void)addCustomData:(void *)data toVertex:(uint32_t)vertex withNumber:(uint32_t)number
{
    struct CGRVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(vert ->extraInformation == NULL){
        vert ->extraInformation = new CGRAVLTree<uint32_t, void>(edgeComparison);
    }else{
        if(vert ->extraInformation ->containsKey(number)){
            vert ->extraInformation ->remove(number);
        }
    }
    vert ->extraInformation ->add(number, data);
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGraph_Notifications> notifyObj =
            (__bridge id <CGRGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(newDataAddedToVertex:dataIdent:)]){
                [notifyObj newDataAddedToVertex:vertex dataIdent:number];
            }
        }
    }
}
-(void *)customDataForVertex:(uint32_t)vertex withNumber:(uint32_t)number
{
    struct CGRVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(vert ->extraInformation == NULL)
        return NULL;
    if (!vert ->extraInformation ->containsKey(number)) {
        return NULL;
    }
    return vert ->extraInformation ->dataForKey(number);
}
-(void *)removeCustomDataForVertex:(uint32_t)vertex withNumber:(uint32_t)number
{
    struct CGRVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(vert ->extraInformation == NULL)
        return NULL;
    if (!vert ->extraInformation ->containsKey(number)) {
        return NULL;
    }
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGraph_Notifications> notifyObj =
            (__bridge id <CGRGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(deletedDataForVertex:dataIdent:)]){
                [notifyObj deletedDataForVertex:vertex dataIdent:number];
            }
        }
    }
    return vert ->extraInformation ->remove(number);
}
#pragma mark -
#pragma mark Edges Custom Data
-(void)addCustomData:(void *)data toEdge:(CGREdge)edge withNumber:(uint32_t)number
{
    struct CGRVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(!vert ->vertexAdjacencyList)
        return;
    if(!vert ->vertexAdjacencyList ->containsKey(edge.vertex2)){
        return;
    }
    
    _CGREdge *cgrEdge = vert ->vertexAdjacencyList ->dataForKey(edge.vertex2);
    if(cgrEdge ->extraInformation == NULL)
    {
        cgrEdge ->extraInformation = new CGRAVLTree<uint32_t, void>(edgeComparison);
    }else{
        if (cgrEdge ->extraInformation ->containsKey(number)) {
            cgrEdge ->extraInformation ->remove(number);
        }
    }
    cgrEdge ->extraInformation ->add(number, data);
    
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGraph_Notifications> notifyObj =
            (__bridge id <CGRGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(newDataAddedToEdge:dataIdent:)]){
                [notifyObj newDataAddedToEdge:edge dataIdent:number];
            }
        }
    }
}
-(void *)customDataForEdge:(CGREdge)edge withNumber:(uint32_t)number
{
    struct CGRVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(!vert ->vertexAdjacencyList)
        return NULL;
    if(!vert ->vertexAdjacencyList ->containsKey(edge.vertex2)){
        return NULL;
    }
    
    _CGREdge *cgrEdge = vert ->vertexAdjacencyList ->dataForKey(edge.vertex2);
    if(cgrEdge ->extraInformation == NULL)
    {
        return NULL;
    }
    if (!cgrEdge ->extraInformation ->containsKey(number)) {
        return NULL;
    }
    return cgrEdge ->extraInformation ->dataForKey(number);
}
-(void *)removeCustomDataForEdge:(CGREdge)edge withNumber:(uint32_t)number
{
    struct CGRVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(!vert ->vertexAdjacencyList)
        return NULL;
    if(!vert ->vertexAdjacencyList ->containsKey(edge.vertex2)){
        return NULL;
    }
    
    _CGREdge *cgrEdge = vert ->vertexAdjacencyList ->dataForKey(edge.vertex2);
    if(cgrEdge ->extraInformation == NULL)
    {
        return NULL;
    }
    if (!cgrEdge ->extraInformation ->containsKey(number)) {
        return NULL;
    }
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGraph_Notifications> notifyObj =
            (__bridge id <CGRGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(deletedDataForEdge:dataIdent:)]){
                [notifyObj deletedDataForEdge:edge dataIdent:number];
            }
        }
    }
    return cgrEdge ->extraInformation ->remove(number);
}
#pragma mark -
#pragma mark Notifications
-(void)addNotifiy:(id <CGRGraph_Notifications>) newNotifyObj
{
    if(notifyList == NULL){
        notifyList = new CGRCircularVector<void *>(20);
    }
    notifyList ->add((__bridge void *)newNotifyObj);
    //[vertexNotifyList addObject:newNotifyObj];
    notifyChanges = YES;
}

-(void)removeNotify:(id <CGRGraph_Notifications>) newNotifyObj
{
    void *bridgeCast = (__bridge void *)newNotifyObj;
    //Look for the notify
    uint32_t notifyListSize = notifyList ->count();
    for(uint32_t i=0; i != notifyListSize; i++)
        if(notifyList ->elementAtIndex(i) == bridgeCast){
            notifyList ->removeAtIndex(i);
            break;
        }
    if(!notifyList ->count())
        notifyChanges = NO;
}

@end
