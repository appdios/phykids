
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

#pragma mark - Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInNode:self];
    
    if (self.isPaused) {
        //Design Mode
        self.currentNode = nil;
        self.startPoint = point;
        [ADPropertyManager setCurrentFillColor:((SKShapeNode*)self.currentNode).fillColor];
        
        [self.touchPoints removeAllObjects];
        [self.touchPoints addObject:[NSValue valueWithCGPoint:self.startPoint]];
    }
    else
    {
        //Run Mode
        SKPhysicsBody *body = [self.physicsWorld bodyAtPoint:point];
        if (body) {
            SKNode *node = body.node;
            [self destroyMouseNode];
            [self createMouseNodeWithNode:node atPoint:point];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInNode:self];
    
    if (self.isPaused) {
        //Design Mode
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
                    if ([reducedPoints count]>3) {
                        [self.currentNode remove];
                        self.currentNode = nil;
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
                self.currentNode = [ADNode jointOfType:[ADPropertyManager selectedNodeType] betweenPointA:point pointB:point inSecene:self];
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
    else
    {
        //Run Mode
        if (self.mouseNode) {
            self.mouseNode.position = point;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isPaused) {
        //Design Mode
        if (self.currentNode) {
            if (self.currentNode.nodeType == ADNodeTypeCircle ||
                self.currentNode.nodeType == ADNodeTypeRectangle ||
                self.currentNode.nodeType == ADNodeTypeGear ||
                self.currentNode.nodeType == ADNodeTypePolygon 
                ) {
                [ADNodeManager setPhysicsBodyToNode:self.currentNode];
            }
            [ADPropertyManager setCurrentFillColor:nil];
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
    
    
//        if (self.currentNode.nodeType == ADNodeTypePolygon) {
//            NSArray *reducedPoints = reducePoints(self.touchPoints,10);
//            BOOL isConvex = isConvexPolygon(reducedPoints);
//            if (isConvex) {
//                [ADNodeManager setPhysicsBodyToNode:self.currentNode];
//            }
//            else{
//                [self.currentNode removeFromParent];
//                NSArray *triangles = [Triangulate Process:reducedPoints];
//                if ([triangles count]) {
//                    __block ADNode *lastNode = nil;
//                    [triangles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                        NSArray *triangle = (NSArray*)obj;
//                        ADNode *triangleNode = [ADNode polygonNodeWithPoints:triangle];
//                        [self addChild:triangleNode];
//                        [ADNodeManager setPhysicsBodyToNode:triangleNode];
//                        if (lastNode!=nil) {
//                            SKPhysicsJointFixed *joint =[SKPhysicsJointFixed jointWithBodyA:lastNode.physicsBody bodyB:triangleNode.physicsBody anchor:CGPointZero];
//                            [self.physicsWorld addJoint:joint];
//                        }
//                        lastNode = triangleNode;
//                    }];
//                    self.currentNode = lastNode;
//                }
//            }
//        }
       // [self addDummyJoint];
}

- (void)addDummyJoint
{
    SKNode *tempNode = [SKSpriteNode spriteNodeWithColor:[UIColor darkGrayColor] size:CGSizeMake(20, 20)];
    tempNode.hidden = YES;
    tempNode.position = CGPointMake(self.frame.size.width/2, 450);
    [self addChild:tempNode];
    tempNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(20, 20)];
    [tempNode.physicsBody setDynamic:NO];
    
    ADNode *jointNode = [ADNode jointOfType:ADNodeTypeRope betweenNodeA:self.currentNode nodeB:tempNode anchorA:self.currentNode.position anchorB:tempNode.position inSecene:self];
    [self.physicsWorld addJoint:jointNode.joint];
    
    [self addChild:jointNode];
}

- (void)adjustShapesForRun
{
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ADNode class]]) {
            ADNode *node = (ADNode*)obj;
            if (node.nodeType < ADNodeTypePivot) {
                [node setPaused:NO];
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
        if ([obj isKindOfClass:[ADNode class]]) {
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
                    node.nodeType == ADNodeTypeSpring ||
                    node.nodeType == ADNodeTypePivot) {
                    ADNode *newNode = [ADNode jointOfType:node.nodeType betweenPointA:node.startPositionA pointB:node.startPositionB inSecene:self];
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
        if ([obj isKindOfClass:[ADNode class]]) {
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
        if ([obj isKindOfClass:[ADNode class]]) {
            [(ADNode*)obj didSimulatePhysics];
        }
        
    }];
}
@end
