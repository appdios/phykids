//
//  ADSceneViewController.m
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//


#import "ADSceneViewController.h"
#import "ADScene.h"
#import "ADSelectionView.h"
#import "ADNodeManager.h"

@import SpriteKit;

@interface ADSceneViewController ()
@property (nonatomic, strong) ADScene *sceneView;
@property (nonatomic, strong) ADSelectionView *selectionView;
@end

@implementation ADSceneViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    SKView *sView = (SKView*)self.view;
    [sView setShowsFPS:YES];
    [sView setShowsNodeCount:YES];
    
    self.sceneView = [[ADScene alloc] initWithSize:self.view.bounds.size];
    self.sceneView.delegate = self;
    [self.sceneView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    [sView presentScene:self.sceneView];
    
    [self.playButton setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"btnStop"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playPauseScene) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)hideSelectionView{
    if (self.selectionView) {
        [self.selectionView removeFromSuperview];
        self.selectionView = nil;
    }
}

- (void)playPauseScene
{
    [self hideSelectionView];
    [self.sceneView playPauseScene];
    [self.playButton setSelected:![self.playButton isSelected]];
}

- (void)showSelectionViewForNode:(SKShapeNode *)node
{
    if (self.selectionView) {
        [self.selectionView removeFromSuperview];
        self.selectionView = nil;
    }
    CGRect boundingBox = [node calculateAccumulatedFrame];
    
    self.selectionView = [[ADSelectionView alloc] initWithFrame:CGRectMake(boundingBox.origin.x, fabs(boundingBox.origin.y - self.view.bounds.size.height+boundingBox.size.height), boundingBox.size.width, boundingBox.size.height)];
    
    [self.view addSubview:self.selectionView];
    [self.selectionView setNode:node];
}

- (IBAction)shapeChanged:(UIButton*)sender
{
    [ADPropertyManager setSelectedNodeType:sender.tag - 1];
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)obj;
            if (btn.tag > 0) {
                btn.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:213.0/255.0 blue:224.0/255.0 alpha:1.0];
            }
        }
    }];
    sender.backgroundColor = [UIColor brownColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
