//
//  CGRDirectedGraph.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/20/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CGRCore/CGRGraph_API.h>
#import <CGRCore/CGRCircularVector.h>
#import <CGRCore/CGRDirectedGraph_BasicTypes.h>
#import <CGRCore/CGRDirectedGraph_API.h>

@interface CGRDirectedGraph : NSObject <CGRGraph_API,CGRDirectedGraph_API>
{
    CGRCircularVector<CGRDirectedVertex *> *vertices;
    uint32_t numberOfVertices;
    
    CGRCircularVector<void *> *notifyList;
    BOOL notifyChanges;
    
    CGRCircularVector<void *> *dataNotifyList;
    //NSMutableArray *dataNotifyList;
    BOOL notifyDataChanges;

}

@end
