
//  ADScene.m
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADScene.h"
#import "ADNodeManager.h"
#import "ADJointNode.h"

@interface ADScene()
@property (nonatomic) BOOL isPaused;
@property (nonatomic, strong) SKPhysicsJointLimit *mouseJoint;
@property (nonatomic, strong) SKNode *mouseNode;
@property (nonatomic, strong) SKNode *currentNode;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic, strong) NSMutableArray *touchPoints;

@end

@implementation ADScene

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.isPaused = NO;
        self.touchPoints = [NSMutableArray array];
        self.physicsWorld.speed = 1.0;
    }
    return self;
}

#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInNode:self];
    
    self.currentNode = nil;
    SKPhysicsBody *body = [self.physicsWorld bodyAtPoint:point];
    if (body && !self.isPaused) {
        SKNode *node = body.node;
        [self destroyMouseNode];
        [self createMouseNodeWithNode:node atPoint:point];
    }
    else if (body && self.isPaused) {
        SKShapeNode *node = (SKShapeNode*)body.node;
        [self.delegate showSelectionViewForNode:node];
    }
    else
    {
        self.startPoint = point;
        self.currentNode = [ADNodeManager nodeOfType:[ADPropertyManager selectedNodeType] atPoint:point];
        [self.currentNode setPaused:self.isPaused];
        [self addChild:self.currentNode];
        [ADPropertyManager setCurrentFillColor:((SKShapeNode*)self.currentNode).fillColor];
        
        [self.touchPoints removeAllObjects];
        [self.touchPoints addObject:[NSValue valueWithCGPoint:self.startPoint]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInNode:self];
    if (self.mouseNode) {
        self.mouseNode.position = point;
    }
    
    if (self.currentNode) {
        
        switch ([ADPropertyManager selectedNodeType]) {
            case ADNodeTypeRectangle:
            {
                [self.currentNode removeFromParent];
                self.currentNode = nil;
                
                self.currentNode = [ADNodeManager rectangleNodeInRect:CGRectMake(self.startPoint.x, self.startPoint.y, point.x - self.startPoint.x, point.y - self.startPoint.y)];
            }
                break;
            case ADNodeTypeCircle:
            {
                [self.currentNode removeFromParent];
                self.currentNode = nil;
                
                CGFloat radius = MAX(abs((point.x - self.startPoint.x)), abs((point.y - self.startPoint.y)));
                self.currentNode = [ADNodeManager circularNodeInRect:CGRectMake(self.startPoint.x, self.startPoint.y, radius*2.0, radius*2.0)];
            }
                break;
            case ADNodeTypePolygon:
            {
                [self.touchPoints addObject:[NSValue valueWithCGPoint:point]];
                if ([self.touchPoints count]>=3) {
                    NSArray *reducedPoints = reducePoints(self.touchPoints,10);
                    [self.currentNode removeFromParent];
                    self.currentNode = nil;
                    self.currentNode = [ADNodeManager polygonNodeWithPoints:reducedPoints];
                }
            }
                break;
            default:
                break;
        }
        if (self.currentNode) {
            if (![self.currentNode.parent isEqual:self]) {
                [self addChild:self.currentNode];
            }
        }
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.mouseNode) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInNode:self];
        CGPoint previousPoint = [touch previousLocationInNode:self];
        [self.mouseJoint.bodyA setVelocity:CGPointMake((point.x - previousPoint.x)*20, (point.y - previousPoint.y)*20)];
        [self destroyMouseNode];
    }
    if (self.currentNode) {
        NSArray *reducedPoints = reducePoints(self.touchPoints,10);
        BOOL isConvex = isConvexPolygon(reducedPoints);
        if (isConvex) {
            [ADNodeManager setPhysicsBodyToNode:self.currentNode];

            
            SKNode *tempNode = [SKSpriteNode spriteNodeWithColor:[UIColor darkGrayColor] size:CGSizeMake(20, 20)];
            tempNode.position = CGPointMake(self.frame.size.width/2, 400);
            [self addChild:tempNode];
            tempNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(20, 20)];
            [tempNode.physicsBody setDynamic:NO];
            
           ADJointNode *jointNode = [ADJointNode jointOfType:ADPhysicsJointTypeSpring betweenNodeA:self.currentNode nodeB:tempNode anchorA:CGPointMake(self.currentNode.position.x-self.currentNode.frame.size.width/2, self.currentNode.position.y+self.currentNode.frame.size.height/2) anchorB:tempNode.position];
            [self.physicsWorld addJoint:jointNode.joint];

            [self addChild:jointNode];
            
        }
        else{
            [self.currentNode removeFromParent];
        }
        [ADPropertyManager setCurrentFillColor:nil];
    }
}

- (void)playPauseScene
{
    self.isPaused = !self.isPaused;
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKShapeNode *node = (SKShapeNode*)obj;
        [node setPaused:self.isPaused];
    }];
}

- (void)createMouseNodeWithNode:(SKNode*)node atPoint:(CGPoint)point
{
    self.mouseNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"touchImage"] size:CGSizeMake(20, 20)];
    self.mouseNode.position = point;
    [self addChild:self.mouseNode];
    
    SKPhysicsBody *mouseBody = [SKPhysicsBody bodyWithCircleOfRadius:5];
    [mouseBody setDynamic:NO];
    [self.mouseNode setPhysicsBody:mouseBody];
    
    self.mouseJoint = [SKPhysicsJointLimit jointWithBodyA:node.physicsBody bodyB:self.mouseNode.physicsBody anchorA:point anchorB:point];
    self.mouseJoint.maxLength = 20;
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

- (void)didSimulatePhysics
{
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ADJointNode class]]) {
            [(ADJointNode*)obj update];
        }
        
    }];
}
@end
