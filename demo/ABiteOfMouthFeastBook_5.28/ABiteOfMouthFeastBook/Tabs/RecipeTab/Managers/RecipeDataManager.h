#import <Foundation/Foundation.h>
#import "RecipeModel.h"

@interface RecipeDataManager : NSObject

+ (instancetype)sharedManager;
- (void)saveRecipe:(RecipeModel *)recipe;
- (void)updateRecipe:(RecipeModel *)recipe;
- (void)deleteRecipe:(RecipeModel *)recipe;
- (NSArray<RecipeModel *> *)getAllRecipes;
- (RecipeModel *)getRecipeById:(NSString *)recipeId;

@end