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
    if (self.currentNode.nodeType == ADNodeTypeSpring) {
        self.currentNode.startPositionA = CGPointMake(self.currentNode.startPositionA.x + (point.x - previousPoint.x), self.currentNode.startPositionA.y - (point.y - previousPoint.y));
        self.currentNode.startPositionB = CGPointMake(self.currentNode.startPositionB.x + (point.x - previousPoint.x), self.currentNode.startPositionB.y - (point.y - previousPoint.y));
    }
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
    
    self.currentNode = node;
}

@end 