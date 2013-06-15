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
    
//    SKPhysicsBody *body = [self.physicsWorld bodyAtPoint:point];
//    if (body) {
//        SKNode *node = body.node;
//        [ADNodeFactory tranformNode:node withMatrix:CGAffineTransformMakeRotation(M_PI/4)];
//        return;
//    }
    SKNode *node = [ADNodeManager nodeOfType:ADNodeTypeSprite subType:ADNodeSubTypeRectangle atPoint:point];
    [node setPaused:self.isPaused];
    [self addChild:node];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)playPauseScene
{
    self.isPaused = !self.isPaused;
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKShapeNode *node = (SKShapeNode*)obj;
        [node setPaused:self.isPaused];
    }];
}

@end
