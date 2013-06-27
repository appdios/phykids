//
//  ADNode.m
//  Phykids
//
//  Created by Aditi Kamal on 6/23/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADNode.h"
#import "ADNodeManager.h"


@implementation ADNode

+ (ADNode*)rectangleNodeInRect:(CGRect)rect
{
    ADNode *node = [[ADNode alloc] init];
    node.nodeType = ADNodeTypeRectangle;
    CGPathRef path = [node newRectanglePathOfSize:rect.size];
    [node setPath:path];
    CGPathRelease(path);
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    [node setPosition:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))];
    node.userData = [NSMutableDictionary dictionary];
    
    [node addChild:[node createNodeAtPoint:CGPointMake(-rect.size.width/2, -rect.size.height/2)]];
    [node addChild:[node createNodeAtPoint:CGPointMake(-rect.size.width/2, rect.size.height/2)]];
    [node addChild:[node createNodeAtPoint:CGPointMake(rect.size.width/2, -rect.size.height/2)]];
    [node addChild:[node createNodeAtPoint:CGPointMake(rect.size.width/2, rect.size.height/2)]];
    
    return node;
}

+ (ADNode*)circularNodeInRect:(CGRect)rect
{
    ADNode *node = [[ADNode alloc] init];
    node.nodeType = ADNodeTypeCircle;
    CGPathRef path = [node newCircularPathOfRadius:rect.size.width/2];
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
    node.nodeType = ADNodeTypePolygon;
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
    
    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSValue *valueObj = (NSValue*)obj;
        CGPoint pointValue = valueObj.CGPointValue;
        [node addChild:[node createNodeAtPoint:subtractPoints(pointValue, centerPoint)]];
    }];
    return node;
}

+ (ADNode*)gearNodeInRect:(CGRect)rect forScene:(SKScene*)scene
{
    ADNode *node = [[ADNode alloc] init];
    node.nodeType = ADNodeTypeGear;
    
    [node setStrokeColor:[UIColor blackColor]];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    [node setPosition:rect.origin];
    node.userData = [NSMutableDictionary dictionary];
    
    NSMutableArray *teethNodes = [NSMutableArray array];
    [node.userData setObject:teethNodes forKey:@"teethNodes"];
    
    NSInteger teeth = 12;
    CGFloat radius = CGRectGetWidth(rect)/2.0;
    NSInteger teethSharpness = 4;
    CGFloat offset = 0.3;
    NSInteger teethWidth = 24;
    
    CGFloat offsetRadius = radius * (1-offset);

    CGPathRef path = [node newCircularPathOfRadius:offsetRadius];
    [node setPath:path];
    CGPathRelease(path);
    
    CGFloat teethCorner = teethSharpness*2+2;
    for(NSInteger i = 0; i<teeth; i++){
        
        double teethAngle = (360/teeth)*i;
        
        SKNode *newNode1 = [node createNodeAtPoint:CGPointMake(offsetRadius*cos((teethAngle+teethWidth/2)*M_PI/180), offsetRadius*sin((teethAngle+teethWidth/2)*M_PI/180))];
        SKNode *newNode2 = [node createNodeAtPoint:CGPointMake(radius*cos((teethAngle+teethWidth/teethCorner)*M_PI/180), radius*sin((teethAngle+teethWidth/teethCorner)*M_PI/180))];
        SKNode *newNode3 = [node createNodeAtPoint:CGPointMake(radius*cos((teethAngle-teethWidth/teethCorner)*M_PI/180), radius*sin((teethAngle-teethWidth/teethCorner)*M_PI/180))];
        SKNode *newNode4 = [node createNodeAtPoint:CGPointMake(offsetRadius*cos((teethAngle-teethWidth/2)*M_PI/180), offsetRadius*sin((teethAngle-teethWidth/2)*M_PI/180))];
        
        
        ADNode *teethNode = [ADNode node];
        NSArray *pointValues = @[[NSValue valueWithCGPoint:newNode1.position],
                                 [NSValue valueWithCGPoint:newNode2.position],
                                 [NSValue valueWithCGPoint:newNode3.position],
                                 [NSValue valueWithCGPoint:newNode4.position]];
        CGPoint centerPoint = polygonCentroid(pointValues);
        if (isnan(centerPoint.x) || isnan(centerPoint.y)) {
            continue;
        }
        teethNode.fillColor = [ADPropertyManager currentFillColor];
        teethNode.strokeColor = [SKColor blackColor];
        teethNode.position = addPoints(node.position, centerPoint);
        CGPathRef teethPathRef = [node newPolygonPathForPoints:pointValues atCenter:centerPoint];
        [teethNode setPath:teethPathRef];
        CGPathRelease(teethPathRef);
        
        node.nodeType = ADNodeTypePolygon;
        [scene addChild:teethNode];
        [teethNodes addObject:teethNode];
//        
//        [node addChild:newNode1];
//        [node addChild:newNode2];
//        [node addChild:newNode3];
//        [node addChild:newNode4];
 
    }
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

- (CGPathRef) newCircularPathOfRadius:(CGFloat)radius
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGAffineTransform matrix = CGAffineTransformIdentity;
    CGPathAddArc(pathRef, &matrix, 0,0, radius, 0, M_PI * 2, YES);
    CGPathMoveToPoint(pathRef, &matrix, -8, 0);
    CGPathAddLineToPoint(pathRef, &matrix, 8, 0);
    CGPathMoveToPoint(pathRef, &matrix, 0, -8);
    CGPathAddLineToPoint(pathRef, &matrix, 0, 8);
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

- (SKNode*)createNodeAtPoint:(CGPoint)p
{
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGPathAddArc(pathRef, nil, 0, 0, 1, 0, M_PI * 2, YES);
    SKShapeNode *node = [SKShapeNode node];
    node.strokeColor = [UIColor blackColor];
    node.path = pathRef;
    CGPathRelease(pathRef);
    
    node.position = p;
    return node;
}

- (void)update:(NSTimeInterval)currentTime
{

}

- (void)didSimulatePhysics
{

}

@end
