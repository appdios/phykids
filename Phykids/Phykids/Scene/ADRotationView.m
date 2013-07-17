//
//  ADRotationView.m
//  Phykids
//
//  Created by Sumit Kumar on 7/16/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADRotationView.h"

@interface ADRotationView()

@property (nonatomic) CGPoint startPoint;
@end

@implementation ADRotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    CGRect rect = CGPathGetBoundingBox(self.node.path);
    CGPoint pp = subtractPoints(self.center, CGPointMake(CGRectGetWidth(rect)/2, CGRectGetHeight(rect)/2)) ;
    
    self.startPoint = pp;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPoint ppoint = [[touches anyObject] previousLocationInView:self];
    
    
    double angleInRadian = atan2(point.y-self.startPoint.y,point.x-self.startPoint.x);
    NSLog(@"%.0f",angleInRadian*57.2957795);
    self.node.zRotation = angleInRadian;
    
    self.center = point;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

@end
