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
    
    [node setPhysicsBody:[SKPhysicsBody bodyWithPolygonFromPath:path]];
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
    [node setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:25]];
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
    
    [node setPhysicsBody:[SKPhysicsBody bodyWithPolygonFromPath:path]];
    return node;
}

+ (CGPathRef) rectanglePathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, nil, CGRectMake(0, 0, size.width, size.height));
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

+ (CGPathRef) circularPathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddEllipseInRect(pathRef, nil, CGRectMake(0, 0, size.width, size.height));
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

+ (CGPathRef) triangularPathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, nil, -size.width/2, -size.height/2);
    CGPathAddLineToPoint(pathRef, nil, 0, size.height/2);
    CGPathAddLineToPoint(pathRef, nil, size.width/2, -size.height/2);
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

@end
