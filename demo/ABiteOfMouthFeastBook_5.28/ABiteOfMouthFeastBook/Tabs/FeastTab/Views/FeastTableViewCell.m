#import "FeastTableViewCell.h"

@interface FeastTableViewCell()

@property (nonatomic, strong) UIImageView *foodImageView;
@property (nonatomic, strong) UILabel *restaurantLabel;
@property (nonatomic, strong) UILabel *dishLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *costLabel;

@end

@implementation FeastTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 创建卡片容器
        UIView *cardView = [[UIView alloc] init];
        cardView.backgroundColor = [UIColor systemBackgroundColor];
        cardView.layer.cornerRadius = 12;
        cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        cardView.layer.shadowOffset = CGSizeMake(0, 2);
        cardView.layer.shadowOpacity = 0.1;
        cardView.layer.shadowRadius = 4;
        [self.contentView addSubview:cardView];
        
        // 设置卡片约束
        cardView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
            [cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
        ]];
        
        // 食物图片
        self.foodImageView = [[UIImageView alloc] init];
        self.foodImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.foodImageView.clipsToBounds = YES;
        self.foodImageView.layer.cornerRadius = 8;
        [cardView addSubview:self.foodImageView];
        
        // 设置自动布局约束
        self.foodImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.foodImageView.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:12],
            [self.foodImageView.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:12],
            [self.foodImageView.widthAnchor constraintEqualToConstant:80],
            [self.foodImageView.heightAnchor constraintEqualToConstant:80],
        ]];
        
        // 餐厅名称
        self.restaurantLabel = [[UILabel alloc] init];
        self.restaurantLabel.font = [UIFont boldSystemFontOfSize:17];
        [cardView addSubview:self.restaurantLabel];
        
        self.restaurantLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.restaurantLabel.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:12],
            [self.restaurantLabel.leadingAnchor constraintEqualToAnchor:self.foodImageView.trailingAnchor constant:12],
            [self.restaurantLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-12],
        ]];
        
        // 菜品名称
        self.dishLabel = [[UILabel alloc] init];
        self.dishLabel.font = [UIFont systemFontOfSize:14];
        self.dishLabel.textColor = [UIColor secondaryLabelColor];
        self.dishLabel.numberOfLines = 2;
        [cardView addSubview:self.dishLabel];
        
        self.dishLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.dishLabel.topAnchor constraintEqualToAnchor:self.restaurantLabel.bottomAnchor constant:4],
            [self.dishLabel.leadingAnchor constraintEqualToAnchor:self.foodImageView.trailingAnchor constant:12],
            [self.dishLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-12],
        ]];
        
        // 底部信息容器
        UIView *bottomContainer = [[UIView alloc] init];
        [cardView addSubview:bottomContainer];
        
        bottomContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [bottomContainer.topAnchor constraintEqualToAnchor:self.foodImageView.bottomAnchor constant:8],
            [bottomContainer.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:12],
            [bottomContainer.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-12],
            [bottomContainer.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-12],
            [bottomContainer.heightAnchor constraintEqualToConstant:24],
        ]];
        
        // 日期标签
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont systemFontOfSize:12];
        self.dateLabel.textColor = [UIColor tertiaryLabelColor];
        [bottomContainer addSubview:self.dateLabel];
        
        // 价格标签
        self.costLabel = [[UILabel alloc] init];
        self.costLabel.font = [UIFont boldSystemFontOfSize:15];
        self.costLabel.textColor = [UIColor systemRedColor];
        self.costLabel.textAlignment = NSTextAlignmentRight;
        [bottomContainer addSubview:self.costLabel];
        
        // 设置底部标签约束
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.costLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [NSLayoutConstraint activateConstraints:@[
            [self.dateLabel.leadingAnchor constraintEqualToAnchor:bottomContainer.leadingAnchor],
            [self.dateLabel.centerYAnchor constraintEqualToAnchor:bottomContainer.centerYAnchor],
            
            [self.costLabel.trailingAnchor constraintEqualToAnchor:bottomContainer.trailingAnchor],
            [self.costLabel.centerYAnchor constraintEqualToAnchor:bottomContainer.centerYAnchor],
        ]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat padding = 12;
    CGFloat imageSize = self.contentView.bounds.size.height - 2 * padding;
    
    // 图片布局
    self.foodImageView.frame = CGRectMake(padding, padding, imageSize, imageSize);
    
    // 文本内容布局
    CGFloat contentX = CGRectGetMaxX(self.foodImageView.frame) + padding;
    CGFloat contentWidth = self.contentView.bounds.size.width - contentX - padding;
    
    // 餐厅名称
    self.restaurantLabel.frame = CGRectMake(contentX, padding, contentWidth, 20);
    
    // 菜品名称
    self.dishLabel.frame = CGRectMake(contentX, CGRectGetMaxY(self.restaurantLabel.frame) + 4, 
                                     contentWidth, 40);
    
    // 日期标签（左下角）
    self.dateLabel.frame = CGRectMake(contentX, self.contentView.bounds.size.height - padding - 16, 
                                     contentWidth * 0.6, 16);
    
    // 价格标签（右下角）
    self.costLabel.frame = CGRectMake(contentX + contentWidth * 0.6, 
                                     self.contentView.bounds.size.height - padding - 16,
                                     contentWidth * 0.4, 16);
    self.costLabel.textAlignment = NSTextAlignmentRight;
}

- (void)configureCellWithFeast:(FeastModel *)feast {
    self.restaurantLabel.text = feast.restaurantName;
    self.dishLabel.text = feast.dishNames;
    
    // 格式化日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    self.dateLabel.text = [formatter stringFromDate:feast.diningDate];
    
    // 格式化价格
    self.costLabel.text = [NSString stringWithFormat:@"¥%.2f", feast.cost];
    
    // 设置图片
    if (feast.foodImage) {
        self.foodImageView.image = feast.foodImage;
    } else {
        self.foodImageView.image = [UIImage systemImageNamed:@"photo"];
        self.foodImageView.tintColor = [UIColor systemGrayColor];
    }
}

@end
