#import <UIKit/UIKit.h>
#import "RecipeModel.h"

@interface RecipeTableViewCell : UITableViewCell

- (void)configureWithRecipe:(RecipeModel *)recipe;

@end