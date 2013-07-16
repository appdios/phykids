//
//  ADSpriteNode.h
//  Phykids
//
//  Created by Aditi Kamal on 6/30/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ADSpriteNode : SKSpriteNode

@property (nonatomic) ADNodeType nodeType;
@property (nonatomic, strong) SKPhysicsJoint *joint;
@property (nonatomic) CGPoint originalPosition;

+ (ADSpriteNode*)pivotJointBetweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB inSecene:(SKScene*)scene;
+ (ADSpriteNode*)pivotJointBetweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB anchorA:(CGPoint)pointA anchorB:(CGPoint)pointB inSecene:(SKScene*)scene;
+ (ADSpriteNode*)pivotJointAtPoint:(CGPoint)point inSecene:(SKScene*)scene;

+ (ADSpriteNode*)physicsJointForJoint:(ADSpriteNode*)node inScene:(SKScene*)scene;

- (void)update:(NSTimeInterval)currentTime;
- (void)didSimulatePhysics;

- (void)remove;
- (void)updatePositionByDistance:(CGPoint)distancePoint;
@end
