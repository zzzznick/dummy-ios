#import <UIKit/UIKit.h>
#import "RecipeModel.h"

@interface AddRecipeViewController : UIViewController

@property (nonatomic, strong) RecipeModel *recipe;
@property (nonatomic, copy) void (^completionHandler)(void);
@property (nonatomic, assign) BOOL isEditMode;  // 添加编辑模式标记

@end