//
//  CGRPolygonCommon.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/19/14.
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
#import "CGRAVLTree.h"

typedef struct CGRPolygonVertex {
    uint32_t vertexIdent;
    NSPoint coordinates;
    uint32_t *colors;
    uint32_t numberOfColors;
    CGRAVLTree<uint32_t, void> *extraInformation;
    
    CGRPolygonVertex(NSPoint coord) :colors(NULL),extraInformation(NULL)
    {
        vertexIdent = -1;
        coordinates = coord;
        numberOfColors = 0;
    }
    ~CGRPolygonVertex()
    {
        if(extraInformation)
            delete extraInformation;
    }
}CGRPolygonVertex;


