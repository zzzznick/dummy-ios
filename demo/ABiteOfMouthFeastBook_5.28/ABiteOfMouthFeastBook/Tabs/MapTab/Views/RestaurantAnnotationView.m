#import "RestaurantAnnotationView.h"

@implementation RestaurantAnnotation

- (instancetype)initWithRestaurant:(RestaurantModel *)restaurant {
    self = [super init];
    if (self) {
        self.restaurant = restaurant;
        self.coordinate = restaurant.coordinate;
        self.title = restaurant.name;
        self.subtitle = restaurant.category;
    }
    return self;
}

@end

@implementation RestaurantAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.canShowCallout = YES;
        self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        UIImage *pinImage = [UIImage systemImageNamed:@"fork.knife.circle.fill"];
        self.image = pinImage;
    }
    return self;
}

@end