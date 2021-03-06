//
//  CGRGraph.h
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
