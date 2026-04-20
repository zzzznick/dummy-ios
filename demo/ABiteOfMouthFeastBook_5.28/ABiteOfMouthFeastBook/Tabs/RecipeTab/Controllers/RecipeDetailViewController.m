#import "RecipeDetailViewController.h"
#import "AddRecipeViewController.h"
#import "RecipeDataManager.h"

@interface RecipeDetailViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIStackView *infoStackView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *cookingTimeLabel;
@property (nonatomic, strong) UIStackView *difficultyStars;
@property (nonatomic, strong) UILabel *ingredientsLabel;
@property (nonatomic, strong) UILabel *stepsLabel;
@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation RecipeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupNavigationBar];
    [self setupUI];
    [self updateUI];
}

- (void)setupNavigationBar {
    self.title = self.recipe.name;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                             target:self
                                                                             action:@selector(editRecipe)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)setupUI {
    // 滚动视图
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    // 内容容器
    UIView *contentView = [[UIView alloc] init];
    [self.scrollView addSubview:contentView];
    
    // 图片视图
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [contentView addSubview:self.imageView];
    
    // 信息栈视图
    self.infoStackView = [[UIStackView alloc] init];
    self.infoStackView.axis = UILayoutConstraintAxisVertical;
    self.infoStackView.spacing = 16;
    self.infoStackView.layoutMargins = UIEdgeInsetsMake(20, 20, 20, 20);
    self.infoStackView.layoutMarginsRelativeArrangement = YES;
    [contentView addSubview:self.infoStackView];
    
    // 名称标签
    self.nameLabel = [self createTitleLabel];
    [self.infoStackView addArrangedSubview:self.nameLabel];
    
    // 烹饪时间
    self.cookingTimeLabel = [self createDetailLabel];
    [self.infoStackView addArrangedSubview:self.cookingTimeLabel];
    
    // 难度星级
    self.difficultyStars = [[UIStackView alloc] init];
    self.difficultyStars.axis = UILayoutConstraintAxisHorizontal;
    self.difficultyStars.spacing = 4;
    [self.infoStackView addArrangedSubview:self.difficultyStars];
    
    // 食材标签
    UILabel *ingredientsTitle = [self createSectionTitleLabel:@"ingredients"];
    [self.infoStackView addArrangedSubview:ingredientsTitle];
    
    self.ingredientsLabel = [self createDetailLabel];
    [self.infoStackView addArrangedSubview:self.ingredientsLabel];
    
    // 步骤标签
    UILabel *stepsTitle = [self createSectionTitleLabel:@"Cooking steps"];
    [self.infoStackView addArrangedSubview:stepsTitle];
    
    self.stepsLabel = [self createDetailLabel];
    [self.infoStackView addArrangedSubview:self.stepsLabel];
    
    // 技巧标签
    UILabel *tipsTitle = [self createSectionTitleLabel:@"Cooking skills"];
    [self.infoStackView addArrangedSubview:tipsTitle];
    
    self.tipsLabel = [self createDetailLabel];
    [self.infoStackView addArrangedSubview:self.tipsLabel];
    
    // 设置约束
    [self setupConstraints:contentView];
}

- (UILabel *)createTitleLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:24];
    label.numberOfLines = 0;
    return label;
}

- (UILabel *)createSectionTitleLabel:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:18];
    return label;
}

- (UILabel *)createDetailLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16];
    label.numberOfLines = 0;
    return label;
}

- (void)setupConstraints:(UIView *)contentView {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // 滚动视图约束
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        // 内容视图约束
        [contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        
        // 图片视图约束
        [self.imageView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
        [self.imageView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
        [self.imageView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],
        [self.imageView.heightAnchor constraintEqualToConstant:250],
        
        // 信息栈视图约束
        [self.infoStackView.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor],
        [self.infoStackView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
        [self.infoStackView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],
        [self.infoStackView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor]
    ]];
}

- (void)updateRecipeData {
    // 从数据管理器获取最新数据
    RecipeModel *updatedRecipe = [[RecipeDataManager sharedManager] getRecipeById:self.recipe.recipeId];
    if (updatedRecipe) {
        self.recipe = updatedRecipe;
        [self updateUI];
    }
}

- (void)updateUI {
    self.title = self.recipe.name;
    
    // 更新图片
    if (self.recipe.image) {
        self.imageView.image = self.recipe.image;
    } else {
        self.imageView.image = [UIImage systemImageNamed:@"photo"];
        self.imageView.tintColor = [UIColor systemGrayColor];
    }
    
    // 更新名称
    self.nameLabel.text = self.recipe.name;
    
    // 更新烹饪时间
    self.cookingTimeLabel.text = [NSString stringWithFormat:@"Cooking time：%ldminute", (long)self.recipe.cookingTime];
    
    // 更新难度星级
    [self updateDifficultyStars];
    
    // 更新食材
    self.ingredientsLabel.text = self.recipe.ingredients;
    
    // 更新步骤
    self.stepsLabel.text = self.recipe.steps;
    
    // 更新技巧
    self.tipsLabel.text = self.recipe.tips ?: @"No special skills for the moment.";
}

- (void)updateDifficultyStars {
    // 清除现有星级
    for (UIView *view in self.difficultyStars.arrangedSubviews) {
        [view removeFromSuperview];
    }
    
    // 添加难度标签
    UILabel *difficultyLabel = [[UILabel alloc] init];
    difficultyLabel.text = @"difficulty：";
    difficultyLabel.font = [UIFont systemFontOfSize:16];
    [self.difficultyStars addArrangedSubview:difficultyLabel];
    
    // 添加星级
    for (int i = 0; i < 5; i++) {
        UIImageView *starView = [[UIImageView alloc] init];
        starView.contentMode = UIViewContentModeScaleAspectFit;
        [starView.widthAnchor constraintEqualToConstant:20].active = YES;
        [starView.heightAnchor constraintEqualToConstant:20].active = YES;
        
        if (i < self.recipe.difficulty) {
            starView.image = [UIImage systemImageNamed:@"star.fill"];
            starView.tintColor = [UIColor systemYellowColor];
        } else {
            starView.image = [UIImage systemImageNamed:@"star"];
            starView.tintColor = [UIColor systemGrayColor];
        }
        
        [self.difficultyStars addArrangedSubview:starView];
    }
}

#pragma mark - Actions

- (void)editRecipe {
    AddRecipeViewController *editVC = [[AddRecipeViewController alloc] init];
    editVC.recipe = self.recipe;
    editVC.completionHandler = ^{
        [self updateUI];  // 添加这行，编辑完成后更新UI
    };
    [self.navigationController pushViewController:editVC animated:YES];
}

@end
