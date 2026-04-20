#import "AddRestaurantViewController.h"
#import <MapKit/MapKit.h>
#import "RestaurantDataManager.h"

@interface AddRestaurantViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, MKMapViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStack;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *categoryField;
@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UITextView *addressTextView;
@property (nonatomic, strong) UITextView *notesTextView;
@property (nonatomic, strong) UIStackView *ratingSelector;
@property (nonatomic, strong) UICollectionView *photosCollectionView;
@property (nonatomic, strong) NSMutableArray<UIImage *> *selectedPhotos;
@property (nonatomic, assign) float selectedRating;

@end

@implementation AddRestaurantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = self.restaurant ? @"编辑餐厅" : @"添加餐厅";
    
    self.selectedPhotos = [NSMutableArray array];
    [self setupUI];
    
    if (self.restaurant) {
        [self setupEditMode];
    } else {
        [self setupAddMode];
    }
}

- (void)setupUI {
    // 创建滚动视图和主堆栈
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    self.mainStack = [[UIStackView alloc] init];
    self.mainStack.axis = UILayoutConstraintAxisVertical;
    self.mainStack.spacing = 16;
    self.mainStack.layoutMargins = UIEdgeInsetsMake(16, 16, 16, 16);
    self.mainStack.layoutMarginsRelativeArrangement = YES;
    [self.scrollView addSubview:self.mainStack];
    
    // 设置地图
    self.mapView = [[MKMapView alloc] init];
    self.mapView.delegate = self;
    [self.mapView.heightAnchor constraintEqualToConstant:200].active = YES;
    [self.mainStack addArrangedSubview:self.mapView];
    
    // 添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.mapView addGestureRecognizer:longPress];
    
    // 基本信息输入
    self.nameField = [self createTextField:@"餐厅名称"];
    self.categoryField = [self createTextField:@"餐厅类型（如：中餐、日料等）"];
    self.phoneField = [self createTextField:@"联系电话"];
    self.phoneField.keyboardType = UIKeyboardTypePhonePad;
    
    [self.mainStack addArrangedSubview:self.nameField];
    [self.mainStack addArrangedSubview:self.categoryField];
    [self.mainStack addArrangedSubview:self.phoneField];
    
    // 地址输入
    UILabel *addressLabel = [self createLabel:@"地址"];
    [self.mainStack addArrangedSubview:addressLabel];
    
    self.addressTextView = [self createTextView:@"输入详细地址"];
    [self.mainStack addArrangedSubview:self.addressTextView];
    
    // 评分选择器
    UILabel *ratingLabel = [self createLabel:@"评分"];
    [self.mainStack addArrangedSubview:ratingLabel];
    
    [self setupRatingSelector];
    
    // 照片选择器
    UILabel *photosLabel = [self createLabel:@"照片"];
    [self.mainStack addArrangedSubview:photosLabel];
    
    [self setupPhotosCollectionView];
    
    // 备注输入
    UILabel *notesLabel = [self createLabel:@"备注"];
    [self.mainStack addArrangedSubview:notesLabel];
    
    self.notesTextView = [self createTextView:@"添加备注信息（可选）"];
    [self.mainStack addArrangedSubview:self.notesTextView];
    
    // 设置约束
    [self setupConstraints];
    
    // 添加保存按钮
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveRestaurant)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (UITextField *)createTextField:(NSString *)placeholder {
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = placeholder;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [textField.heightAnchor constraintEqualToConstant:44].active = YES;
    return textField;
}

- (UITextView *)createTextView:(NSString *)placeholder {
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:16];
    textView.text = placeholder;
    textView.textColor = [UIColor systemGrayColor];
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    textView.layer.cornerRadius = 8;
    textView.delegate = self;
    [textView.heightAnchor constraintEqualToConstant:100].active = YES;
    return textView;
}

- (UILabel *)createLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:16];
    return label;
}

- (void)setupRatingSelector {
    self.ratingSelector = [[UIStackView alloc] init];
    self.ratingSelector.axis = UILayoutConstraintAxisHorizontal;
    self.ratingSelector.spacing = 8;
    self.ratingSelector.distribution = UIStackViewDistributionFillEqually;
    [self.mainStack addArrangedSubview:self.ratingSelector];
    
    for (int i = 1; i <= 5; i++) {
        UIButton *starButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [starButton setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
        starButton.tag = i;
        [starButton addTarget:self action:@selector(ratingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.ratingSelector addArrangedSubview:starButton];
    }
}

- (void)setupPhotosCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumLineSpacing = 8;
    
    self.photosCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.photosCollectionView.backgroundColor = [UIColor systemBackgroundColor];
    self.photosCollectionView.delegate = self;
    self.photosCollectionView.dataSource = self;
   
    [self.photosCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.photosCollectionView.heightAnchor constraintEqualToConstant:120].active = YES;
    
    [self.mainStack addArrangedSubview:self.photosCollectionView];
    
    // 添加照片按钮
    UIButton *addPhotoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [addPhotoButton setTitle:@"添加照片" forState:UIControlStateNormal];
    [addPhotoButton addTarget:self action:@selector(addPhotoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.mainStack addArrangedSubview:addPhotoButton];
}

- (void)setupConstraints {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainStack.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [self.mainStack.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.mainStack.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.mainStack.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.mainStack.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.mainStack.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor]
    ]];
}

- (void)setupEditMode {
    self.nameField.text = self.restaurant.name;
    self.categoryField.text = self.restaurant.category;
    self.phoneField.text = self.restaurant.phoneNumber;
    self.addressTextView.text = self.restaurant.address;
    self.addressTextView.textColor = [UIColor labelColor];
    self.notesTextView.text = self.restaurant.notes;
    self.notesTextView.textColor = [UIColor labelColor];
    
    [self updateRatingUI:self.restaurant.rating];
    self.selectedRating = self.restaurant.rating;
    
    if (self.restaurant.photos) {
        [self.selectedPhotos addObjectsFromArray:self.restaurant.photos];
    }
    
    // 更新地图
    [self updateMapWithCoordinate:self.restaurant.coordinate];
}

- (void)setupAddMode {
    if (CLLocationCoordinate2DIsValid(self.currentLocation)) {
        [self updateMapWithCoordinate:self.currentLocation];
    }
}

- (void)updateMapWithCoordinate:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
    [self.mapView setRegion:region animated:NO];
    
    // 添加或更新标注
    [self.mapView removeAnnotations:self.mapView.annotations];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
}

#pragma mark - Actions

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    [self updateMapWithCoordinate:coordinate];
}

- (void)ratingButtonTapped:(UIButton *)sender {
    self.selectedRating = sender.tag;
    [self updateRatingUI:sender.tag];
}

- (void)updateRatingUI:(float)rating {
    for (UIButton *button in self.ratingSelector.arrangedSubviews) {
        UIImage *starImage = button.tag <= rating ? [UIImage systemImageNamed:@"star.fill"] : [UIImage systemImageNamed:@"star"];
        [button setImage:starImage forState:UIControlStateNormal];
        button.tintColor = button.tag <= rating ? [UIColor systemYellowColor] : [UIColor systemGrayColor];
    }
}

- (void)addPhotoButtonTapped {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)saveRestaurant {
    // 验证输入
    if (![self validateInput]) {
        return;
    }
    
    // 创建或更新餐厅
    RestaurantModel *restaurant = self.restaurant ?: [[RestaurantModel alloc] init];
    restaurant.name = self.nameField.text;
    restaurant.category = self.categoryField.text;
    restaurant.phoneNumber = self.phoneField.text;
    restaurant.address = self.addressTextView.text;
    restaurant.notes = self.notesTextView.text;
    restaurant.rating = self.selectedRating;
    restaurant.photos = [self.selectedPhotos copy];
    
    // 获取地图标注的坐标
    if (self.mapView.annotations.count > 0) {
        MKPointAnnotation *annotation = self.mapView.annotations.firstObject;
        restaurant.coordinate = annotation.coordinate;
    }
    
    // 保存数据
    if (self.restaurant) {
        [[RestaurantDataManager sharedManager] updateRestaurant:restaurant];
    } else {
        [[RestaurantDataManager sharedManager] saveRestaurant:restaurant];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)validateInput {
    if (self.nameField.text.length == 0) {
        [self showAlert:@"请输入餐厅名称"];
        return NO;
    }
    
    if (self.categoryField.text.length == 0) {
        [self showAlert:@"请输入餐厅类型"];
        return NO;
    }
    
    if ([self.addressTextView.text isEqualToString:@"输入详细地址"] || 
        self.addressTextView.text.length == 0) {
        [self showAlert:@"请输入餐厅地址"];
        return NO;
    }
    
    if (self.mapView.annotations.count == 0) {
        [self showAlert:@"请在地图上标记餐厅位置"];
        return NO;
    }
    
    if (self.selectedRating == 0) {
        [self showAlert:@"请选择评分"];
        return NO;
    }
    
    return YES;
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                            style:UIAlertActionStyleDefault
                                          handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    [self.selectedPhotos addObject:selectedImage];
    [self.photosCollectionView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    // 移除现有的子视图
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    // 添加图片视图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = self.selectedPhotos[indexPath.item];
    [cell.contentView addSubview:imageView];
    
    return cell;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.textColor isEqual:[UIColor systemGrayColor]]) {
        textView.text = @"";
        textView.textColor = [UIColor labelColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        if (textView == self.addressTextView) {
            textView.text = @"输入详细地址";
        } else if (textView == self.notesTextView) {
            textView.text = @"添加备注信息（可选）";
        }
        textView.textColor = [UIColor systemGrayColor];
    }
}

@end
