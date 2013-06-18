//
//  ADSelectionView.m
//  Phykids
//
//  Created by Aditi Kamal on 6/14/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADSelectionView.h"
#import "ADNodeManager.h"

static const int kOffset = 20;

@interface ADSelectionView ()
@property(nonatomic, strong) UIView *scaleView;
@property(nonatomic, strong) SKNode *currentNode;
@end

@implementation ADSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self setBackgroundColor:[UIColor lightGrayColor]];
        


      //  [self addOverlay];

        self.scaleView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + self.bounds.size.width - kOffset, self.bounds.origin.y + self.bounds.size.height - kOffset, 20, 20)];
//        self.scaleView.backgroundColor = [UIColor redColor];
        CALayer *slayer = self.scaleView.layer;
        slayer.cornerRadius = 10;
        slayer.borderColor = [UIColor blackColor].CGColor;
        slayer.borderWidth = 2.0;
        slayer.masksToBounds = YES;
     //   [self addSubview:self.scaleView];

        
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
    self.currentNode.position = CGPointMake(self.currentNode.position.x + (point.x - previousPoint.x), self.currentNode.position.y - (point.y - previousPoint.y));
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self.currentNode.userData setObject:[NSValue valueWithCGAffineTransform:self.transform] forKey:@"matrix"];
//
    [ADNodeManager setPhysicsBodyToNode:self.currentNode];
}


- (void)setNode:(SKShapeNode*)node
{
    if (![node isKindOfClass:[SKShapeNode class]]) {
        return;
    }
//    NSValue *matrixValue = [node.userData objectForKey:@"matrix"];
//    if (matrixValue) {
//        self.transform = matrixValue.CGAffineTransformValue;
//    }
    NSLog(@"%.2f",node.zRotation*57.2957795);
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, node.zRotation);
   // transform = CGAffineTransformTranslate(transform,self.frame.size.width/2,self.frame.size.height/2);
    
    self.transform = transform;
    
    self.currentNode = node;
    CGRect  pathBox = CGPathGetPathBoundingBox(node.path);
    double xx = CGRectGetMidX(pathBox) - CGRectGetMidX(self.bounds);
    double yy = CGRectGetMidY(pathBox) - CGRectGetMidY(self.bounds);
    // Create the shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CATransform3D tmatrix = CATransform3DIdentity;
    tmatrix = CATransform3DScale(tmatrix, 1.0, -1.0, 1.0);
    tmatrix = CATransform3DTranslate(tmatrix, abs(xx), abs(yy), 0);
    tmatrix = CATransform3DTranslate(tmatrix, 0.0, -pathBox.size.height, 0);
    [shapeLayer setTransform:tmatrix];
    [shapeLayer setFillColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [shapeLayer setLineWidth:2.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],
      nil]];
    
    [shapeLayer setPath:node.path];
    
    // Set the layer's contents
    //    [shapeLayer setContents:(id)[[UIImage imageNamed:@"balloon.jpg"] CGImage]];
    
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