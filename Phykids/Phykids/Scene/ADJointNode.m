//
//  ADJointNode.m
//  Phykids
//
//  Created by Sumit Kumar on 6/20/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADJointNode.h"

@interface ADJointNode()

@property (nonatomic) ADPhysicsJointType jointType;
@property (nonatomic, strong) SKNode *nodeA;
@property (nonatomic, strong) SKNode *nodeB;
@property (nonatomic) CGPoint anchorPointOffsetA;
@property (nonatomic) CGPoint anchorPointOffsetB;

@end
@implementation ADJointNode

+ (ADJointNode*)jointOfType:(ADPhysicsJointType)type betweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB
{
    return [self jointOfType:type betweenNodeA:nodeA nodeB:nodeB anchorA:nodeA.position anchorB:nodeB.position];
}

+ (ADJointNode*)jointOfType:(ADPhysicsJointType)type betweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB anchorA:(CGPoint)pointA anchorB:(CGPoint)pointB
{
    ADJointNode *joint = [[ADJointNode alloc] init];
    joint.jointType = type;
    joint.nodeA = nodeA;
    joint.nodeB = nodeB;
    joint.anchorPointOffsetA = CGPointMake(pointA.x - nodeA.position.x,pointA.y - nodeA.position.y);
    joint.anchorPointOffsetB = CGPointMake(pointB.x - nodeB.position.x,pointB.y - nodeB.position.y);
    
    switch (type) {
        case ADPhysicsJointTypePivot:
        {
            SKPhysicsJointPin *pinJoint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchor:pointA];
            joint.joint = pinJoint;
            joint.path = CGPathCreateWithEllipseInRect(CGRectMake(-5, -5, 10, 10), nil);
            joint.fillColor = [SKColor blackColor];
            joint.position = pointA;
        }
            break;
        case ADPhysicsJointTypeRope:
        {
            SKPhysicsJointLimit *limitJoint = [SKPhysicsJointLimit jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchorA:pointA anchorB:pointB];
            limitJoint.maxLength = distanceBetween(pointA, pointB);
            joint.joint = limitJoint;
            joint.position = pointA;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, 0, 0);
            CGPathAddLineToPoint(pathRef, nil, pointB.x - joint.position.x, pointB.y - joint.position.y);
            joint.path = pathRef;
            joint.strokeColor = [SKColor blackColor];
        }
            break;
        case ADPhysicsJointTypeSpring:
        {
            SKPhysicsJointSpring *springJoint = [SKPhysicsJointSpring jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchorA:pointA anchorB:pointB];
            springJoint.damping = 0.5;
            springJoint.frequency = 4.0;
            joint.joint = springJoint;
            joint.position = pointA;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, 0, 0);
            CGPathAddLineToPoint(pathRef, nil, pointB.x - joint.position.x, pointB.y - joint.position.y);
            joint.path = pathRef;
            joint.strokeColor = [SKColor blackColor];
        }
            break;
        default:
            break;
    }
    return joint;
}

- (void)update
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
            [self updateRope];
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
   // CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPoint positionA = CGPointMake(self.nodeA.position.x + self.anchorPointOffsetA.x, self.nodeA.position.y + self.anchorPointOffsetA.y);
    CGPoint rotatedPointA = rotatePoint(positionA, self.nodeA.zRotation, self.nodeA.position);
    self.position = rotatedPointA;
    
    CGPoint positionB = CGPointMake(self.nodeB.position.x + self.anchorPointOffsetB.x, self.nodeB.position.y + self.anchorPointOffsetB.y);
    CGPoint rotatedPointB = rotatePoint(positionB, self.nodeB.zRotation, self.nodeB.position);
    
    CGPathRef pathRef = [self createVertices:self.position pointB:rotatedPointB];
//    CGPathMoveToPoint(pathRef, nil, 0, 0);
//    CGPathAddArc(pathRef, nil, 0,0, 2, 0, M_PI * 2, YES);
//    CGPathMoveToPoint(pathRef, nil, 0, 0);
//    CGPathAddLineToPoint(pathRef, nil, rotatedPointB.x - self.position.x, rotatedPointB.y - self.position.y);
//    CGPathAddArc(pathRef, nil, rotatedPointB.x - self.position.x, rotatedPointB.y - self.position.y, 2, 0, M_PI * 2, YES);
    self.path = pathRef;
}

CGPoint updatePoint(CGPoint point,CGPoint originPoint, double angleInRadian)
{
	// get coordinates relative to center
    double dx = point.x - originPoint.x;
    double dy = point.y - originPoint.y;
    // calculate angle and distance
    double a = atan2(dy, dx);
    double dist = sqrt(dx * dx + dy * dy);
    // calculate new angle
    double a2 = a + angleInRadian;
    // calculate new coordinates
    double dx2 = cos(a2) * dist;
    double dy2 = sin(a2) * dist;
    // return coordinates relative to top left corner
    point.x = dx2 + originPoint.x;
    point.y = dy2 + originPoint.y;
    return point;
}

-(CGPathRef)createVertices:(CGPoint)pointA pointB:(CGPoint)pointB{
	
    CGFloat distance = distanceBetween(pointA, pointB);
    CGFloat height = distance*0.08;
	CGFloat numberOfV = 12;
	
    CGPoint point1 = CGPointMake(pointA.x,pointA.y);
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
    
	
    point2 = updatePoint(point2,pointA,angleInRadian);
	point3 = updatePoint(point3,pointA,angleInRadian);
	point4 = updatePoint(point4,pointA,angleInRadian);
	point5 = updatePoint(point5,pointA,angleInRadian);
	point6 = updatePoint(point6,pointA,angleInRadian);
	point7 = updatePoint(point7,pointA,angleInRadian);
	point8 = updatePoint(point8,pointA,angleInRadian);
	point9 = updatePoint(point9,pointA,angleInRadian);
	point10 = updatePoint(point10,pointA,angleInRadian);
	point11 = updatePoint(point11,pointA,angleInRadian);
	point12 = updatePoint(point12,pointA,angleInRadian);
	point13 = updatePoint(point13,pointA,angleInRadian);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, nil, point1.x, point1.y);
    CGPathAddLineToPoint(pathRef, nil, point2.x, point2.y);
    CGPathAddLineToPoint(pathRef, nil, point3.x, point3.y);
    CGPathAddLineToPoint(pathRef, nil, point4.x, point4.y);
    CGPathAddLineToPoint(pathRef, nil, point5.x, point5.y);
    CGPathAddLineToPoint(pathRef, nil, point6.x, point6.y);
    CGPathAddLineToPoint(pathRef, nil, point7.x, point7.y);
    CGPathAddLineToPoint(pathRef, nil, point8.x, point8.y);
    CGPathAddLineToPoint(pathRef, nil, point9.x, point9.y);
    CGPathAddLineToPoint(pathRef, nil, point10.x, point10.y);
    CGPathAddLineToPoint(pathRef, nil, point11.x, point11.y);
    CGPathAddLineToPoint(pathRef, nil, point12.x, point12.y);
    CGPathAddLineToPoint(pathRef, nil, point13.x, point13.y);
    
    return pathRef;
}


@end
