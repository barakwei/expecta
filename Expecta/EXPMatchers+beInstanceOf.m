#import "EXPMatchers+beInstanceOf.h"

EXPMatcherImplementationBegin(beInstanceOf, (Class expected)) {
  prerequisite(^BOOL(id actual) {
    return actual && expected;
  });

  match(^BOOL(id actual) {
    return [actual isMemberOfClass:expected];
  });

  failureMessageForTo(^NSString *(id actual) {
    if(!actual) return @"the actual value is nil/null";
    if(!expected) return @"the expected value is nil/null";
    return [NSString stringWithFormat:@"expected: an instance of %@, got: an instance of %@", [expected class], [actual class]];
  });

  failureMessageForNotTo(^NSString *(id actual) {
    if(!actual) return @"the actual value is nil/null";
    if(!expected) return @"the expected value is nil/null";
    return [NSString stringWithFormat:@"expected: not an instance of %@, got: an instance of %@", [expected class], [actual class]];
  });
}
EXPMatcherImplementationEnd

EXPMatcherAliasImplementation(beAnInstanceOf, beInstanceOf, (Class expected));
EXPMatcherAliasImplementation(beMemberOf,     beInstanceOf, (Class expected));
EXPMatcherAliasImplementation(beAMemberOf,    beInstanceOf, (Class expected));
