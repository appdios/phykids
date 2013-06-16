//
//  ADNodeManager.h
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface ADNodeManager : NSObject

+ (id)nodeOfType:(ADNodeType)type atPoint:(CGPoint)point;
+ (void)tranformNode:(SKNode*)node withMatrix:(CGAffineTransform)matrix;
+ (void)setPhysicsBodyToNode:(SKNode*)node;
+ (SKNode*)currentSelectedNode;
+ (void)setCurrentSelectedNode:(SKNode*)node;
@end
