//
//  ADHelper.c
//  Phykids
//
//  Created by Sumit Kumar on 6/18/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

double PerpendicularDistance(CGPoint Point1, CGPoint Point2, CGPoint Point)
{
    double area = abs(.5 * (Point1.x * Point2.y + Point2.x *
                            Point.y + Point.x * Point1.y - Point2.x * Point1.y - Point.x *
                            Point2.y - Point1.x * Point.y));
    double bottom = sqrt(pow(Point1.x - Point2.x, 2) +
                         pow(Point1.y - Point2.y, 2));
    double height = area / bottom * 2;
    
    return height;
}

void DouglasPeuckerReduction(NSArray *points, int firstPoint, int lastPoint, double tolerance, NSMutableArray *pointIndexsToKeep)
{
    double maxDistance = 0;
    int indexFarthest = 0;
    
    for (int index = firstPoint; index < lastPoint; index++)
    {
        NSValue *point1 = [points objectAtIndex:firstPoint];
        NSValue *point2 = [points objectAtIndex:lastPoint];
        NSValue *point = [points objectAtIndex:index];
        double distance = PerpendicularDistance(point1.CGPointValue,point2.CGPointValue,point.CGPointValue);
        if (distance > maxDistance)
        {
            maxDistance = distance;
            indexFarthest = index;
        }
    }
    
    if (maxDistance > tolerance && indexFarthest != 0)
    {
        //Add the largest point that exceeds the tolerance
        [pointIndexsToKeep addObject:[NSNumber numberWithInt:indexFarthest]];
        
        DouglasPeuckerReduction(points,firstPoint,indexFarthest,tolerance,pointIndexsToKeep);
        DouglasPeuckerReduction(points,indexFarthest,lastPoint,tolerance,pointIndexsToKeep);
    }
}

BOOL arePointsEqual(CGPoint point1, CGPoint point2)
{
    if ((point1.x == point2.x) && (point1.y == point2.y)) {
        return TRUE;
    }
    return FALSE;
}

NSArray* reducePoints(NSArray *Points,double Tolerance)
{
    if (Points==NULL) {
        return Points;
    }
    int i_count = [Points count];
    if (i_count < 3)
        return Points;
    
    int firstPoint = 0;
    int lastPoint = i_count - 1;
    NSMutableArray *pointIndexsToKeep = [[NSMutableArray alloc] init];
    
    
    //Add the first and last index to the keepers
    [pointIndexsToKeep addObject:[NSNumber numberWithInt:firstPoint]];
    [pointIndexsToKeep addObject:[NSNumber numberWithInt:lastPoint]];
    
    
    //The first and the last point cannot be the same
    NSValue *point1 = [Points objectAtIndex:firstPoint];
    NSValue *point2 = [Points objectAtIndex:lastPoint];
    
    while (arePointsEqual(point1.CGPointValue,point2.CGPointValue)) {
        lastPoint--;
    }
    
    DouglasPeuckerReduction(Points,firstPoint,lastPoint,Tolerance,pointIndexsToKeep);
    
    
    NSMutableArray *returnPoints = [NSMutableArray array];
    [pointIndexsToKeep sortUsingSelector:@selector(compare:)];
    
    for (NSNumber *index in pointIndexsToKeep)
    {
        [returnPoints addObject:[Points objectAtIndex:[index intValue]]];
    }
    if ([returnPoints count]<3) {
        return Points;
    }
    return returnPoints;
}

BOOL isConvexPolygon(NSArray *points)
{
	int i,j,k;
	int flag = 0;
	double z;
	int n = [points count];
	if (n < 3)
		return TRUE;
    
	for (i=0;i<n;i++) {
		j = (i + 1) % n;
		k = (i + 2) % n;
        
		NSValue *pointi = [points objectAtIndex:i];
		NSValue *pointj = [points objectAtIndex:j];
		NSValue *pointk = [points objectAtIndex:k];
        
		z  = (((pointj.CGPointValue).x - (pointi.CGPointValue).x) * ((pointk.CGPointValue).y - (pointj.CGPointValue).y));
		z -= (((pointj.CGPointValue).y - (pointi.CGPointValue).y) * ((pointk.CGPointValue).x - (pointj.CGPointValue).x));
		if (z < 0)
			flag |= 1;
        else if (z > 0)
            flag |= 2;
        if (flag == 3)
            return FALSE;
	}
	if (flag != 0)
		return TRUE;
	else
		return TRUE;
}

BOOL isPad()
{
#ifdef UI_USER_INTERFACE_IDIOM
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif
    return NO;
}

UIColor* randomColor()
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}