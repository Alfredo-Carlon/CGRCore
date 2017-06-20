//
//  CGRBSTree.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/2/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#ifndef CGRCore_CGRBSTree_h
#define CGRCore_CGRBSTree_h

#include <libkern/OSAtomic.h>
#include <stdlib.h>


template <class TREE_DATA>
class CGRConcurrentBST
{
private:
    struct BST_Node
    {
        TREE_DATA *data;
        int32_t lock;
        struct BST_Node *left, *right;
        BST_Node(){
            lock = 0;
            data = NULL;
            left = NULL;
            right = NULL;
        }
        BST_Node(TREE_DATA *data){
            lock = 0;
            this ->data = data;
            left = NULL;
            right = NULL;
        }
    };
    
    struct BST_Node *root;
    int32_t ticketDispenser;
    
    typedef int (*comparator)(TREE_DATA *element1, TREE_DATA *element2);
    
    comparator elementComparator;
    
public:
    
    CGRConcurrentBST()
    {
        root = new BST_Node();
        elementComparator = NULL;
        ticketDispenser = 0;
    }
    CGRConcurrentBST(int (*comp)(TREE_DATA *element1, TREE_DATA *element2))
    {
        root = new BST_Node();
        elementComparator = comp;
        ticketDispenser = 0;
    }
    void add(TREE_DATA *data){
        if(elementComparator == NULL)
            return;
        //First get a ticket
        int32_t ticket = OSAtomicIncrement32((volatile int32_t *)&ticketDispenser);
        while(ticket == 0){
            ticket = OSAtomicIncrement32((volatile int32_t *)&ticketDispenser);
        }
        struct BST_Node *curnt = root;
        //find the right place for the node..
        while(true){
            while(!OSAtomicCompareAndSwap32(0, ticket, (volatile int32_t *)(&(curnt ->lock))));
            int result = elementComparator(curnt ->data,data);
            if (result == 0) {
                OSAtomicCompareAndSwap32(ticket,0, (volatile int32_t *)(&(curnt ->lock)));
                return;
            }
            struct BST_Node *next;
            if(result < 0){
                if(curnt ->left == NULL){
                    struct BST_Node *newNode = new BST_Node(data);
                    curnt ->left = newNode;
                    OSAtomicCompareAndSwap32(ticket,0, (volatile int32_t *)(&(curnt ->lock)));
                    return;
                }else
                    next = curnt ->left;
            }else{
                if(curnt ->right == NULL){
                    struct BST_Node *newNode = new BST_Node(data);
                    curnt ->right = newNode;
                    OSAtomicCompareAndSwap32(ticket,0, (volatile int32_t *)(&(curnt ->lock)));
                    return;
                }else
                    next = curnt ->right;
            }
            OSAtomicCompareAndSwap32(ticket,0, (volatile int32_t *)(&(curnt ->lock)));
            curnt = next;
        }
    }
    
};
#endif
