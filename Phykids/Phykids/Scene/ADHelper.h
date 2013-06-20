//
//  ADHelper.h
//  Phykids
//
//  Created by Sumit Kumar on 6/18/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#ifndef Phykids_ADHelper_h
#define Phykids_ADHelper_h

NSArray* reducePoints(NSArray *Points,double Tolerance);
BOOL isConvexPolygon(NSArray *points);
BOOL isPad();
UIColor* randomColor();
CGPoint polygonCentroid(NSArray* vertices);
CGFloat distanceBetween(CGPoint point1,CGPoint point2);

#endif
