#import "DiaryDataManager.h"

@interface DiaryDataManager ()

@property (nonatomic, strong) NSMutableArray<DiaryModel *> *diaries;
@property (nonatomic, strong) NSString *documentsPath;

@end

@implementation DiaryDataManager

+ (instancetype)sharedManager {
    static DiaryDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DiaryDataManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _diaries = [NSMutableArray array];
        _documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        [self loadDiaries];
    }
    return self;
}

- (void)loadDiaries {
    NSString *filePath = [self.documentsPath stringByAppendingPathComponent:@"diaries.plist"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        NSArray *diariesData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self.diaries addObjectsFromArray:diariesData];
    }
}

- (void)saveToDisk {
    NSString *filePath = [self.documentsPath stringByAppendingPathComponent:@"diaries.plist"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.diaries];
    [data writeToFile:filePath atomically:YES];
}

- (void)saveDiary:(DiaryModel *)diary {
    [self.diaries addObject:diary];
    [self saveToDisk];
}

- (void)updateDiary:(DiaryModel *)diary {
    NSInteger index = [self.diaries indexOfObject:diary];
    if (index != NSNotFound) {
        [self.diaries replaceObjectAtIndex:index withObject:diary];
        [self saveToDisk];
    }
}

- (void)deleteDiary:(DiaryModel *)diary {
    [self.diaries removeObject:diary];
    [self saveToDisk];
}

- (NSArray<DiaryModel *> *)getAllDiaries {
    return [self.diaries copy];
}

- (NSArray<DiaryModel *> *)searchDiariesWithKeyword:(NSString *)keyword {
    if (!keyword || keyword.length == 0) {
        return [self getAllDiaries];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"content CONTAINS[cd] %@", keyword];
    return [self.diaries filteredArrayUsingPredicate:predicate];
}

@end