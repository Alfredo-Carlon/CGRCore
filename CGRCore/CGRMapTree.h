//
//  CGRMapTree.h
//  CGRCore
//
//  Created by Alfredo Cruz on 1/2/14.
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

#ifndef CGRCore_CGRMapTree_h
#define CGRCore_CGRMapTree_h

#import <CGRcore/CGR2DGraphDrawing_BasicTypes.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLContext.h>

struct CGRMapTreeNode {
    uint32_t *vertices;
    uint32_t count;
    NSRect enclosingRectangle;
    struct CGRMapTreeNode *children;
    CGRMapTreeNode()
    {
        vertices = NULL;
        children = NULL;
        count = 0;
    }
};

class CGRMapTree
{
private:
    uint32_t _rows, _columns, _capacity;
    struct CGRMapTreeNode *root;
    struct CGRMapTreeNode *drawingRoot;
    
    
    int sortByYVertices(const void *p1, const void *p2)
    {
        struct CGRGeoGraphDrawingVertex *v1,*v2;
        v1 = (struct CGRGeoGraphDrawingVertex *)p1;
        v2 = (struct CGRGeoGraphDrawingVertex *)p2;
        if(v1 ->location.y == v2 ->location.y){
            return v1 ->location.x - v2 ->location.x;
        }
        return v1 ->location.y - v2 ->location.y;
    }
    
    
    int positionForXLeft(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double x)
    {
        uint32_t base = 0;
        uint32_t limit = numberOfVertices;
        uint32_t curnt = numberOfVertices >> 1;
        
        while(base+1 != limit)
        {
            
            if(vertices[curnt].location.x < x){
                base = curnt;
                curnt = base + ((limit-base)>>1);
                continue;
            }
            limit = curnt;
            curnt = base + ((limit-base)>>1);
        }
        return base;
    }
    
    int positionForXRight(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double x)
    {
        uint32_t base = 0;
        uint32_t limit = numberOfVertices;
        uint32_t curnt = numberOfVertices >> 1;
        
        while(base+1 != limit)
        {
            
            if(vertices[curnt].location.x > x){
                limit = curnt;
                curnt = base + ((limit-base)>>1);
                continue;
            }
            base = curnt;
            curnt = base + ((limit-base)>>1);
        }
        return base;
    }
    
    int positionForYLeft(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double y)
    {
        uint32_t base = 0;
        uint32_t limit = numberOfVertices;
        uint32_t curnt = numberOfVertices >> 1;
        
        while(base+1 != limit)
        {
            
            if(vertices[curnt].location.y < y){
                base = curnt;
                curnt = base + ((limit-base)>>1);
                continue;
            }
            limit = curnt;
            curnt = base + ((limit-base)>>1);
        }
        return base;
    }
    
    int positionForYRight(struct CGRGeoGraphDrawBasicVertex *vertices, uint32_t numberOfVertices, double y)
    {
        uint32_t base = 0;
        uint32_t limit = numberOfVertices;
        uint32_t curnt = numberOfVertices >> 1;
        
        while(base+1 != limit)
        {
            
            if(vertices[curnt].location.y > y){
                limit = curnt;
                curnt = base + ((limit-base)>>1);
                continue;
            }
            base = curnt;
            curnt = base + ((limit-base)>>1);
        }
        return base;
    }
    
    
    //Inorder trasversal...
    struct basicStack
    {
        struct CGRMapTreeNode *node;
        struct basicStack *next;
    };
    
    inline void cleanStack(basicStack *stack){
        basicStack *curnt = stack ->next;
        while(curnt != NULL){
            basicStack *tmp = curnt;
            curnt = curnt ->next;
            delete tmp;
        }
        delete curnt;
    }
    
    inline basicStack *pushIntoStack(basicStack *stack, struct CGRMapTreeNode *node)
    {
        if(stack != NULL){
            struct basicStack *next = new basicStack;
            if(next == NULL){
                //Cleanup and throw an exception
                cleanStack(stack);
                NSException *e = [NSException exceptionWithName:@"CGRAVLTree" reason:@"No enough memory for keys vector" userInfo:nil];
                @throw e;
            }
            next ->node = node;
            next ->next = stack;
            return next;
        }
        //If stack is null
        stack = new basicStack;
        if(stack == NULL){
            NSException *e = [NSException exceptionWithName:@"CGRAVLTree" reason:@"No enough memory for keys vector" userInfo:nil];
            @throw e;
        }
        stack ->next = NULL;
        stack ->node = node;
        return stack;
    }
    
    inline struct CGRMapTreeNode *popFromStack(basicStack **stack)
    {
        if(stack == NULL || *stack == NULL)
            return NULL;
        struct CGRMapTreeNode *node = (*stack) ->node;
        basicStack *tmp = *stack;
        *stack = (*stack) ->next;
        delete tmp;
        return node;
    }
    
    
public:
    CGRMapTree(uint32_t rows, uint32_t columns, uint32_t capacity)
    {
        this ->_rows = rows;
        this ->_columns = columns;
        this ->_capacity = capacity;
        root = new CGRMapTreeNode();
    }
    
    ~CGRMapTree()
    {
        basicStack *stack = NULL;
        CGRMapTreeNode *curnt = root;
        root ->count = 0;
        while(stack != NULL || curnt != NULL){
            if(curnt != NULL){
                @try {
                    stack = pushIntoStack(stack, curnt);
                }
                @catch (NSException *exception) {
                    NSException *e = [NSException exceptionWithName:@"CGRMapTree" reason:@"No enough memory for free stack. Possible memory leak" userInfo:nil];
                    @throw e;
                }
                @finally {
                    
                }
                if(curnt ->children == NULL){
                    curnt = NULL;
                    continue;
                }
                if(curnt ->count == _rows*_columns){
                    curnt = NULL;
                    continue;
                }
                curnt = &curnt ->children[curnt ->count++];
                curnt ->count = 0;
            }else{
                curnt = popFromStack(&stack);
                if(curnt ->vertices != NULL)
                    free(curnt ->vertices);
                if(curnt ->children != NULL)
                    delete [] curnt ->children;
                curnt = popFromStack(&stack);
            }
        }
        delete root;
    }
    
    void constructTree(struct CGRGeoGraphDrawBasicVertex *verticesByX, uint32_t numberOfVertices)
    {
        double left, right, top, bottom;
        left = verticesByX[0].location.x;
        right = verticesByX[0].location.x;
        top = verticesByX[0].location.y;
        bottom = verticesByX[0].location.y;
        
        for(uint32_t i=1; i != numberOfVertices; i++){
            if (verticesByX[i].location.x < left) {
                left = verticesByX[i].location.x;
            }
            if (verticesByX[i].location.x > right) {
                right = verticesByX[i].location.x;
            }
            if (verticesByX[i].location.y < bottom) {
                bottom = verticesByX[i].location.y;
            }
            if (verticesByX[i].location.y > top) {
                top = verticesByX[i].location.y;
            }
        }
        
        root ->enclosingRectangle.origin = NSMakePoint(left, bottom);
        root ->enclosingRectangle.size.width = right - left;
        root ->enclosingRectangle.size.height = top - bottom;
        root ->count = numberOfVertices;
        
        struct CGRGeoGraphDrawBasicVertex *sortedByY = (struct CGRGeoGraphDrawBasicVertex *)malloc(sizeof(struct CGRGeoGraphDrawBasicVertex)*100000);
        if(sortedByY == NULL){
            delete root;
            NSException *e = [NSException exceptionWithName:@"CGRMapTreeNotEnoughMemory" reason:@"Not enough memory to hold the vertices sorted by Y" userInfo:nil];
            @throw e;
        }
        uint32_t sortedByYCapacity = 100000;
        
        
        struct basicStack *stack = NULL;
        stack = pushIntoStack(stack, root);
        
        CGRMapTreeNode *curnt = popFromStack(&stack);
        
        while (curnt != NULL) {
            double colSize = curnt ->enclosingRectangle.size.width/(double)_columns;
            double rowSize = curnt ->enclosingRectangle.size.height/(double)_rows;
            
            //Alloc memory for the grid rooted on curnt
            curnt ->children = new struct CGRMapTreeNode[_columns*_rows];
            if(curnt ->children == NULL){
                NSException *e = [NSException exceptionWithName:@"CGRMapTreeNotEnoughMemory" reason:@"Not enough memory to hold the vertices sorted by Y" userInfo:nil];
                @throw e;
            }
            uint32_t childIndex = 0;
            for(uint32_t i=0; i != _columns; i++){
                uint32_t leftLimit = positionForXLeft(verticesByX, numberOfVertices, left+colSize*i);
                uint32_t rightLimit = positionForXRight(verticesByX, numberOfVertices, left+colSize*(i+1));
                if(sortedByYCapacity < (rightLimit - leftLimit + 1))
                {
                    free(sortedByY);
                    sortedByY = (struct CGRGeoGraphDrawBasicVertex *)malloc(sizeof(struct CGRGeoGraphDrawBasicVertex)*(rightLimit - leftLimit + 1));
                    if(sortedByY == NULL){
                        NSException *e = [NSException exceptionWithName:@"CGRMapTreeNotEnoughMemory" reason:@"Not enough memory to hold the vertices sorted by Y" userInfo:nil];
                        @throw e;
                    }
                    sortedByYCapacity = rightLimit - leftLimit + 1;
                }
                
                for(int j=leftLimit; j != rightLimit + 1; j++){
                    sortedByY[j-leftLimit] = verticesByX[j];
                }
                uint32_t sortByYCount = rightLimit - leftLimit+1;
                for(uint32_t j = 0; j != _rows; j++){
                    uint32_t lowLimit = positionForYLeft(sortedByY,sortByYCount , bottom+rowSize*j);
                    uint32_t topLimit = positionForYLeft(sortedByY,sortByYCount , bottom+rowSize*(j+1));
                    curnt ->children[childIndex].count = topLimit - lowLimit + 1;
                    curnt ->children[childIndex].enclosingRectangle = NSMakeRect(left+colSize*i, bottom+rowSize*j, rowSize, colSize);
                    if(curnt ->children[childIndex].count <= _capacity){
                        //We are finished with this partition so copy the idents
                        curnt ->children[childIndex].vertices = (uint32_t *)malloc(sizeof(uint32_t)*curnt ->children[childIndex].count);
                        if(curnt ->children[childIndex].vertices == NULL){
                            NSException *e = [NSException exceptionWithName:@"CGRMapTreeNotEnoughMemory" reason:@"Not enough memory to hold the vertices sorted by Y" userInfo:nil];
                            @throw e;
                        }
                        for(uint32_t k=lowLimit; k != topLimit+1; k++){
                            curnt ->children[childIndex].vertices[k - lowLimit] = sortedByY[k].ident;
                        }
                    }else{
                        stack = pushIntoStack(stack, &curnt ->children[childIndex]);
                    }
                    childIndex++;
                }
                
            }
            if(stack == NULL)
                break;
            curnt = popFromStack(&stack);
        }
        
        free(sortedByY);
        drawingRoot = root;
        
    }
    
    void drawFromRoot(NSRect bounds)
    {
        //First draw each quadrilateral with its color and then draw the grid
        GLfloat squareWidth;
        GLfloat squareHeight;
        
        squareWidth = bounds.size.width/(double)_columns;
        squareHeight = bounds.size.height/(double)_rows;
        
        GLfloat totalNumberVerts = root ->count;
        uint32_t cellIndex = 0;
        for(uint32_t i = 0; i != _columns; i++){
            for(uint32_t j = 0; j != _rows; j++){
                struct CGRMapTreeNode cell = drawingRoot ->children[cellIndex++];
                GLfloat red = cell.count/totalNumberVerts;
                GLfloat blue = 1 - red;
                glBegin(GL_TRIANGLES);
                glColor4f(red, 0, blue,0.5);
                glVertex3d(i*squareWidth, j*squareHeight, 0);
                glVertex3d((i+1)*squareWidth, j*squareHeight, 0);
                glVertex3d(i*squareWidth, (j+1)*squareHeight, 0);
                glVertex3d((i+1)*squareWidth, j*squareHeight, 0);
                glVertex3d(i*squareWidth, (j+1)*squareHeight, 0);
                glVertex3d((i+1)*squareWidth, (j+1)*squareHeight, 0);
                glEnd();
                
            }
        }
        {
            glColor4f(0, 0, 0,1.0);
            glBegin(GL_LINES);
            for(uint32_t i=1; i != _columns; i++){
                glVertex3d(i*squareWidth, 0, 0);
                glVertex3d(i*squareWidth, bounds.size.height, 0);
            }
            for(uint32_t i=1; i != _rows; i++){
                glVertex3d(0, i*squareHeight, 0);
                glVertex3d(bounds.size.width, i*squareHeight, 0);
            }
            glEnd();
        }
        
        
    }
    
    
    uint32_t rows(){return _rows;}
    uint32_t columns(){return _columns;}
    uint32_t capacity(){return _capacity;}
};


#endif
