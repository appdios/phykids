//
//  ADHelper.h
//  Phykids
//
//  Created by Sumit Kumar on 6/18/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#ifndef Phykids_ADHelper_h
#define Phykids_ADHelper_h

#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180


NSArray* reducePoints(NSArray *Points,double Tolerance);
BOOL isConvexPolygon(NSArray *points);
BOOL isPad();
UIColor* randomColor();
CGPoint polygonCentroid(NSArray* vertices);
CGFloat distanceBetween(CGPoint point1,CGPoint point2);
CGPoint rotatePoint(CGPoint p, float angle, CGPoint centerPoint);
CGPoint subtractPoints(const CGPoint v1, const CGPoint v2);
CGPoint multiplyPoint(const CGPoint v, const CGFloat s);
CGPoint normalizePoint(const CGPoint v);
CGPoint addPoints(const CGPoint v1, const CGPoint v2);
CGPoint angleToPoint(const CGFloat a);
CGFloat pointToAngle(const CGPoint v);
CGPoint midpointOfPoints(const CGPoint v1, const CGPoint v2);
#endif
