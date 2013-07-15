//
//  ADSceneViewController.h
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADScene.h"

@interface ADSceneViewController : UIViewController<ADSceneDelegate>

@property (nonatomic, strong) IBOutlet UIButton *playButton;

- (IBAction)shapeChanged:(UIButton*)sender;
- (IBAction)toolSelected:(UIButton*)sender;
@end
