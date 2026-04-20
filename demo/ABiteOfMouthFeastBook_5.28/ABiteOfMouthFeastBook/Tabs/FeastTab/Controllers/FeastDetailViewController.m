#import "FeastDetailViewController.h"
#import "AddFeastViewController.h"
#import "FeastDataManager.h"

@interface FeastDetailViewController ()

@property (nonatomic, strong) UIImageView *foodImageView;
@property (nonatomic, strong) UILabel *restaurantLabel;
@property (nonatomic, strong) UILabel *dishLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *peopleLabel;
@property (nonatomic, strong) UILabel *costLabel;

@end

@implementation FeastDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupUI];
    [self setupNavigationBar];
    [self updateUI];
}

- (void)setupUI {
    CGFloat padding = 20;
    CGFloat yOffset = 100;
    CGFloat width = self.view.bounds.size.width - 2 * padding;
    
    // 食物图片
    self.foodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, yOffset, width, width)];
    self.foodImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.foodImageView.clipsToBounds = YES;
    self.foodImageView.layer.cornerRadius = 10;
    [self.view addSubview:self.foodImageView];
    
    yOffset = CGRectGetMaxY(self.foodImageView.frame) + 20;
    
    // 餐厅名称
    self.restaurantLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, width, 30)];
    self.restaurantLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:self.restaurantLabel];
    
    yOffset += 40;
    
    // 菜品名称
    self.dishLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, width, 60)];
    self.dishLabel.font = [UIFont systemFontOfSize:16];
    self.dishLabel.numberOfLines = 0;
    [self.view addSubview:self.dishLabel];
    
    yOffset += 70;
    
    // 用餐日期
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, width, 25)];
    self.dateLabel.font = [UIFont systemFontOfSize:14];
    self.dateLabel.textColor = [UIColor grayColor];
    [self.view addSubview:self.dateLabel];
    
    yOffset += 30;
    
    // 用餐人数
    self.peopleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, width, 25)];
    self.peopleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.peopleLabel];
    
    yOffset += 30;
    
    // 消费金额
    self.costLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, width, 30)];
    self.costLabel.font = [UIFont boldSystemFontOfSize:20];
    self.costLabel.textColor = [UIColor systemGreenColor];
    [self.view addSubview:self.costLabel];
}

- (void)setupNavigationBar {
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
                                                                              target:self 
                                                                              action:@selector(editFeast)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)updateUI {
    self.title = self.feast.restaurantName;
    self.restaurantLabel.text = self.feast.restaurantName;
    self.dishLabel.text = self.feast.dishNames;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    self.dateLabel.text = [formatter stringFromDate:self.feast.diningDate];
    
    self.peopleLabel.text = [NSString stringWithFormat:@"Number of People: %ld", (long)self.feast.numberOfPeople];
    self.costLabel.text = [NSString stringWithFormat:@"¥%.2f", self.feast.cost];
    
    if (self.feast.foodImage) {
        self.foodImageView.image = self.feast.foodImage;
    } else {
        self.foodImageView.image = [UIImage systemImageNamed:@"photo"];
    }
}

- (void)updateFeastData {
    // 从数据管理器获取最新数据
    FeastModel *updatedFeast = [[FeastDataManager sharedManager] getFeastById:self.feast.feastId];
    if (updatedFeast) {
        self.feast = updatedFeast;
        [self updateUI];
    }
}

- (void)editFeast {
    AddFeastViewController *editVC = [[AddFeastViewController alloc] init];
    editVC.feast = self.feast;
    editVC.completionHandler = ^{
        [self updateFeastData];  // 添加更新回调
    };
    [self.navigationController pushViewController:editVC animated:YES];
}

@end
