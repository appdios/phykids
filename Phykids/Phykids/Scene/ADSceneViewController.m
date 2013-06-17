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
//#import "ADSelectionViewController.h"

@import SpriteKit;

@interface ADSceneViewController ()
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) ADScene *sceneView;
@end

@implementation ADSceneViewController

- (void)loadView
{
    self.view = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    SKView *sView = (SKView*)self.view;
    [sView setShowsFPS:YES];
    [sView setShowsNodeCount:YES];
    
    self.sceneView = [[ADScene alloc] initWithSize:self.view.bounds.size];
    [self.sceneView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    [sView presentScene:self.sceneView];
    
    self.playButton = [[UIButton alloc] init];
    [self.playButton setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"btnStop"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playPauseScene) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    [self addSelectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.playButton.frame = CGRectMake(0, 0, 40, 40);
    self.playButton.center = CGPointMake(30, self.view.bounds.size.height - 30);
}

- (void)addSelectionView{
//    SKNode *currentNode = [ADNodeManager currentNode];
    CGRect boundingBox = CGRectMake(10, 10, 80, 80);//[currentNode calculateAccumulatedFrame];
    ADSelectionView *selectionView = [[ADSelectionView alloc] initWithFrame:boundingBox];
    [self.view addSubview:selectionView];
}

- (void)hideSelectionView{
    
}

- (void)playPauseScene
{
    [self.sceneView playPauseScene];
    [self.playButton setSelected:![self.playButton isSelected]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
