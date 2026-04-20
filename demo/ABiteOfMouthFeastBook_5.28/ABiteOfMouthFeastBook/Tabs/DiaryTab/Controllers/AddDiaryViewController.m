#import "AddDiaryViewController.h"
#import "DiaryModel.h"
#import "DiaryDataManager.h"

@interface AddDiaryViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIButton *addPhotoButton;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation AddDiaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Add food diary";
    
    [self setupNavigationBar];
    [self setupUI];
}

- (void)setupNavigationBar {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveButtonTapped)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(cancelButtonTapped)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)setupUI {
    // 设置日期选择器
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
    self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.datePicker];
    
    // 设置图片视图容器
    UIView *imageContainer = [[UIView alloc] init];
    imageContainer.backgroundColor = [UIColor systemBackgroundColor];
    imageContainer.layer.cornerRadius = 12;
    imageContainer.layer.borderWidth = 1;
    imageContainer.layer.borderColor = [UIColor systemGray4Color].CGColor;
    imageContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageContainer];
    
    // 设置图片视图
    self.photoImageView = [[UIImageView alloc] init];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoImageView.clipsToBounds = YES;
    self.photoImageView.backgroundColor = [UIColor systemGray6Color];
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:50 weight:UIImageSymbolWeightRegular];

    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.layer.cornerRadius = 8;
    self.photoImageView.tintColor = [UIColor systemGrayColor];
    self.photoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageContainer addSubview:self.photoImageView];
    
    // 设置添加图片按钮
    self.addPhotoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addPhotoButton setTitle:@"Add picture" forState:UIControlStateNormal];

    
    self.addPhotoButton.backgroundColor = [UIColor systemBlueColor];
    [self.addPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.addPhotoButton.layer.cornerRadius = 8;
    [self.addPhotoButton addTarget:self action:@selector(addPhotoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.addPhotoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [imageContainer addSubview:self.addPhotoButton];
    
    // 设置文本视图
    self.contentTextView = [[UITextView alloc] init];
    self.contentTextView.font = [UIFont systemFontOfSize:16];
    self.contentTextView.layer.cornerRadius = 8;
    self.contentTextView.layer.borderWidth = 1;
    self.contentTextView.layer.borderColor = [UIColor systemGray4Color].CGColor;
    self.contentTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.contentTextView];
    
    // 在约束部分添加按钮的大小约束
    [NSLayoutConstraint activateConstraints:@[
        [self.datePicker.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.datePicker.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.datePicker.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // 图片容器约束
        [imageContainer.topAnchor constraintEqualToAnchor:self.datePicker.bottomAnchor constant:20],
        [imageContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [imageContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [imageContainer.heightAnchor constraintEqualToConstant:240],
        
        // 图片视图约束
        [self.photoImageView.topAnchor constraintEqualToAnchor:imageContainer.topAnchor constant:15],
        [self.photoImageView.leadingAnchor constraintEqualToAnchor:imageContainer.leadingAnchor constant:15],
        [self.photoImageView.trailingAnchor constraintEqualToAnchor:imageContainer.trailingAnchor constant:-15],
        [self.photoImageView.heightAnchor constraintEqualToConstant:160],
        
        // 添加图片按钮约束
        [self.addPhotoButton.topAnchor constraintEqualToAnchor:self.photoImageView.bottomAnchor constant:15],
        [self.addPhotoButton.leadingAnchor constraintEqualToAnchor:imageContainer.leadingAnchor constant:15],
        [self.addPhotoButton.trailingAnchor constraintEqualToAnchor:imageContainer.trailingAnchor constant:-15],
        [self.addPhotoButton.heightAnchor constraintEqualToConstant:35],
        
        [self.contentTextView.topAnchor constraintEqualToAnchor:imageContainer.bottomAnchor constant:20],
        [self.contentTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.contentTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.contentTextView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20]
    ]];
}

#pragma mark - Actions

- (void)saveButtonTapped {
    if (self.contentTextView.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hint"
                                                                     message:@"Please enter diary content."
                                                              preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Confirm"
                                                style:UIAlertActionStyleDefault
                                              handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    DiaryModel *diary = [[DiaryModel alloc] init];
    diary.content = self.contentTextView.text;
    diary.photo = self.photoImageView.image;
    diary.date = self.datePicker.date;
    
    [[DiaryDataManager sharedManager] saveDiary:diary];
    
    if (self.completionHandler) {
        self.completionHandler();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addPhotoButtonTapped {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;  // 修改这里，移除(id)强制转换
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    self.photoImageView.image = selectedImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
