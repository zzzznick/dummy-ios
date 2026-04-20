#import "FeastDataManager.h"

@interface FeastDataManager()
@property (nonatomic, strong) NSMutableArray<FeastModel *> *feasts;
@end

@implementation FeastDataManager

+ (instancetype)sharedManager {
    static FeastDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FeastDataManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadFeasts];
    }
    return self;
}

- (void)loadFeasts {
    NSString *path = [self feastDataPath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        self.feasts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        self.feasts = [NSMutableArray array];
    }
}

- (void)saveFeasts {
    NSString *path = [self feastDataPath];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.feasts];
    [data writeToFile:path atomically:YES];
}

- (NSString *)feastDataPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    return [documentsDirectory stringByAppendingPathComponent:@"feasts.data"];
}

- (void)saveFeast:(FeastModel *)feast {
    [self.feasts addObject:feast];
    [self saveFeasts];
}

- (void)updateFeast:(FeastModel *)feast {
    NSInteger index = NSNotFound;
    for (NSInteger i = 0; i < self.feasts.count; i++) {
        if ([self.feasts[i].feastId isEqualToString:feast.feastId]) {
            index = i;
            break;
        }
    }
    
    if (index != NSNotFound) {
        [self.feasts replaceObjectAtIndex:index withObject:feast];
        [self saveFeasts];
    }
}

- (FeastModel *)getFeastById:(NSString *)feastId {
    for (FeastModel *feast in self.feasts) {
        if ([feast.feastId isEqualToString:feastId]) {
            return feast;
        }
    }
    return nil;
}

- (void)deleteFeast:(FeastModel *)feast {
    [self.feasts removeObject:feast];
    [self saveFeasts];
}

- (NSArray<FeastModel *> *)getAllFeasts {
    return [self.feasts copy];
}

@end
