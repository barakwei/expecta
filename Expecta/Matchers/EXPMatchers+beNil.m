#import "EXPMatchers+beNil.h"

EXPMatcherImplementationBegin(beNil, (void)) {
  match(^BOOL(id actual) {
    return !actual;
  });

  failureMessageForTo(^NSString *(id actual) {
    return [NSString stringWithFormat:@"expected: nil/null, got: %@", EXPDescribeObject(actual)];
  });

  failureMessageForNotTo(^NSString *(id actual) {
    return [NSString stringWithFormat:@"expected: not nil/null, got: %@", EXPDescribeObject(actual)];
  });
}
EXPMatcherImplementationEnd

EXPMatcherAliasImplementation(beNull, beNil, (void));
