//
//  CGRExplorationGraph.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/7/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CGRCore/CGRGraph_API.h>
#import <CGRCore/CGRExplorationGraph_BasicTypes.h>
#import <CGRCore/CGRVector.h>

@interface CGRExplorationGraph : NSObject <CGRGraph_API>
{
    CGRVector<CGRExplorationVertex> *vertices;
}

@end
