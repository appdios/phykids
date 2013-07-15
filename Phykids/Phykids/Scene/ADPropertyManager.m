//
//  ADPropertyManager.m
//  Phykids
//
//  Created by Sumit Kumar on 6/15/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import "ADPropertyManager.h"

@interface ADPropertyManager()
@property (nonatomic) ADNodeType nodeType;
@property (nonatomic, strong) UIColor *fillColor;
@end

@implementation ADPropertyManager

+ (ADPropertyManager*)sharedInstance
{
    static dispatch_once_t once;
    static ADPropertyManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.nodeType = ADNodeTypeRectangle;
    });
    return sharedInstance;
}

+ (ADNodeType)selectedNodeType
{
    return [[ADPropertyManager sharedInstance] nodeType];
}

+ (void)setSelectedNodeType:(ADNodeType)type
{
    ADPropertyManager *propertyManager = [ADPropertyManager sharedInstance];
    propertyManager.nodeType = type;
}

+ (UIColor*)currentFillColor
{
    ADPropertyManager *propertyManager = [ADPropertyManager sharedInstance];
    if (propertyManager.fillColor == nil) {
        propertyManager.fillColor = randomColor();
    }
    return propertyManager.fillColor;
}

+ (void)setCurrentFillColor:(UIColor*)color
{
    ADPropertyManager *propertyManager = [ADPropertyManager sharedInstance];
    propertyManager.fillColor = color;
}

@end
