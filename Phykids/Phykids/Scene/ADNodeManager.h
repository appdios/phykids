//
//  ADNodeManager.h
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ADNode.h"
#import "ADSpriteNode.h"

@interface ADNodeManager : NSObject


+ (ADNodeManager*)sharedInstance;
+ (void)tranformNode:(ADNode*)node withMatrix:(CGAffineTransform)matrix;
+ (void)setPhysicsBodyToNode:(ADNode*)node;
+ (ADNode*)currentSelectedNode;
+ (void)setCurrentSelectedNode:(ADNode*)node;
@end
