//
//  CGRCommonTypes.h
//  CGRCore
//
//  Created by Alfredo Cruz on 11/7/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#ifndef __CGRCore__CGRCommonTypes__
#define __CGRCore__CGRCommonTypes__


typedef struct CGREdge
{
    unsigned int vertex1;
    unsigned int vertex2;
}CGREdge;

CGREdge makeEdge(unsigned int p, unsigned int q);


int edgeComparison(unsigned int *i, unsigned int *j);

#endif /* defined(__CGRCore__CGRCommonTypes__) */
