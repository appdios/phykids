//
//  ADNodeFactory.h
//  Phykids
//
//  Created by Aditi Kamal on 6/13/13.
//  Copyright (c) 2013 Appdios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    ADNodeTypeSprite,
    ADNodeTypeJoint,
    ADNodeTypeAction
}ADNodeType;

typedef enum
{
    ADNodeSubTypeRectangle,
    ADNodeSubTypeCircle,
    ADNodeSubTypeTriangle,
    ADNodeSubTypePolygon
}ADNodeSubType;

@interface ADNodeFactory : NSObject

+ (id)nodeOfType:(ADNodeType)type subType:(ADNodeSubType)subType atPoint:(CGPoint)point;
@end
