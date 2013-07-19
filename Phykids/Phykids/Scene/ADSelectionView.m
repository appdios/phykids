//
//  ADSelectionView.m
//  Phykids
//
//  Created by Aditi Kamal on 6/14/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADSelectionView.h"

static const int kOffset = 20;

@interface ADSelectionView ()
@property(nonatomic, strong) UIView *rotationView;
@property(nonatomic, strong) ADNode *currentNode;
@property(nonatomic) CGFloat currentAngle;
@property(nonatomic) CGPoint startposition;
@property(nonatomic) BOOL touchToRotate;
@end

@implementation ADSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        self.rotationView = [[UIView alloc] initWithFrame:CGRectMake(0,0,50,50)];
        self.rotationView.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.4];
        CALayer *slayer = self.rotationView.layer;
        slayer.cornerRadius = 25;
        slayer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        slayer.borderWidth = 2.0;
        slayer.masksToBounds = YES;
        [self addSubview:self.rotationView];
        
    }
    return self;
}

- (void)setNode:(ADNode*)node{
    self.currentNode = node;
    self.currentAngle = -node.zRotation;
    self.rotationView.center = CGPointMake(CGRectGetMaxX(self.bounds) - 25, CGRectGetMidY(self.bounds));

    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, -self.rotationView.center.x + self.frame.size.width/2.0, -self.rotationView.center.y + self.frame.size.height/2.0);
    transform = CGAffineTransformRotate(transform, -node.zRotation);
    transform = CGAffineTransformTranslate(transform, self.rotationView.center.x - self.frame.size.width/2.0, self.rotationView.center.y - self.frame.size.height/2.0);
    self.rotationView.transform = transform;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.4].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(centerPoint.x-5, centerPoint.y-5, 10, 10));
    
    CGContextAddPath(context, [self createArcPath].CGPath);
    CGContextDrawPath(context, kCGPathFill);
    
}

- (UIBezierPath *)createArcPath
{
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);

    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:centerPoint];
    [aPath addLineToPoint:CGPointMake(centerPoint.x+self.frame.size.width/2.0, centerPoint.y)];
    [aPath addArcWithCenter:centerPoint radius:self.bounds.size.width/2 startAngle:0 endAngle:-self.currentNode.zRotation clockwise:YES];
    [aPath addLineToPoint:centerPoint];
    return aPath;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.startposition = point;
    self.touchToRotate = NO;
    if (CGRectContainsPoint(self.rotationView.frame, point)) {
        self.touchToRotate = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    if (self.touchToRotate) {
        CGFloat angle = [self rotationAngle:point];
        self.currentNode.zRotation = self.currentNode.originalRotation = -angle;
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, -self.rotationView.center.x + self.frame.size.width/2.0, -self.rotationView.center.y + self.frame.size.height/2.0);
        transform = CGAffineTransformRotate(transform, angle);
        transform = CGAffineTransformTranslate(transform, self.rotationView.center.x - self.frame.size.width/2.0, self.rotationView.center.y - self.frame.size.height/2.0);
        self.rotationView.transform = transform;
        [self setNeedsDisplay];
    }
    else{
        CGPoint previousPoint = [touch previousLocationInView:self];
        [self translateFrom:previousPoint toPoint:point];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat angle = [self rotationAngle:point];

    self.currentAngle = angle;
}

- (void)translateFrom:(CGPoint)previousPoint toPoint:(CGPoint)point{
    self.center = CGPointMake(self.center.x + (point.x - previousPoint.x), self.center.y + (point.y - previousPoint.y));
    if (self.currentNode.nodeType == ADNodeTypeSpring) {
        self.currentNode.startPositionA = CGPointMake(self.currentNode.startPositionA.x + (point.x - previousPoint.x), self.currentNode.startPositionA.y - (point.y - previousPoint.y));
        self.currentNode.startPositionB = CGPointMake(self.currentNode.startPositionB.x + (point.x - previousPoint.x), self.currentNode.startPositionB.y - (point.y - previousPoint.y));
    }
    self.currentNode.originalPosition = self.currentNode.position = CGPointMake(self.currentNode.position.x + (point.x - previousPoint.x), self.currentNode.position.y - (point.y - previousPoint.y));
}

- (float) rotationAngle:(CGPoint)point
{
    CGPoint centerPoint = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    float fromAngle = atan2(self.startposition.y-centerPoint.y, self.startposition.x-centerPoint.x);
    float toAngle = atan2(point.y-centerPoint.y, point.x-centerPoint.x);
    float newAngle = wrapd(self.currentAngle + (toAngle - fromAngle), 0, 2*3.14);
    
    return newAngle;
}

double wrapd(double _val, double _min, double _max)
{
    if(_val < _min) return _max - (_min - _val);
    if(_val > _max) return _min - (_max - _val);
    return _val;
}

@end