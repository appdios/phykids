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
            return [nodeManager rectangleNode:point ofSize:CGSizeMake(20, 20)];
        case ADNodeTypeCircle:
            return [nodeManager circularNode:point ofSize:CGSizeMake(20, 20)];
        case ADNodeTypePolygon:
            return [nodeManager triangularNode:point];
        default:
            break;
    }
    return nil;
}

+ (id)rectangleNodeInRect:(CGRect)rect
{
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    return [nodeManager rectangleNode:rect.origin ofSize:rect.size];
}

+ (id)circularNodeInRect:(CGRect)rect
{
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    return [nodeManager circularNode:rect.origin ofSize:rect.size];
}

+ (id)polygonNodeWithPoints:(NSArray*)points
{
    if ([points count]<3) {
        return nil;
    }
    ADNodeManager *nodeManager = [ADNodeManager sharedInstance];
    return [nodeManager polygonNode:points];
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

- (SKNode*) rectangleNode:(CGPoint)point ofSize:(CGSize)size
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [self newRectanglePathOfSize:size];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    [node setPosition:point];
    
    return node;
}

- (SKNode*) circularNode:(CGPoint)point ofSize:(CGSize)size
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [self newCircularPathOfSize:size];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    [node setPosition:point];
    
    return node;
}

- (SKNode*) triangularNode:(CGPoint)point
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [self newTriangularPathOfSize:CGSizeMake(20, 20)];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    [node setPosition:point];
        
    return node;
}

- (SKNode*) polygonNode:(NSArray*)points
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [self newPolygonPathForPoints:points];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    
    return node;
}

+ (void)setPhysicsBodyToNode:(SKShapeNode*)node{
    SKPhysicsBody *body = [ADPropertyManager selectedNodeType]==ADNodeTypeCircle?
        [SKPhysicsBody bodyWithCircleOfRadius:node.frame.size.width/2]:
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

- (CGPathRef) newPolygonPathForPoints:(NSArray*)points
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity;
    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSValue *pointValue = (NSValue*)obj;
        CGPoint point = [pointValue CGPointValue];
        if (idx==0) {
            CGPathMoveToPoint(pathRef, &matrix, point.x, point.y);
        }
        else{
            CGPathAddLineToPoint(pathRef, &matrix, point.x, point.y);
        }
    }];
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}


@end
