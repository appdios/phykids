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

+ (id)nodeOfType:(ADNodeType)type subType:(ADNodeSubType)subType atPoint:(CGPoint)point
{
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    if (type == ADNodeTypeSprite) {
        switch (subType) {
            case ADNodeSubTypeRectangle:
                return [nodeManager rectangleNode:point];
            case ADNodeSubTypeCircle:
                return [nodeManager circularNode:point];
            case ADNodeSubTypeTriangle:
                return [nodeManager triangularNode:point];
            case ADNodeSubTypePolygon:
                return [nodeManager rectangleNode:point];
                
            default:
                break;
        }
    }
    return nil;
}

+ (void)tranformNode:(SKShapeNode*)node withMatrix:(CGAffineTransform)matrix
{
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    node.path = CGPathCreateCopyByTransformingPath(node.path, &matrix);
    [nodeManager setPhysicsBodyToNode:node];
}

+ (SKNode*)currentNode
{
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    return nodeManager.currentNode;
}

+ (void)setCurrentNode:(SKNode*)node
{
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    nodeManager.currentNode = node;
}

- (SKNode*) rectangleNode:(CGPoint)point
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [self rectanglePathOfSize:CGSizeMake(100, 50)];
    [node setPath:path];
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[self randomColor]];
    [node setPosition:point];
    
    [self setPhysicsBodyToNode:node];
    
    return node;
}

- (SKNode*) circularNode:(CGPoint)point
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [self circularPathOfSize:CGSizeMake(50, 50)];
    [node setPath:path];
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[self randomColor]];
    [node setPosition:point];
    
    [node setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:25]];
    
    return node;
}

- (SKNode*) triangularNode:(CGPoint)point
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [self triangularPathOfSize:CGSizeMake(80, 80)];
    [node setPath:path];
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[self randomColor]];
    [node setPosition:point];
    
    [self setPhysicsBodyToNode:node];
        
    return node;
}

- (void)setPhysicsBodyToNode:(SKShapeNode*)node
{
    SKPhysicsBody *body = [SKPhysicsBody bodyWithPolygonFromPath:node.path];
    [body setDynamic:YES]; // No for static objects
    [body setAllowsRotation:YES]; // No to disable rotation on drag
    [node setPhysicsBody:body];
}

- (CGPathRef) rectanglePathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity; 
    CGPathAddRect(pathRef, &matrix, CGRectMake(0, 0, size.width, size.height));
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

- (CGPathRef) circularPathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity; 
    CGPathAddEllipseInRect(pathRef, &matrix, CGRectMake(0, 0, size.width, size.height));
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

- (CGPathRef) triangularPathOfSize:(CGSize)size
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
