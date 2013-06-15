//
//  ADScene.m
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADScene.h"
#import "ADNodeManager.h"

@interface ADScene()
@property (nonatomic) BOOL isPaused;
@property (nonatomic, strong) SKPhysicsJointLimit *mouseJoint;
@property (nonatomic, strong) SKNode *mouseNode;
@end

@implementation ADScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.isPaused = YES;
    }
    return self;
}

#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInNode:self];
    
    SKPhysicsBody *body = [self.physicsWorld bodyAtPoint:point];
    if (body) {
        SKNode *node = body.node;
        [ADNodeManager setCurrentNode:node];
        if (self.isPaused) {
            
        }
        else
        {
            [self destroyMouseNode];
            [self createMouseNodeAtPoint:point];
        }
        
    }
    else
    {
        SKNode *node = [ADNodeManager nodeOfType:ADNodeTypeSprite subType:ADNodeSubTypeRectangle atPoint:point];
        [node setPaused:self.isPaused];
        [self addChild:node];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInNode:self];
    self.mouseNode.position = point;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self destroyMouseNode];
}

- (void)playPauseScene
{
    self.isPaused = !self.isPaused;
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKShapeNode *node = (SKShapeNode*)obj;
        [node setPaused:self.isPaused];
    }];
}

- (void)createMouseNodeAtPoint:(CGPoint)point
{
    self.mouseNode = [SKSpriteNode spriteNodeWithImageNamed:@"touchImage"];
    self.mouseNode.position = point;
    [self addChild:self.mouseNode];
    
    SKPhysicsBody *mouseBody = [SKPhysicsBody bodyWithCircleOfRadius:20];
    [mouseBody setDynamic:NO];
    [self.mouseNode setPhysicsBody:mouseBody];
    
    self.mouseJoint = [SKPhysicsJointLimit jointWithBodyA:[ADNodeManager currentNode].physicsBody bodyB:self.mouseNode.physicsBody anchorA:[ADNodeManager currentNode].position anchorB:point];
    self.mouseJoint.maxLength = 10;
    [self.physicsWorld addJoint:self.mouseJoint];
}

- (void)destroyMouseNode
{
    if (self.mouseNode) {
        [self.mouseNode removeFromParent];
        self.mouseNode = nil;
    }
    if (self.mouseJoint) {
        [self.physicsWorld removeJoint:self.mouseJoint];
        self.mouseJoint = nil;
    }
}
@end
