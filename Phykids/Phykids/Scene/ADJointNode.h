//
//  ADJointNode.h
//  Phykids
//
//  Created by Sumit Kumar on 6/20/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum
{
    ADPhysicsJointTypePivot,
    ADPhysicsJointTypeRope
}ADPhysicsJointType;

@interface ADJointNode : SKShapeNode

@property (nonatomic, strong) SKPhysicsJoint *joint;

+ (ADJointNode*)jointOfType:(ADPhysicsJointType)type betweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB;
- (void)update;
@end
