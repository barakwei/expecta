#import "ExpectaSupport.h"
#import "NSValue+Expecta.h"
#import "NSObject+Expecta.h"
#import "EXPUnsupportedObject.h"
#import "EXPFloatTuple.h"
#import "EXPDoubleTuple.h"
#import "EXPDefines.h"
#import <objc/runtime.h>
#import <stdatomic.h>

@interface NSObject (ExpectaXCTestRecordFailure)

// suppress warning
- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filename atLine:(NSUInteger)lineNumber expected:(BOOL)expected;

@end

id _EXPObjectify(const char *type, void *value) {
  id obj = nil;
  if(strcmp(type, @encode(char)) == 0 || strcmp(type, @encode(atomic_char)) == 0) {
    obj = @(*(char *)value);
  } else if(strcmp(type, @encode(_Bool)) == 0 || strcmp(type, @encode(atomic_bool)) == 0) {
    obj = @(*(_Bool *)value);
  } else if(strcmp(type, @encode(double)) == 0) {
    obj = @(*(double *)value);
  } else if(strcmp(type, @encode(float)) == 0) {
    obj = @(*(float *)value);
  } else if(strcmp(type, @encode(int)) == 0 || strcmp(type, @encode(atomic_int)) == 0) {
    obj = @(*(int *)value);
  } else if(strcmp(type, @encode(long)) == 0 || strcmp(type, @encode(atomic_long)) == 0) {
    obj = @(*(long *)value);
  } else if(strcmp(type, @encode(long long)) == 0 || strcmp(type, @encode(atomic_llong)) == 0) {
    obj = @(*(long long *)value);
  } else if(strcmp(type, @encode(short)) == 0 || strcmp(type, @encode(atomic_short)) == 0) {
    obj = @(*(short *)value);
  } else if(strcmp(type, @encode(unsigned char)) == 0 || strcmp(type, @encode(atomic_uchar)) == 0) {
    obj = @(*(unsigned char *)value);
  } else if(strcmp(type, @encode(unsigned int)) == 0 || strcmp(type, @encode(atomic_uint)) == 0) {
    obj = @(*(unsigned int *)value);
  } else if(strcmp(type, @encode(unsigned long)) == 0 || strcmp(type, @encode(atomic_ulong)) == 0) {
    obj = @(*(unsigned long *)value);
  } else if(strcmp(type, @encode(unsigned long long)) == 0 || strcmp(type, @encode(atomic_ullong)) == 0) {
    obj = @(*(unsigned long long *)value);
  } else if(strcmp(type, @encode(unsigned short)) == 0 || strcmp(type, @encode(atomic_ushort)) == 0) {
    obj = @(*(unsigned short *)value);
  } else if(strstr(type, @encode(EXPBasicBlock)) != NULL) {
      // @encode(EXPBasicBlock) returns @? as of clang 4.1.
      // This condition must occur before the test for id/class type,
      // otherwise blocks will be treated as vanilla objects.
      id actual = *(EXPBasicBlock *)value;
      obj = [[actual copy] autorelease];
  } else if((strstr(type, @encode(id)) != NULL) || (strstr(type, @encode(Class)) != 0)) {
    obj = *(id *)value;
  } else if(strcmp(type, @encode(__typeof__(nil))) == 0) {
    obj = nil;
  } else if(strstr(type, "ff}{") != NULL || strstr(type, "=ff}") != NULL ||
            strstr(type, "=fff}") != NULL || strstr(type, "=ffff}") != NULL) {
    NSUInteger size;
    NSGetSizeAndAlignment(type, &size, NULL);
    obj = [[[EXPFloatTuple alloc] initWithFloatValues:(float *)value
                                                 size:size / sizeof(float)] autorelease];
  } else if(strstr(type, "dd}{") != NULL || strstr(type, "=dd}") != NULL ||
            strstr(type, "=ddd}") != NULL || strstr(type, "=dddd}") != NULL) {
    NSUInteger size;
    NSGetSizeAndAlignment(type, &size, NULL);
    obj = [[[EXPDoubleTuple alloc] initWithDoubleValues:(double *)value
                                                   size:size / sizeof(double)] autorelease];
  } else if(type[0] == '{') {
    EXPUnsupportedObject *actual = [[[EXPUnsupportedObject alloc] initWithType:@"struct"] autorelease];
    obj = actual;
  } else if(type[0] == '(') {
    EXPUnsupportedObject *actual = [[[EXPUnsupportedObject alloc] initWithType:@"union"] autorelease];
    obj = actual;
  } else {
    void *actual = *(void **)value;
    obj = (actual == NULL ? nil : [NSValue valueWithPointer:actual]);
  }
  if([obj isKindOfClass:[NSValue class]] && ![obj isKindOfClass:[NSNumber class]]) {
    [(NSValue *)obj set_EXP_objCType:type];
  }
  return obj;
}

EXPExpect *_EXP_expect(id testCase, int lineNumber, const char *fileName, EXPIdBlock actualBlock) {
  return [EXPExpect expectWithActualBlock:actualBlock testCase:testCase lineNumber:lineNumber fileName:fileName];
}

void EXPFail(id testCase, int lineNumber, const char *fileName, NSString *message) {
  NSLog(@"%s:%d %@", fileName, lineNumber, message);
  NSString *reason = [NSString stringWithFormat:@"%s:%d %@", fileName, lineNumber, message];
  NSException *exception = [NSException exceptionWithName:@"Expecta Error" reason:reason userInfo:nil];

  if(testCase && [testCase respondsToSelector:@selector(recordFailureWithDescription:inFile:atLine:expected:)]){
      [testCase recordFailureWithDescription:message
                                      inFile:@(fileName)
                                      atLine:lineNumber
                                    expected:NO];
  } else {
    [exception raise];
  }
}

NSString *EXPDescribeObject(id obj) {
  if(obj == nil) {
    return @"nil/null";
  } else if([obj isKindOfClass:[NSValue class]] && ![obj isKindOfClass:[NSNumber class]]) {
    const char *type = [(NSValue *)obj _EXP_objCType];
    if(type) {
      if(strcmp(type, @encode(SEL)) == 0) {
        return [NSString stringWithFormat:@"@selector(%@)", NSStringFromSelector([obj pointerValue])];
      } else if(strcmp(type, @encode(Class)) == 0) {
        return NSStringFromClass([obj pointerValue]);
      }
    }
  }
  NSString *description = [obj description];
  if([obj isKindOfClass:[NSArray class]]) {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[obj count]];
    for(id o in obj) {
      [arr addObject:EXPDescribeObject(o)];
    }
    description = [NSString stringWithFormat:@"(%@)", [arr componentsJoinedByString:@", "]];
  } else if([obj isKindOfClass:[NSSet class]] || [obj isKindOfClass:[NSOrderedSet class]]) {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[obj count]];
    for(id o in obj) {
      [arr addObject:EXPDescribeObject(o)];
    }
    description = [NSString stringWithFormat:@"{(%@)}", [arr componentsJoinedByString:@", "]];
  } else if([obj isKindOfClass:[NSDictionary class]]) {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[obj count]];
    for(id k in obj) {
      id v = obj[k];
      [arr addObject:[NSString stringWithFormat:@"%@ = %@;",EXPDescribeObject(k), EXPDescribeObject(v)]];
    }
    description = [NSString stringWithFormat:@"{%@}", [arr componentsJoinedByString:@" "]];
  } else if([obj isKindOfClass:[NSAttributedString class]]) {
    description = [obj string];
  } else {
    description = [description stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
  }
  return description;
}

void EXP_prerequisite(EXPMatchBlock block) {
  [[[NSThread currentThread] threadDictionary][@"EXP_currentMatcher"] setPrerequisiteBlock:block];
}

void EXP_match(EXPMatchBlock block) {
  [[[NSThread currentThread] threadDictionary][@"EXP_currentMatcher"] setMatchBlock:block];
}

void EXP_failureMessageForTo(EXPFailureMessageBlock block) {
  [[[NSThread currentThread] threadDictionary][@"EXP_currentMatcher"] setFailureMessageForToBlock:block];
}

void EXP_failureMessageForNotTo(EXPFailureMessageBlock block) {
  [[[NSThread currentThread] threadDictionary][@"EXP_currentMatcher"] setFailureMessageForNotToBlock:block];
}

