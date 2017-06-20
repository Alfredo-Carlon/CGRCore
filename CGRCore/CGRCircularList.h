//
//  CGRCircularList.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/12/14.
//  Copyright (c) 2014 Alfredo Cruz. All rights reserved.
//

#ifndef CGRCore_CGRCircularList_h
#define CGRCore_CGRCircularList_h
template <class LIST_DATA>
struct _CGRCircularListNode
{
    LIST_DATA data;
    struct _CGRCircularListNode<LIST_DATA> *next;
    struct _CGRCircularListNode<LIST_DATA> *prev;
    _CGRCircularListNode(LIST_DATA d, _CGRCircularListNode<LIST_DATA> *p, _CGRCircularListNode<LIST_DATA> *n)
    {
        data = d;
        next = n;
        prev = p;
    }
};

template <class LIST_DATA>
class CGRCircularList {
    struct _CGRCircularListNode<LIST_DATA> *head;
    struct _CGRCircularListNode<LIST_DATA> *tail;
    
    struct _CGRCircularListNode<LIST_DATA> *iterationPtr;
    uint32_t _numberOfNodes;
    
    
    //Deleted pool
    struct _CGRCircularListNode<LIST_DATA> *deletedPoolHead;
    struct _CGRCircularListNode<LIST_DATA> *deletedPoolTail;
    
    //Links first to newNode and last to newNode
    void _linkNodesToNode(_CGRCircularListNode<LIST_DATA> *first, _CGRCircularListNode<LIST_DATA> *newNode, _CGRCircularListNode<LIST_DATA> *last){
        if(first == NULL){
            //We didn't have elements so newNode is the first one
            head = newNode;
            tail = newNode;
            iterationPtr = newNode;
            head ->prev = tail;
            tail ->next = head;
            return;
        }
        first ->next = newNode;
        last ->prev = newNode;
    }
    
    struct _CGRCircularListNode<LIST_DATA> *_newNode(LIST_DATA data, _CGRCircularListNode<LIST_DATA> *prev, _CGRCircularListNode<LIST_DATA> *next)
    {
        struct _CGRCircularListNode<LIST_DATA> *newNode;
        if(deletedPoolHead){
            newNode = deletedPoolHead;
            deletedPoolHead = deletedPoolHead ->next;
            newNode ->data = data;
            newNode ->next = next;
            newNode ->prev = prev;
        }else{
            newNode = new _CGRCircularListNode<LIST_DATA>(data,prev,next);
        }
        _numberOfNodes++;
        return newNode;
    }
    void _removeNode(_CGRCircularListNode<LIST_DATA> *node)
    {
        if(node ->next){
            node ->next ->prev = node ->prev;
            node ->prev ->next = node ->next;
        }else{
            head = NULL;
            tail = NULL;
            iterationPtr = NULL;
        }
        if (node == head) {
            head = node ->next;
        }
        if(node == tail){
            tail = node ->prev;
        }
        node ->next = NULL;
        node ->prev = NULL;
        _numberOfNodes--;
        if(deletedPoolHead){
            deletedPoolTail ->next = node;
            deletedPoolTail = deletedPoolTail ->next;
        }else{
            deletedPoolHead = node;
            deletedPoolTail = node;
        }
    }
    
public:
    CGRCircularList()
    {
        head = NULL;
        tail = NULL;
        iterationPtr = NULL;
        deletedPoolHead = NULL;
        deletedPoolTail = NULL;
        _numberOfNodes = 0;
    }
    ~CGRCircularList()
    {
        tail ->next = NULL;
        while (head) {
            struct _CGRCircularListNode<LIST_DATA> *tmp = head;
            head = head ->next;
            delete tmp;
        }
        while (deletedPoolHead) {
            struct _CGRCircularListNode<LIST_DATA> *tmp = deletedPoolHead;
            deletedPoolHead = deletedPoolHead ->next;
            delete tmp;
        }
        head = NULL;
        tail = NULL;
        iterationPtr = NULL;
    }
    //Adds a new element at the tail of the list
    void add(LIST_DATA newElement)
    {
        struct _CGRCircularListNode<LIST_DATA> *newNode = _newNode(newElement, tail,head);
        _linkNodesToNode(tail,newNode,head);
        tail = newNode;
    }
    //Inserts the element at 'index', index is circular so it may be greater than the number
    //of actual nodes in the list
    void insertAtIndex(LIST_DATA element, uint32_t index)
    {
        struct _CGRCircularListNode<LIST_DATA> *iter = head;
        while (iter) {
            if (!index)
                break;
            iter = iter ->next;
        }
        struct _CGRCircularListNode<LIST_DATA> *newNode;
        
        newNode = _newNode(element, NULL, NULL);
        
        if(iter){
            newNode ->next = iter;
            newNode ->prev = iter ->prev;
        }
        _linkNodesToNode(newNode ->prev, newNode, newNode ->next);
    }
    
    //Inserts the element at the position of the iterator, the iterator doesn't change
    void insertAtIterator(LIST_DATA element)
    {
        if(iterationPtr){
            struct _CGRCircularListNode<LIST_DATA> *newNode;
            newNode = _newNode(element, iterationPtr ->prev, iterationPtr);
            _linkNodesToNode(iterationPtr ->prev, newNode, iterationPtr);
        }else{
            add(element);
        }
    }
    
    //Returns the element where the iterator points if the list is empty it throws an exception
    LIST_DATA elementAtIterator()
    {
        if (iterationPtr) {
            return  iterationPtr ->data;
        }
        throw -1;
    }
    //Advances the iterator pointer by one and returns the data in the node
    //Throws an exception if the list is empty
    LIST_DATA nextElement(){
        if (iterationPtr) {
            iterationPtr = iterationPtr ->next;
            return iterationPtr ->data;
        }
        throw -1;
    }
    //Pulls back the iterator by one and returns the data in the node
    //Throws an exception if the list is empty
    LIST_DATA prevElement()
    {
        if(iterationPtr){
            iterationPtr = iterationPtr ->prev;
            return iterationPtr ->data;
        }
        throw -1;
    }
    //Advances the iterator "places" times and returns the data in the node
    //Throws an exception if the list is empty
    LIST_DATA advanceIterator(uint32_t places)
    {
        if(iterationPtr){
            while(places){
                iterationPtr = iterationPtr ->next;
                places--;
            }
            return iterationPtr ->data;
        }
        throw -1;
    }
    //Backs the iterator up by "places" and returns the data in the node
    //throws an exception if the list is empty
    LIST_DATA backupIterator(uint32_t places)
    {
        if (iterationPtr) {
            while(places){
                iterationPtr = iterationPtr ->prev;
                places--;
            }
            return iterationPtr ->data;
        }
        throw -1;
    }
    
    
    //Removes the data at the iterator, if the list is empty then throws an exception
    //the iterator points to the next node in the list
    LIST_DATA removeAtIterator()
    {
        if(!iterationPtr)
            throw -1;
        
        struct _CGRCircularListNode<LIST_DATA> *tmp = iterationPtr ->next;
        LIST_DATA returnData = iterationPtr ->data;
        _removeNode(iterationPtr);
        iterationPtr = tmp;
        return returnData;
    }
    
    //Returns the number of nodes in the list
    uint32_t numberOfNodes()
    {
        return _numberOfNodes;
    }
    
};

#endif
