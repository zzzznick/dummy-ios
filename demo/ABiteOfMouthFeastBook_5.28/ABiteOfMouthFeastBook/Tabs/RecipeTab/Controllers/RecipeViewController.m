#import "RecipeViewController.h"
#import "RecipeTableViewCell.h"
#import "RecipeModel.h"
#import "RecipeDataManager.h"
#import "AddRecipeViewController.h"
#import "RecipeDetailViewController.h"

@interface RecipeViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView *emptyStateView;
@property (nonatomic, strong) NSMutableArray<RecipeModel *> *recipes;
@property (nonatomic, strong) NSMutableArray<RecipeModel *> *filteredRecipes;

@end

@implementation RecipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Cooking Secrets";
    [self setupUI];
    [self setupSearchBar];
    [self setupRefreshControl];
    [self setupEmptyStateView];
}

- (void)setupUI {
    // 添加按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                         target:self 
                                                                                         action:@selector(addRecipe)];
    
    // 表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[RecipeTableViewCell class] forCellReuseIdentifier:@"RecipeCell"];
    [self.view addSubview:self.tableView];
}

- (void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search dish name";
    self.tableView.tableHeaderView = self.searchBar;
}

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
}

- (void)setupEmptyStateView {
    self.emptyStateView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    UIImageView *emptyImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"book.closed"]];
    emptyImageView.contentMode = UIViewContentModeScaleAspectFit;
    emptyImageView.tintColor = [UIColor systemGrayColor];
    
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = @"No recipes have been added yet.\nClick + Add your first recipe.";
    emptyLabel.numberOfLines = 0;
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor systemGrayColor];
    
    [self.emptyStateView addSubview:emptyImageView];
    [self.emptyStateView addSubview:emptyLabel];
    
    // 设置约束
    emptyImageView.translatesAutoresizingMaskIntoConstraints = NO;
    emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [emptyImageView.centerXAnchor constraintEqualToAnchor:self.emptyStateView.centerXAnchor],
        [emptyImageView.centerYAnchor constraintEqualToAnchor:self.emptyStateView.centerYAnchor constant:-40],
        [emptyImageView.widthAnchor constraintEqualToConstant:60],
        [emptyImageView.heightAnchor constraintEqualToConstant:60],
        
        [emptyLabel.topAnchor constraintEqualToAnchor:emptyImageView.bottomAnchor constant:20],
        [emptyLabel.centerXAnchor constraintEqualToAnchor:self.emptyStateView.centerXAnchor],
        [emptyLabel.leadingAnchor constraintEqualToAnchor:self.emptyStateView.leadingAnchor constant:20],
        [emptyLabel.trailingAnchor constraintEqualToAnchor:self.emptyStateView.trailingAnchor constant:-20]
    ]];
    
    [self.view addSubview:self.emptyStateView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
}

#pragma mark - Data Management

- (void)refreshData {
    self.recipes = [[[RecipeDataManager sharedManager] getAllRecipes] mutableCopy];
    [self updateFilteredRecipes];
    [self.refreshControl endRefreshing];
}

- (void)updateFilteredRecipes {
    if (self.searchBar.text.length > 0) {
        NSString *searchText = self.searchBar.text.lowercaseString;
        self.filteredRecipes = [self.recipes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RecipeModel *recipe, NSDictionary *bindings) {
            return [recipe.name.lowercaseString containsString:searchText];
        }]].mutableCopy;
    } else {
        self.filteredRecipes = [self.recipes mutableCopy];
    }
    
    self.emptyStateView.hidden = self.filteredRecipes.count > 0;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)addRecipe {
    AddRecipeViewController *addVC = [[AddRecipeViewController alloc] init];
    addVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredRecipes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecipeCell"];
    [cell configureWithRecipe:self.filteredRecipes[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RecipeModel *recipe = self.filteredRecipes[indexPath.row];
    RecipeDetailViewController *detailVC = [[RecipeDetailViewController alloc] init];
    detailVC.recipe = recipe;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RecipeModel *recipe = self.filteredRecipes[indexPath.row];
        [[RecipeDataManager sharedManager] deleteRecipe:recipe];
        [self.recipes removeObject:recipe];
        [self.filteredRecipes removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        self.emptyStateView.hidden = self.filteredRecipes.count > 0;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateFilteredRecipes) object:nil];
    [self performSelector:@selector(updateFilteredRecipes) withObject:nil afterDelay:0.3];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end
