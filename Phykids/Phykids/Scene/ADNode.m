//
//  ADNode.m
//  Phykids
//
//  Created by Aditi Kamal on 6/23/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADNode.h"
#import "ADNodeManager.h"

@implementation ADJointConnectingNode

- (void)highlight
{
    
}

- (void)unHighlight
{
    
}

@end

@interface ADNode()

@property (nonatomic, strong) SKNode *nodeA;
@property (nonatomic, strong) SKNode *nodeB;
@property (nonatomic) CGPoint anchorPointOffsetA;
@property (nonatomic) CGPoint anchorPointOffsetB;
@property (nonatomic, strong) ADRope *vRope;

@end

@implementation ADNode

+ (ADNode*)rectangleNodeInRect:(CGRect)rect
{
    ADNode *node = [[ADNode alloc] init];
    node.nodeType = ADNodeTypeRectangle;
    CGPathRef path = [node newRectanglePathOfSize:rect.size];
    [node setPath:path];
    CGPathRelease(path);
    [node unHighlight];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    [node setPosition:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))];
    node.userData = [NSMutableDictionary dictionary];
    
    [node addChild:[node createNodeAtPoint:CGPointMake(-rect.size.width/2, -rect.size.height/2)]];
    [node addChild:[node createNodeAtPoint:CGPointMake(-rect.size.width/2, rect.size.height/2)]];
    [node addChild:[node createNodeAtPoint:CGPointMake(rect.size.width/2, -rect.size.height/2)]];
    [node addChild:[node createNodeAtPoint:CGPointMake(rect.size.width/2, rect.size.height/2)]];
    
    node.originalPosition = node.position;
    return node;
}

+ (ADNode*)circularNodeInRect:(CGRect)rect
{
    ADNode *node = [[ADNode alloc] init];
    node.nodeType = ADNodeTypeCircle;
    CGPathRef path = [node newCircularPathOfRadius:rect.size.width/2];
    [node setPath:path];
    CGPathRelease(path);
    [node unHighlight];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    [node setPosition:rect.origin];
    node.userData = [NSMutableDictionary dictionary];
    
    node.originalPosition = node.position;
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
    [node unHighlight];
    [node setFillColor:[ADPropertyManager currentFillColor]];
    
    [node setPosition:centerPoint];
    node.userData = [NSMutableDictionary dictionary];
    
    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSValue *valueObj = (NSValue*)obj;
        CGPoint pointValue = valueObj.CGPointValue;
        [node addChild:[node createNodeAtPoint:subtractPoints(pointValue, centerPoint)]];
    }];
    
    node.originalPosition = node.position;
    return node;
}

+ (ADNode*)gearNodeInRect:(CGRect)rect forScene:(SKScene*)scene
{
    ADNode *node = [[ADNode alloc] init];
    node.nodeType = ADNodeTypeGear;
    
    [node unHighlight];
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
        [teethNode unHighlight];
        teethNode.position = addPoints(node.position, centerPoint);
        CGPathRef teethPathRef = [node newPolygonPathForPoints:pointValues atCenter:centerPoint];
        [teethNode setPath:teethPathRef];
        CGPathRelease(teethPathRef);
        
        [scene addChild:teethNode];
        [teethNodes addObject:teethNode];
 
    }
    node.originalPosition = node.position;
    return node;
}

+ (ADNode*)physicsJointForJoint:(ADNode*)node inScene:(SKScene*)scene
{
    if (node.nodeType == ADNodeTypeRope ||
        node.nodeType == ADNodeTypeSpring) {
        NSArray *shapeNodes1 = [scene nodesAtPoint:node.startPositionA];
        ADNode *node1 = nil;
        for (ADNode *shapeNode in shapeNodes1) {
            if ([shapeNode isKindOfClass:[ADNode class]]) {
                if (shapeNode.nodeType < ADNodeTypePivot) {
                    if (node1 == nil) {
                        node1 = shapeNode;
                        break;
                    }
                }
            }
        }
        
        NSArray *shapeNodes2 = [scene nodesAtPoint:node.startPositionB];
        ADNode *node2 = nil;
        for (ADNode *shapeNode in shapeNodes2) {
            if ([shapeNode isKindOfClass:[ADNode class]]) {
                if (shapeNode.nodeType < ADNodeTypePivot) {
                    if (node2 == nil && ![shapeNode isEqual:node1]) {
                        node2 = shapeNode;
                        break;
                    }
                }
            }
        }
        
        if (node1 || node2) {
            ADNode *newNode = [ADNode jointOfType:node.nodeType betweenNodeA:node1?node1:scene nodeB:node2?node2:scene anchorA:node.startPositionA anchorB:node.startPositionB inSecene:scene];
            [node remove];
            return newNode;
        }
        else{
            [node remove];
        }
    }
    return nil;
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
    CGPathMoveToPoint(pathRef, &matrix, 0, 0);
    CGPathAddLineToPoint(pathRef, &matrix, radius, 0);
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
    ADJointConnectingNode *node  = [ADJointConnectingNode spriteNodeWithImageNamed:@"blackdot"];
    node.parentNode = self;
    node.userInteractionEnabled = NO;
    node.position = p;
    return node;
}

+ (ADNode*)jointOfType:(ADNodeType)type betweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB inSecene:(SKScene*)scene
{
    return [self jointOfType:type betweenNodeA:nodeA nodeB:nodeB anchorA:nodeA.position anchorB:nodeB.position inSecene:scene];
}

+ (ADNode*)jointOfType:(ADNodeType)type betweenNodeA:(SKNode*)nodeA nodeB:(SKNode*)nodeB anchorA:(CGPoint)pointA anchorB:(CGPoint)pointB inSecene:(SKScene*)scene
{
    ADNode *joint = [[ADNode alloc] init];
    joint.nodeType = type;
    joint.nodeA = nodeA;
    joint.nodeB = nodeB;
    joint.startPositionA = pointA;
    joint.startPositionB = pointB;
    joint.anchorPointOffsetA = CGPointMake(pointA.x - nodeA.position.x,pointA.y - nodeA.position.y);
    joint.anchorPointOffsetB = CGPointMake(pointB.x - nodeB.position.x,pointB.y - nodeB.position.y);
    joint.strokeColor = [UIColor brownColor];

    switch (type) {
        case ADNodeTypePivot:
        {
            SKPhysicsJointPin *pinJoint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchor:pointA];
            joint.joint = pinJoint;
            CGPathRef pathRef = CGPathCreateWithEllipseInRect(CGRectMake(-5, -5, 10, 10), nil);
            joint.path = pathRef;
            CGPathRelease(pathRef);
            joint.fillColor = [SKColor blackColor];
            joint.position = pointA;
        }
            break;
        case ADNodeTypeRope:
        {
            SKPhysicsJointLimit *limitJoint = [SKPhysicsJointLimit jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchorA:pointA anchorB:pointB];
            limitJoint.maxLength = distanceBetween(pointA, pointB);
            joint.joint = limitJoint;
            joint.position = pointA;
            
            joint.vRope = [[ADRope alloc] initWithPoints:pointA pointB:pointB spriteSheet:scene antiSagHack:0.1];
            [joint.vRope updateParentOfAllNodes:joint];
            
        }
            break;
        case ADNodeTypeSpring:
        {
            SKPhysicsJointSpring *springJoint = [SKPhysicsJointSpring jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchorA:pointA anchorB:pointB];
            springJoint.damping = 0.4;
            springJoint.frequency = 4.0;
            joint.joint = springJoint;
            joint.position = pointA;
            
            CGPathRef pathRef = [joint newSpringPath:joint.position pointB:pointB];
            joint.path = pathRef;
            CGPathRelease(pathRef);
        }
            break;
        default:
            break;
    }
    joint.originalPosition = joint.position;
    return joint;
}

+ (ADNode*)jointOfType:(ADNodeType)type betweenPointA:(CGPoint)pointA pointB:(CGPoint)pointB inSecene:(SKScene*)scene
{
    ADNode *joint = [[ADNode alloc] init];
    joint.nodeType = type;
    joint.startPositionA = pointA;
    joint.startPositionB = pointB;
    joint.strokeColor = [UIColor brownColor];
    switch (type) {
        case ADNodeTypePivot:
        {
            CGPathRef pathRef = CGPathCreateWithEllipseInRect(CGRectMake(-5, -5, 10, 10), nil);
            joint.path = pathRef;
            CGPathRelease(pathRef);
            joint.fillColor = [SKColor blackColor];
            joint.position = pointA;
        }
            break;
        case ADNodeTypeRope:
        {
            joint.position = pointA;
            joint.vRope = [[ADRope alloc] initWithPoints:pointA pointB:pointB spriteSheet:scene antiSagHack:0.0];
            [joint.vRope updateParentOfAllNodes:joint];
        }
            break;
        case ADNodeTypeSpring:
        {
            joint.position = pointA;
            
            CGPathRef pathRef = [joint newSpringPath:joint.position pointB:pointB];
            joint.path = pathRef;
            CGPathRelease(pathRef);
        }
            break;
        default:
            break;
    }
    joint.originalPosition = joint.position;
    return joint;
}


- (void)update:(NSTimeInterval)currentTime
{
    
    switch (self.nodeType) {
        case ADNodeTypePivot:
        {
            [self updatePivot];
        }
            break;
        case ADNodeTypeRope:
        {
            [self updateRope];
        }
            break;
        case ADNodeTypeSpring:
        {
            [self updateSpring];
        }
            break;
        default:
            break;
    }
}

- (void)didSimulatePhysics
{
    switch (self.nodeType) {
        case ADNodeTypeRope:
        {
            [self.vRope updateSprites];
        }
            break;
            
        default:
            break;
    }
}

- (void)updatePivot
{
    CGPoint positionA = CGPointMake(self.nodeA.position.x + self.anchorPointOffsetA.x, self.nodeA.position.y + self.anchorPointOffsetA.y);
    CGPoint rotatedPoint = rotatePoint(positionA, self.nodeA.zRotation, self.nodeA.position);
    self.position = rotatedPoint;
}

- (void) updateRope
{
    CGPoint positionA = CGPointMake(self.nodeA.position.x + self.anchorPointOffsetA.x, self.nodeA.position.y + self.anchorPointOffsetA.y);
    CGPoint rotatedPointA = rotatePoint(positionA, self.nodeA.zRotation, self.nodeA.position);
    self.position = rotatedPointA;
    
    CGPoint positionB = CGPointMake(self.nodeB.position.x + self.anchorPointOffsetB.x, self.nodeB.position.y + self.anchorPointOffsetB.y);
    CGPoint rotatedPointB = rotatePoint(positionB, self.nodeB.zRotation, self.nodeB.position);
    
    [self.vRope updateWithPoints:rotatedPointA pointB:rotatedPointB dt:0.04];
}

- (void) updateSpring
{
    CGPoint positionA = CGPointMake(self.nodeA.position.x + self.anchorPointOffsetA.x, self.nodeA.position.y + self.anchorPointOffsetA.y);
    CGPoint rotatedPointA = rotatePoint(positionA, self.nodeA.zRotation, self.nodeA.position);
    self.position = rotatedPointA;
    
    CGPoint positionB = CGPointMake(self.nodeB.position.x + self.anchorPointOffsetB.x, self.nodeB.position.y + self.anchorPointOffsetB.y);
    CGPoint rotatedPointB = rotatePoint(positionB, self.nodeB.zRotation, self.nodeB.position);
    
    CGPathRef pathRef = [self newSpringPath:self.position pointB:rotatedPointB];
    self.path = pathRef;
    CGPathRelease(pathRef);
}

- (CGPathRef)newRopePath:(CGPoint)pointA pointB:(CGPoint)pointB{
    [self removeAllChildren];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, nil, 0, 0);
    CGPathAddArc(pathRef, nil, 0,0, 2, 0, M_PI * 2, YES);
    CGPathMoveToPoint(pathRef, nil, 0, 0);
    CGPathAddLineToPoint(pathRef, nil, pointB.x - pointA.x, pointB.y - pointA.y);
    CGPathAddArc(pathRef, nil, pointB.x - pointA.x, pointB.y - pointA.y, 2, 0, M_PI * 2, YES);
    
    if ([self.children count]) {
        [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx==0) {
                ((SKNode*)obj).position = CGPointZero;
            }
            else if (idx==1) {
                ((SKNode*)obj).position = CGPointMake(pointB.x - pointA.x, pointB.y - pointA.y);
            }
        }];
    }
    else
    {
        [self addChild:[self createNodeAtPoint:CGPointZero]];
        [self addChild:[self createNodeAtPoint:CGPointMake(pointB.x - pointA.x, pointB.y - pointA.y)]];
    }
    
    return pathRef;
}

-(CGPathRef)newSpringPath:(CGPoint)pointA pointB:(CGPoint)pointB{
	[self removeAllChildren];
    
    CGFloat distance = distanceBetween(pointA, pointB);
    CGFloat height = distanceBetween(self.startPositionA, self.startPositionB)*0.08;
    if (height>40) {
        height = 40;
    }
	CGFloat numberOfV = 12;
	
    CGPoint point1 = CGPointMake(pointA.x, pointA.y);
	CGPoint  point2 = CGPointMake(pointA.x+1*(distance/numberOfV), pointA.y);
	CGPoint  point3 = CGPointMake(pointA.x+2*(distance/numberOfV), pointA.y-height);
	CGPoint  point4 = CGPointMake(pointA.x+3*(distance/numberOfV), pointA.y+ height);
	CGPoint  point5 = CGPointMake(pointA.x+4*(distance/numberOfV), pointA.y- height);
	CGPoint  point6 = CGPointMake(pointA.x+5*(distance/numberOfV), pointA.y+ height);
	CGPoint  point7 = CGPointMake(pointA.x+6*(distance/numberOfV), pointA.y- height);
	CGPoint  point8 = CGPointMake(pointA.x+7*(distance/numberOfV), pointA.y+ height);
	CGPoint  point9 = CGPointMake(pointA.x+8*(distance/numberOfV), pointA.y- height);
	CGPoint  point10 = CGPointMake(pointA.x+9*(distance/numberOfV), pointA.y+ height);
	CGPoint  point11 = CGPointMake(pointA.x+10*(distance/numberOfV), pointA.y-height);
	CGPoint  point12 = CGPointMake(pointA.x+11*(distance/numberOfV), pointA.y);
	CGPoint  point13 = CGPointMake(pointA.x+12*(distance/numberOfV), pointA.y) ;
	
	double angleInRadian = atan2(pointB.y-pointA.y,pointB.x-pointA.x);
    
	
    point2 = rotatePoint(point2, angleInRadian, pointA);
	point3 = rotatePoint(point3, angleInRadian, pointA);
	point4 = rotatePoint(point4, angleInRadian, pointA);
	point5 = rotatePoint(point5, angleInRadian, pointA);
	point6 = rotatePoint(point6, angleInRadian, pointA);
	point7 = rotatePoint(point7, angleInRadian, pointA);
	point8 = rotatePoint(point8, angleInRadian, pointA);
	point9 = rotatePoint(point9, angleInRadian, pointA);
	point10 = rotatePoint(point10, angleInRadian, pointA);
	point11 = rotatePoint(point11, angleInRadian, pointA);
	point12 = rotatePoint(point12, angleInRadian, pointA);
	point13 = rotatePoint(point13, angleInRadian, pointA);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGPathMoveToPoint(pathRef, nil, point1.x - pointA.x, point1.y - pointA.y);
    CGPathAddArc(pathRef, nil, 0,0, 2, 0, M_PI * 2, YES);
    
    CGPathMoveToPoint(pathRef, nil, point1.x - pointA.x, point1.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point2.x - pointA.x, point2.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point3.x - pointA.x, point3.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point4.x - pointA.x, point4.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point5.x - pointA.x, point5.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point6.x - pointA.x, point6.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point7.x - pointA.x, point7.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point8.x - pointA.x, point8.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point9.x - pointA.x, point9.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point10.x - pointA.x, point10.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point11.x - pointA.x, point11.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point12.x - pointA.x, point12.y - pointA.y);
    CGPathAddLineToPoint(pathRef, nil, point13.x - pointA.x, point13.y - pointA.y);
    
    CGPathAddArc(pathRef, nil, point13.x - pointA.x, point13.y - pointA.y, 2, 0, M_PI * 2, YES);
    
    [self addChild:[self createNodeAtPoint:CGPointMake(point1.x - pointA.x, point1.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point2.x - pointA.x, point2.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point3.x - pointA.x, point3.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point4.x - pointA.x, point4.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point5.x - pointA.x, point5.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point6.x - pointA.x, point6.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point7.x - pointA.x, point7.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point8.x - pointA.x, point8.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point9.x - pointA.x, point9.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point10.x - pointA.x, point10.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point11.x - pointA.x, point11.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point12.x - pointA.x, point12.y - pointA.y)]];
    [self addChild:[self createNodeAtPoint:CGPointMake(point13.x - pointA.x, point13.y - pointA.y)]];
    
    
    return pathRef;
}

- (void)remove
{
    if (self.nodeType == ADNodeTypeRope) {
        [self.vRope removeAllNodes];
    }
    if (self.nodeType == ADNodeTypeGear) {
        NSArray *teethNodes = [[self userData] objectForKey:@"teethNodes"];
        if (teethNodes) {
            [self.scene removeChildrenInArray:teethNodes];
        }
    }
    
    [self removeFromParent];
}

- (void)highlight
{
    self.strokeColor = [UIColor blueColor];
    self.lineWidth = 4.0;
}

- (void)unHighlight
{
    self.strokeColor = self.gluedToScene?[UIColor redColor]:[UIColor blackColor];
    self.lineWidth = 1.0;
}

- (void)updatePositionByDistance:(CGPoint)distancePoint{
    self.position = addPoints(self.position, distancePoint);
    self.originalPosition = self.position;
    if (self.nodeType  == ADNodeTypeSpring) {
        self.startPositionA = addPoints(self.startPositionA, distancePoint);
        self.startPositionB = addPoints(self.startPositionB, distancePoint);
    }
    else if(self.nodeType  == ADNodeTypeRope){
        self.startPositionA = addPoints(self.startPositionA, distancePoint);
        self.startPositionB = addPoints(self.startPositionB, distancePoint);
        [self.vRope updatePositionOfAllNodesBy:distancePoint];
    }
}
@end
