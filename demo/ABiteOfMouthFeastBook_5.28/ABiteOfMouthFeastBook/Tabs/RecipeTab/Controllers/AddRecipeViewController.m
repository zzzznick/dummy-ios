#import "AddRecipeViewController.h"
#import "RecipeDataManager.h"
#import "RecipeDetailViewController.h"  // 添加这行
#import "RecipeDataManager.h"

@interface AddRecipeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *cookingTimeField;
@property (nonatomic, strong) UIStackView *difficultySelector;
@property (nonatomic, strong) UITextView *ingredientsTextView;
@property (nonatomic, strong) UITextView *stepsTextView;
@property (nonatomic, strong) UITextView *tipsTextView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, assign) NSInteger selectedDifficulty;

@end

@implementation AddRecipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 根据是否有传入的recipe判断是编辑模式还是新建模式
    self.isEditMode = (self.recipe != nil);
    self.title = self.isEditMode ? @"Edit Recipe" : @"Add Recipe";
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = self.recipe ? @"Edit recipe" : @"Add Recipe";
    
    [self setupUI];
    if (self.recipe) {
        [self setupEditMode];
    }
}

- (void)setupUI {
    // 创建滚动视图
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    UIStackView *mainStack = [[UIStackView alloc] init];
    mainStack.axis = UILayoutConstraintAxisVertical;
    mainStack.spacing = 20;
    mainStack.layoutMargins = UIEdgeInsetsMake(20, 20, 20, 20);
    mainStack.layoutMarginsRelativeArrangement = YES;
    [self.scrollView addSubview:mainStack];
    
    // 图片预览视图
    self.previewImageView = [[UIImageView alloc] init];
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.previewImageView.clipsToBounds = YES;
    self.previewImageView.backgroundColor = [UIColor systemGray6Color];
    self.previewImageView.layer.cornerRadius = 8;
//    self.previewImageView = [UIImage systemImageNamed:@"camera.fill"];
    [mainStack addArrangedSubview:self.previewImageView];
    [self.previewImageView.heightAnchor constraintEqualToConstant:200].active = YES;
    
    // 图片选择按钮
    self.imageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.imageButton setTitle:@"Select Picture" forState:UIControlStateNormal];
    self.imageButton.backgroundColor = [UIColor systemBlueColor];
    [self.imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.imageButton.layer.cornerRadius = 8;
    [self.imageButton addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    [mainStack addArrangedSubview:self.imageButton];
    [self.imageButton.heightAnchor constraintEqualToConstant:44].active = YES;
    
    // 名称输入框
    self.nameField = [self createTextField:@"Dish Name"];
    [mainStack addArrangedSubview:self.nameField];
    
    // 烹饪时间输入框
    self.cookingTimeField = [self createTextField:@"Cooking time (minutes)"];
    self.cookingTimeField.keyboardType = UIKeyboardTypeNumberPad;
    [mainStack addArrangedSubview:self.cookingTimeField];
    
    // 难度选择器
    [self setupDifficultySelector:mainStack];
    
    // 食材输入框
    UILabel *ingredientsLabel = [self createLabel:@"ingredients"];
    [mainStack addArrangedSubview:ingredientsLabel];
    
    self.ingredientsTextView = [self createTextView:@"Please enter the ingredient list, one item per line."];
    [mainStack addArrangedSubview:self.ingredientsTextView];
    
    // 步骤输入框
    UILabel *stepsLabel = [self createLabel:@"Cooking steps"];
    [mainStack addArrangedSubview:stepsLabel];
    
    self.stepsTextView = [self createTextView:@"Please enter detailed cooking steps."];
    [mainStack addArrangedSubview:self.stepsTextView];
    
    // 技巧输入框
    UILabel *tipsLabel = [self createLabel:@"Cooking skills"];
    [mainStack addArrangedSubview:tipsLabel];
    
    self.tipsTextView = [self createTextView:@"Please enter cooking tips (optional)."];
    [mainStack addArrangedSubview:self.tipsTextView];
    
    // 设置约束
    mainStack.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [mainStack.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [mainStack.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [mainStack.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [mainStack.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [mainStack.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor]
    ]];
    
    // 添加保存按钮
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                             target:self
                                                                             action:@selector(saveRecipe)];
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

- (void)setupDifficultySelector:(UIStackView *)mainStack {
    UILabel *difficultyLabel = [self createLabel:@"difficulty"];
    [mainStack addArrangedSubview:difficultyLabel];
    
    self.difficultySelector = [[UIStackView alloc] init];
    self.difficultySelector.axis = UILayoutConstraintAxisHorizontal;
    self.difficultySelector.spacing = 10;
    self.difficultySelector.distribution = UIStackViewDistributionFillEqually;
    [mainStack addArrangedSubview:self.difficultySelector];
    
    for (int i = 1; i <= 5; i++) {
        UIButton *starButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [starButton setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
        starButton.tag = i;
        [starButton addTarget:self action:@selector(difficultySelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.difficultySelector addArrangedSubview:starButton];
    }
}

- (void)setupEditMode {
    if (self.recipe.image) {
        self.previewImageView.image = self.recipe.image;
        self.selectedImage = self.recipe.image;
        [self.imageButton setTitle:@"Change picture" forState:UIControlStateNormal];
    }
    
    self.nameField.text = self.recipe.name;
    self.cookingTimeField.text = [NSString stringWithFormat:@"%ld", (long)self.recipe.cookingTime];
    self.ingredientsTextView.text = self.recipe.ingredients;
    self.ingredientsTextView.textColor = [UIColor labelColor];
    self.stepsTextView.text = self.recipe.steps;
    self.stepsTextView.textColor = [UIColor labelColor];
    self.tipsTextView.text = self.recipe.tips;
    self.tipsTextView.textColor = [UIColor labelColor];
    
    [self updateDifficultyUI:self.recipe.difficulty];
    self.selectedDifficulty = self.recipe.difficulty;
}

#pragma mark - Actions

- (void)selectImage {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)difficultySelected:(UIButton *)sender {
    self.selectedDifficulty = sender.tag;
    [self updateDifficultyUI:sender.tag];
}

- (void)updateDifficultyUI:(NSInteger)difficulty {
    for (UIButton *button in self.difficultySelector.arrangedSubviews) {
        UIImage *starImage = button.tag <= difficulty ? [UIImage systemImageNamed:@"star.fill"] : [UIImage systemImageNamed:@"star"];
        [button setImage:starImage forState:UIControlStateNormal];
        button.tintColor = button.tag <= difficulty ? [UIColor systemYellowColor] : [UIColor systemGrayColor];
    }
}

- (void)saveRecipe {
    // 验证输入
    if (![self validateInput]) {
        return;
    }
    
    // 创建或更新菜谱
    RecipeModel *recipe = self.recipe ?: [[RecipeModel alloc] init];
    recipe.name = self.nameField.text;
    recipe.cookingTime = [self.cookingTimeField.text integerValue];
    recipe.difficulty = self.selectedDifficulty;
    recipe.ingredients = self.ingredientsTextView.text;
    recipe.steps = self.stepsTextView.text;
    recipe.tips = self.tipsTextView.text;
    recipe.image = self.selectedImage;
    
    if (self.isEditMode) {
        [[RecipeDataManager sharedManager] updateRecipe:recipe];
        if ([self.navigationController.viewControllers.lastObject isKindOfClass:[RecipeDetailViewController class]]) {
            RecipeDetailViewController *detailVC = (RecipeDetailViewController *)self.navigationController.viewControllers.lastObject;
            [detailVC updateRecipeData];
        }
    } else {
        [[RecipeDataManager sharedManager] saveRecipe:recipe];  // 使用 saveRecipe: 而不是 addRecipe:
    }
    
    if (self.completionHandler) {
        self.completionHandler();  // 确保这行代码被执行
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)validateInput {
    if (self.nameField.text.length == 0) {
        [self showAlert:@"Please enter the dish name."];
        return NO;
    }
    
    if (self.cookingTimeField.text.length == 0 || [self.cookingTimeField.text integerValue] <= 0) {
        [self showAlert:@"Please enter a valid cooking time."];
        return NO;
    }
    
    if (self.selectedDifficulty == 0) {
        [self showAlert:@"Please select the difficulty level."];
        return NO;
    }
    
    if ([self.ingredientsTextView.text isEqualToString:@"Please enter the ingredient list, one item per line."] ||
        self.ingredientsTextView.text.length == 0) {
        [self showAlert:@"Please enter the ingredient list."];
        return NO;
    }
    
    if ([self.stepsTextView.text isEqualToString:@"Please enter detailed cooking steps."] ||
        self.stepsTextView.text.length == 0) {
        [self showAlert:@"Please enter cooking steps."];
        return NO;
    }
    
    return YES;
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tip"
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Determine"
                                            style:UIAlertActionStyleDefault
                                          handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    self.selectedImage = selectedImage;
    self.previewImageView.image = selectedImage;
    [self.imageButton setTitle:@"Change picture" forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
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
        if (textView == self.ingredientsTextView) {
            textView.text = @"Please enter the ingredient list, one item per line.";
        } else if (textView == self.stepsTextView) {
            textView.text = @"Please enter detailed cooking steps.";
        } else if (textView == self.tipsTextView) {
            textView.text = @"Please enter cooking tips (optional).";
        }
        textView.textColor = [UIColor systemGrayColor];
    }
}

@end
