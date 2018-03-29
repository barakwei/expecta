#import <Foundation/Foundation.h>

#define EXPObjectify(value) \
  ({ \
    __typeof__((value)) _local = (value); \
    _EXPObjectify(@encode(__typeof__((value))), (void *)&_local); \
  })
#define EXP_expect(actual) _EXP_expect(self, __LINE__, __FILE__, ^id{ __typeof__((actual)) strongActual = (actual); return EXPObjectify(strongActual); })
#define EXPMatcherInterface(matcherName, matcherArguments) _EXPMatcherInterface(matcherName, matcherArguments)
#define EXPMatcherImplementationBegin(matcherName, matcherArguments) _EXPMatcherImplementationBegin(matcherName, matcherArguments)
#define EXPMatcherImplementationEnd _EXPMatcherImplementationEnd
#define EXPMatcherAliasImplementation(newMatcherName, oldMatcherName, matcherArguments) _EXPMatcherAliasImplementation(newMatcherName, oldMatcherName, matcherArguments)

#define EXP_failure(message) EXPFail(self, __LINE__, __FILE__, message)


@interface Expecta : NSObject

+ (NSTimeInterval)asynchronousTestTimeout;
+ (void)setAsynchronousTestTimeout:(NSTimeInterval)timeout;

@end
