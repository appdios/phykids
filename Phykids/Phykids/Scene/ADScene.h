//
//  ADScene.h
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol ADSceneDelegate <NSObject>
- (void)showSelectionViewForNode:(SKShapeNode*)node;
@end

@interface ADScene : SKScene

@property (nonatomic, weak) id<ADSceneDelegate> delegate;
@property (nonatomic) BOOL isPaused;
@property (nonatomic) BOOL toolSelected;
- (void)playPauseScene;
@end
