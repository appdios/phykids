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
    
    self.selectionView = [[ADSelectionView alloc] initWithFrame:CGRectZero];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [tapGesture setCancelsTouchesInView:YES];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)tapGesture:(UITapGestureRecognizer*)recognizer{
    if (self.sceneView.isPaused) {
        CGPoint point = [recognizer locationInView:self.view];
        SKNode *node = [self.sceneView nodeAtPoint:[self.sceneView convertPointFromView:point]];
        if ([node isKindOfClass:[ADScene class]]) {
            [self hideSelectionView];
        }
        if (node) {
            [self showSelectionViewForNode:(ADNode*)node];
        }
    }
}

- (void)showSelectionViewForNode:(SKShapeNode *)node
{
    [self.view addSubview:self.selectionView];
    [self.selectionView setNode:node];
}

- (void)hideSelectionView{
    if (self.selectionView) {
        if (self.selectionView.currentNode) {
            [self.selectionView.currentNode unHighlight];
        }
        [self.selectionView removeFromSuperview];
    }
}

- (void)playPauseScene
{
    [self showHideMenu];
    [self hideSelectionView];
    [self.sceneView playPauseScene];
    [self.playButton setSelected:![self.playButton isSelected]];
}

- (void)showHideMenu
{
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)obj;
            if (btn.tag > 0) {
                btn.hidden = self.sceneView.isPaused;
            }
        }
    }];
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
