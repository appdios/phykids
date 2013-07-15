//
//  ADSpriteNode.m
//  Phykids
//
//  Created by Aditi Kamal on 6/30/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADSpriteNode.h"
#import "ADNode.h"

@interface ADSpriteNode()

@property (nonatomic, strong) SKNode *nodeA;
@property (nonatomic, strong) SKNode *nodeB;
@property (nonatomic) CGPoint anchorPointOffsetA;
@property (nonatomic) CGPoint anchorPointOffsetB;

@end

@implementation ADSpriteNode

+ (ADSpriteNode*)pivotJointBetweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB inSecene:(SKScene*)scene
{
    return [self pivotJointBetweenNodeA:nodeA nodeB:nodeB anchorA:nodeA.position anchorB:nodeB.position inSecene:scene];
}

+ (ADSpriteNode*)pivotJointBetweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB anchorA:(CGPoint)pointA anchorB:(CGPoint)pointB inSecene:(SKScene*)scene
{
    ADSpriteNode *joint = [ADSpriteNode spriteNodeWithImageNamed:@"pivot"];
    joint.nodeType = ADNodeTypePivot;
    joint.nodeA = nodeA;
    joint.nodeB = nodeB;
    joint.anchorPointOffsetA = CGPointMake(pointA.x - nodeA.position.x,pointA.y - nodeA.position.y);
    joint.anchorPointOffsetB = CGPointMake(pointB.x - nodeB.position.x,pointB.y - nodeB.position.y);
    
    SKPhysicsJointPin *pinJoint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchor:pointA];
    joint.joint = pinJoint;
    joint.position = pointA;
    joint.originalPosition = joint.position;
    return joint;
}

+ (ADSpriteNode*)pivotJointAtPoint:(CGPoint)point inSecene:(SKScene*)scene
{
    ADSpriteNode *joint = [ADSpriteNode spriteNodeWithImageNamed:@"pivot"];
    joint.nodeType = ADNodeTypePivot;
    joint.originalPosition = point;
    joint.position = point;

    return joint;
}

+ (ADSpriteNode*)physicsJointForJoint:(ADSpriteNode*)node inScene:(SKScene*)scene
{
    if (node.nodeType == ADNodeTypePivot) {
        NSArray *shapeNodes = [scene nodesAtPoint:node.position];
        ADNode *node1 = nil;
        ADNode *node2 = nil;
        for (ADNode *shapeNode in shapeNodes) {
            if (shapeNode.nodeType < ADNodeTypePivot) {
                if (node1 == nil) {
                    node1 = shapeNode;
                }
                else if(node2 == nil)
                {
                    node2 = shapeNode;
                    break;
                }
            }
        }
        if (node1 || node2) {
            ADSpriteNode *newNode = [ADSpriteNode pivotJointBetweenNodeA:node1?node1:scene nodeB:node2?node2:scene anchorA:node.position anchorB:node.position inSecene:scene];
            [node remove];
            return newNode;
        }
        else{
            [node remove];
        }
    }
    return nil;
}

- (void)update:(NSTimeInterval)currentTime
{
    CGPoint positionA = CGPointMake(self.nodeA.position.x + self.anchorPointOffsetA.x, self.nodeA.position.y + self.anchorPointOffsetA.y);
    CGPoint rotatedPoint = rotatePoint(positionA, self.nodeA.zRotation, self.nodeA.position);
    self.position = rotatedPoint;
}

- (void)didSimulatePhysics
{

}

- (void)remove
{
    [self removeFromParent];
}

- (void)highlight
{

}

- (void)unHighlight
{

}

@end
