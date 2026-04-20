#import "RestaurantDataManager.h"

@interface RestaurantDataManager()

@property (nonatomic, strong) NSMutableArray<RestaurantModel *> *restaurants;
@property (nonatomic, copy) NSString *restaurantsFilePath;

@end

@implementation RestaurantDataManager

+ (instancetype)sharedManager {
    static RestaurantDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RestaurantDataManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths.firstObject;
        self.restaurantsFilePath = [documentsDirectory stringByAppendingPathComponent:@"restaurants.data"];
        
        [self loadRestaurants];
    }
    return self;
}

- (void)loadRestaurants {
    NSData *data = [NSData dataWithContentsOfFile:self.restaurantsFilePath];
    if (data) {
        self.restaurants = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        self.restaurants = [NSMutableArray array];
    }
}

- (void)saveRestaurantsToDisk {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.restaurants];
    [data writeToFile:self.restaurantsFilePath atomically:YES];
}

- (void)saveRestaurant:(RestaurantModel *)restaurant {
    [self.restaurants addObject:restaurant];
    [self saveRestaurantsToDisk];
}

- (void)updateRestaurant:(RestaurantModel *)restaurant {
    NSInteger index = [self.restaurants indexOfObject:restaurant];
    if (index != NSNotFound) {
        [self.restaurants replaceObjectAtIndex:index withObject:restaurant];
        [self saveRestaurantsToDisk];
    }
}

- (void)deleteRestaurant:(RestaurantModel *)restaurant {
    [self.restaurants removeObject:restaurant];
    [self saveRestaurantsToDisk];
}

- (NSArray<RestaurantModel *> *)getAllRestaurants {
    return [self.restaurants copy];
}

- (NSArray<RestaurantModel *> *)getRestaurantsNearby:(CLLocationCoordinate2D)coordinate withinDistance:(CLLocationDistance)distance {
    NSMutableArray *nearbyRestaurants = [NSMutableArray array];
    
    for (RestaurantModel *restaurant in self.restaurants) {
        CLLocation *restaurantLocation = [[CLLocation alloc] initWithLatitude:restaurant.coordinate.latitude
                                                                  longitude:restaurant.coordinate.longitude];
        CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                              longitude:coordinate.longitude];
        
        CLLocationDistance distanceInMeters = [restaurantLocation distanceFromLocation:targetLocation];
        if (distanceInMeters <= distance) {
            [nearbyRestaurants addObject:restaurant];
        }
    }
    
    return nearbyRestaurants;
}

@end