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
@property(nonatomic, strong) UIView *scaleView;
@end

@implementation ADSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.scaleView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + self.bounds.size.width - kOffset, self.bounds.origin.y + self.bounds.size.height - kOffset, 20, 20)];
        CALayer *slayer = self.scaleView.layer;
        slayer.cornerRadius = 10;
        slayer.borderColor = [UIColor blackColor].CGColor;
        slayer.borderWidth = 2.0;
        slayer.masksToBounds = YES;
    //    [self addSubview:self.scaleView];
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];


    self.center = CGPointMake(self.center.x + (point.x - previousPoint.x), self.center.y + (point.y - previousPoint.y));
    self.currentNode.originalPosition = self.currentNode.position = CGPointMake(self.currentNode.position.x + (point.x - previousPoint.x), self.currentNode.position.y - (point.y - previousPoint.y));
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   // [ADNodeManager setPhysicsBodyToNode:self.currentNode inWorld:self.];
}


- (void)setNode:(ADNode*)node
{
    if ([node isKindOfClass:[SKScene class]]) {
        return;
    }
    
    if (self.currentNode) {
        [self.currentNode unHighlight];
    }
    [node highlight];
    
//    CGPoint pathPoint = CGPathGetCurrentPoint(node.path);
    self.currentNode = node;
    return;
//    CGRect  pathBox = CGPathGetBoundingBox(node.path);
    
//    CGPoint centerDiffPoint =  CGPointMake(self.center.x - CGRectGetMidX(pathBox), self.center.y - CGRectGetMidY(pathBox));
//    // Create the shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//    CATransform3D tmatrix = CATransform3DIdentity;
//    NSLog(@"%.0f",node.zRotation*57.2957795);
//    tmatrix = CATransform3DRotate(tmatrix, node.zRotation, 0, 0, 1);
//    tmatrix = CATransform3DScale(tmatrix, 1.0, -1.0, 1.0);
//    tmatrix = CATransform3DTranslate(tmatrix, CGRectGetWidth(pathBox)/2,CGRectGetHeight(pathBox)/2 - CGRectGetHeight(pathBox), 0);
//
//    [shapeLayer setTransform:tmatrix];
    [shapeLayer setFillColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [shapeLayer setLineWidth:2.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],
      nil]];
    
    [shapeLayer setPath:CGPathCreateWithRect(self.bounds, nil)];
//    [shapeLayer setPath:CGPathCreateWithRect(pathBox, nil)];
    
    [self.layer addSublayer:shapeLayer];
    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation
                     animationWithKeyPath:@"lineDashPhase"];
    
    [dashAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
    [dashAnimation setToValue:[NSNumber numberWithFloat:15.0f]];
    [dashAnimation setDuration:0.75f];
    [dashAnimation setRepeatCount:10000];
    
    [shapeLayer addAnimation:dashAnimation forKey:@"linePhase"];
}

@end 