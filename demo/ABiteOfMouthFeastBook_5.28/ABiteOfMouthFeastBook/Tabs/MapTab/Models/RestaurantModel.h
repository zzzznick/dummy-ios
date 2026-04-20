#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface RestaurantModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;           // 餐厅名称
@property (nonatomic, copy) NSString *address;        // 地址
@property (nonatomic, copy) NSString *phoneNumber;    // 电话
@property (nonatomic, assign) CLLocationCoordinate2D coordinate; // 坐标
@property (nonatomic, assign) float rating;           // 评分（1-5星）
@property (nonatomic, copy) NSString *notes;          // 备注
@property (nonatomic, strong) NSArray<UIImage *> *photos; // 照片集
@property (nonatomic, copy) NSString *category;       // 餐厅类型（中餐、日料等）

@end