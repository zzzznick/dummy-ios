#import <Foundation/Foundation.h>

@interface DataBackupManager : NSObject

+ (instancetype)sharedManager;
- (void)backupData;
- (void)restoreData;
- (BOOL)hasBackup;

@end