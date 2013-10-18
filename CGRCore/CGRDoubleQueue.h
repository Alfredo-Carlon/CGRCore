//
//  CGRDoubleQueue.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/14/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#ifndef CGRCore_CGRDoubleQueue_h
#define CGRCore_CGRDoubleQueue_h

template <class QUEUE_DATA>
struct queueData
{
    QUEUE_DATA data;
    struct queueData *next;
};

template <class QUEUE_DATA>
class CGRDoubleQueue {
    struct queueData<QUEUE_DATA> *head;
    struct queueData<QUEUE_DATA> *tail;
    int32_t headLock,tailLock,ticketDispenser;
    QUEUE_DATA nullValue;
    
public:
    DoubleQueue(QUEUE_DATA nv)
    {
        head = NULL;
        tail = NULL;
        headLock = 0;
        tailLock = 0;
        ticketDispenser = 0;
        nullValue = nv;
    }
    ~DoubleQueue()
    {
        int32_t newTicket = OSAtomicIncrement32((volatile int32_t *)&ticketDispenser);
        while(!newTicket)
            newTicket = OSAtomicIncrement32((volatile int32_t *)&ticketDispenser);
        while(!OSAtomicCompareAndSwap32(0,newTicket,(volatile int32_t *)&headLock));
        
        //Free the elements
        while(head != NULL){
            struct queueData<QUEUE_DATA> *obj = head;
            head = head ->next;
            free(obj);
        }
        OSAtomicCompareAndSwap32(newTicket,0,(volatile int32_t *)&headLock);
    }
    bool add(QUEUE_DATA newData)
    {
        struct queueData<QUEUE_DATA> *element = malloc(sizeof(struct queueData<QUEUE_DATA>));
        if(element == NULL)
            return NO;
        element ->data = newData;
        element ->next = NULL;
        //Now lock the tail..
        int32_t newTicket = OSAtomicIncrement32((volatile int32_t *)&ticketDispenser);
        while(!newTicket)
            newTicket = OSAtomicIncrement32((volatile int32_t *)&ticketDispenser);
        while(!OSAtomicCompareAndSwap32(0,newTicket,(volatile int32_t *)&tailLock));
        //If the tail is NULL then we lock the head also
        if(tail == NULL){
            while(!OSAtomicCompareAndSwap32(0,newTicket,(volatile int32_t *)&headLock));
            //set the head and the tail
            head = element;
            tail = element;
            //Release both locks tail first
            OSAtomicCompareAndSwap32(newTicket,0,(volatile int32_t *)&tailLock);
            return YES;
            
        }else{
            //We don't need to lock the head
            tail ->next = element;
            tail = element;
            OSAtomicCompareAndSwap32(newTicket,0,(volatile int32_t *)&tailLock);
            return YES;
        }
    }
    QUEUE_DATA get()
    {
        //Lock the head
        int32_t newTicket = OSAtomicIncrement32((volatile int32_t *)&ticketDispenser);
        while(!newTicket)
            newTicket = OSAtomicIncrement32((volatile int32_t *)&ticketDispenser);
        while(!OSAtomicCompareAndSwap32(0,newTicket,(volatile int32_t *)&headLock));
        
        if(head == NULL){
            OSAtomicCompareAndSwap32(newTicket,0,(volatile int32_t *)&headLock);
            return nullValue;
        }
        struct queueData<QUEUE_DATA> *obj = head;
        head = head ->next;
        OSAtomicCompareAndSwap32(newTicket,0,(volatile int32_t *)&headLock);
        QUEUE_DATA data = obj ->data;
        free(obj);
        return data;
    }
    
};

#endif
