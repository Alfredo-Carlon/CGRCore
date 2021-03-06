//
//  CGRGeometricCommon.h
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

#import <Foundation/Foundation.h>
#define PI 3.14159265

enum CGRTurn{
    CGRLeftTurn,
    CGRRightTurn,
    CGRCollinear,
    CGRInvalid
};

struct polarCoord
{
    double radius;
    double angle;
};

//Returns a new polar coord
struct polarCoord newPolarCoord(double radius, double angle);

enum CGRTurn __leftright(NSPoint p0,NSPoint p1, NSPoint p2);
//The difference vector d = p-q
NSPoint __diffVector(NSPoint p, NSPoint q);
//The sum vector d = p+q
NSPoint __sumVector(NSPoint p, NSPoint q);
//The dot product between two vectors
double __dotProduct(NSPoint p, NSPoint q);
//The norm of a vector
double __norm(NSPoint p);
//the p1,ref,p2 angle in counter clockwise order
CGFloat __angleBetweenP1P2WithRef(NSPoint p1,NSPoint p2,NSPoint ref);

NSPoint __intersectionPoint(NSPoint p0,NSPoint p1,NSPoint p2, NSPoint p3);
