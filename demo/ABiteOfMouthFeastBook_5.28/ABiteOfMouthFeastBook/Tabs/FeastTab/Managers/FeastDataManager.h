#import <Foundation/Foundation.h>
#import "FeastModel.h"

@interface FeastDataManager : NSObject

+ (instancetype)sharedManager;
- (void)saveFeast:(FeastModel *)feast;
- (void)updateFeast:(FeastModel *)feast;
- (void)deleteFeast:(FeastModel *)feast;
- (NSArray<FeastModel *> *)getAllFeasts;
- (FeastModel *)getFeastById:(NSString *)feastId;

@end