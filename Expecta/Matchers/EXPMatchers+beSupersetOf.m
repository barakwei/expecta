#import "EXPMatchers+contain.h"

EXPMatcherImplementationBegin(beSupersetOf, (id subset)) {
  BOOL subsetIsNil = (subset == nil);

  BOOL(^actualIsCompatible)(id actual) = ^BOOL(id actual) {
    return [actual isKindOfClass:[NSDictionary class]] || [actual respondsToSelector:@selector(containsObject:)];
  };

  BOOL(^classMatches)(id actual) = ^BOOL(id actual) {
    // For some instances the isKindOfClass: method returns false, even though
    // they are both actually dictionaries. e.g. Comparing a NSCFDictionary and a
    // NSDictionary.
    // Or in cases when you compare NSMutableArray (which implementation is __NSArrayM:NSMutableArray:NSArray)
    // and NSArray (which implementation is __NSArrayI:NSArray)
    BOOL bothAreIdenticalCollectionClasses = ([actual isKindOfClass:[NSDictionary class]] && [subset isKindOfClass:[NSDictionary class]]) ||
          ([actual isKindOfClass:[NSArray class]] && [subset isKindOfClass:[NSArray class]]) ||
          ([actual isKindOfClass:[NSSet class]] && [subset isKindOfClass:[NSSet class]]) ||
          ([actual isKindOfClass:[NSOrderedSet class]] && [subset isKindOfClass:[NSOrderedSet class]]);

    return bothAreIdenticalCollectionClasses || [subset isKindOfClass:[actual class]];
  };

  prerequisite(^BOOL(id actual) {
    return actualIsCompatible(actual) && !subsetIsNil && classMatches(actual);
  });

  match(^BOOL(id actual) {
    if(!actualIsCompatible(actual)) return NO;

    if([actual isKindOfClass:[NSDictionary class]]) {
      for (id key in subset) {
        id actualValue = [actual valueForKey:key];
        id subsetValue = [subset valueForKey:key];

        if (![subsetValue isEqual:actualValue]) return NO;
      }
    } else {
      for (id object in subset) {
        if (![actual containsObject:object]) return NO;
      }
    }

    return YES;
  });

  failureMessageForTo(^NSString *(id actual) {
    if(!actualIsCompatible(actual)) return [NSString stringWithFormat:@"%@ is not an instance of NSDictionary and does not implement -containsObject:", EXPDescribeObject(actual)];

    if(subsetIsNil) return @"the expected value is nil/null";

    if(!classMatches(actual)) return [NSString stringWithFormat:@"%@ does not match the class of %@", EXPDescribeObject(subset), EXPDescribeObject(actual)];

    return [NSString stringWithFormat:@"expected %@ to be a superset of %@", EXPDescribeObject(actual), EXPDescribeObject(subset)];
  });

  failureMessageForNotTo(^NSString *(id actual) {
    if(!actualIsCompatible(actual)) return [NSString stringWithFormat:@"%@ is not an instance of NSDictionary and does not implement -containsObject:", EXPDescribeObject(actual)];

    if(subsetIsNil) return @"the expected value is nil/null";

    if(!classMatches(actual)) return [NSString stringWithFormat:@"%@ does not match the class of %@", EXPDescribeObject(subset), EXPDescribeObject(actual)];

    return [NSString stringWithFormat:@"expected %@ not to be a superset of %@", EXPDescribeObject(actual), EXPDescribeObject(subset)];
  });
}
EXPMatcherImplementationEnd
