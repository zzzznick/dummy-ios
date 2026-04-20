#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DiaryModel : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSDate *date;

// 初始化方法
- (instancetype)initWithContent:(NSString *)content
                         photo:(UIImage *)photo
                          date:(NSDate *)date;

// 编码和解码方法
- (void)encodeWithCoder:(NSCoder *)coder;
- (instancetype)initWithCoder:(NSCoder *)coder;

@end