#import "twoView.h"
#import "AppsFlyerLib/AppsFlyerLib.h"
#import <AdjustSdk/AdjustSdk.h>
#import <sys/utsname.h>

// UIDevice category to get the device model identifier
@interface UIDevice (ModelName)
@property (nonatomic, readonly) NSString *modelName;
- (NSString *)vkKeychainIDFV;
@end

@implementation UIDevice (ModelName)
- (NSString *)modelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString *)vkKeychainIDFV {
    // Simulated method to return the vendor identifier
    return [[UIDevice currentDevice].identifierForVendor UUIDString] ?: @"";
}
@end

@implementation twoView
static NSString *const AppShellVer = @"1.0.0";
// Initializer
- (instancetype)initWithURL:(NSString *)url  initEventType:(NSString *)eventType initAdEventList:(NSString *)eventList inAppJump:(NSString *)inAppJump {
    self = [super init];
    if (self) {
        self.eventType = eventType;
        self.adEventList = eventList;
        self.isInappJump = inAppJump;
        [self setupNavigationBar];
        [self setupWebViewWithURL:url];
    }
    return self;
}

// Setup Navigation Bar
- (void)setupNavigationBar {
    self.navigationController.navigationBar.barTintColor = [UIColor systemBlueColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

// Setup WebView
- (void)setupWebViewWithURL:(NSString *)url {
    WKWebViewConfiguration *two_config = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *two_userContent = [[WKUserContentController alloc] init];
    
    [two_userContent addScriptMessageHandler:self name:@"eventTracker"];
    [two_userContent addScriptMessageHandler:self name:@"openSafari"];
    
    two_config.userContentController = two_userContent;
    
    // 创建 WebView
    self.twoWbView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:two_config];
    self.twoWbView.navigationDelegate = self;
    self.twoWbView.UIDelegate = self;
    [self configureCustomUserAgent];
    [self.view addSubview:self.twoWbView];
    
    [self.twoWbView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
            [self.twoWbView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [self.twoWbView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
            [self.twoWbView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [self.twoWbView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
    // 加载 URL
    [self loadURL:url];
}

// Load URL into WebView
- (void)loadURL:(NSString *)url {
    NSURL *urlObject = [NSURL URLWithString:url];
    if (urlObject) {
        [self.twoWbView loadRequest:[NSURLRequest requestWithURL:urlObject]];
    } else {
        NSLog(@"Invalid URL: %@", url);
    }
}

// JavaScript Message Handler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"eventTracker"]) {
        NSDictionary *body = message.body;
        NSString *name = body[@"eventName"];
        NSString *data = body[@"eventValue"];
        
        NSLog(@"Received name: %@, data: %@  eventType:%@", name, data,self.eventType);
        if (data) {
            NSDictionary *json = [self parseJSON:data];
            if ([self.eventType isEqualToString:@"af"]) {
                
            } else if ([self.eventType isEqualToString:@"ad"]) {
                [self logWithAdjust:body];
            }
            return;
        }
    }else if ([message.name isEqualToString:@"openSafari"]){
        NSDictionary *body = message.body;
        NSString *url = body[@"url"];
        if (url.length > 0) {
            [self openURL:url];
        }
    }
}

- (void)configureCustomUserAgent {
    // Gather device information
    NSString *deviceModel = [[UIDevice currentDevice] model]; // e.g., "iPhone"
    NSString *sysVersion = [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"]; // e.g., "18_0"
    NSString *modelName = [[UIDevice currentDevice] modelName]; // e.g., "iPhone12,1"
    NSString *uuid = [[UIDevice currentDevice] vkKeychainIDFV]; // Vendor identifier
    
    // Construct custom User-Agent string
    NSString *customUserAgent = [NSString stringWithFormat:
                                @"Mozilla/5.0 (%@; CPU iPhone OS %@ like Mac OS X) AppleWebKit(KHTML, like Gecko) Mobile AppShellVer:%@ Chrome/41.0.2228.0 Safari/7534.48.3 model:%@ UUID:%@",
                                deviceModel, sysVersion, AppShellVer, modelName, uuid];
    
    // Set custom User-Agent
    self.twoWbView.customUserAgent = customUserAgent;
}

// Parse JSON Data
- (NSDictionary *)parseJSON:(NSString *)data {
    NSData *subData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:subData options:0 error:&error];
    
    if (error) {
        NSLog(@"JSON parsing error: %@", error.localizedDescription);
        return nil;
    }
    
    return json;
}

// Log Event with Adjust
- (void)logWithAdjust:(NSDictionary *)body {
    NSString *name = body[@"eventName"];
    if (!name) return;

    id eventData = body[@"eventValue"];
    if ([eventData isKindOfClass:[NSString class]]) {
        NSData *jsonData = [eventData dataUsingEncoding:NSUTF8StringEncoding];
        eventData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    }

    NSMutableDictionary *eventTokenMap = [@{
        @"test1": @"{REGISTER_EVENT_TOKEN}"
    } mutableCopy];
    
    if (self.adEventList) {
        NSData *eventListData = [self.adEventList dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:eventListData options:0 error:&error];
        if (!error) {
            [eventTokenMap addEntriesFromDictionary:json];
        }
    }

    NSString *adjustEventToken = eventTokenMap[name];

    if ([eventData objectForKey:@"af_revenue"]) {
        NSDictionary *dataDict = eventData;
        double revenue = 0;
        NSString *currency = @"";
        
        if ([dataDict isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in dataDict) {
                if ([key isEqualToString:@"currency"]) {
                    currency = dataDict[key];
                }
                if ([key isEqualToString:@"af_revenue"]) {
                    revenue = [dataDict[key] doubleValue];
                }
            }
        }

        if (adjustEventToken) {
            ADJEvent *event = [[ADJEvent alloc] initWithEventToken:adjustEventToken];
            [event setRevenue:revenue currency:currency];
            [Adjust trackEvent:event];
            NSLog(@"Reported Adjust revenue event: %@", adjustEventToken);
        }
    } else if (adjustEventToken) {
        ADJEvent *event = [[ADJEvent alloc] initWithEventToken:adjustEventToken];
        [Adjust trackEvent:event];
        NSLog(@"Reported Adjust event: %@", adjustEventToken);
    }
}

// Open URL
- (void)openURL:(NSString *)url {
    NSURL *validUrl = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:validUrl]) {
        [[UIApplication sharedApplication] openURL:validUrl options:@{} completionHandler:nil];
    } else {
        NSLog(@"无效的 URL 或无法打开 URL");
    }
}

// WebView: Open Links in External Browser
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (navigationAction.targetFrame == nil) {
        NSURL *url = navigationAction.request.URL;
        NSLog(@"拦截打开 URL  %@",navigationAction.request.URL);
        // 检查 URL 是否包含 t.me
        if ([url.host containsString:@"t.me"]) {
            // 如果包含 t.me，则外部跳转
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            return nil;  // 返回 nil 以阻止在 WebView 中加载
        }
        if ([self.isInappJump isEqualToString:@"true"]){
            [webView loadRequest:navigationAction.request];
        }else{
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    return nil;
}

// WebView: Handle Authentication Challenges
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

@end
