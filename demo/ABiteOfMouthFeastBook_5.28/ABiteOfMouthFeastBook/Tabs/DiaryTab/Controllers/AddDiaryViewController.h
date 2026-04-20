#import <UIKit/UIKit.h>

@interface AddDiaryViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy) void (^completionHandler)(void);

@end