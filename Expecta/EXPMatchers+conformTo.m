#import "EXPMatchers+conformTo.h"
#import "NSValue+Expecta.h"
#import <objc/runtime.h>

EXPMatcherImplementationBegin(conformTo, (Protocol *expected)) {
    prerequisite(^BOOL(id actual) {
        return actual && expected;
    });

    match(^BOOL(id actual) {
        return [actual conformsToProtocol:expected];
    });

    failureMessageForTo(^NSString *(id actual) {
        if(!actual) return @"the object is nil/null";
        if(!expected) return @"the protocol is nil/null";

        NSString *name = NSStringFromProtocol(expected);
        return [NSString stringWithFormat:@"expected: %@ to conform to %@", actual, name];
    });

    failureMessageForNotTo(^NSString *(id actual) {
        if(!actual) return @"the object is nil/null";
        if(!expected) return @"the protocol is nil/null";

        NSString *name = NSStringFromProtocol(expected);
        return [NSString stringWithFormat:@"expected: %@ not to conform to %@", actual, name];
    });
}
EXPMatcherImplementationEnd
