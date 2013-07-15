//
//  ADNode.h
//  Phykids
//
//  Created by Aditi Kamal on 6/23/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ADNode : SKShapeNode

+ (ADNode*)rectangleNodeInRect:(CGRect)rect;
+ (ADNode*)circularNodeInRect:(CGRect)rect;
+ (ADNode*)polygonNodeWithPoints:(NSArray*)points;
@end