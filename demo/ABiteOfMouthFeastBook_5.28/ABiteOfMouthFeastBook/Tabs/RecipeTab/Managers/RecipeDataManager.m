#import "RecipeDataManager.h"

@interface RecipeDataManager()

@property (nonatomic, strong) NSMutableArray<RecipeModel *> *recipes;
@property (nonatomic, copy) NSString *recipesFilePath;

@end

@implementation RecipeDataManager

+ (instancetype)sharedManager {
    static RecipeDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RecipeDataManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths.firstObject;
        self.recipesFilePath = [documentsDirectory stringByAppendingPathComponent:@"recipes.data"];
        
        [self loadRecipes];
    }
    return self;
}

- (void)loadRecipes {
    NSData *data = [NSData dataWithContentsOfFile:self.recipesFilePath];
    if (data) {
        self.recipes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        self.recipes = [NSMutableArray array];
    }
}

- (void)saveRecipesToDisk {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.recipes];
    [data writeToFile:self.recipesFilePath atomically:YES];
}

- (void)saveRecipe:(RecipeModel *)recipe {
    [self.recipes addObject:recipe];
    [self saveRecipesToDisk];
}

- (void)updateRecipe:(RecipeModel *)recipe {
    NSInteger index = [self.recipes indexOfObject:recipe];
    if (index != NSNotFound) {
        [self.recipes replaceObjectAtIndex:index withObject:recipe];
        [self saveRecipesToDisk];
    }
}

- (void)deleteRecipe:(RecipeModel *)recipe {
    [self.recipes removeObject:recipe];
    [self saveRecipesToDisk];
}

- (NSArray<RecipeModel *> *)getAllRecipes {
    return [self.recipes copy];
}

- (RecipeModel *)getRecipeById:(NSString *)recipeId {
    for (RecipeModel *recipe in self.recipes) {
        if ([recipe.recipeId isEqualToString:recipeId]) {
            return recipe;
        }
    }
    return nil;
}

@end