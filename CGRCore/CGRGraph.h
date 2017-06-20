//
//  CGRGraph.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/15/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "CGRGraph_API.h"
#import "CGRCircularVector.h"
#import "CGRGraph_BasicTypes.h"
#import "CGRCircularVector.h"


@interface CGRGraph : NSObject <CGRGraph_API>
{
    
    CGRCircularVector<CGRVertex *> *vertices;
    
    //NSMutableArray *vertexNotifyList;
    CGRCircularVector<void *> *notifyList;
    BOOL notifyChanges;
    
    
}



@end
