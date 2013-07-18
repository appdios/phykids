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
@end

@implementation ADSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
        self.rotationView = [[UIView alloc] initWithFrame:CGRectMake(0,0,50,50)];
        CALayer *slayer = self.rotationView.layer;
        slayer.cornerRadius = 25;
        slayer.borderColor = [UIColor blackColor].CGColor;
        slayer.borderWidth = 2.0;
        slayer.masksToBounds = YES;
        [self addSubview:self.rotationView];
        
    }
    return self;
}
    
- (void)adjustSubviews{
    self.rotationView.center = CGPointMake(CGRectGetMaxX(self.bounds) - 25, CGRectGetMaxY(self.bounds) - 25);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];

    
//    [self translateFrom:previousPoint toPoint:point];
    [self rotateFrom:previousPoint toPoint:point];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)translateFrom:(CGPoint)previousPoint toPoint:(CGPoint)point{
    self.center = CGPointMake(self.center.x + (point.x - previousPoint.x), self.center.y + (point.y - previousPoint.y));
    if (self.currentNode.nodeType == ADNodeTypeSpring) {
        self.currentNode.startPositionA = CGPointMake(self.currentNode.startPositionA.x + (point.x - previousPoint.x), self.currentNode.startPositionA.y - (point.y - previousPoint.y));
        self.currentNode.startPositionB = CGPointMake(self.currentNode.startPositionB.x + (point.x - previousPoint.x), self.currentNode.startPositionB.y - (point.y - previousPoint.y));
    }
    self.currentNode.originalPosition = self.currentNode.position = CGPointMake(self.currentNode.position.x + (point.x - previousPoint.x), self.currentNode.position.y - (point.y - previousPoint.y));
}
    
- (void)rotateFrom:(CGPoint)previousPoint toPoint:(CGPoint)point{
	double angleInRadian = angleBetweenPoints(point, CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0));
    self.transform = CGAffineTransformMakeRotation(angleInRadian);
}

@end