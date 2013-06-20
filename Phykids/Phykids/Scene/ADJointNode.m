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
@end
@implementation ADJointNode

+ (ADJointNode*)jointOfType:(ADPhysicsJointType)type betweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB
{
    ADJointNode *joint = [[ADJointNode alloc] init];
    joint.jointType = type;
    joint.nodeA = nodeA;
    joint.nodeB = nodeB;
    switch (type) {
        case ADPhysicsJointTypePivot:
        {
            SKPhysicsJointLimit *limitJoint = [SKPhysicsJointLimit jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchorA:nodeA.position anchorB:nodeA.position];
            limitJoint.maxLength = 0.1;
            joint.joint = limitJoint;
            joint.path = CGPathCreateWithEllipseInRect(CGRectMake(-5, -5, 10, 10), nil);
            joint.fillColor = [SKColor blackColor];
            joint.position = nodeA.position;
        }
            break;
        case ADPhysicsJointTypeRope:
        {
            SKPhysicsJointLimit *limitJoint = [SKPhysicsJointLimit jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchorA:nodeA.position anchorB:nodeB.position];
            limitJoint.maxLength = distanceBetween(nodeA.position, nodeB.position);
            joint.joint = limitJoint;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, 0, 0);
            CGPathAddLineToPoint(pathRef, nil, nodeB.position.x - nodeA.position.x, nodeB.position.y - nodeA.position.y);
            joint.path = pathRef;
            joint.position = nodeA.position;
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
            self.position = self.nodeA.position;
        }
            break;
        case ADPhysicsJointTypeRope:
        {
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, 0, 0);
            CGPathAddLineToPoint(pathRef, nil, self.nodeB.position.x - self.nodeA.position.x, self.nodeB.position.y - self.nodeA.position.y);
            self.path = pathRef;
            self.position = self.nodeA.position;
        }
            break;
        default:
            break;
    }
}

@end
