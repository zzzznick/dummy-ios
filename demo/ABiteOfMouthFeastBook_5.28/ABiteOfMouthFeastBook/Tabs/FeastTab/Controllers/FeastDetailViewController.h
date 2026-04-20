#import <UIKit/UIKit.h>
#import "FeastModel.h"

@interface FeastDetailViewController : UIViewController

@property (nonatomic, strong) FeastModel *feast;
- (void)updateFeastData;

@end