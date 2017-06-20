//
//  CGRPolygonCommon.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/19/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

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


