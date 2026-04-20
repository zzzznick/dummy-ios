#import "oneView.h"
#import "AppsFlyerLib/AppsFlyerLib.h"
#import <AdjustSdk/AdjustSdk.h>

@implementation oneView

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
    WKWebViewConfiguration *abomfb_config = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *abomfb_userContent = [[WKUserContentController alloc] init];
    
    // JavaScript 注入
    NSString *abomfb_jsCode = @"window.jsBridge = { postMessage: function(name, data) { window.webkit.messageHandlers.Post.postMessage({name, data}) } };";
    WKUserScript *abomfb_code1 = [[WKUserScript alloc] initWithSource:abomfb_jsCode
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:NO];
    [abomfb_userContent addUserScript:abomfb_code1];
    [abomfb_userContent addScriptMessageHandler:self name:@"Post"];
    [abomfb_userContent addScriptMessageHandler:self name:@"event"];

    // 应用版本信息注入
    NSString *abomfb_appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *abomfb_Str1 = [NSString stringWithFormat:@"window.WgPackage = {name: '%@', version: '%@'}", [[NSBundle mainBundle] bundleIdentifier], abomfb_appVersion];
    WKUserScript *abomfb_ScrUser1 = [[WKUserScript alloc] initWithSource:abomfb_Str1
                                                       injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                    forMainFrameOnly:NO];
    [abomfb_userContent addUserScript:abomfb_ScrUser1];
    [abomfb_userContent addScriptMessageHandler:self name:@"Ball"];
    
    abomfb_config.userContentController = abomfb_userContent;
    
    // 创建 WebView
    self.lpgoewndsa2View = [[WKWebView alloc] initWithFrame:self.view.frame configuration:abomfb_config];
    self.lpgoewndsa2View.navigationDelegate = self;
    self.lpgoewndsa2View.UIDelegate = self;
    [self.view addSubview:self.lpgoewndsa2View];
    
    [self.lpgoewndsa2View setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
            [self.lpgoewndsa2View.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [self.lpgoewndsa2View.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
            [self.lpgoewndsa2View.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [self.lpgoewndsa2View.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
    // 加载 URL
    [self loadURL:url];
}

// Load URL into WebView
- (void)loadURL:(NSString *)url {
    NSURL *urlObject = [NSURL URLWithString:url];
    if (urlObject) {
        [self.lpgoewndsa2View loadRequest:[NSURLRequest requestWithURL:urlObject]];
    } else {
        NSLog(@"Invalid URL: %@", url);
    }
}

// JavaScript Message Handler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"Post"]) {
        NSDictionary *body = message.body;
        NSString *name = body[@"name"];
        NSString *data = body[@"data"];
        
        NSLog(@"Received Post message: %@, data: %@", name, data);
        if (data) {
            NSDictionary *json = [self parseJSON:data];
            if (![name isEqualToString:@"openWindow"]) {
                if ([self.eventType isEqualToString:@"af"]) {
                    [self logWithAppsFlyer:name message:json];
                } else if ([self.eventType isEqualToString:@"ad"]) {
                    [self logWithAdjust:name eventData:data];
                }
                return;
            }
            
            
            NSString *url = json[@"url"];
            if (url.length > 0) {
                [self openURL:url];
            }
        }
    }else if([message.name isEqualToString:@"event"]){
        NSString* messageBody = message.body;
        NSString* name = [messageBody componentsSeparatedByString:@"+"][0];
        NSString* data = [messageBody componentsSeparatedByString:@"+"][1];
        NSLog(@"Received event message: %@, data: %@", name, data);
        if (data) {
            NSDictionary *json = [self parseJSON:data];
            if (![name isEqualToString:@"openWindow"]) {
                if ([self.eventType isEqualToString:@"af"]) {
                    [self logWithAppsFlyer:name message:json];
                } else if ([self.eventType isEqualToString:@"ad"]) {
                    [self logWithAdjust:name eventData:data];
                }
                return;
            }
            
            
            NSString *url = json[@"url"];
            if (url.length > 0) {
                [self openURL:url];
            }
        }
    }
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



// Log Event with AppsFlyer
- (void)logWithAppsFlyer:(NSString *)name message:(NSDictionary *)message {
    if ([@[@"firstrecharge", @"recharge", @"withdrawOrderSuccess"] containsObject:name]) {
        id amount = message[@"amount"];
        id currency = message[@"currency"];
        
        if (amount && currency) {
            double revenue = [amount doubleValue];
            if ([name isEqualToString:@"withdrawOrderSuccess"]) {
                revenue = -revenue;
            }
            [[AppsFlyerLib shared]logEventWithEventName:name eventValues:@{
                AFEventParamRevenue : @(revenue),
                AFEventParamCurrency : currency
            } completionHandler:^(NSDictionary *response, NSError *error) {
                if (response) {
                    NSLog(@"AppsFlyer event logged successfully: %@", response);
                }
                if (error) {
                    NSLog(@"AppsFlyer event log error: %@", error);
                }
            }];
            
        }
    } else {
        NSLog(@"AppsFlyer event  %@", name);
        [[AppsFlyerLib shared]logEventWithEventName:name eventValues:message completionHandler:^(NSDictionary *response, NSError *error) {
            if (response) {
                NSLog(@"AppsFlyer event logged successfully: %@", response);
            }
            if (error) {
                NSLog(@"AppsFlyer event log error: %@", error);
            }
        }];
    }
}

// Log Event with Adjust
- (void)logWithAdjust:(NSString *)name eventData:(id)eventData {

    if ([eventData isKindOfClass:[NSString class]]) {
        NSData *jsonData = [eventData dataUsingEncoding:NSUTF8StringEncoding];
        eventData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    }

    NSMutableDictionary *eventTokenMap = [@{
        @"test": @"{REGISTER_EVENT_TOKEN}"
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
    
    if ([name isEqualToString:@"openWindow"]) {
        NSDictionary *dataDict = eventData;
        NSString *urlString = dataDict[@"url"];
        NSURL *url = [NSURL URLWithString:urlString];
        if (url) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    } else if ([@[@"firstrecharge", @"recharge", @"withdrawOrderSuccess"] containsObject:name]) {
        NSDictionary *dataDict = eventData;
        double revenue = 0;
        NSString *currency = @"BRL";
        
        if ([dataDict isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in dataDict) {
                if ([key isEqualToString:@"currency"]) {
                    currency = dataDict[key];
                }
                if ([key isEqualToString:@"amount"]) {
                    revenue = [dataDict[key] doubleValue];
                }
            }
        }
        
        if (adjustEventToken) {
            ADJEvent *event = [[ADJEvent alloc] initWithEventToken:adjustEventToken];
            [event setRevenue:revenue currency:currency];
            [Adjust trackEvent:event];
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
        NSLog(@"无效的 URL 或无法打开 URL  %@",navigationAction.request.URL);
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
