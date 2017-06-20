//
//  CGRDirectedGraph.m
//  CGRCore
//
//  Created by Alfredo Cruz on 10/20/14.
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

#import "CGRDirectedGraph.h"


@implementation CGRDirectedGraph

-(id)init
{
    if(![super init])
        return nil;
    vertices = new CGRCircularVector<CGRDirectedVertex *>();
    numberOfVertices = 0;
    notifyList = NULL;
    notifyChanges = NO;

    return self;
}
-(id)initWithVerticesCapacity:(uint32_t)verticesInitialCapacity
{
    if(![super init])
        return nil;
    vertices = new CGRCircularVector<CGRDirectedVertex *>(verticesInitialCapacity);
    numberOfVertices = 0;
    notifyList = NULL;
    notifyChanges = NO;

    return self;
}

#pragma mark -
#pragma mark Vertices Basics
//Adds a vertex
-(uint32_t)addVertex
{
    CGRDirectedVertex *nv = new CGRDirectedVertex();
    uint32_t ident = vertices ->add(nv);
    nv ->vertexIdent = ident;
    numberOfVertices++;
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

//Returns the neighbors for a vertex
-(CGRCircularVector<uint32_t> *)neighborsForVertex:(uint32_t)vertex
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    
    CGRCircularVector<uint32_t> *neighbors = NULL;
    
    if(vert ->inAdjacencyList == NULL &&
       vert ->outAdjacencyList == NULL){
        neighbors = new CGRCircularVector<uint32_t>(0,0);
        return neighbors;
    }
    
    @try {
        if(vert ->inAdjacencyList != NULL){
            CGRAVLTreeKeys<uint32_t> neigh = vert ->inAdjacencyList ->keySet();
            neighbors = new CGRCircularVector<uint32_t>(neigh.size, neigh.size);
            for(uint32_t i=0; i != neigh.size; i++){
                neighbors ->add(neigh.keys[i]);
            }
            free(neigh.keys);
        }
        if(vert ->outAdjacencyList != NULL){
            CGRAVLTreeKeys<uint32_t> neigh = vert ->outAdjacencyList ->keySet();
            if(neighbors == NULL){
                neighbors = new CGRCircularVector<uint32_t>(neigh.size, neigh.size);
            }
            for(uint32_t i=0; i != neigh.size; i++){
                neighbors ->add(neigh.keys[i]);
            }
            free(neigh.keys);
        }
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

-(CGRCircularVector<uint32_t> *)inNeighborsForVertex:(uint32_t)vertex
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    
    CGRCircularVector<uint32_t> *neighbors = NULL;
    
    if(vert ->inAdjacencyList == NULL){
        neighbors = new CGRCircularVector<uint32_t>(0,0);
        return neighbors;
    }
    
    @try {
        CGRAVLTreeKeys<uint32_t> neigh = vert ->inAdjacencyList ->keySet();
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
    
}

-(CGRCircularVector<uint32_t> *)outNeighborsForVertex:(uint32_t)vertex
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    
    CGRCircularVector<uint32_t> *neighbors = NULL;
    
    if(vert ->outAdjacencyList == NULL){
        neighbors = new CGRCircularVector<uint32_t>(0,0);
        return neighbors;
    }
    
    @try {
        CGRAVLTreeKeys<uint32_t> neigh = vert ->outAdjacencyList ->keySet();
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
}
-(uint32_t)inDegreeForVertex:(uint32_t)vertex
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    
    if(vert ->inAdjacencyList == NULL){
        return 0;
    }
    
    @try {
        CGRAVLTreeKeys<uint32_t> neigh = vert ->inAdjacencyList ->keySet();
        free(neigh.keys);
        return neigh.size;
    }
    @catch (NSException *exception) {
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNotEnoughMemory" reason:@"No enough memory for vertex's adjacencyList" userInfo:nil];
        @throw e;
    }
    @finally {
        
    }
}
-(uint32_t)outDegreeForVertex:(uint32_t)vertex
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    
    if(vert ->outAdjacencyList == NULL){
        return 0;
    }
    
    @try {
        CGRAVLTreeKeys<uint32_t> neigh = vert ->outAdjacencyList ->keySet();
        free(neigh.keys);
        return neigh.size;
    }
    @catch (NSException *exception) {
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNotEnoughMemory" reason:@"No enough memory for vertex's adjacencyList" userInfo:nil];
        @throw e;
    }
    @finally {
        
    }
}
-(BOOL) vertex:(uint32_t)vertex1 isNeighborOf:(uint32_t)vertex2
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(vert ->inAdjacencyList != NULL){
        if(vert ->inAdjacencyList ->containsKey(vertex2))
            return YES;
    }
    if (vert ->outAdjacencyList != NULL) {
        return vert ->outAdjacencyList ->containsKey(vertex2);
    }
    return NO;
    
}

-(BOOL) vertex:(uint32_t)vertex1 isInNeighborOf:(uint32_t)vertex2
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if (vert ->outAdjacencyList != NULL) {
        return vert ->outAdjacencyList ->containsKey(vertex2);
    }
    return NO;
}

-(BOOL) vertex:(uint32_t)vertex1 isOutNeighborOf:(uint32_t)vertex2
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(vert ->inAdjacencyList != NULL){
        if(vert ->inAdjacencyList ->containsKey(vertex2))
            return YES;
    }
    return NO;
}

-(uint32_t)vertexDegree:(uint32_t)vertex
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    uint32_t degree = 0;
    if(vert ->inAdjacencyList != NULL){
        degree += vert ->inAdjacencyList ->numberOfNodes();
    }
    if(vert ->outAdjacencyList != NULL){
        degree += vert ->outAdjacencyList ->numberOfNodes();
    }
    return degree;
}

-(uint32_t)vertexInDegree:(uint32_t)vertex
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(vert ->inAdjacencyList != NULL){
        return vert ->inAdjacencyList ->numberOfNodes();
    }
    return 0;
}

-(uint32_t)vertexOutDegree:(uint32_t)vertex
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(vert ->outAdjacencyList != NULL){
        return vert ->outAdjacencyList ->numberOfNodes();
    }
    return 0;
}
-(void)removeAllVertices
{
    uint32_t noV = [self vertexSetSize];
    for(uint32_t i = noV-1; i != -1; i--)
    {
        [self removeVertex:i];
    }
}
#pragma mark -
#pragma mark EdgeBasics

//Adds an edge
-(void) addEdge:(CGREdge)edge
{
    //Check if the vertices are not already neightbors
    CGRDirectedVertex *vertex1 = vertices ->elementAtIndex(edge.vertex1);
    CGRDirectedVertex *vertex2 = vertices ->elementAtIndex(edge.vertex2);
    if(vertex1 == NULL || vertex2 == NULL || vertex1 == vertex2)
        return; //One of the vertices do not exist or its the same vertex
    
    if(vertex1 ->outAdjacencyList == NULL){
        vertex1 ->outAdjacencyList = new CGRAVLTree<uint32_t, _CGRDirectedEdge >(edgeComparison);
    }else if(vertex1 ->outAdjacencyList ->containsKey(vertex2 ->vertexIdent))
        return; //the vertices are already neighbors
    //Create the new edge
    if(vertex2 ->inAdjacencyList == NULL){
        vertex2 ->inAdjacencyList = new CGRAVLTree<uint32_t, _CGRDirectedEdge >(edgeComparison);
    }
    
    _CGRDirectedEdge *newEdge = new _CGRDirectedEdge(edge.vertex1, edge.vertex2);
    vertex1 ->outAdjacencyList ->add(edge.vertex2, newEdge);
    vertex2 ->inAdjacencyList ->add(edge.vertex1, newEdge);
    //vertex1 ->vertexDegree += 1;
    //vertex2 ->vertexDegree += 1;
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
//Removes a vertex
-(void)removeVertex:(uint32_t)vertex
{
    [self removeAllVertexNeighbors:vertex];
    
    ////////TEMPORAL REMOVAL!!!!!!!!!!
    ///////    // Could be replaced for a 'registered pointer' version for tracking propourses!!!!!!!!!
    
    CGRDirectedVertex *v = vertices ->removeAtIndex(vertex);
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
-(void)removeAllVertexNeighbors:(uint32_t)vertex
{
    CGRCircularVector<uint32_t> *neighbors = [self neighborsForVertex:vertex];
    for(uint32_t i=0; i != neighbors ->count(); i++){
        [self removeEdge:makeEdge(vertex, neighbors ->elementAtIndex(i))];
        [self removeEdge:makeEdge(neighbors ->elementAtIndex(i),vertex)];
    }
    delete neighbors;
}
-(void)removeAllInNeighborsForVertex:(uint32_t)vertex
{
    CGRCircularVector<uint32_t> *neighbors = [self inNeighborsForVertex:vertex];
    for(uint32_t i=0; i != neighbors ->count(); i++){
        [self removeEdge:makeEdge(neighbors ->elementAtIndex(i), vertex)];
    }
    delete neighbors;
}
-(void)removeAllOutNeighborsForVertex:(uint32_t)vertex
{
    CGRCircularVector<uint32_t> *neighbors = [self outNeighborsForVertex:vertex];
    for(uint32_t i=0; i != neighbors ->count(); i++){
        [self removeEdge:makeEdge(vertex,neighbors ->elementAtIndex(i))];
    }
    delete neighbors;
}
//Removes an Edge
-(void)removeEdge:(CGREdge)edge
{
    CGRDirectedVertex *vertex1_ptr = vertices ->elementAtIndex(edge.vertex1);
    CGRDirectedVertex *vertex2_ptr = vertices ->elementAtIndex(edge.vertex2);
    
    if(vertex1_ptr == NULL || vertex2_ptr == NULL)
        return;
    if(vertex1_ptr ->outAdjacencyList == NULL || vertex2_ptr ->inAdjacencyList == NULL)
        return;
    
    _CGRDirectedEdge *edge_ptr = vertex1_ptr ->outAdjacencyList ->dataForKey(edge.vertex2);
    if(edge_ptr == NULL){
        return;
    }else{
        vertex1_ptr ->outAdjacencyList ->remove(edge.vertex2);
        vertex2_ptr ->inAdjacencyList ->remove(edge.vertex1);
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
#pragma mark -
#pragma mark Basic Operations and Queries

#pragma mark -
#pragma mark Edges Custom Data
-(void)addCustomData:(void *)data toEdge:(CGREdge)edge withNumber:(uint32_t)number
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(vert ->outAdjacencyList == NULL){
        return;
    }
    
    if(!vert ->outAdjacencyList ->containsKey(edge.vertex2)){
        return;
    }
    
    _CGRDirectedEdge *cgrEdge = vert ->outAdjacencyList ->dataForKey(edge.vertex2);
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
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if (vert ->outAdjacencyList == NULL) {
        return NULL;
    }
    if(!vert ->outAdjacencyList ->containsKey(edge.vertex2)){
        return NULL;
    }
    
    _CGRDirectedEdge *cgrEdge = vert ->outAdjacencyList ->dataForKey(edge.vertex2);
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
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if (vert ->outAdjacencyList == NULL) {
        return NULL;
    }
    if(!vert ->outAdjacencyList ->containsKey(edge.vertex2)){
        return NULL;
    }
    
    _CGRDirectedEdge *cgrEdge = vert ->outAdjacencyList ->dataForKey(edge.vertex2);
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
#pragma mark Vertices Custom Data
-(void)addCustomData:(void *)data toVertex:(uint32_t)vertex withNumber:(uint32_t)number
{
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
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
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
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
    struct CGRDirectedVertex *vert = vertices ->elementAtIndex(vertex);
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
#pragma mark Notifications
//Just to Compile
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
