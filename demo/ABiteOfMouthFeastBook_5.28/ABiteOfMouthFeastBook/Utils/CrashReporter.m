#import "CrashReporter.h"

@interface CrashReporter()

@property (nonatomic, copy) NSString *logPath;

@end

@implementation CrashReporter

+ (instancetype)sharedReporter {
    static CrashReporter *reporter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reporter = [[CrashReporter alloc] init];
    });
    return reporter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths.firstObject;
        self.logPath = [documentsDirectory stringByAppendingPathComponent:@"crash_logs"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.logPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.logPath
                                    withIntermediateDirectories:YES
                                                     attributes:nil
                                                          error:nil];
        }
    }
    return self;
}

- (void)startMonitoring {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

void uncaughtExceptionHandler(NSException *exception) {
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                        dateStyle:NSDateFormatterMediumStyle
                                                        timeStyle:NSDateFormatterMediumStyle];
    
    NSString *crashLog = [NSString stringWithFormat:@"Crash Date: %@\nException Name: %@\nReason: %@\n\nCall Stack:\n%@",
                         dateString, name, reason, [callStack componentsJoinedByString:@"\n"]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"crash_logs"];
    NSString *logFile = [logPath stringByAppendingPathComponent:[NSString stringWithFormat:@"crash_%@.log",
                        [[NSUUID UUID] UUIDString]]];
    
    [crashLog writeToFile:logFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)logError:(NSError *)error {
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                        dateStyle:NSDateFormatterMediumStyle
                                                        timeStyle:NSDateFormatterMediumStyle];
    
    NSString *errorLog = [NSString stringWithFormat:@"Error Date: %@\nDomain: %@\nCode: %ld\nDescription: %@\n\nUser Info: %@",
                         dateString,
                         error.domain,
                         (long)error.code,
                         error.localizedDescription,
                         error.userInfo];
    
    NSString *logFile = [self.logPath stringByAppendingPathComponent:[NSString stringWithFormat:@"error_%@.log",
                        [[NSUUID UUID] UUIDString]]];
    
    [errorLog writeToFile:logFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end