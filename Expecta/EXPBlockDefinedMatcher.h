//
//  EXPRuntimeMatcher.h
//  Expecta
//
//  Created by Luke Redpath on 26/03/2012.
//  Copyright (c) 2012 Peter Jihoon Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EXPMatcher.h"
#import "EXPDefines.h"

typedef BOOL (^EXPMatchBlock)(id actual);
typedef NSString *(^EXPFailureMessageBlock)(id actual);

@interface EXPBlockDefinedMatcher : NSObject <EXPMatcher> {
  EXPMatchBlock prerequisiteBlock;
  EXPMatchBlock matchBlock;
  EXPFailureMessageBlock failureMessageForToBlock;
  EXPFailureMessageBlock failureMessageForNotToBlock;
}

@property(nonatomic, copy) EXPMatchBlock prerequisiteBlock;
@property(nonatomic, copy) EXPMatchBlock matchBlock;
@property(nonatomic, copy) EXPFailureMessageBlock failureMessageForToBlock;
@property(nonatomic, copy) EXPFailureMessageBlock failureMessageForNotToBlock;

@end
