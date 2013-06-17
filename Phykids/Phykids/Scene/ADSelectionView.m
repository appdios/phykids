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
        [self setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
        


        [self addOverlay];

        self.scaleView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + self.bounds.size.width - kOffset, self.bounds.origin.y + self.bounds.size.height - kOffset, 20, 20)];
        self.scaleView.backgroundColor = [UIColor redColor];
        [self addSubview:self.scaleView];

        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if(CGRectContainsPoint(self.scaleView.frame, point)){
        self.transform = CGAffineTransformRotate(self.transform, M_PI);
    }
    else{
        CGPoint previousPoint = [touch previousLocationInView:self];
        self.transform = CGAffineTransformTranslate(self.transform, point.x - previousPoint.x, point.y - previousPoint.y);
    }
}

- (void)move:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:gesture.view];
    
    CGAffineTransform matrix =  CGAffineTransformMakeTranslation(translation.x, translation.y);
    gesture.view.transform = matrix;
    
   
}

- (void)layoutSubviews
{
}

- (void)addOverlay
{
    // Create the shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGRect shapeRect = CGRectMake(kOffset/2, kOffset/2, self.bounds.size.width-2*kOffset, self.bounds.size.height-2*kOffset);
    [shapeLayer setFrame:shapeRect];
    //    [shapeLayer setPosition:self.view.bounds.origin];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor redColor] CGColor]];
    [shapeLayer setLineWidth:2.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],
      nil]];
    
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, shapeRect);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
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


//- (void)drawRect:(CGRect)rect
//{
//   }



@end 