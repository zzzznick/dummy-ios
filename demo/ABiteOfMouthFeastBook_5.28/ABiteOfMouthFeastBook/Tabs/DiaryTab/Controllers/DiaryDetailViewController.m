#import "DiaryDetailViewController.h"

@interface DiaryDetailViewController ()

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *dateLabel;

@end

@implementation DiaryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Details of Gourmet Diary";
    
    [self setupUI];
    [self updateUI];
}

- (void)setupUI {
    // 图片视图
    self.photoImageView = [[UIImageView alloc] init];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.clipsToBounds = YES;
    self.photoImageView.layer.cornerRadius = 10;
    self.photoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.photoImageView];
    
    // 内容标签
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:16];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.contentLabel];
    
    // 日期标签
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont systemFontOfSize:14];
    self.dateLabel.textColor = [UIColor systemGrayColor];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.dateLabel];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [self.photoImageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.photoImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.photoImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.photoImageView.heightAnchor constraintEqualToConstant:200],
        
        [self.contentLabel.topAnchor constraintEqualToAnchor:self.photoImageView.bottomAnchor constant:20],
        [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.contentLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [self.dateLabel.topAnchor constraintEqualToAnchor:self.contentLabel.bottomAnchor constant:10],
        [self.dateLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

- (void)updateUI {
    if (self.diary.photo) {
        self.photoImageView.image = self.diary.photo;
    } else {
        self.photoImageView.image = [UIImage systemImageNamed:@"photo"];
        self.photoImageView.tintColor = [UIColor systemGrayColor];
    }
    
    self.contentLabel.text = self.diary.content;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    self.dateLabel.text = [formatter stringFromDate:self.diary.date];
}

@end
