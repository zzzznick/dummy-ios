#import <UIKit/UIKit.h>
#import "RecipeModel.h"

@interface RecipeDetailViewController : UIViewController

@property (nonatomic, strong) RecipeModel *recipe;
- (void)updateRecipeData;

@end