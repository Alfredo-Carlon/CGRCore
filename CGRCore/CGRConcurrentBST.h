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
        uint32_t lock;
        struct BST_Node *left, *right;
    };
    
    struct BST_Node *root;
    int32_t ticketDispenser;
    
    typedef int (*comparator)(TREE_DATA *element1, TREE_DATA *element2);
    
    comparator elementComparator;
    
};
#endif
