//
//  VStick.h
//
//  Created by patrick on 14/10/2010.
//

#import "ADRopePoint.h"

@interface ADStick : NSObject

- (id)initWith:(ADRopePoint*)argA pointb:(ADRopePoint*)argB;
- (void)contract;
- (ADRopePoint*)getPointA;
- (ADRopePoint*)getPointB;
@end
