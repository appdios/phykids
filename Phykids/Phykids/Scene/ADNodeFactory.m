//
//  ADNodeFactory.m
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADNodeFactory.h"
@import SpriteKit;

@implementation ADNodeFactory

+ (id)nodeOfType:(ADNodeType)type subType:(ADNodeSubType)subType atPoint:(CGPoint)point
{
    if (type == ADNodeTypeSprite) {
        switch (subType) {
            case ADNodeSubTypeRectangle:
                return [ADNodeFactory rectangleNode:point];
            case ADNodeSubTypeCircle:
                return [ADNodeFactory circularNode:point];
            case ADNodeSubTypeTriangle:
                return [ADNodeFactory triangularNode:point];
            case ADNodeSubTypePolygon:
                return [ADNodeFactory rectangleNode:point];
                
            default:
                break;
        }
    }
    return nil;
}

+ (SKNode*) rectangleNode:(CGPoint)point
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [ADNodeFactory rectanglePathOfSize:CGSizeMake(100, 50)];
    [node setPath:path];
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADNodeFactory randomColor]];
    [node setPosition:point];
    
    [ADNodeFactory setPhysicsBodyToNode:node];
    
    return node;
}

+ (SKNode*) circularNode:(CGPoint)point
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [ADNodeFactory circularPathOfSize:CGSizeMake(50, 50)];
    [node setPath:path];
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADNodeFactory randomColor]];
    [node setPosition:point];
    
    [ADNodeFactory setPhysicsBodyToNode:node];
    
    return node;
}

+ (SKNode*) triangularNode:(CGPoint)point
{
    SKShapeNode *node = [SKShapeNode node];
    CGPathRef path = [ADNodeFactory triangularPathOfSize:CGSizeMake(100, 100)];
    [node setPath:path];
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADNodeFactory randomColor]];
    [node setPosition:point];
    
    [ADNodeFactory setPhysicsBodyToNode:node];
        
    return node;
}

+ (void)setPhysicsBodyToNode:(SKShapeNode*)node
{
    SKPhysicsBody *body = [SKPhysicsBody bodyWithPolygonFromPath:node.path];
    [body setDynamic:YES]; // No for static objects
    [body setAllowsRotation:YES]; // No to disable rotation on drag
    [node setPhysicsBody:body];
}

+ (CGPathRef) rectanglePathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity; //Change matrix based to translate/Rotate/Scale
    CGPathAddRect(pathRef, &matrix, CGRectMake(0, 0, size.width, size.height));
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

+ (CGPathRef) circularPathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity; //Change matrix based to translate/Rotate/Scale
    CGPathAddEllipseInRect(pathRef, &matrix, CGRectMake(0, 0, size.width, size.height));
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

+ (CGPathRef) triangularPathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity; //Change matrix based to translate/Rotate/Scale
    CGPathMoveToPoint(pathRef, &matrix, -size.width/2, -size.height/2);
    CGPathAddLineToPoint(pathRef, &matrix, 0, size.height/2);
    CGPathAddLineToPoint(pathRef, &matrix, size.width/2, -size.height/2);
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

+ (UIColor*)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); 
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

+ (void)tranformNode:(SKShapeNode*)node
{
    CGAffineTransform matrix = CGAffineTransformMakeRotation(M_PI/2); //Change matrix based to translate/Rotate/Scale
    node.path = CGPathCreateCopyByTransformingPath(node.path, &matrix);
    [ADNodeFactory setPhysicsBodyToNode:node];
}

@end
