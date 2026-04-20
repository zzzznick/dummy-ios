#import "RecipeTableViewCell.h"

@interface RecipeTableViewCell()

@property (nonatomic, strong) UIImageView *recipeImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *cookingTimeLabel;
@property (nonatomic, strong) UIStackView *difficultyStars;

@end

@implementation RecipeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 菜品图片
    self.recipeImageView = [[UIImageView alloc] init];
    self.recipeImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.recipeImageView.clipsToBounds = YES;
    self.recipeImageView.layer.cornerRadius = 8;
    [self.contentView addSubview:self.recipeImageView];
    
    // 菜品名称
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.contentView addSubview:self.nameLabel];
    
    // 烹饪时间
    self.cookingTimeLabel = [[UILabel alloc] init];
    self.cookingTimeLabel.font = [UIFont systemFontOfSize:14];
    self.cookingTimeLabel.textColor = [UIColor systemGrayColor];
    [self.contentView addSubview:self.cookingTimeLabel];
    
    // 难度星级
    self.difficultyStars = [[UIStackView alloc] init];
    self.difficultyStars.axis = UILayoutConstraintAxisHorizontal;
    self.difficultyStars.spacing = 2;
    [self.contentView addSubview:self.difficultyStars];
    
    // 设置约束
    [self setupConstraints];
}

- (void)setupConstraints {
    self.recipeImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.cookingTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.difficultyStars.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // 图片约束
        [self.recipeImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
        [self.recipeImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.recipeImageView.widthAnchor constraintEqualToConstant:80],
        [self.recipeImageView.heightAnchor constraintEqualToConstant:80],
        
        // 名称标签约束
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.recipeImageView.trailingAnchor constant:15],
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.recipeImageView.topAnchor],
        [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
        
        // 烹饪时间标签约束
        [self.cookingTimeLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],
        [self.cookingTimeLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:8],
        
        // 难度星级约束
        [self.difficultyStars.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],
        [self.difficultyStars.bottomAnchor constraintEqualToAnchor:self.recipeImageView.bottomAnchor],
        [self.difficultyStars.heightAnchor constraintEqualToConstant:20]
    ]];
}

- (void)configureWithRecipe:(RecipeModel *)recipe {
    self.nameLabel.text = recipe.name;
    self.cookingTimeLabel.text = [NSString stringWithFormat:@"cooking time：%ldminutes", (long)recipe.cookingTime];
    
    if (recipe.image) {
        self.recipeImageView.image = recipe.image;
    } else {
        self.recipeImageView.image = [UIImage systemImageNamed:@"photo"];
    }
    
    // 清除现有星级
    for (UIView *view in self.difficultyStars.arrangedSubviews) {
        [view removeFromSuperview];
    }
    
    // 添加难度星级
    for (int i = 0; i < 5; i++) {
        UIImageView *starView = [[UIImageView alloc] init];
        starView.contentMode = UIViewContentModeScaleAspectFit;
        [starView.widthAnchor constraintEqualToConstant:15].active = YES;
        [starView.heightAnchor constraintEqualToConstant:15].active = YES;
        
        if (i < recipe.difficulty) {
            starView.image = [UIImage systemImageNamed:@"star.fill"];
            starView.tintColor = [UIColor systemYellowColor];
        } else {
            starView.image = [UIImage systemImageNamed:@"star"];
            starView.tintColor = [UIColor systemGrayColor];
        }
        
        [self.difficultyStars addArrangedSubview:starView];
    }
}

@end
