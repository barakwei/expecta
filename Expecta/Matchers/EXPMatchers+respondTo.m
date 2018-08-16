#import "EXPMatchers+respondTo.h"
#import "EXPMatcherHelpers.h"

EXPMatcherImplementationBegin(respondTo, (SEL expected)) {
  prerequisite(^BOOL(id actual) {
    return actual && expected;
  });

  match(^BOOL(id actual) {
    return [actual respondsToSelector:expected];
  });

  failureMessageForTo(^NSString *(id actual) {
    if (!actual) return @"the object is nil/null";
    if (!expected) return @"the selector is null";
    return [NSString stringWithFormat:@"expected: %@ to respond to %@", EXPDescribeObject(actual), NSStringFromSelector(expected)];
  });

  failureMessageForNotTo(^NSString *(id actual) {
    if (!actual) return @"the object is nil/null";
    if (!expected) return @"the selector is null";
    return [NSString stringWithFormat:@"expected: %@ not to respond to %@", EXPDescribeObject(actual), NSStringFromSelector(expected)];
  });
}
EXPMatcherImplementationEnd
