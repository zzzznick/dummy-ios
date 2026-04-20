#import <UIKit/UIKit.h>
#import "FeastModel.h"

@interface AddFeastViewController : UIViewController

@property (nonatomic, copy) void (^completionHandler)(void);
@property (nonatomic, strong) FeastModel *feast;

@end