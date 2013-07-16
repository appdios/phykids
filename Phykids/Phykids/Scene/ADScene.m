
//  ADScene.m
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADScene.h"
#import "ADNodeManager.h"
#import "ADNode.h"
#import "Triangulate.h"
#import "ADSpriteNode.h"

@interface ADScene()
@property (nonatomic, strong) SKPhysicsJointLimit *mouseJoint;
@property (nonatomic, strong) SKNode *mouseNode;
@property (nonatomic, strong) ADNode *currentNode;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic, strong) NSMutableArray *touchPoints;

@end

@implementation ADScene

static CGPoint lastFramePositionOfSelectedNode;
static CGFloat lastFrameZRotationOfSelectedNode;

- (id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.isPaused = YES;
        self.touchPoints = [NSMutableArray array];
        self.physicsWorld.speed = 1.0;
    }
    return self;
}

- (void)testAction{
    SKNode *cNode = [[self children] lastObject];
    if (cNode) {
        SKAction *action1 = [SKAction customActionWithDuration:0.1 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            node.physicsBody.velocity =  CGPointMake(0, 400);
//            node.physicsBody.angularVelocity = M_PI;
        }];
        SKAction *action2 = [SKAction fadeAlphaTo:0.0 duration:0.1];
        SKAction *action3 = [SKAction removeFromParent];
        SKAction *sequenceAction = [SKAction sequence:@[action1,action2,action3]];
        [cNode runAction:sequenceAction];
        
    }
}

#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInNode:self];
    
    if (self.isPaused) {
        //Design Mode
        self.startPoint = point;
        
        
        if (self.toolSelected) {
            if (self.currentNode) {
                [self.currentNode unHighlight];
                self.currentNode = nil;
            }
            NSArray *nodes = [self nodesAtPoint:self.startPoint];
            if (nodes.count) {
                self.currentNode = [nodes lastObject];
                if ([self.currentNode isKindOfClass:[ADJointConnectingNode class]]) {
                    self.currentNode = ((ADJointConnectingNode*)self.currentNode).parentNode;
                }
                [self.currentNode highlight];
            }
        }
        else{
            self.currentNode = nil;
            [ADPropertyManager setCurrentFillColor:((SKShapeNode*)self.currentNode).fillColor];
            
            [self.touchPoints removeAllObjects];
            [self.touchPoints addObject:[NSValue valueWithCGPoint:self.startPoint]];
        }
    }
    else
    {
        //Run Mode
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInNode:self];
    CGPoint ppoint = [touch previousLocationInNode:self];
    
    if (self.isPaused) {
        //Design Mode
        
        if (self.toolSelected) {
            if (self.currentNode) {
                [self.currentNode updatePositionByDistance:subtractPoints(point, ppoint)];
            }
        }
        else{
            if (self.currentNode) {
                [self.currentNode remove];
                self.currentNode = nil;
            }
            
            switch ([ADPropertyManager selectedNodeType]) {
                case ADNodeTypeRectangle:
                {
                    self.currentNode = [ADNode rectangleNodeInRect:CGRectMake(self.startPoint.x, self.startPoint.y, point.x - self.startPoint.x, point.y - self.startPoint.y)];
                }
                    break;
                case ADNodeTypeCircle:
                {
                    CGFloat radius = MAX(abs((point.x - self.startPoint.x)), abs((point.y - self.startPoint.y)));
                    self.currentNode = [ADNode circularNodeInRect:CGRectMake(self.startPoint.x, self.startPoint.y, radius*2.0, radius*2.0)];
                }
                    break;
                case ADNodeTypePolygon:
                {
                    [self.touchPoints addObject:[NSValue valueWithCGPoint:point]];
                    if ([self.touchPoints count]>=3) {
                        NSMutableArray *reducedPoints = reducePoints(self.touchPoints,10);
                        grahamMain(reducedPoints);
                        if ([reducedPoints count]>=3) {
                            self.currentNode = [ADNode polygonNodeWithPoints:reducedPoints];
                        }
                    }
                }
                    break;
                case ADNodeTypeGear:
                {
                    NSArray *teethNodes = [[self.currentNode userData] objectForKey:@"teethNodes"];
                    if (teethNodes) {
                        [self removeChildrenInArray:teethNodes];
                    }
                    
                    CGFloat radius = MAX(abs((point.x - self.startPoint.x)), abs((point.y - self.startPoint.y)));
                    self.currentNode = [ADNode gearNodeInRect:CGRectMake(self.startPoint.x, self.startPoint.y, radius*2.0, radius*2.0) forScene:self];
                }
                    break;
                case ADNodeTypeSpring:
                case ADNodeTypeRope:
                {
                    self.currentNode = [ADNode jointOfType:[ADPropertyManager selectedNodeType] betweenPointA:self.startPoint pointB:point inSecene:self];
                }
                    break;
                case ADNodeTypePivot:
                {
                    self.currentNode = (ADNode*)[ADSpriteNode pivotJointAtPoint:point inSecene:self];
                }
                    break;
                default:
                    break;
            }
            
            if (self.currentNode) {
                [self addChild:self.currentNode];
            }
        }
    }
    else
    {
        //Run Mode
        if (self.mouseNode) {
            self.mouseNode.position = point;
        }
        else{
            SKPhysicsBody *body = [self.physicsWorld bodyAtPoint:point];
            if (body) {
                SKNode *node = body.node;
                [self destroyMouseNode];
                [self createMouseNodeWithNode:node atPoint:point];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isPaused) {
        //Design Mode
        if (self.toolSelected) {
//            if (self.currentNode) {
//                [self.currentNode unHighlight];
//            }
        }
        else{
            if (self.currentNode) {
                if (((ADNode*)self.currentNode).nodeType == ADNodeTypeCircle ||
                    ((ADNode*)self.currentNode).nodeType == ADNodeTypeRectangle ||
                    ((ADNode*)self.currentNode).nodeType == ADNodeTypeGear ||
                    ((ADNode*)self.currentNode).nodeType == ADNodeTypePolygon
                    ) {
                    [ADNodeManager setPhysicsBodyToNode:self.currentNode];
                }
                [ADPropertyManager setCurrentFillColor:nil];
            }
        }
        
    }
    else{
        //Run Mode
        if (self.mouseNode) {
            const CGFloat deceleration = 30;
            const CGFloat angularDeceleration = 20;
            
            CGPoint currentPosition = self.mouseJoint.bodyA.node.position;
            CGPoint delta = CGPointMake(currentPosition.x - lastFramePositionOfSelectedNode.x, currentPosition.y - lastFramePositionOfSelectedNode.y);
            self.mouseJoint.bodyA.velocity = CGPointMake(delta.x * deceleration, delta.y * deceleration);
            
            CGFloat currentZRotation = self.mouseJoint.bodyA.node.zRotation;
            self.mouseJoint.bodyA.angularVelocity = (currentZRotation - lastFrameZRotationOfSelectedNode) * angularDeceleration;
            
            [self destroyMouseNode];
        }
    }
}


- (void)adjustShapesForRun
{
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ADNode class]] ||
            [obj isKindOfClass:[ADSpriteNode class]]) {
            ADNode *node = (ADNode*)obj;
            [node unHighlight];
            if (node.nodeType < ADNodeTypePivot) {
                [node setPaused:NO];
                node.physicsBody.dynamic = !node.gluedToScene;
            }
            else if (node.nodeType == ADNodeTypePivot){
                ADSpriteNode *newNode = [ADSpriteNode physicsJointForJoint:(ADSpriteNode*)node inScene:self];
                if (newNode) {
                    [self addChild:newNode];
                    [self.physicsWorld addJoint:newNode.joint];
                }
            }
            else{
                ADNode *newNode = [ADNode physicsJointForJoint:node inScene:self];
                if (newNode) {
                    [self addChild:newNode];
                    [self.physicsWorld addJoint:newNode.joint];
                }
            }
        }
        
    }];
}

- (void)moveShapesBackToOriginalPosition
{
    [self.physicsWorld removeAllJoints];
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ADNode class]] ||
            [obj isKindOfClass:[ADSpriteNode class]]) {
            ADNode *node = (ADNode*)obj;
            if (node.nodeType < ADNodeTypePivot) {
                [node setPaused:YES];
                node.zRotation = 0;
                node.position = node.originalPosition;
                node.physicsBody.velocity = CGPointZero;
                node.physicsBody.angularVelocity = 0.0;
            }
            else{
                if (node.nodeType == ADNodeTypeRope ||
                    node.nodeType == ADNodeTypeSpring) {
                    ADNode *newNode = [ADNode jointOfType:node.nodeType betweenPointA:node.startPositionA pointB:node.startPositionB inSecene:self];
                    [self addChild:newNode];
                    [node remove];
                }
                else if (node.nodeType == ADNodeTypePivot) {
                    ADSpriteNode *newNode = [ADSpriteNode pivotJointAtPoint:node.originalPosition inSecene:self];
                    [self addChild:newNode];
                    [node remove];
                }
            }
        }
    }];
}

- (void)playPauseScene
{
    if (self.paused) {
        [self adjustShapesForRun];
    }
    else
    {
        [self moveShapesBackToOriginalPosition];
    }
    self.isPaused = !self.isPaused;
    
}

- (void)createMouseNodeWithNode:(SKNode*)node atPoint:(CGPoint)point
{
    self.mouseNode = [SKSpriteNode spriteNodeWithImageNamed:@"pivot"];
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

- (void)update:(NSTimeInterval)currentTime
{
    if (self.isPaused) {
        return;
    }
    if (self.mouseJoint && self.mouseNode) {
        lastFramePositionOfSelectedNode = self.mouseJoint.bodyA.node.position;
        lastFrameZRotationOfSelectedNode = self.mouseJoint.bodyA.node.zRotation;
    }
    
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ADNode class]] ||
            [obj isKindOfClass:[ADSpriteNode class]]) {
            [(ADNode*)obj update:currentTime];
        }
        
    }];
}

- (void)didSimulatePhysics
{
    if (self.isPaused) {
        return;
    }
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ADNode class]] ||
            [obj isKindOfClass:[ADSpriteNode class]]) {
            [(ADNode*)obj didSimulatePhysics];
        }
        
    }];
}
@end
