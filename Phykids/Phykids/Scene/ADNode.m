//
//  ADNode.m
//  Phykids
//
//  Created by Aditi Kamal on 6/23/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADNode.h"

@implementation ADNode

+ (ADNode*)rectangleNodeInRect:(CGRect)rect
{
    ADNode *node = [[ADNode alloc] init];
    CGPathRef path = [node newRectanglePathOfSize:rect.size];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    [node setPosition:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))];
    node.userData = [NSMutableDictionary dictionary];
    return node;
}

+ (ADNode*)circularNodeInRect:(CGRect)rect
{
    ADNode *node = [[ADNode alloc] init];
    CGPathRef path = [node newCircularPathOfSize:rect.size];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    [node setPosition:rect.origin];
    node.userData = [NSMutableDictionary dictionary];
    return node;
}

+ (ADNode*)polygonNodeWithPoints:(NSArray*)points
{
    if ([points count]<3) {
        return nil;
    }
    ADNode *node = [[ADNode alloc] init];
    CGPoint centerPoint = polygonCentroid(points);
    if (isnan(centerPoint.x) || isnan(centerPoint.y)) {
        return node;
    }
    CGPathRef path = [node newPolygonPathForPoints:points atCenter:centerPoint];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    
    [node setPosition:centerPoint];
    node.userData = [NSMutableDictionary dictionary];
    return node;
}

- (CGPathRef) newRectanglePathOfSize:(CGSize)size
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity;
    CGPathAddRect(pathRef, &matrix, CGRectMake(-size.width/2, -size.height/2, size.width, size.height));
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

- (CGPathRef) newPolygonPathForPoints:(NSArray*)points atCenter:(CGPoint)centerPoint
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity;
    
    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSValue *pointValue = (NSValue*)obj;
        CGPoint point = [pointValue CGPointValue];
        if (idx==0) {
            CGPathMoveToPoint(pathRef, &matrix, point.x - centerPoint.x, point.y - centerPoint.y);
        }
        else{
            CGPathAddLineToPoint(pathRef, &matrix, point.x - centerPoint.x, point.y - centerPoint.y);
        }
    }];
    CGPathCloseSubpath(pathRef);
    
    return pathRef;
}

@end
