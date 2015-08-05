#import <Foundation/Foundation.h>

@interface EXPUnsupportedObject : NSObject {
  NSString *_type;
}

@property (nonatomic, retain) NSString *type;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(NSString *)type NS_DESIGNATED_INITIALIZER;

@end
