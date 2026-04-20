#import <Foundation/Foundation.h>

@interface CrashReporter : NSObject

+ (instancetype)sharedReporter;
- (void)startMonitoring;
- (void)logError:(NSError *)error;

@end