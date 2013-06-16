//
//  ADPropertyManager.m
//  Phykids
//
//  Created by Sumit Kumar on 6/15/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADPropertyManager.h"

@interface ADPropertyManager()
@property (nonatomic) ADNodeType currentNodeType;
@end

@implementation ADPropertyManager

+ (ADPropertyManager*)sharedInstance
{
    static dispatch_once_t once;
    static ADPropertyManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (ADNodeType)selectedNodeType
{
    return [[ADPropertyManager sharedInstance] currentNodeType];
}

+ (void)setSelectedNodeType:(ADNodeType)type
{
    ADPropertyManager *propertyManager = [ADPropertyManager sharedInstance];
    propertyManager.currentNodeType = type;
}
@end
