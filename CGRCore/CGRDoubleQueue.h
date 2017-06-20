//
//  CGRDoubleQueue.h
//  CGRCore
//
//  Created by Alfredo Cruz on 10/14/13.
//  Copyright (c) 2013 Alfredo Cruz.
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
    CGRDoubleQueue(QUEUE_DATA nv)
    {
        head = NULL;
        tail = NULL;
        headLock = 0;
        tailLock = 0;
        ticketDispenser = 0;
        nullValue = nv;
    }
    ~CGRDoubleQueue()
    {
        int32_t newTicket = OSAtomicIncrement32((volatile int32_t *)
                                                &ticketDispenser);
        while(!newTicket)
            newTicket = OSAtomicIncrement32((volatile int32_t *)
                                            &ticketDispenser);
        while(!OSAtomicCompareAndSwap32(0,newTicket,(volatile int32_t *)
                                        &headLock));
        
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
        struct queueData<QUEUE_DATA> *element = (struct queueData<QUEUE_DATA> *)
                malloc(sizeof(struct queueData<QUEUE_DATA>));
        if(element == NULL)
            return NO;
        element ->data = newData;
        element ->next = NULL;
        //Now lock the tail..
        int32_t newTicket = OSAtomicIncrement32((volatile int32_t *)
                                                &ticketDispenser);
        while(!newTicket)
            newTicket = OSAtomicIncrement32((volatile int32_t *)
                                            &ticketDispenser);
        while(!OSAtomicCompareAndSwap32(0,newTicket,(volatile int32_t *)
                                        &tailLock));
        //If the tail is NULL then we lock the head also
        if(head == NULL){
            while(!OSAtomicCompareAndSwap32(0,newTicket,(volatile int32_t *)
                                            &headLock));
            //set the head and the tail
            head = element;
            tail = element;
            //Release both locks tail first
            OSAtomicCompareAndSwap32(newTicket,0,(volatile int32_t *)&tailLock);
            OSAtomicCompareAndSwap32(newTicket,0,(volatile int32_t *)&headLock);
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
        int32_t newTicket = OSAtomicIncrement32((volatile int32_t *)
                                                &ticketDispenser);
        while(!newTicket)
            newTicket = OSAtomicIncrement32((volatile int32_t *)
                                            &ticketDispenser);
        while(!OSAtomicCompareAndSwap32(0,newTicket,(volatile int32_t *)
                                        &headLock));
        
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
