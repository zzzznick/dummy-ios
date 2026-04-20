#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RestaurantModel.h"

@interface AddRestaurantViewController : UIViewController

@property (nonatomic, strong) RestaurantModel *restaurant;  // 编辑模式时使用
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;  // 添加模式时使用当前位置

@end