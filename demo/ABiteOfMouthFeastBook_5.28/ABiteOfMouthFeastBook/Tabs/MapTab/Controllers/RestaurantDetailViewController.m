#import "RestaurantDetailViewController.h"
#import <MapKit/MapKit.h>
#import "AddRestaurantViewController.h"

@interface RestaurantDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStackView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UICollectionView *photosCollectionView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIStackView *ratingStars;
@property (nonatomic, strong) UIButton *addressButton;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UILabel *notesLabel;

@end

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupNavigationBar];
    [self setupUI];
    [self updateUI];
}

- (void)setupNavigationBar {
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                             target:self
                                                                             action:@selector(editButtonTapped)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)setupUI {
    // 创建滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    
    // 创建主堆栈视图
    self.mainStackView = [[UIStackView alloc] init];
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.spacing = 16;
    [self.scrollView addSubview:self.mainStackView];
    
    // 设置地图视图
    self.mapView = [[MKMapView alloc] init];
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    [self.mapView.heightAnchor constraintEqualToConstant:200].active = YES;
    [self.mainStackView addArrangedSubview:self.mapView];
    
    // 设置照片集合视图
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(120, 120);
    layout.minimumLineSpacing = 8;
    
    self.photosCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.photosCollectionView.backgroundColor = [UIColor systemBackgroundColor];
    self.photosCollectionView.dataSource = self;
    self.photosCollectionView.delegate = self;
    [self.photosCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.photosCollectionView.heightAnchor constraintEqualToConstant:120].active = YES;
    [self.mainStackView addArrangedSubview:self.photosCollectionView];
    
    // 创建信息容器
    UIStackView *infoStack = [[UIStackView alloc] init];
    infoStack.axis = UILayoutConstraintAxisVertical;
    infoStack.spacing = 12;
    infoStack.layoutMargins = UIEdgeInsetsMake(16, 16, 16, 16);
    infoStack.layoutMarginsRelativeArrangement = YES;
    [self.mainStackView addArrangedSubview:infoStack];
    
    // 设置餐厅名称
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:24];
    [infoStack addArrangedSubview:self.nameLabel];
    
    // 设置餐厅类型
    self.categoryLabel = [[UILabel alloc] init];
    self.categoryLabel.font = [UIFont systemFontOfSize:16];
    self.categoryLabel.textColor = [UIColor systemGrayColor];
    [infoStack addArrangedSubview:self.categoryLabel];
    
    // 设置评分星级
    self.ratingStars = [[UIStackView alloc] init];
    self.ratingStars.axis = UILayoutConstraintAxisHorizontal;
    self.ratingStars.spacing = 4;
    [infoStack addArrangedSubview:self.ratingStars];
    
    // 设置地址按钮
    self.addressButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addressButton addTarget:self action:@selector(openInMaps) forControlEvents:UIControlEventTouchUpInside];
    [infoStack addArrangedSubview:self.addressButton];
    
    // 设置电话按钮
    self.phoneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.phoneButton addTarget:self action:@selector(callRestaurant) forControlEvents:UIControlEventTouchUpInside];
    [infoStack addArrangedSubview:self.phoneButton];
    
    // 设置备注
    self.notesLabel = [[UILabel alloc] init];
    self.notesLabel.numberOfLines = 0;
    [infoStack addArrangedSubview:self.notesLabel];
    
    // 设置约束
    [self setupConstraints];
}

- (void)setupConstraints {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.mainStackView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor]
    ]];
}

- (void)updateUI {
    // 更新地图
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.restaurant.coordinate, 500, 500);
    [self.mapView setRegion:region animated:NO];
    
    // 添加标注
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.restaurant.coordinate;
    annotation.title = self.restaurant.name;
    [self.mapView addAnnotation:annotation];
    
    // 更新基本信息
    self.nameLabel.text = self.restaurant.name;
    self.categoryLabel.text = self.restaurant.category;
    [self updateRatingStars];
    
    // 更新地址按钮
    [self.addressButton setImage:[UIImage systemImageNamed:@"map"] forState:UIControlStateNormal];
    [self.addressButton setTitle:[NSString stringWithFormat:@" %@", self.restaurant.address] forState:UIControlStateNormal];
    
    // 更新电话按钮
    [self.phoneButton setImage:[UIImage systemImageNamed:@"phone"] forState:UIControlStateNormal];
    [self.phoneButton setTitle:[NSString stringWithFormat:@" %@", self.restaurant.phoneNumber] forState:UIControlStateNormal];
    
    // 更新备注
    self.notesLabel.text = self.restaurant.notes;
    
    [self.photosCollectionView reloadData];
}

- (void)updateRatingStars {
    // 清除现有星级
    for (UIView *view in self.ratingStars.arrangedSubviews) {
        [view removeFromSuperview];
    }
    
    // 添加星级
    for (int i = 0; i < 5; i++) {
        UIImageView *starView = [[UIImageView alloc] init];
        [starView.widthAnchor constraintEqualToConstant:20].active = YES;
        [starView.heightAnchor constraintEqualToConstant:20].active = YES;
        
        if (i < self.restaurant.rating) {
            starView.image = [UIImage systemImageNamed:@"star.fill"];
            starView.tintColor = [UIColor systemYellowColor];
        } else {
            starView.image = [UIImage systemImageNamed:@"star"];
            starView.tintColor = [UIColor systemGrayColor];
        }
        
        [self.ratingStars addArrangedSubview:starView];
    }
}

#pragma mark - Actions

- (void)editButtonTapped {
    AddRestaurantViewController *editVC = [[AddRestaurantViewController alloc] init];
    editVC.restaurant = self.restaurant;
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)openInMaps {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.restaurant.coordinate];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.restaurant.name;
    [mapItem openInMapsWithLaunchOptions:nil];
}

- (void)callRestaurant {
    NSString *phoneNumber = [self.restaurant.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL options:@{} completionHandler:nil];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.restaurant.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = self.restaurant.photos[indexPath.item];
    [cell.contentView addSubview:imageView];
    
    return cell;
}

@end