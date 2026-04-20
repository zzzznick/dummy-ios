#import "RestaurantModel.h"

@implementation RestaurantModel

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [coder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [coder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    [coder encodeFloat:self.rating forKey:@"rating"];
    [coder encodeObject:self.notes forKey:@"notes"];
    [coder encodeObject:self.photos forKey:@"photos"];
    [coder encodeObject:self.category forKey:@"category"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.address = [coder decodeObjectForKey:@"address"];
        self.phoneNumber = [coder decodeObjectForKey:@"phoneNumber"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [coder decodeDoubleForKey:@"latitude"];
        coordinate.longitude = [coder decodeDoubleForKey:@"longitude"];
        self.coordinate = coordinate;
        self.rating = [coder decodeFloatForKey:@"rating"];
        self.notes = [coder decodeObjectForKey:@"notes"];
        self.photos = [coder decodeObjectForKey:@"photos"];
        self.category = [coder decodeObjectForKey:@"category"];
    }
    return self;
}

@end