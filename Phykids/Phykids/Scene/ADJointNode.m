//
//  ADJointNode.m
//  Phykids
//
//  Created by Sumit Kumar on 6/20/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADJointNode.h"
#import "ADRope.h"

@interface ADJointNode()

@property (nonatomic) ADPhysicsJointType jointType;
@property (nonatomic, strong) SKNode *nodeA;
@property (nonatomic, strong) SKNode *nodeB;
@property (nonatomic) CGPoint anchorPointOffsetA;
@property (nonatomic) CGPoint anchorPointOffsetB;
@property (nonatomic) CGPoint startPositionA;
@property (nonatomic) CGPoint startPositionB;
@property (nonatomic, strong) ADRope *vRope;

@end
@implementation ADJointNode

+ (ADJointNode*)jointOfType:(ADPhysicsJointType)type betweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB inSecene:(SKScene*)scene
{
    return [self jointOfType:type betweenNodeA:nodeA nodeB:nodeB anchorA:nodeA.position anchorB:nodeB.position inSecene:scene];
}

+ (ADJointNode*)jointOfType:(ADPhysicsJointType)type betweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB anchorA:(CGPoint)pointA anchorB:(CGPoint)pointB inSecene:(SKScene*)scene
{
    ADJointNode *joint = [[ADJointNode alloc] init];
    joint.jointType = type;
    joint.nodeA = nodeA;
    joint.nodeB = nodeB;
    joint.startPositionA = pointA;
    joint.startPositionB = pointB;
    joint.anchorPointOffsetA = CGPointMake(pointA.x - nodeA.position.x,pointA.y - nodeA.position.y);
    joint.anchorPointOffsetB = CGPointMake(pointB.x - nodeB.position.x,pointB.y - nodeB.position.y);
    
    switch (type) {
        case ADPhysicsJointTypePivot:
        {
            SKPhysicsJointPin *pinJoint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchor:pointA];
            joint.joint = pinJoint;
            CGPathRef pathRef = CGPathCreateWithEllipseInRect(CGRectMake(-5, -5, 10, 10), nil);
            joint.path = pathRef;
            CGPathRelease(pathRef);
            joint.fillColor = [SKColor blackColor];
            joint.strokeColor = [UIColor brownColor];
            joint.position = pointA;
        }
            break;
        case ADPhysicsJointTypeRope:
        {
            SKPhysicsJointLimit *limitJoint = [SKPhysicsJointLimit jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchorA:pointA anchorB:pointB];
            limitJoint.maxLength = distanceBetween(pointA, pointB);
            joint.joint = limitJoint;
            joint.position = pointA;
            
            joint.vRope = [[ADRope alloc] initWithPoints:pointA pointB:pointB spriteSheet:scene];
            
            joint.strokeColor = [SKColor blackColor];
        }
            break;
        case ADPhysicsJointTypeSpring:
        {
            SKPhysicsJointSpring *springJoint = [SKPhysicsJointSpring jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchorA:pointA anchorB:pointB];
            springJoint.damping = 0.4;
            springJoint.frequency = 4.0;
            joint.joint = springJoint;
            joint.position = pointA;
            
            CGPathRef pathRef = [joint newSpringPath:joint.position pointB:pointB];
            joint.path = pathRef;
            CGPathRelease(pathRef);
            joint.strokeColor = [UIColor blackColor];
        }
            break;
        default:
            break;
    }
    return joint;
}

- (void)update:(NSTimeInterval)currentTime
{
    
    switch (self.jointType) {
        case ADPhysicsJointTypePivot:
        {
            [self updatePivot];
        }
            break;
        case ADPhysicsJointTypeRope:
        {
            [self updateRope];
        }
            break;
        case ADPhysicsJointTypeSpring:
        {
            [self updateSpring];
        }
            break;
        default:
            break;
    }
}

- (void)didSimulatePhysics
{
    switch (self.jointType) {
        case ADPhysicsJointTypeRope:
        {
            [self.vRope updateSprites];
        }
            break;
        
        default:
            break;
    }
}

- (void)updatePivot
{
    CGPoint positionA = CGPointMake(self.nodeA.position.x + self.anchorPointOffsetA.x, self.nodeA.position.y + self.anchorPointOffsetA.y);
    CGPoint rotatedPoint = rotatePoint(positionA, self.nodeA.zRotation, self.nodeA.position);
    self.position = rotatedPoint;
}

- (void) updateRope
{
    CGPoint positionA = CGPointMake(self.nodeA.position.x + self.anchorPointOffsetA.x, self.nodeA.position.y + self.anchorPointOffsetA.y);
    CGPoint rotatedPointA = rotatePoint(positionA, self.nodeA.zRotation, self.nodeA.position);
    self.position = rotatedPointA;
    
    CGPoint positionB = CGPointMake(self.nodeB.position.x + self.anchorPointOffsetB.x, self.nodeB.position.y + self.anchorPointOffsetB.y);
    CGPoint rotatedPointB = rotatePoint(positionB, self.nodeB.zRotation, self.nodeB.position);

    [self.vRope updateWithPoints:rotatedPointA pointB:rotatedPointB dt:0.04];
}

- (void) updateSpring
{
    CGPoint positionA = CGPointMake(self.nodeA.position.x + self.anchorPointOffsetA.x, self.nodeA.position.y + self.anchorPointOffsetA.y);
    CGPoint rotatedPointA = rotatePoint(positionA, self.nodeA.zRotation, self.nodeA.position);
    self.position = rotatedPointA;
    
    CGPoint positionB = CGPointMake(self.nodeB.position.x + self.anchorPointOffsetB.x, self.nodeB.position.y + self.anchorPointOffsetB.y);
    CGPoint rotatedPointB = rotatePoint(positionB, self.nodeB.zRotation, self.nodeB.position);
    
    CGPathRef pathRef = [self newSpringPath:self.position pointB:rotatedPointB];
    self.path = pathRef;
    CGPathRelease(pathRef);
}

- (CGPathRef)newRopePath:(CGPoint)pointA pointB:(CGPoint)pointB{

    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, nil, 0, 0);
    CGPathAddArc(pathRef, nil, 0,0, 2, 0, M_PI * 2, YES);
    CGPathMoveToPoint(pathRef, nil, 0, 0);
    CGPathAddLineToPoint(pathRef, nil, pointB.x - pointA.x, pointB.y - pointA.y);
    CGPathAddArc(pathRef, nil, pointB.x - pointA.x, pointB.y - pointA.y, 2, 0, M_PI * 2, YES);
    
    if ([self.children count]) {
        [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx==0) {
                ((SKNode*)obj).position = CGPointZero;
            }
            else if (idx==1) {
                ((SKNode*)obj).position = CGPointMake(pointB.x - pointA.x, pointB.y - pointA.y);
            }
        }];
    }
    else
    {
        [self addChild:[self createNodeAtPoint:CGPointZero]];
        [self addChild:[self createNodeAtPoint:CGPointMake(pointB.x - pointA.x, pointB.y - pointA.y)]];
    }    

    return pathRef;
}

-(CGPathRef)newSpringPath:(CGPoint)pointA pointB:(CGPoint)pointB{
	[self removeAllChildren];
    
    CGFloat distance = distanceBetween(pointA, pointB);
    CGFloat height = distanceBetween(self.startPositionA, self.startPositionB)*0.08;
    if (height>20) {
        height = 20;
    }
	CGFloat numberOfV = 12;
	
    CGPoint point1 = CGPointMake(pointA.x, pointA.y);
	CGPoint  point2 = CGPointMake(pointA.x+1*(distance/numberOfV), pointA.y);
	CGPoint  point3 = CGPointMake(pointA.x+2*(distance/numberOfV), pointA.y-height);
	CGPoint  point4 = CGPointMake(pointA.x+3*(distance/numberOfV), pointA.y+ height);
	CGPoint  point5 = CGPointMake(pointA.x+4*(distance/numberOfV), pointA.y- height);
	CGPoint  point6 = CGPointMake(pointA.x+5*(distance/numberOfV), pointA.y+ height);
	CGPoint  point7 = CGPointMake(pointA.x+6*(distance/numberOfV), pointA.y- height);
	CGPoint  point8 = CGPointMake(pointA.x+7*(distance/numberOfV), pointA.y+ height);
	CGPoint  point9 = CGPointMake(pointA.x+8*(distance/numberOfV), pointA.y- height);
	CGPoint  point10 = CGPointMake(pointA.x+9*(distance/numberOfV), pointA.y+ height);
	CGPoint  point11 = CGPointMake(pointA.x+10*(distance/numberOfV), pointA.y-height);
	CGPoint  point12 = CGPointMake(pointA.x+11*(distance/numberOfV), pointA.y);
	CGPoint  point13 = CGPointMake(pointA.x+12*(distance/numberOfV), pointA.y) ;
	
	double angleInRadian = atan2(pointB.y-pointA.y,pointB.x-pointA.x);
    
	
    point2 = rotatePoint(point2, angleInRadian, pointA);
	point3 = rotatePoint(point3, angleInRadian, pointA);
	point4 = rotatePoint(point4, angleInRadian, pointA);
	point5 = rotatePoint(point5, angleInRadian, pointA);
	point6 = rotatePoint(point6, angleInRadian, pointA);
	point7 = rotatePoint(point7, angleInRadian, pointA);
	point8 = rotatePoint(point8, angleInRadian, pointA);
	point9 = rotatePoint(point9, angleInRadian, pointA);
	point10 = rotatePoint(point10, angleInRadian, pointA);
	point11 = rotatePoint(point11, angleInRadian, pointA);
	point12 = rotatePoint(point12, angleInRadian, pointA);
	point13 = rotatePoint(point13, angleInRadian, pointA);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGPathMoveToPoint(pathRef, nil, point1.x - pointA.x, point1.y - pointA.y);
    CGPathAddArc(pathRef, nil, 0,0, 2, 0, M_PI * 2, YES);
    
    CGPathMoveToPoint(pathRef, nil, point1.x - pointA.x, point1.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point2.x - pointA.x, point2.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point3.x - pointA.x, point3.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point4.x - pointA.x, point4.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point5.x - pointA.x, point5.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point6.x - pointA.x, point6.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point7.x - pointA.x, point7.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point8.x - pointA.x, point8.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point9.x - pointA.x, point9.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point10.x - pointA.x, point10.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point11.x - pointA.x, point11.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point12.x - pointA.x, point12.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point13.x - pointA.x, point13.y - pointA.y);
    
    CGPathAddArc(pathRef, nil, point13.x - pointA.x, point13.y - pointA.y, 2, 0, M_PI * 2, YES);
    
    [self addChild:[self createNodeAtPoint:CGPointMake(point1.x - pointA.x, point1.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point2.x - pointA.x, point2.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point3.x - pointA.x, point3.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point4.x - pointA.x, point4.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point5.x - pointA.x, point5.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point6.x - pointA.x, point6.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point7.x - pointA.x, point7.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point8.x - pointA.x, point8.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point9.x - pointA.x, point9.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point10.x - pointA.x, point10.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point11.x - pointA.x, point11.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point12.x - pointA.x, point12.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point13.x - pointA.x, point13.y - pointA.y)]];

    
    return pathRef;
}

- (SKNode*)createNodeAtPoint:(CGPoint)p
{
    CGMutablePathRef pathRef = CGPathCreateMutable();

    CGPathAddArc(pathRef, nil, 0, 0, 2, 0, M_PI * 2, YES);
    SKShapeNode *node = [SKShapeNode node];
    node.strokeColor = [UIColor brownColor];
    node.path = pathRef;
    CGPathRelease(pathRef);
    
    node.position = p;
    return node;
}


@end
