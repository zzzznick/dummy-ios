#import "RootTabBarController.h"
#import "FeastViewController.h"
#import "RecipeViewController.h"
#import "DiaryViewController.h"

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewControllers];

}

- (void)setupViewControllers {
    // 我的盛宴
    FeastViewController *feastVC = [[FeastViewController alloc] init];
    feastVC.title = @"My Feast";
    UINavigationController *feastNav = [[UINavigationController alloc] initWithRootViewController:feastVC];
    feastNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Feast" 
                                                       image:[UIImage systemImageNamed:@"fork.knife"] 
                                               selectedImage:[UIImage systemImageNamed:@"fork.knife.fill"]];
    
    // 烹饪秘籍
    RecipeViewController *recipeVC = [[RecipeViewController alloc] init];
    recipeVC.title = @"Recipes";
    UINavigationController *recipeNav = [[UINavigationController alloc] initWithRootViewController:recipeVC];
    recipeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Recipes" 
                                                        image:[UIImage systemImageNamed:@"book"] 
                                                selectedImage:[UIImage systemImageNamed:@"book.fill"]];
    
    // 美食日记
    DiaryViewController *diaryVC = [[DiaryViewController alloc] init];
    diaryVC.title = @"Food Diary";
    UINavigationController *diaryNav = [[UINavigationController alloc] initWithRootViewController:diaryVC];
    diaryNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Food Diary" 
                                                       image:[UIImage systemImageNamed:@"note.text"] 
                                               selectedImage:[UIImage systemImageNamed:@"note.text.badge.plus"]];
    
    self.viewControllers = @[feastNav, recipeNav, diaryNav];
}



@end
