#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RecipeModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *recipeId;
@property (nonatomic, copy) NSString *name;           // 菜品名称
@property (nonatomic, copy) NSString *ingredients;    // 食材
@property (nonatomic, copy) NSString *steps;         // 烹饪步骤
@property (nonatomic, assign) NSInteger cookingTime;  // 烹饪时间（分钟）
@property (nonatomic, assign) NSInteger difficulty;   // 难度等级（1-5）
@property (nonatomic, strong) UIImage *image;        // 成品图片
@property (nonatomic, copy) NSString *tips;          // 烹饪技巧

@end