#import "RecipeModel.h"

@implementation RecipeModel

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.ingredients forKey:@"ingredients"];
    [coder encodeObject:self.steps forKey:@"steps"];
    [coder encodeInteger:self.cookingTime forKey:@"cookingTime"];
    [coder encodeInteger:self.difficulty forKey:@"difficulty"];
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeObject:self.tips forKey:@"tips"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.ingredients = [coder decodeObjectForKey:@"ingredients"];
        self.steps = [coder decodeObjectForKey:@"steps"];
        self.cookingTime = [coder decodeIntegerForKey:@"cookingTime"];
        self.difficulty = [coder decodeIntegerForKey:@"difficulty"];
        self.image = [coder decodeObjectForKey:@"image"];
        self.tips = [coder decodeObjectForKey:@"tips"];
    }
    return self;
}

@end