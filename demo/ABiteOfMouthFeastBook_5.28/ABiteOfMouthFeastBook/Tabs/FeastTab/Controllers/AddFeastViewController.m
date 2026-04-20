#import "AddFeastViewController.h"
#import "FeastModel.h"
#import "FeastDataManager.h"

@interface AddFeastViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextField *restaurantNameField;
@property (nonatomic, strong) UITextField *dishNamesField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *numberOfPeopleField;
@property (nonatomic, strong) UITextField *costField;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation AddFeastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.feast ? @"Edit Feast" : @"Add New Feast";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupScrollView];
    [self setupUI];
    [self setupKeyboardHandling];
    [self setupNavigationBar];
    
    if (self.feast) {
        [self setupEditMode];
    }
}

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    // 初始设置 contentView 的高度，后续会根据实际内容调整
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 800)];
    [self.scrollView addSubview:self.contentView];
}

- (void)setupNavigationBar {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveFeast)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)setupUI {
    // 创建加载指示器
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
    
    CGFloat padding = 20;
    CGFloat yOffset = 30;
    CGFloat width = self.contentView.bounds.size.width - 2 * padding;
    CGFloat fieldHeight = 44;
    
    // 创建表单容器
    UIView *formContainer = [[UIView alloc] initWithFrame:CGRectMake(padding, yOffset, width, 400)];
    formContainer.backgroundColor = [UIColor systemBackgroundColor];
    formContainer.layer.cornerRadius = 12;
    formContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    formContainer.layer.shadowOffset = CGSizeMake(0, 2);
    formContainer.layer.shadowOpacity = 0.1;
    formContainer.layer.shadowRadius = 4;
    [self.contentView addSubview:formContainer];
    
    CGFloat formPadding = 15;
    CGFloat formYOffset = formPadding;
    
    // 餐厅名称输入框
    UILabel *restaurantLabel = [[UILabel alloc] initWithFrame:CGRectMake(formPadding, formYOffset, width - 2 * formPadding, 20)];
    restaurantLabel.text = @"Restaurant Name";
    restaurantLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    restaurantLabel.textColor = [UIColor labelColor];
    [formContainer addSubview:restaurantLabel];
    
    formYOffset += 25;
    
    self.restaurantNameField = [[UITextField alloc] initWithFrame:CGRectMake(formPadding, formYOffset, width - 2 * formPadding, fieldHeight)];
    self.restaurantNameField.placeholder = @"Please enter restaurant name";
    self.restaurantNameField.borderStyle = UITextBorderStyleRoundedRect;
    self.restaurantNameField.delegate = self;
    [formContainer addSubview:self.restaurantNameField];
    
    formYOffset += fieldHeight + 20;
    
    // 菜品名称输入框
    UILabel *dishLabel = [[UILabel alloc] initWithFrame:CGRectMake(formPadding, formYOffset, width - 2 * formPadding, 20)];
    dishLabel.text = @"Ordering content";
    dishLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    dishLabel.textColor = [UIColor labelColor];
    [formContainer addSubview:dishLabel];
    
    formYOffset += 25;
    
    self.dishNamesField = [[UITextField alloc] initWithFrame:CGRectMake(formPadding, formYOffset, width - 2 * formPadding, fieldHeight)];
    self.dishNamesField.placeholder = @"Please enter ordering content.";
    self.dishNamesField.borderStyle = UITextBorderStyleRoundedRect;
    self.dishNamesField.delegate = self;
    [formContainer addSubview:self.dishNamesField];
    
    formYOffset += fieldHeight + 20;
    
    // 日期选择器
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(formPadding, formYOffset, width - 2 * formPadding, 20)];
    dateLabel.text = @"meal time";
    dateLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    dateLabel.textColor = [UIColor labelColor];
    [formContainer addSubview:dateLabel];
    
    formYOffset += 25;
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(formPadding, formYOffset, width - 2 * formPadding, 100)];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    if (@available(iOS 13.4, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
    }
    [formContainer addSubview:self.datePicker];
    
    formYOffset += 60;
    
    // 人数输入框
    UILabel *peopleLabel = [[UILabel alloc] initWithFrame:CGRectMake(formPadding, formYOffset, width - 2 * formPadding, 20)];
    peopleLabel.text = @"Number of diners";
    peopleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    peopleLabel.textColor = [UIColor labelColor];
    [formContainer addSubview:peopleLabel];
    
    formYOffset += 25;
    
    self.numberOfPeopleField = [[UITextField alloc] initWithFrame:CGRectMake(formPadding, formYOffset, width - 2 * formPadding, fieldHeight)];
    self.numberOfPeopleField.placeholder = @"Please enter the number of diners.";
    self.numberOfPeopleField.borderStyle = UITextBorderStyleRoundedRect;
    self.numberOfPeopleField.keyboardType = UIKeyboardTypeNumberPad;
    self.numberOfPeopleField.delegate = self;
    [formContainer addSubview:self.numberOfPeopleField];
    
    formYOffset += fieldHeight + 20;
    
    // 费用输入框
    UILabel *costLabel = [[UILabel alloc] initWithFrame:CGRectMake(formPadding, formYOffset, width - 2 * formPadding, 20)];
    costLabel.text = @"consumption amount";
    costLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    costLabel.textColor = [UIColor labelColor];
    [formContainer addSubview:costLabel];
    
    formYOffset += 25;
    
    self.costField = [[UITextField alloc] initWithFrame:CGRectMake(formPadding, formYOffset, width - 2 * formPadding, fieldHeight)];
    self.costField.placeholder = @"Please enter consumption amount.";
    self.costField.borderStyle = UITextBorderStyleRoundedRect;
    self.costField.keyboardType = UIKeyboardTypeDecimalPad;
    self.costField.delegate = self;
    [formContainer addSubview:self.costField];
    
    // 更新表单容器高度
    CGRect formFrame = formContainer.frame;
    formFrame.size.height = formYOffset + fieldHeight + formPadding;
    formContainer.frame = formFrame;
    
    yOffset = CGRectGetMaxY(formContainer.frame) + 30;
    
    // 图片选择区域
    UIView *imageContainer = [[UIView alloc] initWithFrame:CGRectMake(padding, yOffset, width, width + 60)];
    imageContainer.backgroundColor = [UIColor systemBackgroundColor];
    imageContainer.layer.cornerRadius = 12;
    imageContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    imageContainer.layer.shadowOffset = CGSizeMake(0, 2);
    imageContainer.layer.shadowOpacity = 0.1;
    imageContainer.layer.shadowRadius = 4;
    [self.contentView addSubview:imageContainer];
    
    UILabel *imageLabel = [[UILabel alloc] initWithFrame:CGRectMake(formPadding, 15, width - 2 * formPadding, 20)];
    imageLabel.text = @"Food photo";
    imageLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    imageLabel.textColor = [UIColor labelColor];
    [imageContainer addSubview:imageLabel];
    
    // 预览图片视图
    UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(formPadding, 50, width - 2 * formPadding, width - 2 * formPadding)];
    previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    previewImageView.backgroundColor = [UIColor systemGray6Color];
    previewImageView.layer.cornerRadius = 8;
    previewImageView.clipsToBounds = YES;
    previewImageView.tintColor = [UIColor systemGrayColor];
    [imageContainer addSubview:previewImageView];
    
    // 图片选择按钮
    self.imageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.imageButton.frame = CGRectMake(formPadding, CGRectGetMaxY(previewImageView.frame) + 10, width - 2 * formPadding, 44);
    [self.imageButton setTitle:@"Select Picture" forState:UIControlStateNormal];
    self.imageButton.backgroundColor = [UIColor systemBlueColor];
    [self.imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.imageButton.layer.cornerRadius = 8;
    [self.imageButton addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    [imageContainer addSubview:self.imageButton];
    
    // 更新 contentView 的高度和 scrollView 的 contentSize
    yOffset = CGRectGetMaxY(imageContainer.frame) + 30;
    CGRect frame = self.contentView.frame;
    frame.size.height = yOffset;
    self.contentView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, yOffset);
}

#pragma mark - Actions

- (void)selectImage {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self.activityIndicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        UIImage *compressedImage = [self compressImage:originalImage maxSize:1024 * 1024]; // 1MB
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectedImage = compressedImage;
            
            // 更新预览图片
            for (UIView *subview in self.imageButton.superview.subviews) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *previewImageView = (UIImageView *)subview;
                    previewImageView.image = compressedImage;
                    previewImageView.tintColor = [UIColor labelColor];
                    break;
                }
            }
            
            // 更新按钮状态
            [self.imageButton setTitle:@"Replace Picture" forState:UIControlStateNormal];
            [self.imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [self.activityIndicator stopAnimating];
            [picker dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (UIImage *)compressImage:(UIImage *)image maxSize:(NSInteger)maxSize {
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while (imageData.length > maxSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    if (imageData) {
        return [UIImage imageWithData:imageData];
    }
    return image;
}

- (void)saveFeast {
    [self.activityIndicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FeastModel *feast = [self validateAndCreateFeast];
        if (!feast) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
            });
            return;
        }
        
        // 保存数据
        if (self.feast) {
            [[FeastDataManager sharedManager] updateFeast:feast];
        } else {
            [[FeastDataManager sharedManager] saveFeast:feast];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler();  // 确保在保存数据后调用
            }
            [self.activityIndicator stopAnimating];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

// 移除 validateAndCreateFeast 中的 completionHandler 调用
- (FeastModel *)validateAndCreateFeast {
    // 验证输入
    if (self.restaurantNameField.text.length == 0) {
        [self showAlertWithMessage:@"Please enter restaurant name"];
        return nil;
    }
    
    if (self.dishNamesField.text.length == 0) {
        [self showAlertWithMessage:@"Please enter dish names"];
        return nil;
    }
    
    NSInteger numberOfPeople = [self.numberOfPeopleField.text integerValue];
    if (numberOfPeople <= 0) {
        [self showAlertWithMessage:@"Please enter valid number of people"];
        return nil;
    }
    
    CGFloat cost = [self.costField.text floatValue];
    if (cost <= 0) {
        [self showAlertWithMessage:@"Please enter valid cost"];
        return nil;
    }
    
    // 创建或更新 FeastModel
    FeastModel *feast = self.feast ?: [[FeastModel alloc] init];
    if (!self.feast) {
        feast.feastId = [[NSUUID UUID] UUIDString];
    }
    feast.restaurantName = self.restaurantNameField.text;
    feast.dishNames = self.dishNamesField.text;
    feast.diningDate = self.datePicker.date;
    feast.numberOfPeople = numberOfPeople;
    feast.cost = cost;
    feast.foodImage = self.selectedImage;
    
    return feast;
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setupEditMode {
    self.restaurantNameField.text = self.feast.restaurantName;
    self.dishNamesField.text = self.feast.dishNames;
    self.datePicker.date = self.feast.diningDate;
    self.numberOfPeopleField.text = [NSString stringWithFormat:@"%ld", (long)self.feast.numberOfPeople];
    self.costField.text = [NSString stringWithFormat:@"%.2f", self.feast.cost];
    self.selectedImage = self.feast.foodImage;
    if (self.selectedImage) {
        [self.imageButton setTitle:@"Replace Picture" forState:UIControlStateNormal];
        // 更新预览图片
        for (UIView *subview in self.imageButton.superview.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *previewImageView = (UIImageView *)subview;
                previewImageView.image = self.selectedImage;
                previewImageView.tintColor = [UIColor labelColor];
                break;
            }
        }
    }
}

- (void)setupKeyboardHandling {
    // 注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
    
    // 添加点击手势来关闭键盘
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(dismissKeyboard)];
    [self.scrollView addGestureRecognizer:tapGesture];
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
