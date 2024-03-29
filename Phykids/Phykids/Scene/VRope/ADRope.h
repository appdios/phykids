

#import "ADRopePoint.h"
#import "ADStick.h"
#import <SpriteKit/SpriteKit.h>

#define PTM_RATIO 1

@interface ADRope : NSObject

- (id)initWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB spriteSheet:(SKNode*)spriteSheetArg antiSagHack:(CGFloat)antiSagHack;
- (void)createRope:(CGPoint)pointA pointB:(CGPoint)pointB;
- (void)resetWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB;
- (void)updateWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB dt:(float)dt;
- (void)updateSprites;
- (void)updateSpritesWithPoints:(CGPoint)pointA pointB:(CGPoint)pointB;
- (void)removeAllNodes;
- (void)updateParentOfAllNodes:(id)parent;
- (void)updatePositionOfAllNodesBy:(CGPoint)distancePoint;
@end
