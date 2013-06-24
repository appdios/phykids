

#import "ADStick.h"
@interface ADStick() {
	ADRopePoint *pointA;
	ADRopePoint *pointB;
	CGFloat hypotenuse;
}
@end

@implementation ADStick
- (id)initWith:(ADRopePoint*)argA pointb:(ADRopePoint*)argB {
	if((self = [super init])) {
		pointA = argA;
		pointB = argB;
		hypotenuse = distanceBetween(CGPointMake(pointA.x, pointA.y), CGPointMake(pointB.x, pointB.y));
	}
	return self;
}

- (void)contract {
	float dx = pointB.x - pointA.x;
	float dy = pointB.y - pointA.y;
	float h = distanceBetween(CGPointMake(pointA.x, pointA.y), CGPointMake(pointB.x, pointB.y));
	float diff = hypotenuse - h;
	float offx = (diff * dx / h) * 0.5;
	float offy = (diff * dy / h) * 0.5;
	pointA.x-=offx;
	pointA.y-=offy;
	pointB.x+=offx;
	pointB.y+=offy;
}

- (ADRopePoint*)getPointA {
	return pointA;
}

- (ADRopePoint*)getPointB {
	return pointB;
}
@end
