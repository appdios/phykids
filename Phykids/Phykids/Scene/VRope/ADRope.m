

#import "ADRope.h"

@interface ADRope()
{
    NSInteger numPoints;
	CGFloat antiSagHack;
    SKNode* spriteSheet;
}
@property (nonatomic, strong) NSMutableArray *ropePoints;
@property (nonatomic, strong) NSMutableArray *ropeSticks;
@property (nonatomic, strong) NSMutableArray *ropeNodes;
@end

@implementation ADRope

- (id)initWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB spriteSheet:(SKNode*)spriteSheetArg{
	if((self = [super init])) {
		spriteSheet = spriteSheetArg;
        self.ropePoints = [NSMutableArray array];
        self.ropeSticks = [NSMutableArray array];
        self.ropeNodes = [NSMutableArray array];
		[self createRope:pointA pointB:pointB];
	}
	return self;
}


- (void)createRope:(CGPoint)pointA pointB:(CGPoint)pointB {
	
	float distance = distanceBetween(pointA,pointB);
	int segmentFactor = 12; //increase value to have less segments per rope, decrease to have more segments
	numPoints = distance/segmentFactor;
	CGPoint diffVector = CGPointMake(pointB.x - pointA.x, pointB.y - pointA.y);
	float multiplier = distance / (numPoints-1);
	antiSagHack = 0.1f; //HACK: scale down rope points to cheat sag. set to 0 to disable, max suggested value 0.1
	for(int i=0;i<numPoints;i++) {
		CGPoint tmpVector = addPoints(pointA, multiplyPoint(normalizePoint(diffVector),multiplier*i*(1-antiSagHack)));
		ADRopePoint *tmpPoint = [[ADRopePoint alloc] init];
		[tmpPoint setPos:tmpVector.x y:tmpVector.y];
		[self.ropePoints addObject:tmpPoint];
	}
	for(int i=0;i<numPoints-1;i++) {
		ADStick *tmpStick = [[ADStick alloc] initWith:[self.ropePoints objectAtIndex:i] pointb:[self.ropePoints objectAtIndex:i+1]];
		[self.ropeSticks addObject:tmpStick];
	}
	if(spriteSheet!=nil) {
		for(int i=0;i<numPoints-1;i++) {
			ADRopePoint *point1 = [[self.ropeSticks objectAtIndex:i] getPointA];
			ADRopePoint *point2 = [[self.ropeSticks objectAtIndex:i] getPointB];
		//	CGPoint stickVector = subtractPoints(CGPointMake(point1.x,point1.y),CGPointMake(point2.x,point2.y));
		//	float stickAngle = pointToAngle(stickVector);
            
            SKShapeNode *node = [SKShapeNode node];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathAddArc(pathRef, nil, 0,0, 4, 0, M_PI * 2, YES);
            node.path = pathRef;
            CGPathRelease(pathRef);
            
            node.strokeColor = [UIColor brownColor];
            node.fillColor = [UIColor brownColor];
            node.position = subtractPoints(midpointOfPoints(CGPointMake(point1.x,point1.y),CGPointMake(point2.x,point2.y)), spriteSheet.position);
            //node.zRotation = -1 * RADIANS_TO_DEGREES(stickAngle);

            [spriteSheet addChild:node];
            [self.ropeNodes addObject:node];
		}
	}
}

-(void)resetWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB {
	float distance = distanceBetween(pointA,pointB);
	CGPoint diffVector = subtractPoints(pointB,pointA);
	float multiplier = distance / (numPoints - 1);
	for(int i=0;i<numPoints;i++) {
		CGPoint tmpVector = addPoints(pointA, multiplyPoint(normalizePoint(diffVector),multiplier*i*(1-antiSagHack)));
		ADRopePoint *tmpPoint = [self.ropePoints objectAtIndex:i];
		[tmpPoint setPos:tmpVector.x y:tmpVector.y];
		
	}
}


-(void)updateWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB dt:(float)dt {
	//manually set position for first and last point of rope
    if ([self.ropePoints count]<numPoints) {
        return;
    }
    if (numPoints==0 || [self.ropePoints count]==0) {
        return;
    }
	[[self.ropePoints objectAtIndex:0] setPos:pointA.x y:pointA.y];
	[[self.ropePoints objectAtIndex:numPoints-1] setPos:pointB.x y:pointB.y];
	
	//update points, apply gravity
	for(int i=1;i<numPoints-1;i++) {
		[[self.ropePoints objectAtIndex:i] applyGravity:dt];
		[[self.ropePoints objectAtIndex:i] update];
	}
	
	//contract sticks
	int iterations = 4;
	for(int j=0;j<iterations;j++) {
		for(int i=0;i<numPoints-1;i++) {
			[[self.ropeSticks objectAtIndex:i] contract];
		}
	}
}

-(void)updateSprites {
	if(spriteSheet!=nil) {
		for(int i=0;i<numPoints-1;i++) {
			ADRopePoint *point1 = [[self.ropeSticks objectAtIndex:i] getPointA];
			ADRopePoint *point2 = [[self.ropeSticks objectAtIndex:i] getPointB];
			CGPoint point1_ = CGPointMake(point1.x,point1.y);
			CGPoint point2_ = CGPointMake(point2.x,point2.y);
		//	float stickAngle = pointToAngle(subtractPoints(point1_,point2_));
			
            SKNode *tmpSprite = [self.ropeNodes objectAtIndex:i];
			[tmpSprite setPosition:subtractPoints(midpointOfPoints(point1_,point2_),spriteSheet.position)];
			//[tmpSprite setZRotation: -1 * RADIANS_TO_DEGREES(stickAngle)];
		}
	}	
}

-(void)updateSpritesWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB {
	float distance = distanceBetween(pointA,pointB);
	CGPoint diffVector = subtractPoints(pointB,pointA);
	float multiplier = distance / (numPoints-1);
	antiSagHack = 0.0f; //HACK: scale down rope points to cheat sag. set to 0 to disable, max suggested value 0.1
	for(int i=0;i<numPoints-1;i++) {
		CGPoint tmpVector = addPoints(pointA, multiplyPoint(normalizePoint(diffVector),multiplier*i*(1-antiSagHack)));
		CGPoint point1 = CGPointMake(tmpVector.x, tmpVector.y);
		
		CGPoint tmpVector2 = addPoints(pointA, multiplyPoint(normalizePoint(diffVector),multiplier*(i+1)*(1-antiSagHack)));
		CGPoint point2 = CGPointMake(tmpVector2.x, tmpVector2.y);
		
		CGPoint stickVector = subtractPoints(CGPointMake(point1.x,point1.y),CGPointMake(point2.x,point2.y));
		float stickAngle = pointToAngle(stickVector);
		
		SKNode *tmpSprite = [self.ropeNodes objectAtIndex:i];
		[tmpSprite setPosition:subtractPoints(midpointOfPoints(point1,point2),spriteSheet.position)];
		[tmpSprite setZRotation: -RADIANS_TO_DEGREES(stickAngle)];
		
	}
	
	
}


@end
