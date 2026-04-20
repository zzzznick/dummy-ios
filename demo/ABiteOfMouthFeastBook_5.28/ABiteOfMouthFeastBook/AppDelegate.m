//
//  AppDelegate.m
//  ABiteOfMouthFeastBook
//
//  Created by qq on 2025/2/14.
//

#import "AppDelegate.h"
#import "FirstController.h"
#import <UserNotifications/UserNotifications.h>
#import "Reachability.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@property Boolean abmfb_isFirstOpen;
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.abmfb_isFirstOpen = false;
//    [self addReachabilityManager:application didFinishLaunchingWithOptions:launchOptions];
    
    // 创建窗口并设置 LaunchViewController 为根视图控制器
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    FirstController *launchVC = [[FirstController alloc] init];
    self.window.rootViewController = launchVC;
    [self.window makeKeyAndVisible];
    
    // 创建 Reachability 实例
        self.reachability = [Reachability reachabilityForInternetConnection];
        
    // 获取当前网络状态
        NetworkStatus status = [self.reachability currentReachabilityStatus];
        
        switch (status) {
            case NotReachable:
                NSLog(@"No internet connection");
                break;
            case ReachableViaWiFi:
                NSLog(@"Connected via WiFi");
                [self getInfo_application];
                break;
            case ReachableViaWWAN:
                NSLog(@"Connected via WWAN");
                [self getInfo_application];
                break;
            default:
                break;
        }
    
        // 设置网络状态变化的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkStatusChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        // 启动通知
        [self.reachability startNotifier];
    
    return YES;
}
- (void)networkStatusChanged:(NSNotification *)notification {
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    
    switch (status) {
        case NotReachable:
            NSLog(@"网络不可用");
            break;
        case ReachableViaWiFi:
            NSLog(@"通过 Wi-Fi 连接");
            [self getInfo_application];
            break;
        case ReachableViaWWAN:
            NSLog(@"通过蜂窝网络连接");
            [self getInfo_application];
            break;
        default:
            break;
    }
}

- (void)getInfo_application {
      
    if (self.abmfb_isFirstOpen == true){
        return;
    }
    self.abmfb_isFirstOpen = true;
    //发送通知给APP首屏页面，让其有网络时重新请求
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GFEDAW" object:nil];
    
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    
    // 检查用户是否已经授予追踪权限
        if (@available(iOS 14, *)) {
            ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
            
            if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
                // 请求授权
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                    switch (status) {
                        case ATTrackingManagerAuthorizationStatusAuthorized:
                            NSLog(@"用户授权了追踪权限");
                            break;
                        case ATTrackingManagerAuthorizationStatusDenied:
                            NSLog(@"用户拒绝了追踪权限");
                            break;
                        case ATTrackingManagerAuthorizationStatusRestricted:
                            NSLog(@"追踪权限受限");
                            break;
                        case ATTrackingManagerAuthorizationStatusNotDetermined:
                            NSLog(@"用户尚未做出选择");
                            break;
                        default:
                            break;
                    }
                }];
            } else if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                // 用户已经授权
                NSLog(@"用户已经授权了追踪权限");
            } else {
                // 用户拒绝或权限受限
                NSLog(@"用户拒绝了追踪权限或权限受限");
            }
        } else {
            // 如果 iOS 版本低于 14，直接跳过
            NSLog(@"iOS 版本过低，无法请求追踪权限");
        }
    
}
@end
