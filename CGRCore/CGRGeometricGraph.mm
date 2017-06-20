//
//  CGRGeometricGraph.m
//  CGRCore
//
//  Created by Alfredo Cruz on 11/12/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#import "CGRGeometricGraph.h"
#import "CGRGeometricCommon.h"
#import <OpenGL/gl.h>

@implementation CGRGeometricGraph

-(id)init
{
    if(![super init])
        return nil;
    vertices = new CGRCircularVector<CGRGeometricVertex *>();
    numberOfVertices = 0;
    
    constrainsList = NULL;
    notifyList = NULL;
    notifyChanges = NO;
    constrainedGraph = NO;
    return self;
}
-(id)initWithVerticesCapacity:(uint32_t)verticesInitialCapacity
{
    if(![super init])
        return nil;
    vertices = new CGRCircularVector<CGRGeometricVertex *>(verticesInitialCapacity);
    numberOfVertices = 0;
    
    constrainsList = NULL;
    notifyList = NULL;
    notifyChanges = NO;
    constrainedGraph = NO;
    polarCenter = NSMakePoint(0, 0);
    polarDirection = NSMakePoint(1, 0);
    return self;
}

inline CGRGeometricVertex *newGeometricVertex(NSPoint coordinates){
    CGRGeometricVertex *newVert = new CGRGeometricVertex(coordinates);
    return newVert;
}

#pragma mark -
#pragma mark Vertices Basics
//Adds a vertex
-(uint32_t)addVertex
{
    CGRGeometricVertex *nv = newGeometricVertex(NSMakePoint(0, 0));
    uint32_t ident = vertices ->add(nv);
    nv ->vertexIdent = ident;
    numberOfVertices++;
    
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
    
    CGRGeometricVertex *nv = newGeometricVertex(coordinates);
    uint32_t ident = vertices ->add(nv);
    nv ->vertexIdent = ident;
    numberOfVertices++;
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGeometricGraph_Notifications> notifyObj =
            (__bridge id <CGRGeometricGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(vertexAdded:atCoordinates:)]){
                [notifyObj vertexAdded:ident atCoordinates:coordinates];
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
    
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(vertex);
    return vert ->coordinates;
}
-(void)setCoordinatesForVertex:(uint32_t)vertex coordinates:(NSPoint)cords
{
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(vertex);
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
    vert ->coordinates = cords;
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGeometricGraph_Notifications> notifyObj =
            (__bridge id <CGRGeometricGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(coordinatesChangedForVertex:coordinates:)]){
                [notifyObj coordinatesChangedForVertex:vertex coordinates:cords];
            }
        }
    }
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
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(vertex);
    
    CGRCircularVector<uint32_t> *neighbors;
    
    if(vert ->adjacencyList == NULL){
        neighbors = new CGRCircularVector<uint32_t>(0,0);
        return neighbors;
    }
    
    @try {
        CGRAVLTreeKeys<uint32_t> neigh = vert ->adjacencyList ->keySet();
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


-(BOOL) vertex:(uint32_t)vertex1 isNeighborOf:(uint32_t)vertex2
{
    //Bad Argument check
    if(vertex1 < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(vertex1);
    
    if(vert ->adjacencyList == NULL){
        return NO;
    }
    return vert ->adjacencyList ->containsKey(vertex2);
    
}
-(uint32_t)vertexDegree:(uint32_t)vertex
{
    
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(vertex);
    
    if(vert ->adjacencyList == NULL)
        return 0;
    return vert ->adjacencyList ->numberOfNodes();
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
//The center of the polar plane
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
    CGRGeometricVertex *vertex1 = vertices ->elementAtIndex(edge.vertex1);
    CGRGeometricVertex *vertex2 = vertices ->elementAtIndex(edge.vertex2);
    
    if(vertex1 ->adjacencyList == NULL){
        vertex1 ->adjacencyList = new CGRAVLTree<uint32_t, _CGRGeometricEdge >(edgeComparison);
    }else if(vertex1 ->adjacencyList ->containsKey(vertex2 ->vertexIdent))
        return; //the vertices are already neighbors
    
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
    
    //Create the new edge
    if(vertex2 ->adjacencyList == NULL){
        vertex2 ->adjacencyList = new CGRAVLTree<uint32_t, _CGRGeometricEdge >(edgeComparison);
    }
    
    _CGRGeometricEdge *newEdge = new _CGRGeometricEdge(edge.vertex1, edge.vertex2);
    vertex1 ->adjacencyList ->add(edge.vertex2, newEdge);
    vertex2 ->adjacencyList ->add(edge.vertex1, newEdge);
    vertex1 ->vertexDegree += 1;
    vertex2 ->vertexDegree += 1;
    
    if(notifyChanges){
        uint32_t vertNotifyCount = notifyList ->count();
        for(uint32_t i=0; i != vertNotifyCount; i++){
            id <CGRGeometricGraph_Notifications> notifyObj =
            (__bridge id <CGRGeometricGraph_Notifications>) notifyList ->elementAtIndex(i);
            
            if([notifyObj respondsToSelector:@selector(edgeAdded:)]){
                [notifyObj edgeAdded:edge];
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
    
    CGRCircularVector<uint32_t> *neighbors = [self neighborsForVertex:vertex];
    for(uint32_t i=0; i != neighbors ->count(); i++){
        [self removeEdge:makeEdge(vertex, neighbors ->elementAtIndex(i))];
    }
    delete neighbors;
    
    ////////TEMPORAL REMOVAL!!!!!!!!!!
///////    // Could be replaced for a 'registered pointer' version for tracking propourses!!!!!!!!!
    
    CGRGeometricVertex *v = vertices ->removeAtIndex(vertex);
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
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    CGRCircularVector<uint32_t> *neighbors = [self neighborsForVertex:vertex];
    for(uint32_t i=0; i != neighbors ->count(); i++){
        [self removeEdge:makeEdge(vertex, neighbors ->elementAtIndex(i))];
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
    
    CGRGeometricVertex *vertex1_ptr = vertices ->elementAtIndex(edge.vertex1);
    CGRGeometricVertex *vertex2_ptr = vertices ->elementAtIndex(edge.vertex2);
    
    
    if(vertex1_ptr ->adjacencyList == NULL || vertex2_ptr ->adjacencyList == NULL)
        return;
    
    _CGRGeometricEdge *edge_ptr = vertex1_ptr ->adjacencyList ->dataForKey(edge.vertex2);
    if(edge_ptr != NULL){
        
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
        
        vertex1_ptr ->adjacencyList ->remove(edge.vertex2);
        vertex2_ptr ->adjacencyList ->remove(edge.vertex1);
        delete edge_ptr;
    }else{
        return; //The vertices are not neighbors
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
    NSPoint p2, p3;
    p2 = [self coordinatesForVertex:edge.vertex1];
    p3 = [self coordinatesForVertex:edge.vertex2];
    return [self segmentFromPoint:p0 to:p1 intersectsSegmentFrom:p2 to:p3];
}
-(NSPoint)intersectionPointOfSegmentFromPoint:(NSPoint)p0 to:(NSPoint)p1 andSegmentFrom:(NSPoint)p2 to:(NSPoint)p3
{
    NSPoint intersection;
    if (![self segmentFromPoint:p0 to:p1 intersectsSegmentFrom:p2 to:p3]) {
        intersection.x = NAN;
        intersection.y = NAN;
        return intersection;
    }
    return __intersectionPoint(p0, p1, p2, p3);
}
-(NSPoint)intersectionPointOfSegmentFromPoint:(NSPoint)p0 to:(NSPoint)p1 withEdge:(CGREdge)edge
{
    NSPoint intersection = {NAN,NAN};
    NSPoint p2, p3;
    p2 = [self coordinatesForVertex:edge.vertex1];
    p3 = [self coordinatesForVertex:edge.vertex2];
    if(![self segmentFromPoint:p0 to:p1 intersectsEdge:edge]){
        return intersection;
    }
    return __intersectionPoint(p0, p1, p2, p3);
}
-(NSPoint)intersectionPointOfEdge:(CGREdge)edge1 withEdge:(CGREdge)edge2
{
    NSPoint p0,p1;
    p0 = [self coordinatesForVertex:edge1.vertex1];
    p1 = [self coordinatesForVertex:edge1.vertex2];
    return [self intersectionPointOfSegmentFromPoint:p0 to:p1 withEdge:edge2];
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
    NSPoint v1C = [self coordinatesForVertex:edge.vertex1];
    NSPoint v2C = [self coordinatesForVertex:edge.vertex2];
    return [self distanceFromPoint:v1C to:v2C];
}
#pragma mark -
#pragma mark Edges Custom Data
-(void)addCustomData:(void *)data toEdge:(CGREdge)edge withNumber:(uint32_t)number
{
    //Bad Argument check
    if(edge.vertex1 < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    
    if(!vert ->adjacencyList)
        return;
    if(!vert ->adjacencyList ->containsKey(edge.vertex2)){
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
    
    _CGRGeometricEdge *cgrEdge = vert ->adjacencyList ->dataForKey(edge.vertex2);
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
    
    //Bad Argument check
    if(edge.vertex1 < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    
    if(!vert ->adjacencyList)
        return NULL;
    if(!vert ->adjacencyList ->containsKey(edge.vertex2)){
        return NULL;
    }
    
    _CGRGeometricEdge *cgrEdge = vert ->adjacencyList ->dataForKey(edge.vertex2);
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
    //Bad Argument check
    if(edge.vertex1 < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(edge.vertex1);
    
    if(!vert ->adjacencyList)
        return NULL;
    if(!vert ->adjacencyList ->containsKey(edge.vertex2)){
        return NULL;
    }
    
    _CGRGeometricEdge *cgrEdge = vert ->adjacencyList ->dataForKey(edge.vertex2);
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
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(vertex);
    
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
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(vertex);
    
    if(vert ->extraInformation == NULL)
        return NULL;
    if (!vert ->extraInformation ->containsKey(number)) {
        return NULL;
    }
    return vert ->extraInformation ->dataForKey(number);
}
-(void *)removeCustomDataForVertex:(uint32_t)vertex withNumber:(uint32_t)number
{
    //Bad Argument check
    if(vertex < vertices ->count()){}else{NSException *e = [NSException exceptionWithName:@"CGRGeometricGraphExceptionNoSuchVertex" reason:@"No vertex with the given ident" userInfo:nil];
        @throw e;}
    
    struct CGRGeometricVertex *vert = vertices ->elementAtIndex(vertex);
    
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
#pragma mark -
#pragma mark Constrains
-(void)addConstrain:(id <CGRGeometricGraph_Constrains>)newConstrain
{
    if (constrainsList == NULL) {
        constrainsList = new CGRCircularVector<void *>(20);
    }
    constrainsList ->add((__bridge void *)newConstrain);
    constrainedGraph = YES;
}
-(void)removeConstrain:(id<CGRGeometricGraph_Constrains>)constrain
{
    void *bridgeCast = (__bridge void *)constrain;
    //Look for the notify
    uint32_t constrainsListSize = constrainsList ->count();
    for(uint32_t i=0; i != constrainsListSize; i++)
        if(constrainsList ->elementAtIndex(i) == bridgeCast){
            constrainsList ->removeAtIndex(i);
            break;
        }
    if(!constrainsList ->count())
        constrainedGraph = NO;
}

@end
