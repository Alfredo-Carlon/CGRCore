//
//  CGRDirectedGraph.h
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
