//
//  CGRGeometricCommon.m
//  CGRCore
//
//  Created by Alfredo Cruz on 10/23/14.
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

#import "CGRGeometricCommon.h"

enum CGRTurn __leftright(NSPoint p0,NSPoint p1, NSPoint p2){
    CGFloat res = (p1.x - p0.x)*(p2.y - p0.y) - (p1.y - p0.y)*(p2.x - p0.x);
    if(fabs(res) < 0.000001)
        return CGRCollinear;
    if(res > 0)
        return CGRLeftTurn;
    if(res < 0)
        return CGRRightTurn;
    return CGRCollinear;
}

NSPoint __diffVector(NSPoint p, NSPoint q){
    NSPoint diff;
    diff.x = p.x - q.x;
    diff.y = p.y - q.y;
    return diff;
}
NSPoint __sumVector(NSPoint p, NSPoint q)
{
    return NSMakePoint(p.x + q.x, p.y + q.y);
}
//The dot product between two vectors
double __dotProduct(NSPoint p, NSPoint q){
    return p.x*q.x + p.y*q.y;
}

//The norm of a vector
double __norm(NSPoint p)
{
    return sqrt(__dotProduct(p, p));
}
//the p1,ref,p2 angle in counter clockwise order
CGFloat __angleBetweenP1P2WithRef(NSPoint p1,NSPoint p2,NSPoint ref){
    NSPoint p = __diffVector(p1, ref);
    NSPoint q = __diffVector(p2, ref);
    return acos(__dotProduct(p, q)/(__norm(p)*__norm(q)));
}

NSPoint __intersectionPoint(NSPoint p0,NSPoint p1,NSPoint p2, NSPoint p3)
{
    NSPoint dirVec1, dirVec2;
    dirVec1 = __diffVector(p1, p0);
    dirVec2 = __diffVector(p3, p2);
    double term1 = (p2.x - p0.x)*dirVec1.y;
    double term2 = -1*(p2.y - p0.y)*dirVec1.x;
    double term = term1 + term2;
    double coef = dirVec2.x*dirVec1.y - dirVec2.y*dirVec1.x;
    double alpha = term/coef;
    NSPoint intersection;
    intersection.x = alpha*dirVec2.x + p2.x;
    intersection.y = alpha*dirVec2.y + p2.y;
    return intersection;
}
struct polarCoord newPolarCoord(double radius, double angle)
{
    struct polarCoord cord;
    cord.radius = radius;
    cord.angle = angle;
    return cord;
}
