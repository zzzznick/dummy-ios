

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface oneView : UIViewController <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *lpgoewndsa2View;
@property (nonatomic, copy) NSString *adEventList;
@property (nonatomic, copy) NSString *eventType;
@property (nonatomic, copy) NSString *isInappJump;

- (instancetype)initWithURL:(NSString *)url  initEventType:(NSString *)eventType initAdEventList:(NSString *)eventList inAppJump:(NSString *)inAppJump;
@end
