#import <MapKit/MapKit.h>
#import "RestaurantModel.h"

@interface RestaurantAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) RestaurantModel *restaurant;

- (instancetype)initWithRestaurant:(RestaurantModel *)restaurant;

@end

@interface RestaurantAnnotationView : MKAnnotationView

@end