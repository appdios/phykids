//
//  ADSelectionView.m
//  Phykids
//
//  Created by Aditi Kamal on 6/14/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADSelectionView.h"
#import "ADMathHelper.h"

static const int kOffset = 20;

@interface ADSelectionView ()
@property(nonatomic, strong) UIView *scaleView;
@end

@implementation ADSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      //  [self setBackgroundColor:[UIColor lightGrayColor]];
        


      //  [self addOverlay];

        self.scaleView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + self.bounds.size.width - kOffset, self.bounds.origin.y + self.bounds.size.height - kOffset, 20, 20)];
//        self.scaleView.backgroundColor = [UIColor redColor];
        CALayer *slayer = self.scaleView.layer;
        slayer.cornerRadius = 10;
        slayer.borderColor = [UIColor blackColor].CGColor;
        slayer.borderWidth = 2.0;
        slayer.masksToBounds = YES;
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
    CGPoint previousPoint = [touch previousLocationInView:self];

//    if(CGRectContainsPoint(self.scaleView.frame, point)){
        self.transform = CGAffineTransformRotate(self.transform, angleBetweenPoints(point, previousPoint));
//    }
//    else{
////        self.transform = CGAffineTransformTranslate(self.transform, point.x - previousPoint.x, point.y - previousPoint.y);
//    }
}


- (void)setPath:(CGPathRef)path
{
    CGRect  pathBox = CGPathGetPathBoundingBox(path);
    double xx = CGRectGetMidX(pathBox) - CGRectGetMidX(self.bounds);
    double yy = CGRectGetMidY(pathBox) - CGRectGetMidY(self.bounds);
    // Create the shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setTransform:CATransform3DMakeTranslation(abs(xx), abs(yy), 0)];
    [shapeLayer setFillColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [shapeLayer setLineWidth:2.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],
      nil]];
    
    [shapeLayer setPath:path];
    
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