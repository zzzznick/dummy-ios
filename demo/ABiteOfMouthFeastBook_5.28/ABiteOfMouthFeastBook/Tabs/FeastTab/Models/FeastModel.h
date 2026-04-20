#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FeastModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *feastId;
@property (nonatomic, copy) NSString *restaurantName;
@property (nonatomic, copy) NSString *dishNames;
@property (nonatomic, strong) NSDate *diningDate;
@property (nonatomic, assign) NSInteger numberOfPeople;
@property (nonatomic, assign) CGFloat cost;
@property (nonatomic, strong) UIImage *foodImage;

@end