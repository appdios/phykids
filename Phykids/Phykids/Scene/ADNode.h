//
//  ADNode.h
//  Phykids
//
//  Created by Aditi Kamal on 6/23/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ADRope.h"

@interface ADNode : SKShapeNode
@property (nonatomic) ADNodeType nodeType;
@property (nonatomic, strong) SKPhysicsJoint *joint;
@property (nonatomic) CGPoint originalPosition;
@property (nonatomic) CGPoint startPositionA;
@property (nonatomic) CGPoint startPositionB;

+ (ADNode*)rectangleNodeInRect:(CGRect)rect;
+ (ADNode*)circularNodeInRect:(CGRect)rect;
+ (ADNode*)polygonNodeWithPoints:(NSArray*)points;
+ (ADNode*)gearNodeInRect:(CGRect)rect forScene:(SKScene*)scene;


+ (ADNode*)jointOfType:(ADNodeType)type betweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB inSecene:(SKScene*)scene;
+ (ADNode*)jointOfType:(ADNodeType)type betweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB anchorA:(CGPoint)pointA anchorB:(CGPoint)pointB inSecene:(SKScene*)scene;
+ (ADNode*)jointOfType:(ADNodeType)type betweenPointA:(CGPoint)pointA pointB:(CGPoint)pointB inSecene:(SKScene*)scene;

+ (ADNode*)physicsJointForJoint:(ADNode*)node inScene:(SKScene*)scene;

- (void)update:(NSTimeInterval)currentTime;
- (void)didSimulatePhysics;

- (void)remove;
- (void)highlight;
- (void)unHighlight;
@end
