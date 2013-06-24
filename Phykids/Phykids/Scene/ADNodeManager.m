//
//  ADNodeManager.m
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADNodeManager.h"

@interface ADNodeManager()
@property (nonatomic, strong) SKNode *currentNode;
@end

@implementation ADNodeManager

+ (ADNodeManager*)sharedInstance
{
    static dispatch_once_t once;
    static ADNodeManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)tranformNode:(SKShapeNode*)node withMatrix:(CGAffineTransform)matrix
{
//    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    CGPathRef path = CGPathCreateCopyByTransformingPath(node.path, &matrix);
    node.path = path;
    CGPathRelease(path);
//    [nodeManager setPhysicsBodyToNode:node];
}

+ (SKNode*)currentSelectedNode
{
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    return nodeManager.currentNode;
}

+ (void)setCurrentSelectedNode:(SKNode*)node
{
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    nodeManager.currentNode = node;
}

+ (void)setPhysicsBodyToNode:(SKShapeNode*)node{
    SKPhysicsBody *body = [ADPropertyManager selectedNodeType]==ADNodeTypeCircle?
        [SKPhysicsBody bodyWithCircleOfRadius:node.frame.size.width/2]:
        [SKPhysicsBody bodyWithPolygonFromPath:node.path];
    [body setDynamic:YES]; // No for static objects
    [body setAllowsRotation:YES]; // No to disable rotation on drag
    [body setUsesPreciseCollisionDetection:NO]; // SLow, turn false if require performance
    [body setRestitution:0.5]; // bounciness  - elasticity
    [node setPhysicsBody:body];
}


@end
