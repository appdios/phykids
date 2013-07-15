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
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
//    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)tapGesture:(UITapGestureRecognizer*)recognizer{
    if (self.sceneView.isPaused) {
        CGPoint point = [recognizer locationInView:self.view];
        NSArray *nodes = [self.sceneView nodesAtPoint:[self.sceneView convertPointFromView:point]];
        __block ADNode *shapeNode = nil;
        [nodes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[ADNode class]] && ((ADNode*)obj).nodeType<ADNodeTypePivot) {
                shapeNode = (ADNode*)obj;
                *stop = YES;
            }
        }];
//        [nodes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            if ([obj isKindOfClass:[ADNode class]] ||
//                [obj isKindOfClass:[ADSpriteNode class]]) {
//                shapeNode = (ADNode*)obj;
//                *stop = YES;
//            }
//        }];
        if (shapeNode) {
            [shapeNode setGluedToScene:!shapeNode.gluedToScene];
            [shapeNode unHighlight];
//            [self showSelectionViewForNode:shapeNode];
        }
        else {
//            [self hideSelectionView];
        }
    }
}

- (void)showSelectionViewForNode:(SKShapeNode *)node
{
    CGRect nodeFrame =[node calculateAccumulatedFrame];
    CGPoint originPoint = [self.sceneView convertPointToView:nodeFrame.origin];
    self.selectionView.frame = CGRectMake(originPoint.x, originPoint.y - nodeFrame.size.height, nodeFrame.size.width, nodeFrame.size.height);
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
    self.sceneView.toolSelected = NO;
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

- (IBAction)toolSelected:(UIButton*)sender
{
    self.sceneView.toolSelected = YES;
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
