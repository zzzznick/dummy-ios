#import "DiaryModel.h"

@implementation DiaryModel

- (instancetype)initWithContent:(NSString *)content photo:(UIImage *)photo date:(NSDate *)date {
    self = [super init];
    if (self) {
        _content = content;
        _photo = photo;
        _date = date ?: [NSDate date];
    }
    return self;
}

- (instancetype)init {
    return [self initWithContent:nil photo:nil date:[NSDate date]];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeObject:self.photo forKey:@"photo"];
    [coder encodeObject:self.date forKey:@"date"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _content = [coder decodeObjectForKey:@"content"];
        _photo = [coder decodeObjectForKey:@"photo"];
        _date = [coder decodeObjectForKey:@"date"];
    }
    return self;
}

@end