#import <Foundation/Foundation.h>
#import "RestaurantModel.h"

@interface RestaurantDataManager : NSObject

+ (instancetype)sharedManager;
- (void)saveRestaurant:(RestaurantModel *)restaurant;
- (void)updateRestaurant:(RestaurantModel *)restaurant;
- (void)deleteRestaurant:(RestaurantModel *)restaurant;
- (NSArray<RestaurantModel *> *)getAllRestaurants;
- (NSArray<RestaurantModel *> *)getRestaurantsNearby:(CLLocationCoordinate2D)coordinate withinDistance:(CLLocationDistance)distance;

@end