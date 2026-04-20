// ... 其他代码保持不变 ...

- (void)setupViewControllers {
    // 第一个标签页
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage systemImageNamed:@"house"] selectedImage:[UIImage systemImageNamed:@"house.fill"]];
    
    // 第二个标签页
    RecipeViewController *recipeVC = [[RecipeViewController alloc] init];
    UINavigationController *recipeNav = [[UINavigationController alloc] initWithRootViewController:recipeVC];
    recipeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"菜谱" image:[UIImage systemImageNamed:@"book"] selectedImage:[UIImage systemImageNamed:@"book.fill"]];
    
    // 第三个标签页
    MapViewController *mapVC = [[MapViewController alloc] init];
    UINavigationController *mapNav = [[UINavigationController alloc] initWithRootViewController:mapVC];
    mapNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"美食地图" image:[UIImage systemImageNamed:@"map"] selectedImage:[UIImage systemImageNamed:@"map.fill"]];
    
    self.viewControllers = @[homeNav, recipeNav, mapNav];
}

// ... 其他代码保持不变 ...