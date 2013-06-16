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

+ (id)nodeOfType:(ADNodeType)type atPoint:(CGPoint)point
{
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    switch (type) {
        case ADNodeTypeRectangle:
            return [nodeManager rectangleNode:point];
        case ADNodeTypeCircle:
            return [nodeManager circularNode:point];
        case ADNodeTypePolygon:
            return [nodeManager triangularNode:point];
        default:
            break;
    }
    return nil;
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

- (SKNode*) rectangleNode:(CGPoint)point
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [self newRectanglePathOfSize:CGSizeMake(100, 50)];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[self randomColor]];
    [node setPosition:point];
    
    return node;
}

- (SKNode*) circularNode:(CGPoint)point
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [self newCircularPathOfSize:CGSizeMake(50, 50)];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[self randomColor]];
    [node setPosition:point];
    
    return node;
}

- (SKNode*) triangularNode:(CGPoint)point
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [self newTriangularPathOfSize:CGSizeMake(80, 80)];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[self randomColor]];
    [node setPosition:point];
        
    return node;
}

+ (void)setPhysicsBodyToNode:(SKShapeNode*)node{
    SKPhysicsBody *body = [ADPropertyManager selectedNodeType]==ADNodeTypeCircle?
        [SKPhysicsBody bodyWithCircleOfRadius:25]:
        [SKPhysicsBody bodyWithPolygonFromPath:node.path];
    [body setDynamic:YES]; // No for static objects
    [body setAllowsRotation:YES]; // No to disable rotation on drag
    [body setUsesPreciseCollisionDetection:YES]; // SLow, turn false if require performance
    [node setPhysicsBody:body];
}

- (CGPathRef) newRectanglePathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity; 
    CGPathAddRect(pathRef, &matrix, CGRectMake(0, 0, size.width, size.height));
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

- (CGPathRef) newCircularPathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity;
    CGPathAddArc(pathRef, &matrix, 0,0, size.width/2, 0, M_PI * 2, YES);
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

- (CGPathRef) newTriangularPathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity; 
    CGPathMoveToPoint(pathRef, &matrix, -size.width/2, -size.height/2);
    CGPathAddLineToPoint(pathRef, &matrix, 0, size.height/2);
    CGPathAddLineToPoint(pathRef, &matrix, size.width/2, -size.height/2);
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

- (UIColor*)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); 
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}



@end
