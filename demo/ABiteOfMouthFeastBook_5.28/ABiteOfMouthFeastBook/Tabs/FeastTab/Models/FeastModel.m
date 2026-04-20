#import "FeastModel.h"

@implementation FeastModel

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.feastId forKey:@"feastId"];
    [coder encodeObject:self.restaurantName forKey:@"restaurantName"];
    [coder encodeObject:self.dishNames forKey:@"dishNames"];
    [coder encodeObject:self.diningDate forKey:@"diningDate"];
    [coder encodeInteger:self.numberOfPeople forKey:@"numberOfPeople"];
    [coder encodeFloat:self.cost forKey:@"cost"];
    [coder encodeObject:self.foodImage forKey:@"foodImage"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.feastId = [coder decodeObjectForKey:@"feastId"];
        self.restaurantName = [coder decodeObjectForKey:@"restaurantName"];
        self.dishNames = [coder decodeObjectForKey:@"dishNames"];
        self.diningDate = [coder decodeObjectForKey:@"diningDate"];
        self.numberOfPeople = [coder decodeIntegerForKey:@"numberOfPeople"];
        self.cost = [coder decodeFloatForKey:@"cost"];
        self.foodImage = [coder decodeObjectForKey:@"foodImage"];
    }
    return self;
}

@end