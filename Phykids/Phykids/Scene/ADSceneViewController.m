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
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) ADScene *sceneView;
@property (nonatomic, strong) ADSelectionView *selectionView;
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
    self.sceneView.delegate = self;
    [self.sceneView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    [sView presentScene:self.sceneView];
    
    self.playButton = [[UIButton alloc] init];
    [self.playButton setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"btnStop"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playPauseScene) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.playButton.frame = CGRectMake(0, 0, 40, 40);
    self.playButton.center = CGPointMake(30, self.view.bounds.size.height - 30);
}

- (void)hideSelectionView{
    if (self.selectionView) {
        [self.selectionView removeFromSuperview];
        self.selectionView = nil;
    }
}

- (void)playPauseScene
{
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
    
    
    
    //CGRectMake(boundingBox.origin.x - 10 + boundingBox.size.width/2, self.view.bounds.size.height - boundingBox.origin.y - boundingBox.size.height/2 - 10, boundingBox.size.width + 40, boundingBox.size.height + 40)];
    [self.view addSubview:self.selectionView];
    [self.selectionView setPath:node.path];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
