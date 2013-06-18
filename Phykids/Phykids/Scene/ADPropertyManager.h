//
//  ADPropertyManager.h
//  Phykids
//
//  Created by Sumit Kumar on 6/15/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    ADNodeTypeRectangle,
    ADNodeTypeCircle,
    ADNodeTypePolygon,
    
}ADNodeType;

@interface ADPropertyManager : NSObject

+ (ADNodeType)selectedNodeType;
+ (void)setSelectedNodeType:(ADNodeType)type;
+ (UIColor*)currentFillColor;
+ (void)setCurrentFillColor:(UIColor*)color;

@end
