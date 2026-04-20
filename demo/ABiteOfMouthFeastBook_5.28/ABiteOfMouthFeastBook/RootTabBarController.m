#import "RootTabBarController.h"
#import "HomeViewController.h"
#import "RecipeViewController.h"
#import "MapViewController.h"

@interface RootTabBarController ()

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewControllers];
    [self setupAppearance];
}

- (void)setupViewControllers {
    // 首页
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" 
                                                      image:[UIImage systemImageNamed:@"house"] 
                                              selectedImage:[UIImage systemImageNamed:@"house.fill"]];
    
    // 菜谱
    RecipeViewController *recipeVC = [[RecipeViewController alloc] init];
    UINavigationController *recipeNav = [[UINavigationController alloc] initWithRootViewController:recipeVC];
    recipeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"菜谱" 
                                                        image:[UIImage systemImageNamed:@"book"] 
                                                selectedImage:[UIImage systemImageNamed:@"book.fill"]];
    
    // 美食地图
    MapViewController *mapVC = [[MapViewController alloc] init];
    UINavigationController *mapNav = [[UINavigationController alloc] initWithRootViewController:mapVC];
    mapNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"美食地图" 
                                                     image:[UIImage systemImageNamed:@"map"] 
                                             selectedImage:[UIImage systemImageNamed:@"map.fill"]];
    
    self.viewControllers = @[homeNav, recipeNav, mapNav];
}

- (void)setupAppearance {
    // 设置标签栏外观
    self.tabBar.tintColor = [UIColor systemOrangeColor];
    
    // 设置导航栏外观
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor systemBackgroundColor];
    appearance.shadowColor = nil;
    
    [UINavigationBar appearance].standardAppearance = appearance;
    [UINavigationBar appearance].scrollEdgeAppearance = appearance;
    
    // 设置标签栏外观
    UITabBarAppearance *tabAppearance = [[UITabBarAppearance alloc] init];
    [tabAppearance configureWithOpaqueBackground];
    tabAppearance.backgroundColor = [UIColor systemBackgroundColor];
    
    self.tabBar.standardAppearance = tabAppearance;
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = tabAppearance;
    }
}

@end