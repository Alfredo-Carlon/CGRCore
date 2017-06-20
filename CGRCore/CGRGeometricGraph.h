//
//  CGRGeometricGraph.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/12/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CGRCore/CGRGraph_API.h>
#import <CGRCore/CGRCircularVector.h>
#import <CGRCore/CGRGeometricGraph_BasicTypes.h>
#import <CGRCore/CGRGeometricGraph_API.h>
#import <CGRCore/CGRGeometricGraph_Notifications.h>
#import <CGRCore/CGRGeometricGraph_Constrains.h>

@interface CGRGeometricGraph : NSObject <CGRGraph_API,CGRGeometricGraph_API>
{
    CGRCircularVector<CGRGeometricVertex *> *vertices;
    uint32_t numberOfVertices;
    
    ////////////////// Polar coordinates ///////////////
    
    NSPoint polarCenter;
    NSPoint polarDirection;
    double referenceAngle;
    ////////////////// Polar coordinates ///////////////
    
    
    CGRCircularVector<void *> *notifyList;
    BOOL notifyChanges;

    CGRCircularVector<void *> *constrainsList;
    BOOL constrainedGraph;
    
}

//Adds a vertex at (0,0)
-(uint32_t)addVertex;


/////////////   TEST


@end
