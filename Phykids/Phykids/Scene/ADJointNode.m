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
            CGPoint positionA = CGPointMake(self.nodeA.position.x + self.anchorPointOffsetA.x, self.nodeA.position.y + self.anchorPointOffsetA.y);
            CGFloat radius = distanceBetween(self.nodeA.position, positionA);
            CGPoint rotatedPoint = CGPointMake(radius * cosf(self.nodeA.zRotation), radius * sinf(self.nodeA.zRotation));
            self.position = CGPointMake(self.nodeA.position.x + rotatedPoint.x, self.nodeA.position.y + rotatedPoint.y);
        }
            break;
        case ADPhysicsJointTypeRope:
        {
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPoint positionA = CGPointMake(self.nodeA.position.x + self.anchorPointOffsetA.x, self.nodeA.position.y + self.anchorPointOffsetA.y);
            CGFloat radius = distanceBetween(self.nodeA.position, positionA);
            CGPoint rotatedPoint = CGPointMake(radius * cos(self.nodeA.zRotation), radius * sin(self.nodeA.zRotation));
            self.position = CGPointMake(self.nodeA.position.x + rotatedPoint.x, self.nodeA.position.y + rotatedPoint.y);
            
            CGPathMoveToPoint(pathRef, nil, 0, 0);
            CGPathAddArc(pathRef, nil, 0,0, 2, 0, M_PI * 2, YES);
            CGPathMoveToPoint(pathRef, nil, 0, 0);
            CGPathAddLineToPoint(pathRef, nil, self.nodeB.position.x - self.position.x, self.nodeB.position.y - self.position.y);
            CGPathAddArc(pathRef, nil, self.nodeB.position.x - self.position.x,self.nodeB.position.y - self.position.y, 2, 0, M_PI * 2, YES);
            self.path = pathRef;
        }
            break;
        case ADPhysicsJointTypeSpring:
        {
            CGMutablePathRef pathRef = CGPathCreateMutable();
            self.position = self.nodeA.position;
            CGPathMoveToPoint(pathRef, nil, 0, 0);
            CGPathAddLineToPoint(pathRef, nil, self.nodeB.position.x - self.position.x, self.nodeB.position.y - self.position.y);
            self.path = pathRef;
        }
            break;
        default:
            break;
    }
}

@end
