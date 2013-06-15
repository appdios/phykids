//
//  ADSelectionView.m
//  Phykids
//
//  Created by Aditi Kamal on 6/14/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADSelectionView.h"

@implementation ADSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    float dash[2]={6 ,5}; // pattern 6 times “solid”, 5 times “empty”
    CGContextSetLineDash(context,0,dash,2);
    CGContextAddRect(context, CGRectMake(0, 0, 30, 30));
}



@end
