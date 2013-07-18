//
//  ADSelectionView.h
//  Phykids
//
//  Created by Aditi Kamal on 6/14/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "ADNodeManager.h"

@interface ADSelectionView : UIView
@property(nonatomic, strong) ADNode *currentNode;

- (void)adjustSubviews;
@end
