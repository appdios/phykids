//
//  ADMathHelper.m
//  Phykids
//
//  Created by Aditi Kamal on 6/17/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADMathHelper.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (180.0 * x / M_PI)

@implementation ADMathHelper

double angleBetweenPoints(CGPoint point1, CGPoint point2)
{
    double deltaX = point1.x - point2.x;
    double deltaY = point1.y - point2.y;
    double angleInDegrees = atan2(deltaY, deltaX);
    
    return angleInDegrees;
}
@end
