#import "EXPMatchers+match.h"
#import "EXPMatcherHelpers.h"

EXPMatcherImplementationBegin(match, (NSString *expected)) {
  __block NSRegularExpression *regex = nil;
  __block NSError *regexError = nil;
  
  prerequisite(^BOOL(id actual) {
    if (!actual || !expected) {
      return NO;
    }

    regex = [NSRegularExpression regularExpressionWithPattern:expected options:0 error:&regexError];
    return regex != nil;
  });
  
  match(^BOOL(id actual) {
    NSRange range = [regex rangeOfFirstMatchInString:actual options:0 range:NSMakeRange(0, [actual length])];
    return !NSEqualRanges(range, NSMakeRange(NSNotFound, 0));
  });
  
  failureMessageForTo(^NSString *(id actual) {
    if (!actual) return @"the object is nil/null";
    if (!expected) return @"the expression is nil/null";
    if (regexError) return [NSString stringWithFormat:@"unable to create regular expression from given parameter: %@", [regexError localizedDescription]];
    return [NSString stringWithFormat:@"expected: %@ to match to %@", EXPDescribeObject(actual), expected];
  });
  
  failureMessageForNotTo(^NSString *(id actual) {
    if (!actual) return @"the object is nil/null";
    if (!expected) return @"the expression is nil/null";
    if (regexError) return [NSString stringWithFormat:@"unable to create regular expression from given parameter: %@", [regexError localizedDescription]];
    return [NSString stringWithFormat:@"expected: %@ not to match to %@", EXPDescribeObject(actual), expected];
  });
}
EXPMatcherImplementationEnd
