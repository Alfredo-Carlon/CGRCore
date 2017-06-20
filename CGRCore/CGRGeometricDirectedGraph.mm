//
//  CGRGeometricDirectedGraph.m
//  CGRCore
//
//  Created by Alfredo Cruz on 10/22/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

#import "CGRGeometricDirectedGraph.h"
#import "CGRGeometricCommon.h"
#import <OpenGL/gl.h>

@implementation CGRGeometricDirectedGraph

-(id)init
{
    if(![super init])
        return nil;
    vertices = new CGRCircularVector<CGRGeometricDirectedVertex *>();
    notifyList = NULL;
    notifyChanges = NO;
    constrainsList = NULL;
    constrainedGraph = NO;
    return self;
}
-(id)initWithVerticesCapacity:(uint32_t)verticesInitialCapacity
{
    if(![super init])
        return nil;
    vertices = new CGRCircularVector<CGRGeometricDirectedVertex *>(verticesInitialCapacity);
    constrainsList = NULL;
    notifyList = NULL;
    notifyChanges = NO;
    constrainedGraph = NO;
    return self;
}

inline CGRGeometricDirectedVertex *newGeometricDirectedVertex(NSPoint coordinates){
    CGRGeometricDirectedVertex *newVert = new CGRGeometricDirectedVertex(coordinates);
    return newVert;
}

#pragma mark -
#pragma mark Vertices Basics
//Adds a vertex
-(uint32_t)addVertex
{
    CGRGeometricDirectedVertex *nv = newGeometricDirectedVertex(NSMakePoint(0, 0));
    uint32_t ident = vertices ->add(nv);
    nv ->vertexIdent = ident;
    return ident;
}

-(uint32_t)addVertex:(NSPoint)coordinates
{
    if(constrainedGraph)
    {
        uint32_t constrainsSize = constrainsList ->count();
        for(uint32_t i=0; i != constrainsSize; i++){
            void *bridgeCast = constrainsList ->elementAtIndex(i);
            id <CGRGeometricGraph_Constrains> constrain = (__bridge id <CGRGeometricGraph_Constrains>)bridgeCast;
            if([constrain respondsToSelector:@selector(canAddVertex:)]){
                if(![constrain canAddVertex:coordinates])
                    return -1;
            }
        }
    }
    
    CGRGeometricDirectedVertex *nv = newGeometricDirectedVertex(coordinates);
    uint32_t ident = vertices ->add(nv);
    nv ->vertexIdent = ident;
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGeometricGraph_Notifications> notifyObj =
            (__bridge id <CGRGeometricGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(vertexAdded:atCoordinates:)]){
                [notifyObj vertexAdded:ident atCoordinates:NSMakePoint(0, 0)];
            }
        }
    }
    return ident;
}

-(NSPoint)coordinatesForVertex:(uint32_t)vertex
{
    
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    
    return vert ->coordinates;
}
-(void)setCoordinatesForVertex:(uint32_t)vertex coordinates:(NSPoint)cords
{
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    if(constrainedGraph)
    {
        uint32_t constrainsSize = constrainsList ->count();
        for(uint32_t i=0; i != constrainsSize; i++){
            void *bridgeCast = constrainsList ->elementAtIndex(i);
            id <CGRGeometricGraph_Constrains> constrain = (__bridge id <CGRGeometricGraph_Constrains>)bridgeCast;
            if([constrain respondsToSelector:@selector(canMoveVertex:to:)]){
                if(![constrain canMoveVertex:vertex to:cords])
                    return;
            }
        }
    }
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    
    vert ->coordinates = cords;
}


-(uint32_t)vertexSetSize
{
    return vertices ->count();
}

//Returns the neighbors for a vertex
-(CGRCircularVector<uint32_t> *)neighborsForVertex:(uint32_t)vertex
{
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    
    
    CGRCircularVector<uint32_t> *neighbors = NULL;
    
    if(vert ->inAdjacencyList == NULL &&
       vert ->outAdjacencyList == NULL){
        neighbors = new CGRCircularVector<uint32_t>(0,0);
        return neighbors;
    }
    
    @try {
        uint32_t size = (vert ->inAdjacencyList != NULL)? vert ->inAdjacencyList ->numberOfNodes():0;
        size += (vert ->outAdjacencyList != NULL)? vert ->outAdjacencyList ->numberOfNodes():0;
        neighbors = new CGRCircularVector<uint32_t>(size, size);
        if(vert ->inAdjacencyList != NULL){
            CGRAVLTreeKeys<uint32_t> neigh = vert ->inAdjacencyList ->keySet();
            for(uint32_t i=0; i != neigh.size; i++){
                neighbors ->add(neigh.keys[i]);
            }
            free(neigh.keys);
        }
        if(vert ->outAdjacencyList != NULL){
            CGRAVLTreeKeys<uint32_t> neigh = vert ->outAdjacencyList ->keySet();
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
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    
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
    
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
    
    
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
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
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
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
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
    //Bad Argument check
    if(vertex1 < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex1);
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
    //Bad Argument check
    if(vertex1 < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex1);
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
    //Bad Argument check
    if(vertex1 < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex1);
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
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
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
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
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
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
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
#pragma mark Vertices operations (polar)
-(void) setPolarCenter:(NSPoint)center
{
    polarCenter = center;
}
//The direction of the polar plane
-(void) setPolarDirection:(NSPoint)base
{
    NSPoint dif = __diffVector(base, polarCenter);
    //NSPoint ref = NSMakePoint(polarCenter.x + 1, polarCenter.y);
    referenceAngle = acos((dif.x)/(__norm(dif)));
    polarDirection = base;
}
//Add a new vertex 'with' polar coordinates
-(uint32_t) addVertexPolar:(double)radius angle:(double)angle
{
    double refAngle = referenceAngle + angle;
    NSPoint recCoords = NSMakePoint(polarCenter.x + radius*cos(refAngle), polarCenter.y + radius*sin(refAngle));
    return [self addVertex:recCoords];
}
//Returns the polar coordinates of the vertex
-(struct polarCoord)polarCoordinatesForVertex:(uint32_t)vertex
{
    NSPoint recCords = [self coordinatesForVertex:vertex];
    recCords.x -= polarCenter.x;
    recCords.y -= polarCenter.y;
    struct polarCoord polarCords;
    if(recCords.x == 0)
        polarCords.angle = PI/2;
    else
        polarCords.angle = atan(recCords.y/recCords.x);
    polarCords.angle = referenceAngle + polarCords.angle;
    polarCords.radius = __norm(recCords);
    return polarCords;
}
//Sets the coordinates of the vertex
-(void)setCoordinatesForVertexPolar:(uint32_t)vertex coordinates:(struct polarCoord)cords
{
    //NSPoint recCoords = NSMakePoint(cords.radius*cos(cords.angle), cords.radius*sin(cords.angle));
    double refAngle = referenceAngle + cords.angle;
    NSPoint recCoords = NSMakePoint(polarCenter.x + cords.radius*cos(refAngle), polarCenter.y + cords.radius*sin(refAngle));
    [self setCoordinatesForVertex:vertex coordinates:recCoords];
}
#pragma mark -
#pragma mark EdgeBasics

//Adds an edge
-(void) addEdge:(CGREdge)edge
{
    //Bad Argument check
    uint32_t verticesCount = vertices ->count();
    if(edge.vertex1 < verticesCount && edge.vertex2 < verticesCount){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    //Check if the vertices are not already neightbors
    CGRGeometricDirectedVertex *vertex1 = vertices ->elementAtIndex(edge.vertex1);
    CGRGeometricDirectedVertex *vertex2 = vertices ->elementAtIndex(edge.vertex2);
    if(vertex1 == NULL || vertex2 == NULL || vertex1 == vertex2)
        return; //One of the vertices do not exist or its the same vertex
    
    if(vertex1 ->outAdjacencyList == NULL){
        vertex1 ->outAdjacencyList = new CGRAVLTree<uint32_t, _CGRGeometricDirectedEdge >(edgeComparison);
    }else if(vertex1 ->outAdjacencyList ->containsKey(vertex2 ->vertexIdent))
        return; //the vertices are already neighbors
    //Create the new edge
    if(vertex2 ->inAdjacencyList == NULL){
        vertex2 ->inAdjacencyList = new CGRAVLTree<uint32_t, _CGRGeometricDirectedEdge >(edgeComparison);
    }
    
    _CGRGeometricDirectedEdge *newEdge = new _CGRGeometricDirectedEdge(edge.vertex1, edge.vertex2);
    vertex1 ->outAdjacencyList ->add(edge.vertex2, newEdge);
    vertex2 ->inAdjacencyList ->add(edge.vertex1, newEdge);
    if(constrainedGraph)
    {
        uint32_t constrainsSize = constrainsList ->count();
        for(uint32_t i=0; i != constrainsSize; i++){
            void *bridgeCast = constrainsList ->elementAtIndex(i);
            id <CGRGeometricGraph_Constrains> constrain = (__bridge id <CGRGeometricGraph_Constrains>)bridgeCast;
            if([constrain respondsToSelector:@selector(canAddEdge:)]){
                if(![constrain canAddEdge:edge])
                    return;
            }
        }
    }
    
}
//Removes a vertex
-(void)removeVertex:(uint32_t)vertex
{
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    if(constrainedGraph)
    {
        uint32_t constrainsSize = constrainsList ->count();
        for(uint32_t i=0; i != constrainsSize; i++){
            void *bridgeCast = constrainsList ->elementAtIndex(i);
            id <CGRGeometricGraph_Constrains> constrain = (__bridge id <CGRGeometricGraph_Constrains>)bridgeCast;
            if([constrain respondsToSelector:@selector(canRemoveVertex:)]){
                if(![constrain canRemoveVertex:vertex])
                    return;
            }
        }
    }
    
    
    [self removeAllVertexNeighbors:vertex];
    
    ////////TEMPORAL REMOVAL!!!!!!!!!!
    ///////    // Could be replaced for a 'registered pointer' version for tracking propourses!!!!!!!!!
    
    CGRGeometricDirectedVertex *v = vertices ->removeAtIndex(vertex);
    free(v);
    uint32_t vsize = vertices ->count();
    for(uint32_t i=vertex; i != vsize; i++){
        vertices ->elementAtIndex(i)->vertexIdent--;
    }
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGeometricGraph_Notifications> notifyObj =
            (__bridge id <CGRGeometricGraph_Notifications>) notifyList ->elementAtIndex(i);
            
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
    //Bad Argument check
    uint32_t verticesCount = vertices ->count();
    if(edge.vertex1 < verticesCount && edge.vertex2 < verticesCount){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}

    
    CGRGeometricDirectedVertex *vertex1_ptr = vertices ->elementAtIndex(edge.vertex1);
    CGRGeometricDirectedVertex *vertex2_ptr = vertices ->elementAtIndex(edge.vertex2);
    
    
    if(vertex1_ptr ->outAdjacencyList == NULL || vertex2_ptr ->inAdjacencyList == NULL)
        return;
    
    _CGRGeometricDirectedEdge *edge_ptr = vertex1_ptr ->outAdjacencyList ->dataForKey(edge.vertex2);
    if(edge_ptr == NULL){
        return;
    }else{
        if(constrainedGraph)
        {
            uint32_t constrainsSize = constrainsList ->count();
            for(uint32_t i=0; i != constrainsSize; i++){
                void *bridgeCast = constrainsList ->elementAtIndex(i);
                id <CGRGeometricGraph_Constrains> constrain = (__bridge id <CGRGeometricGraph_Constrains>)bridgeCast;
                if([constrain respondsToSelector:@selector(canRemoveEdge:)]){
                    if(![constrain canRemoveEdge:edge])
                        return;
                }
            }
        }
        
        vertex1_ptr ->outAdjacencyList ->remove(edge.vertex2);
        vertex2_ptr ->inAdjacencyList ->remove(edge.vertex1);
        delete edge_ptr;
    }
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGeometricGraph_Notifications> notifyObj =
            (__bridge id <CGRGeometricGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(edgeRemoved:)]){
                [notifyObj edgeRemoved:edge];
            }
        }
    }

}
#pragma mark -
#pragma mark Basic Operations and Queries

-(enum CGRTurn) segmentFrom:(unsigned int)p0 turnsLeftRightOn:(unsigned int)p1 to:(unsigned int)p2
{
    return __leftright([self coordinatesForVertex:p0], [self coordinatesForVertex:p1], [self coordinatesForVertex:p2]);
}
-(enum CGRTurn) segmentFrom:(unsigned int)p0 turnsLeftRightOnPoint:(NSPoint)p1 to:(unsigned int)p2
{
    return __leftright([self coordinatesForVertex:p0], p1, [self coordinatesForVertex:p2]);
}
-(enum CGRTurn) segmentFromPoint:(NSPoint)p0 turnsLeftRightOn:(NSPoint)p1 to:(NSPoint)p2
{
    return __leftright(p0, p1, p2);
    
}

-(BOOL)segmentFrom:(unsigned int)v0 to:(unsigned int)v1 intersectsSegmentFrom:(unsigned int)v2 to:(unsigned int)v3
{
    CGREdge edge1 = makeEdge(v0, v1);
    CGREdge edge2 = makeEdge(v2, v3);
    if([self segmentFrom:edge1.vertex1 turnsLeftRightOn:edge1.vertex2 to:edge2.vertex1] !=
       [self segmentFrom:edge1.vertex1 turnsLeftRightOn:edge1.vertex2 to:edge2.vertex2]){
        enum CGRTurn turn1 = [self segmentFrom:edge1.vertex1 turnsLeftRightOn:edge2.vertex1 to:edge2.vertex2];
        if(turn1 == CGRCollinear){
            return NO;
        }
        enum CGRTurn turn2 = [self segmentFrom:edge1.vertex2 turnsLeftRightOn:edge2.vertex1 to:edge2.vertex2];
        if(turn2 == CGRCollinear){
            return NO;
        }
        if (turn1 == turn2) {
            return NO;
        }
        turn1 = [self segmentFrom:edge2.vertex1 turnsLeftRightOn:edge1.vertex1 to:edge1.vertex2];
        if(turn1 == CGRCollinear){
            return NO;
        }
        turn2 = [self segmentFrom:edge2.vertex2 turnsLeftRightOn:edge1.vertex1 to:edge1.vertex2];
        if(turn2 == CGRCollinear){
            return NO;
        }
        if (turn1 == turn2) {
            return NO;
        }
        return YES;
    }
    return NO;
}
-(BOOL)segmentFromPoint:(NSPoint)p0 to:(NSPoint)p1 intersectsSegmentFrom:(NSPoint)p2 to:(NSPoint)p3
{
    if([self segmentFromPoint:p0 turnsLeftRightOn:p1 to:p2] !=
       [self segmentFromPoint:p0 turnsLeftRightOn:p1 to:p3]){
        enum CGRTurn turn1 = [self segmentFromPoint:p0 turnsLeftRightOn:p2 to:p3];
        if(turn1 == CGRCollinear){
            return NO;
        }
        enum CGRTurn turn2 = [self segmentFromPoint:p1 turnsLeftRightOn:p2 to:p3];
        if(turn2 == CGRCollinear){
            return NO;
        }
        if (turn1 == turn2) {
            return NO;
        }
        turn1 = [self segmentFromPoint:p2 turnsLeftRightOn:p0 to:p1];
        if(turn1 == CGRCollinear){
            return NO;
        }
        turn2 = [self segmentFromPoint:p3 turnsLeftRightOn:p0 to:p1];
        if(turn2 == CGRCollinear){
            return NO;
        }
        if (turn1 == turn2) {
            return NO;
        }
        return YES;
    }
    return NO;
}
-(BOOL)edge:(CGREdge)edge1 intersectsEdge:(CGREdge)edge2
{
    if([self vertex:edge1.vertex1 isNeighborOf:edge1.vertex2] && [self vertex:edge2.vertex1 isNeighborOf:edge2.vertex1]){
        if([self segmentFrom:edge1.vertex1 turnsLeftRightOn:edge1.vertex2 to:edge2.vertex1] !=
           [self segmentFrom:edge1.vertex1 turnsLeftRightOn:edge1.vertex2 to:edge2.vertex2]){
            enum CGRTurn turn1 = [self segmentFrom:edge1.vertex1 turnsLeftRightOn:edge2.vertex1 to:edge2.vertex2];
            if(turn1 == CGRCollinear){
                return NO;
            }
            enum CGRTurn turn2 = [self segmentFrom:edge1.vertex2 turnsLeftRightOn:edge2.vertex1 to:edge2.vertex2];
            if(turn2 == CGRCollinear){
                return NO;
            }
            if (turn1 == turn2) {
                return NO;
            }
            turn1 = [self segmentFrom:edge2.vertex1 turnsLeftRightOn:edge1.vertex1 to:edge1.vertex2];
            if(turn1 == CGRCollinear){
                return NO;
            }
            turn2 = [self segmentFrom:edge2.vertex2 turnsLeftRightOn:edge1.vertex1 to:edge1.vertex2];
            if(turn2 == CGRCollinear){
                return NO;
            }
            if (turn1 == turn2) {
                return NO;
            }
            return YES;
        }
        return NO;
    }
    return NO;
}
-(BOOL)segmentFromPoint:(NSPoint)p0 to:(NSPoint)p1 intersectsEdge:(CGREdge)edge
{
    unsigned int numPoints = [self vertexSetSize];
    
    if(!(edge.vertex1 < numPoints && edge.vertex2 < numPoints))
        return NO;
    NSPoint p2, p3;
    p2 = [self coordinatesForVertex:edge.vertex1];
    p3 = [self coordinatesForVertex:edge.vertex2];
    return [self segmentFromPoint:p0 to:p1 intersectsSegmentFrom:p2 to:p3];
}
-(NSPoint)intersectionPointOfSegmentFromPoint:(NSPoint)p0 to:(NSPoint)p1 andSegmentFrom:(NSPoint)p2 to:(NSPoint)p3
{
    NSPoint intersection;
    if (![self segmentFromPoint:p0 to:p1 intersectsSegmentFrom:p2 to:p3]) {
        intersection.x = INFINITY;
        intersection.y = INFINITY;
        return intersection;
    }
    return __intersectionPoint(p0, p1, p2, p3);
}
-(NSPoint)intersectionPointOfSegmentFromPoint:(NSPoint)p0 to:(NSPoint)p1 withEdge:(CGREdge)edge
{
    NSPoint intersection = {NAN,NAN};
    
    if(![self segmentFromPoint:p0 to:p1 intersectsEdge:edge]){
        return intersection;
    }
    return __intersectionPoint(p0, p1, [self coordinatesForVertex:edge.vertex1],
                               [self coordinatesForVertex:edge.vertex2]);
}
-(NSPoint)intersectionPointOfEdge:(CGREdge)edge1 withEdge:(CGREdge)edge2
{
    NSPoint intersection = {NAN,NAN};
    if(![self edge:edge1 intersectsEdge:edge2]){
        return intersection;
    }
    return __intersectionPoint([self coordinatesForVertex:edge1.vertex1],
                               [self coordinatesForVertex:edge1.vertex2],
                               [self coordinatesForVertex:edge2.vertex1],
                               [self coordinatesForVertex:edge2.vertex2]);
}
-(double)angleBetweenVertex:(uint32_t)v1 andVertex2:(uint32_t)v2 withReference:(uint32_t)ref
{
    NSPoint v1C = [self coordinatesForVertex:v1];
    NSPoint v2C = [self coordinatesForVertex:v2];
    NSPoint refC = [self coordinatesForVertex:ref];
    return __angleBetweenP1P2WithRef(v1C, v2C, refC);
}
-(double)angleBetweenVertex:(uint32_t)v1 andVertex2:(uint32_t)v2 withReferencePoint:(NSPoint)ref
{
    
    NSPoint v1C = [self coordinatesForVertex:v1];
    NSPoint v2C = [self coordinatesForVertex:v2];
    return __angleBetweenP1P2WithRef(v1C, v2C, ref);
}

-(double)distanceFromPoint:(NSPoint)p1 toVertex:(uint32_t)v1
{
    return __norm(__diffVector([self coordinatesForVertex:v1], p1));
}
-(double)distanceFromPoint:(NSPoint)p1 to:(NSPoint)p2;
{
    return __norm(__diffVector(p1, p2));
}
-(double)lengthOfEdge:(CGREdge)edge
{
    return [self distanceFromPoint:[self coordinatesForVertex:edge.vertex1]
                                to:[self coordinatesForVertex:edge.vertex2]];
}
#pragma mark -
#pragma mark Edges Custom Data
-(void)addCustomData:(void *)data toEdge:(CGREdge)edge withNumber:(uint32_t)number
{
    //Bad Argument check
    if(edge.vertex1 < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    
    if(vert ->outAdjacencyList == NULL){
        return;
    }
    
    if(!vert ->outAdjacencyList ->containsKey(edge.vertex2)){
        return;
    }
    
    //Check if we can add the data
    if(constrainedGraph)
    {
        uint32_t constrainsSize = constrainsList ->count();
        for(uint32_t i=0; i != constrainsSize; i++){
            void *bridgeCast = constrainsList ->elementAtIndex(i);
            id <CGRGeometricGraph_Constrains> constrain = (__bridge id <CGRGeometricGraph_Constrains>)bridgeCast;
            if([constrain respondsToSelector:@selector(canAddData:withId:toEdge:)]){
                if(![constrain canAddData:data withId:number toEdge:edge])
                    return;
            }
        }
    }
    
    
    _CGRGeometricDirectedEdge *cgrEdge = vert ->outAdjacencyList ->dataForKey(edge.vertex2);
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
            id <CGRGeometricGraph_Notifications> notifyObj =
            (__bridge id <CGRGeometricGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(newDataAddedToEdge:dataIdent:)]){
                [notifyObj newDataAddedToEdge:edge dataIdent:number];
            }
        }
    }
    
}
-(void *)customDataForEdge:(CGREdge)edge withNumber:(uint32_t)number
{
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(edge.vertex1);
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
    
    _CGRGeometricDirectedEdge *cgrEdge = vert ->outAdjacencyList ->dataForKey(edge.vertex2);
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
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    if(vert == NULL){
        NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;
    }
    if(!vert ->outAdjacencyList)
        return NULL;
    if(!vert ->outAdjacencyList ->containsKey(edge.vertex2)){
        return NULL;
    }
    
    _CGRGeometricDirectedEdge *cgrEdge = vert ->outAdjacencyList ->dataForKey(edge.vertex2);
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
            id <CGRGeometricGraph_Notifications> notifyObj =
            (__bridge id <CGRGeometricGraph_Notifications>) notifyList ->elementAtIndex(i);
            
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
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
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
            id <CGRGeometricGraph_Notifications> notifyObj =
            (__bridge id <CGRGeometricGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(newDataAddedToVertex:dataIdent:)]){
                [notifyObj newDataAddedToVertex:vertex dataIdent:number];
            }
        }
    }
    
}
-(void *)customDataForVertex:(uint32_t)vertex withNumber:(uint32_t)number
{
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
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
    struct CGRGeometricDirectedVertex *vert = vertices ->elementAtIndex(vertex);
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
            id <CGRGeometricGraph_Notifications> notifyObj =
            (__bridge id <CGRGeometricGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(deletedDataForVertex:dataIdent:)]){
                [notifyObj deletedDataForVertex:vertex dataIdent:number];
            }
        }
    }
    return vert ->extraInformation ->remove(number);
}
#pragma mark -
#pragma mark Notifications
//Just to compile
//Just to Compile
-(void)addNotifiy:(id<CGRGraph_Notifications>)newNotifyObj{}
-(void)removeNotify:(id<CGRGraph_Notifications>)newNotifyObj{}
-(void)addGeometricNotifiy:(id <CGRGeometricGraph_Notifications>) newNotifyObj
{
    if(notifyList == NULL){
        notifyList = new CGRCircularVector<void *>(20);
    }
    notifyList ->add((__bridge void *)newNotifyObj);
    //[vertexNotifyList addObject:newNotifyObj];
    notifyChanges = YES;
}

-(void)removeGeometricNotify:(id <CGRGeometricGraph_Notifications>) newNotifyObj
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

