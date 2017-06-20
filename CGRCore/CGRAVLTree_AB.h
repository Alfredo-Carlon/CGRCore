//
//  CGRAVLTree_AB.h
//  CGRCore
//
//  Created by Alfredo Cruz on 1/11/15.
//  Copyright (c) 2015 Alfredo Cruz. All rights reserved.
//

/// Implementation of a simple Array Based AVL Tree.

#ifndef CGRCore_CGRAVLTree_AB_h
#define CGRCore_CGRAVLTree_AB_h

#import "CGRAVLTree.h"

//Note: this is NOT thread safe

template <class KEY, class DATA>
struct CGRAVLTreeABNode
{
    KEY key;
    DATA data;
    bool leaf; //True if the node is a leaf, false otherwise
    uint32_t height;
    
    CGRAVLTreeABNode(KEY k, DATA *d)
    {
        key = k;
        data = d;
        leaf = true;
        height = 0;
    }
    ~CGRAVLTreeABNode()
    {
        
    }
};

template <class KEY, class DATA>
class CGRAVLTreeAB {
    
private:
    //User supplied key comparator
    typedef int (*comparator)(KEY *key1, KEY *key2);
    comparator keyComparator;
    
    //The list of nodes in the tree
    CGRAVLTreeABNode<KEY, DATA> *nodes;
    
    uint32_t _numberOfNodes;
    
    inline uint32_t leftChild(uint32_t index){
        return 2*index - 1;
    }
    inline uint32_t rightChild(uint32_t index){
        return 2*index;
    }
    
    inline void rotateLeft(CGRAVLTreeABNode<KEY, DATA> *node)
    {
        uint32_t nodeIndex = ((uint64_t)nodes - (uint64_t)node)/sizeof(CGRAVLTreeABNode<KEY,DATA>);
        CGRAVLTreeNode<KEY, DATA> *tmp;
        tmp = node ->right ->left;
        node ->right ->left = node ->right ->right;
        node ->right ->right = tmp;
        
        tmp = node ->left;
        node ->left = node ->right ->left;
        node ->right ->left = tmp;
        
        tmp = node ->left;
        node ->left = node -> right;
        node ->right = tmp;
        
        KEY tmpKey;
        DATA *tmpData;
        tmpKey = node ->key;
        tmpData = node ->data;
        
        node ->key = node ->left ->key;
        node ->data = node ->left ->data;
        
        node ->left -> key = tmpKey;
        node ->left ->data = tmpData;
    }
    
    inline void rotateRight(CGRAVLTreeNode<KEY, DATA> *node){
        CGRAVLTreeNode<KEY, DATA> *tmp;
        tmp = node ->left;
        node ->left = node ->right;
        node ->right = tmp;
        
        tmp = node ->left;
        node ->left = node ->right ->left;
        node ->right ->left = tmp;
        
        tmp = node ->right ->left;
        node ->right ->left = node ->right ->right;
        node ->right ->right = tmp;
        
        KEY tmpKey;
        DATA *tmpData;
        tmpKey = node ->key;
        tmpData = node ->data;
        
        node ->key = node ->right ->key;
        node ->data = node ->right ->data;
        
        node ->right ->key = tmpKey;
        node ->right ->data = tmpData;
        
    }
    
    inline void recomputeHeight(CGRAVLTreeNode<KEY, DATA> *node)
    {
        if(node == NULL)
            return;
        
        if(node ->left == NULL && node ->right == NULL){
            node ->height = 0;
            return;
        }
        
        uint32_t leftHeight = 0;
        uint32_t rightHeight = 0;
        if(node ->left != NULL)
        {
            leftHeight = node ->left ->height;
        }
        if(node ->right != NULL){
            rightHeight = node ->right ->height;
        }
        
        node ->height = (leftHeight > rightHeight)?leftHeight+1:rightHeight+1;
    }
    
    void rebalance(CGRAVLTreeNode<KEY, DATA> *node){
        uint32_t leftHeight, rightHeight;
        leftHeight = 0;
        rightHeight = 0;
        if(node ->left != NULL){
            leftHeight = node ->left ->height;
        }
        if(node ->right != NULL){
            rightHeight = node ->right ->height;
        }
        if(leftHeight == rightHeight + 2)
        {
            uint32_t leftLeftHeight;
            if(node ->left ->left == NULL)
                leftLeftHeight = 0;
            else
                leftLeftHeight = node ->left ->left ->height;
            
            if(leftLeftHeight  == rightHeight + 1){
                //Do a right rotation around node and recompute node->right and node's height
                rotateRight(node);
                recomputeHeight(node ->right);
                recomputeHeight(node);
            }
            else if(leftLeftHeight == rightHeight){
                //Do a left rotation around node ->left followed by a right rotation around node and recompute
                //node ->right, node ->left and node's height
                rotateLeft(node ->left);
                rotateRight(node);
                recomputeHeight(node ->right);
                recomputeHeight(node ->left);
                recomputeHeight(node);
                
            }
        }
        else if(rightHeight == leftHeight + 2){
            uint32_t rightRightHeight;
            if(node ->right ->right == NULL)
                rightRightHeight = 0;
            else
                rightRightHeight = node ->right ->right ->height;
            
            if(rightRightHeight == leftHeight + 1){
                //Do a left rotation around node and recompute node ->left and node's height
                rotateLeft(node);
                recomputeHeight(node ->left);
                recomputeHeight(node);
            }
            else if(rightRightHeight == leftHeight){
                //Do a right rotation around node ->right and a left rotation around node and recalculate node ->right,
                //node ->left and node's height
                rotateRight(node ->right);
                rotateLeft(node);
                recomputeHeight(node ->right);
                recomputeHeight(node ->left);
                recomputeHeight(node);
                
            }
        }
    }
    
    
    //Inorder trasversal...
    struct basicStack
    {
        CGRAVLTreeNode<KEY, DATA> *node;
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
    
    inline basicStack *pushIntoStack(basicStack *stack, CGRAVLTreeNode<KEY, DATA> *node)
    {
        if(stack != NULL){
            struct basicStack *next = new basicStack;
            if(next == NULL){
                //Cleanup and throw an exception
                cleanStack(stack);
                CGRAVLTreeNotEnoughSpace exception;
                throw exception;
                //NSException *e = [NSException exceptionWithName:@"CGRAVLTree" reason:@"No enough memory for keys vector" userInfo:nil];
                //@throw e;
            }
            next ->node = node;
            next ->next = stack;
            return next;
        }
        //If stack is null
        stack = new basicStack;
        if(stack == NULL){
            CGRAVLTreeNotEnoughSpace exception;
            throw exception;
            //NSException *e = [NSException exceptionWithName:@"CGRAVLTree" reason:@"No enough memory for keys vector" userInfo:nil];
            //@throw e;
        }
        stack ->next = NULL;
        stack ->node = node;
        return stack;
    }
    
    inline CGRAVLTreeNode<KEY, DATA> *popFromStack(basicStack **stack)
    {
        if(stack == NULL)
            return NULL;
        CGRAVLTreeNode<KEY, DATA> *node = (*stack) ->node;
        basicStack *tmp = *stack;
        *stack = (*stack) ->next;
        delete tmp;
        return node;
    }
    
    void _removeNode(CGRAVLTreeNode<KEY, DATA> * root){
        if(!root)
            return;
        if(root ->left != NULL){
            _removeNode(root ->left);
            root ->left = NULL;
        }
        if(root ->right != NULL){
            _removeNode(root ->right);
            root ->right = NULL;
        }
        delete root;
    }
    
public:
    
    CGRAVLTree()
    {
        keyComparator = NULL;
        rootNode = NULL;
        _numberOfNodes = 0;
        defaultStack = NULL;
    }
    
    ~CGRAVLTree()
    {
        struct __stack
        {
            CGRAVLTreeNode<KEY, DATA> *info;
            struct __stack *next;
            __stack(CGRAVLTreeNode<KEY, DATA> *i, struct __stack *n){
                info = i;
                next = n;
            }
        };
        struct __stack *last = new __stack(rootNode,NULL);
        while (last) {
            if(last ->info == NULL){
                struct __stack *tmp = last;
                last = last ->next;
                delete tmp;
                continue;
            }
            if(last ->info ->left != NULL){
                struct __stack *next = new __stack(last ->info ->left,last);
                last ->info ->left = NULL;
                last = next;
                continue;
            }
            if(last ->info ->right != NULL){
                struct __stack *next = new __stack(last ->info ->right,last);
                last ->info ->right = NULL;
                last = next;
                continue;
            }
            struct __stack *tmp = last;
            last = last ->next;
            
            delete tmp ->info;
            delete tmp;
            
        }
        keyComparator = NULL;
        rootNode = NULL;
        _numberOfNodes = 0;
    }
    
    CGRAVLTree (int (*comp)(KEY *key1, KEY *key2))
    {
        keyComparator = comp;
        rootNode = NULL;
        _numberOfNodes = 0;
        defaultStack = NULL;
    }
    
    
    void add(KEY key, DATA *data){
        
        if(keyComparator == NULL)
            return;
        
        
        //Adds a new node to the tree and rebalance if necessary
        CGRAVLTreeNode<KEY,DATA> *newNode;
        //Look for the node and if its not present then update the heigh of the tree and rebalance if necessary
        
        if (rootNode == NULL) {
            newNode = new CGRAVLTreeNode<KEY,DATA>(key,data);
            if(newNode == NULL){
                //NSException *e = [NSException exceptionWithName:@"CGRAVLTreeOutOfMemoryException" reason:@"Couldn't allocate memory for tree node" userInfo:nil];
                //@throw e;
                CGRAVLTreeNotEnoughSpace exception;
                throw exception;
            }
            rootNode = newNode;
            _numberOfNodes = 1;
            return;
        }
        
        struct pathNode
        {
            CGRAVLTreeNode<KEY, DATA> *node;
            struct pathNode *next;
            pathNode(CGRAVLTreeNode<KEY, DATA> *n){
                node = n;
                next = NULL;
            }
            ~pathNode()
            {
                
            }
        };
        struct pathNode *last = new pathNode(rootNode);
        CGRAVLTreeNode<KEY, DATA> *curnt = rootNode;
        bool found = false;
        while(true){
            int res = keyComparator(&(curnt ->key),&key);
            
            if(res < 0){
                if(curnt -> right == NULL){
                    newNode = new CGRAVLTreeNode<KEY,DATA>(key,data);
                    if(newNode == NULL){
                        //NSException *e = [NSException exceptionWithName:@"CGRAVLTreeOutOfMemoryException" reason:@"Couldn't allocate memory for tree node" userInfo:nil];
                        //@throw e;
                        CGRAVLTreeNotEnoughSpace exception;
                        throw exception;
                    }
                    curnt ->right = newNode;
                    _numberOfNodes++;
                    break;
                }
                struct pathNode *next = new pathNode(curnt ->right);
                next ->next = last;
                last = next;
                curnt = curnt ->right;
                continue;
            }else if(res > 0){
                if(curnt ->left == NULL){
                    newNode = new CGRAVLTreeNode<KEY,DATA>(key,data);
                    if(newNode == NULL){
                        //NSException *e = [NSException exceptionWithName:@"CGRAVLTreeOutOfMemoryException" reason:@"Couldn't allocate memory for tree node" userInfo:nil];
                        //@throw e;
                        CGRAVLTreeNotEnoughSpace exception;
                        throw exception;
                    }
                    curnt ->left = newNode;
                    _numberOfNodes++;
                    break;
                }
                struct pathNode *next = new pathNode(curnt ->left);
                next ->next = last;
                last = next;
                curnt = curnt ->left;
                continue;
            }
            found = true;
            break;
        }
        //Now recalculate the heigh of the tree and reblance if necessary
        bool finished = false;
        if(found)
            finished = true;
        while(last != NULL){
            if(finished){
                struct pathNode *next = last;
                last = last ->next;
                delete next;
                continue;
            }
            uint32_t leftHeight, rightHeight;
            leftHeight = 0;
            rightHeight = 0;
            if(last -> node ->left != NULL){
                leftHeight = last -> node ->left ->height;
            }
            if(last -> node ->right != NULL){
                rightHeight = last -> node ->right ->height;
            }
            uint32_t difference = 0;
            difference = (leftHeight > rightHeight)?leftHeight - rightHeight:rightHeight - leftHeight;
            if(difference < 2){
                //No rebalance is needed
                last -> node ->height =  (leftHeight > rightHeight)?leftHeight+1:rightHeight+1;
                struct pathNode *next = last;
                last = last ->next;
                delete next;
                continue;
            }
            //If we get here then we need to rebalance the tree..
            uint32_t startHeight = last -> node ->height;
            rebalance(last ->node);
            if(last ->node -> height == startHeight){
                finished = true;
            }
            struct pathNode *next = last;
            last = last ->next;
            delete next;
        }
        
    }
    
    //Adds a new item to the tree using *stack as a stack
    //If *stack is null then it uses the 'default stack'
    void addWithStack(KEY key, DATA *data, CGRLinearStack<CGRAVLTreeNode<KEY, DATA> *> *stack)
    {
        CGRLinearStack<CGRAVLTreeNode<KEY, DATA> *> *workStack = stack;
        
        if(stack == NULL){
            if(!defaultStack){
                defaultStack = new CGRLinearStack<CGRAVLTreeNode<KEY, DATA> *>(10,20);
                workStack = defaultStack;
            }else{
                workStack = defaultStack;
            }
        }
        workStack ->reset();
        if(keyComparator == NULL)
            return;
        
        //Adds a new node to the tree and rebalance if necessary
        CGRAVLTreeNode<KEY,DATA> *newNode;
        //Look for the node and if its not present then update the heigh of the tree and rebalance if necessary
        
        if (rootNode == NULL) {
            newNode = new CGRAVLTreeNode<KEY,DATA>(key,data);
            if(newNode == NULL){
                //NSException *e = [NSException exceptionWithName:@"CGRAVLTreeOutOfMemoryException" reason:@"Couldn't allocate memory for tree node" userInfo:nil];
                //@throw e;
                CGRAVLTreeNotEnoughSpace exception;
                throw exception;
            }
            rootNode = newNode;
            _numberOfNodes = 1;
            return;
        }
        
        
        //struct pathNode *last = new pathNode(rootNode);
        workStack ->push(rootNode);
        CGRAVLTreeNode<KEY, DATA> *curnt = rootNode;
        bool found = false;
        while(true){
            int res = keyComparator(&(curnt ->key),&key);
            
            if(res < 0){
                if(curnt -> right == NULL){
                    newNode = new CGRAVLTreeNode<KEY,DATA>(key,data);
                    if(newNode == NULL){
                        //NSException *e = [NSException exceptionWithName:@"CGRAVLTreeOutOfMemoryException" reason:@"Couldn't allocate memory for tree node" userInfo:nil];
                        //@throw e;
                        CGRAVLTreeNotEnoughSpace exception;
                        throw exception;
                    }
                    curnt ->right = newNode;
                    _numberOfNodes++;
                    break;
                }
                //struct pathNode *next = new pathNode(curnt ->right);
                workStack ->push(curnt ->right);
                //next ->next = last;
                //last = next;
                curnt = curnt ->right;
                continue;
            }else if(res > 0){
                if(curnt ->left == NULL){
                    newNode = new CGRAVLTreeNode<KEY,DATA>(key,data);
                    if(newNode == NULL){
                        //NSException *e = [NSException exceptionWithName:@"CGRAVLTreeOutOfMemoryException" reason:@"Couldn't allocate memory for tree node" userInfo:nil];
                        //@throw e;
                        CGRAVLTreeNotEnoughSpace exception;
                        throw exception;
                    }
                    curnt ->left = newNode;
                    _numberOfNodes++;
                    break;
                }
                //struct pathNode *next = new pathNode(curnt ->left);
                //next ->next = last;
                //last = next;
                workStack ->push(curnt ->left);
                curnt = curnt ->left;
                continue;
            }
            found = true;
            break;
        }
        //Now recalculate the heigh of the tree and reblance if necessary
        bool finished = false;
        if(found)
            finished = true;
        uint32_t stackSize = workStack ->count();
        for(uint32_t i=0; i != stackSize; i++){
            if(finished){
                return;
            }
            uint32_t leftHeight, rightHeight;
            leftHeight = 0;
            rightHeight = 0;
            CGRAVLTreeNode<KEY, DATA> *node = workStack ->pop();
            if(node ->left != NULL){
                leftHeight = node ->left ->height;
            }
            if(node ->right != NULL){
                rightHeight = node ->right ->height;
            }
            uint32_t difference = 0;
            difference = (leftHeight > rightHeight)?leftHeight - rightHeight:rightHeight - leftHeight;
            if(difference < 2){
                //No rebalance is needed
                node ->height =  (leftHeight > rightHeight)?leftHeight+1:rightHeight+1;
                continue;
            }
            //If we get here then we need to rebalance the tree..
            uint32_t startHeight = node ->height;
            rebalance(node);
            if(node -> height == startHeight){
                finished = true;
            }
        }
        
        
        
    }
    
    DATA *remove(KEY key)
    {
        //First look for the data
        if(keyComparator == NULL)
            return NULL;
        
        //Look for the node and if its not present then update the heigh of the tree and rebalance if necessary
        
        if (rootNode == NULL) {
            return NULL;
        }
        
        struct pathNode
        {
            CGRAVLTreeNode<KEY, DATA> *node;
            struct pathNode *next;
            pathNode(CGRAVLTreeNode<KEY, DATA> *n){
                node = n;
                next = NULL;
            }
        };
        struct pathNode *last = new pathNode(rootNode);
        CGRAVLTreeNode<KEY, DATA> *curnt = rootNode;
        bool found = false;
        while(true){
            int res = keyComparator(&(curnt ->key),&key);
            
            if(res < 0){
                if(curnt -> right == NULL){
                    found = false;
                    break;
                }
                struct pathNode *next = new pathNode(curnt ->right);
                next ->next = last;
                last = next;
                curnt = curnt ->right;
                continue;
            }else if(res > 0){
                if(curnt ->left == NULL){
                    found = false;
                    break;
                }
                struct pathNode *next = new pathNode(curnt ->left);
                next ->next = last;
                last = next;
                curnt = curnt ->left;
                continue;
            }
            found = true;
            break;
        }
        
        DATA *retVal = NULL;
        while(1){
            //If we found the key we remove the node
            if(found){
                _numberOfNodes--;
                CGRAVLTreeNode<KEY, DATA> *toDelete = curnt;
                //First try to find the leftmost leaf of the right subtree
                if(toDelete ->right != NULL)
                {
                    //We have a right subtree
                    curnt = toDelete ->right;
                    struct pathNode *next = new pathNode(curnt);
                    next ->next = last;
                    last = next;
                    
                    while (curnt ->left != NULL) {
                        struct pathNode *next;
                        next = new pathNode(curnt ->left);
                        curnt = curnt ->left;
                        next ->next = last;
                        last = next;
                    }
                    //Check if curnt has a right subtree.. if so we need to shift forward
                    if(curnt ->right){
                        CGRAVLTreeNode<KEY, DATA> *rightNode = curnt ->right;
                        retVal = toDelete ->data;
                        toDelete ->key = curnt ->key;
                        toDelete ->data = curnt ->data;
                        curnt ->key = rightNode ->key;
                        curnt ->data = rightNode ->data;
                        curnt ->left = rightNode ->left;
                        curnt ->right = rightNode ->right;
                        delete rightNode;
                    }else{
                        retVal = toDelete ->data;
                        toDelete ->key = curnt ->key;
                        toDelete ->data = curnt ->data;
                        //Pop from the stack
                        struct pathNode *tmp = last;
                        last = last ->next;
                        delete tmp;
                        if(last ->node ->left == curnt){
                            last ->node ->left = NULL;
                        }else{
                            last ->node ->right = NULL;
                        }
                        delete curnt;
                    }
                    break;
                }
                else if(toDelete ->left)
                {
                    //We don't have a right descendent but we do have a left.
                    //Find the leaf to switch for on the left subtree
                    curnt = toDelete ->left;
                    
                    struct pathNode *next = new pathNode(curnt);
                    next ->next = last;
                    last = next;
                    
                    //Check if curnt has a right child
                    if(curnt ->right){
                        //Add it to the stack
                        struct pathNode *next;
                        next = new pathNode(curnt);
                        next ->next = last;
                        last = next;
                        //We have a right child then swap it with toDelete
                        retVal = toDelete ->data;
                        toDelete ->key = curnt ->right ->key;
                        toDelete ->data = curnt ->right ->data;
                        delete curnt ->right;
                        //?????
                        curnt ->right = NULL;
                        
                    }else if(curnt ->left){
                        retVal = toDelete ->data;
                        toDelete ->key = curnt ->key;
                        toDelete -> data = curnt ->data;
                        CGRAVLTreeNode<KEY, DATA> *leftNode = curnt ->left;
                        curnt ->key = leftNode ->key;
                        curnt ->data = leftNode ->data;
                        curnt ->left = leftNode ->left;
                        curnt ->right = leftNode ->right;
                        delete leftNode;
                    }else{
                        retVal = toDelete ->data;
                        toDelete ->key = curnt ->key;
                        toDelete ->data = curnt ->data;
                        struct pathNode *tmp = last;
                        last = last ->next;
                        delete tmp;
                        if(last ->node ->left == curnt){
                            last ->node ->left = NULL;
                        }else{
                            last ->node ->right = NULL;
                        }
                        delete curnt;
                    }
                    break;
                }else{
                    //We are deleting a leaf
                    if(last ->next != NULL){
                        retVal = toDelete ->data;
                        if(last ->next ->node ->left == toDelete) {
                            last ->next ->node ->left = NULL;
                        }else
                            last ->next ->node ->right = NULL;
                        delete toDelete;
                        struct pathNode *tmp = last;
                        last = last ->next;
                        delete tmp;
                    }else{
                        //We are deleting the root
                        rootNode = NULL;
                        delete toDelete;
                        delete last;
                        last = NULL;
                    }
                    break;
                }
            }
        }
        
        
        //Now recalculate the heigh of the tree and reblance if necessary
        bool finished = false;
        while(last != NULL){
            if(finished){
                struct pathNode *next = last;
                last = last ->next;
                delete next;
                continue;
            }
            uint32_t leftHeight, rightHeight;
            leftHeight = 0;
            rightHeight = 0;
            if(last -> node ->left != NULL){
                leftHeight = last -> node ->left ->height;
            }
            if(last -> node ->right != NULL){
                rightHeight = last -> node ->right ->height;
            }
            uint32_t difference = 0;
            difference = (leftHeight > rightHeight)?leftHeight - rightHeight:rightHeight - leftHeight;
            if(difference < 2){
                //No rebalance is needed
                if(last ->node ->left == NULL && last ->node ->right == NULL){
                    last ->node ->height = 0;
                }else{
                    last -> node ->height =  (leftHeight > rightHeight)?leftHeight + 1:rightHeight + 1;
                }
                struct pathNode *next = last;
                last = last ->next;
                delete next;
                continue;
            }
            //If we get here then we need to rebalance the tree..
            uint32_t startHeight = last -> node ->height;
            rebalance(last ->node);
            if(last ->node -> height == startHeight){
                finished = true;
            }
            struct pathNode *next = last;
            last = last ->next;
            delete next;
        }
        return retVal;
        
    }
    
    DATA *removeWithStack(KEY key, CGRLinearStack<CGRAVLTreeNode<KEY, DATA> *> *stack)
    {
        CGRLinearStack<CGRAVLTreeNode<KEY, DATA> *> *workStack = stack;
        
        if(stack == NULL){
            if(!defaultStack){
                defaultStack = new CGRLinearStack<CGRAVLTreeNode<KEY, DATA> *>(10,20);
                workStack = defaultStack;
            }else{
                workStack = defaultStack;
            }
        }
        workStack ->reset();
        //First look for the data
        if(keyComparator == NULL)
            return NULL;
        
        //Look for the node and if its not present then update the heigh of the tree and rebalance if necessary
        
        if (rootNode == NULL) {
            return NULL;
        }
        workStack ->push(rootNode);
        CGRAVLTreeNode<KEY, DATA> *curnt = rootNode;
        bool found = false;
        while(true){
            int res = keyComparator(&(curnt ->key),&key);
            
            if(res < 0){
                if(curnt -> right == NULL){
                    found = false;
                    break;
                }
                workStack ->push(curnt ->right);
                curnt = curnt ->right;
                continue;
            }else if(res > 0){
                if(curnt ->left == NULL){
                    found = false;
                    break;
                }
                workStack ->push(curnt ->left);
                curnt = curnt ->left;
                continue;
            }
            found = true;
            break;
        }
        
        DATA *retVal = NULL;
        while(1){
            //If we found the key we remove the node
            if(found){
                CGRAVLTreeNode<KEY, DATA> *toDelete = curnt;
                curnt = toDelete ->right;
                if(curnt != NULL)
                {
                    if(curnt -> left != NULL || curnt ->right != NULL){
                        workStack ->push(curnt);
                    }
                    while(curnt ->left != NULL){
                        workStack ->push(curnt ->left);
                        curnt = curnt ->left;
                    }
                    //Check if we have a right neighbor
                    if(curnt ->right != NULL){
                        retVal = toDelete ->data;
                        toDelete ->key = curnt ->key;
                        toDelete ->data = curnt ->data;
                        //update the parent's pointer and delete the node
                        if(workStack ->top() == curnt){
                            //We never traveled down the tree
                            workStack ->pop();
                        }
                        CGRAVLTreeNode<KEY, DATA> *node = workStack ->pop();
                        if (node ->left == curnt) {
                            node ->left = curnt ->right;
                        }else{
                            node ->right = curnt ->right;
                        }
                        delete curnt;
                        _numberOfNodes--;
                        break;
                    }
                }else{
                    curnt = toDelete ->left;
                    if(curnt != NULL && (curnt ->left != NULL || curnt ->right != NULL)){
                        //Swap the values
                        
                        if(workStack ->count != 1){
                            //Update the parent
                            retVal = toDelete ->data;
                            CGRAVLTreeNode<KEY, DATA> *node = workStack ->pop();
                            CGRAVLTreeNode<KEY, DATA> *parent = workStack ->top();
                            if (parent ->left == toDelete) {
                                parent ->left = curnt;
                            }else{
                                parent ->right = curnt;
                            }
                            workStack ->push(node);
                            delete toDelete;
                            _numberOfNodes--;
                            break;
                        }else{
                            //Replace the root
                            retVal = rootNode ->data;
                            delete rootNode;
                            rootNode = curnt;
                            _numberOfNodes--;
                            break;
                        }
                    }
                }
                if(curnt == NULL){
                    //We are deleting a leaf
                    //Update the parent
                    if(workStack ->count != 1){
                        retVal = toDelete ->data;
                        CGRAVLTreeNode<KEY, DATA> *node = workStack ->pop();
                        CGRAVLTreeNode<KEY, DATA> *parent = workStack ->top();
                        if(parent ->left == toDelete) {
                            parent ->left = NULL;
                        }else
                            parent ->right = NULL;
                        delete toDelete;
                    }else{
                        //We are deleting the root
                        rootNode = NULL;
                        delete toDelete;
                    }
                }else{
                    retVal = toDelete ->data;
                    toDelete ->key = curnt ->key;
                    toDelete ->data = curnt ->data;
                    CGRAVLTreeNode<KEY, DATA> *node = workStack ->pop();
                    if (node ->left == curnt) {
                        node ->left = NULL;
                    }else{
                        node ->right = NULL;
                    }
                    
                    delete curnt;
                }
                _numberOfNodes--;
                break;
                
            }
        }
        
        
        //Now recalculate the heigh of the tree and reblance if necessary
        bool finished = false;
        uint32_t stackSize = workStack ->count();
        for(uint32_t i=0; i != stackSize; i++){
            if(finished){
                break;
            }
            uint32_t leftHeight, rightHeight;
            leftHeight = 0;
            rightHeight = 0;
            CGRAVLTreeNode<KEY, DATA> *node = workStack ->pop();
            if(node ->left != NULL){
                leftHeight = node ->left ->height;
            }
            if(node ->right != NULL){
                rightHeight = node ->right ->height;
            }
            uint32_t difference = 0;
            difference = (leftHeight > rightHeight)?leftHeight - rightHeight:rightHeight - leftHeight;
            if(difference < 2){
                //No rebalance is needed
                if(node ->left == NULL && node ->right == NULL){
                    node ->height = 0;
                }else{
                    node ->height =  (leftHeight > rightHeight)?leftHeight + 1:rightHeight + 1;
                }
                continue;
            }
            //If we get here then we need to rebalance the tree..
            uint32_t startHeight = node ->height;
            rebalance(node);
            if(node -> height == startHeight){
                finished = true;
            }
            
        }
        return retVal;
    }
    
    DATA *dataForKey(KEY key)
    {
        //First look for the data
        if(keyComparator == NULL)
            return NULL;
        
        //Look for the node and if its not present then update the heigh of the tree and rebalance if necessary
        
        if (rootNode == NULL) {
            return NULL;
        }
        
        CGRAVLTreeNode<KEY, DATA> *curnt = rootNode;
        while(true){
            int res = keyComparator(&(curnt ->key),&key);
            
            if(res < 0){
                if(curnt -> right == NULL){
                    return NULL;
                }
                curnt = curnt ->right;
                continue;
            }else if(res > 0){
                if(curnt ->left == NULL){
                    return NULL;
                }
                curnt = curnt ->left;
                continue;
            }
            return curnt ->data;
        }
    }
    
    bool containsKey(KEY key)
    {
        //First look for the data
        if(keyComparator == NULL)
            return false;
        
        //Look for the node and if its not present then update the heigh of the tree and rebalance if necessary
        
        if (rootNode == NULL) {
            return false;
        }
        
        CGRAVLTreeNode<KEY, DATA> *curnt = rootNode;
        while(true){
            int res = keyComparator(&(curnt ->key),&key);
            
            if(res < 0){
                if(curnt -> right == NULL){
                    return false;
                }
                curnt = curnt ->right;
                continue;
            }else if(res > 0){
                if(curnt ->left == NULL){
                    return false;
                }
                curnt = curnt ->left;
                continue;
            }
            return true;
        }
    }
    
    uint32_t numberOfNodes()
    {
        return _numberOfNodes;
    }
    struct CGRAVLTreeKeys<KEY> keySet()
    {
        struct CGRAVLTreeKeys<KEY> keys;
        keys.size = this ->numberOfNodes();
        keys.keys = (KEY *)malloc(sizeof(KEY)*keys.size);
        
        
        
        //CGRCircularVector<KEY> *keys = new CGRCircularVector<KEY>(this ->numberOfNodes(),this ->numberOfNodes());
        /*if(keys == NULL) {
         NSException *e = [NSException exceptionWithName:@"CGRAVLTree" reason:@"No enough memory for keys vector" userInfo:nil];
         @throw e;
         }*/
        //Inorder trasversal...
        basicStack *stack = NULL;
        CGRAVLTreeNode<KEY, DATA> *curntNode = rootNode;
        uint32_t curntKeyIndex = 0;
        while(stack != NULL || curntNode != NULL){
            if(curntNode != NULL){
                try {
                    stack = pushIntoStack(stack, curntNode);
                }
                catch (CGRAVLTreeNotEnoughSpace exception) {
                    //NSException *e = [NSException exceptionWithName:@"CGRAVLTree" reason:@"No enough memory for keys vector" userInfo:nil];
                    //uint32_t keysSize = keys ->count();
                    /*for(uint32_t i=0; i != keysSize; i++){
                     delete keys ->elementAtIndex(i);
                     }*/
                    free(keys.keys);
                    throw exception;
                    
                }
                
                curntNode = curntNode ->left;
            }else{
                CGRAVLTreeNode<KEY, DATA> *node = popFromStack(&stack);
                /*KEY *key = new KEY;
                 if(key == NULL){
                 NSException *e = [NSException exceptionWithName:@"CGRAVLTree" reason:@"No enough memory for keys vector" userInfo:nil];
                 cleanStack(stack);
                 
                 uint32_t keysSize = keys ->size();
                 for(uint32_t i=0; i != keysSize; i++){
                 delete keys ->elementAtIndex(i);
                 }
                 throw e;
                 }
                 memcpy(key, &node ->key, sizeof(KEY));*/
                keys.keys[curntKeyIndex++] = node ->key;
                curntNode = node ->right;
            }
        }
        return keys;
    }
    
    void removeAllNodes()
    {
        _removeNode(rootNode);
        rootNode = NULL;
        _numberOfNodes = 0;
    }
    
    
    
    
};




#endif
