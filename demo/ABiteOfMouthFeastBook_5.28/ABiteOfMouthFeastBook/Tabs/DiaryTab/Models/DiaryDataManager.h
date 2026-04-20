#import <Foundation/Foundation.h>
#import "DiaryModel.h"

@interface DiaryDataManager : NSObject

+ (instancetype)sharedManager;

- (void)saveDiary:(DiaryModel *)diary;
- (void)updateDiary:(DiaryModel *)diary;
- (void)deleteDiary:(DiaryModel *)diary;
- (NSArray<DiaryModel *> *)getAllDiaries;
- (NSArray<DiaryModel *> *)searchDiariesWithKeyword:(NSString *)keyword;

@end