#import "DataBackupManager.h"

@interface DataBackupManager()

@property (nonatomic, copy) NSString *backupPath;

@end

@implementation DataBackupManager

+ (instancetype)sharedManager {
    static DataBackupManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataBackupManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths.firstObject;
        self.backupPath = [documentsDirectory stringByAppendingPathComponent:@"backup"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.backupPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.backupPath
                                    withIntermediateDirectories:YES
                                                     attributes:nil
                                                          error:nil];
        }
    }
    return self;
}

- (void)backupData {
    NSString *feastPath = [self getFeastFilePath];
    NSString *backupFeastPath = [self.backupPath stringByAppendingPathComponent:@"feast.backup"];
    
    [[NSFileManager defaultManager] copyItemAtPath:feastPath toPath:backupFeastPath error:nil];
}

- (void)restoreData {
    NSString *backupFeastPath = [self.backupPath stringByAppendingPathComponent:@"feast.backup"];
    NSString *feastPath = [self getFeastFilePath];
    
    [[NSFileManager defaultManager] copyItemAtPath:backupFeastPath toPath:feastPath error:nil];
}

- (BOOL)hasBackup {
    NSString *backupFeastPath = [self.backupPath stringByAppendingPathComponent:@"feast.backup"];
    return [[NSFileManager defaultManager] fileExistsAtPath:backupFeastPath];
}

#pragma mark - Helper Methods

- (NSString *)getFeastFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    return [documentsDirectory stringByAppendingPathComponent:@"feasts.data"];
}

@end