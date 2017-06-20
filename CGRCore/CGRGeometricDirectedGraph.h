//
//  CGRGeometricDirectedGraph.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/22/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CGRCore/CGRDirectedGraph_API.h>
#import <CGRCore/CGRGraph_API.h>
#import <CGRCore/CGRCircularVector.h>
#import <CGRCore/CGRGeometricDirectedGraph_BasicTypes.h>
#import <CGRCore/CGRGeometricGraph_API.h>
#import <CGRCore/CGRDrawableGraph_API.h>

@interface CGRGeometricDirectedGraph : NSObject <CGRDirectedGraph_API,CGRGeometricGraph_API,CGRGraph_API>
{
    CGRCircularVector<CGRGeometricDirectedVertex *> *vertices;
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
@end
