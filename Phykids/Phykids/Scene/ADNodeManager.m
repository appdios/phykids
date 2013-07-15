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

+ (void)tranformNode:(ADNode*)node withMatrix:(CGAffineTransform)matrix
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

+ (void)setCurrentSelectedNode:(ADNode*)node
{
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    nodeManager.currentNode = node;
}

+ (void)setPhysicsBodyToNode:(ADNode*)node{
    SKPhysicsBody *body = nil;
    switch ([ADPropertyManager selectedNodeType]) {
        case ADNodeTypeCircle:
            body = [SKPhysicsBody bodyWithCircleOfRadius:node.frame.size.width/2];
            break;
        case ADNodeTypeGear:
            body = [SKPhysicsBody bodyWithCircleOfRadius:node.frame.size.width/2];
            break;
        default:
            body = [SKPhysicsBody bodyWithPolygonFromPath:node.path];
            break;
    }        
    
    
    [body setDynamic:YES]; // No for static objects
    [body setAllowsRotation:YES]; // No to disable rotation on drag
    [body setUsesPreciseCollisionDetection:NO]; // SLow, turn false if require performance
    [body setRestitution:0.5]; // bounciness  - elasticity
    [body setMass:1];
    [node setPhysicsBody:body];
    
    if ([ADPropertyManager selectedNodeType]==ADNodeTypeGear) {
        NSArray *teethNodes = [[node userData] objectForKey:@"teethNodes"];
        [teethNodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ADNode *teethNode = (ADNode*)obj;
            teethNode.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:teethNode.path];
            teethNode.physicsBody.mass = 0.1;
            SKPhysicsJointFixed *joint =[SKPhysicsJointFixed jointWithBodyA:teethNode.physicsBody bodyB:body anchor:CGPointZero];
            [node.scene.physicsWorld addJoint:joint];
        }];
    }
}


@end
