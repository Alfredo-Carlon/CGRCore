//
//  CGRCommonTypes.cpp
//  CGRCore
//
//  Created by Alfredo Cruz on 11/7/13.
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

#include "CGRCommonTypes.h"


CGREdge makeEdge(unsigned int p, unsigned int q)
{
    CGREdge newEdge;
    newEdge.vertex1 = p;
    newEdge.vertex2 = q;
    return newEdge;
}

int edgeComparison(unsigned int *i, unsigned int *j){
    if(*i < *j)
        return -1;
    if(*i > *j)
        return 1;
    return 0;
}

