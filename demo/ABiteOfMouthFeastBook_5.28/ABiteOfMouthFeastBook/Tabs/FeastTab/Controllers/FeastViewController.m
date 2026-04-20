#import "FeastViewController.h"
#import "FeastTableViewCell.h"
#import "AddFeastViewController.h"
#import "FeastDetailViewController.h"
#import "FeastDataManager.h"

@interface FeastViewController ()

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *feastItems;
@property (nonatomic, strong) NSArray *filteredFeastItems;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView *emptyStateView;
@property (nonatomic, strong) NSMutableArray<FeastModel *> *feasts;
@property (nonatomic, strong) NSMutableArray<FeastModel *> *filteredFeasts;
@property (nonatomic, strong) UILabel *totalCostLabel;
@property (nonatomic, assign) NSInteger currentSortPreference; // 0: 日期降序, 1: 日期升序, 2: 价格降序, 3: 价格升序
@end

@implementation FeastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 加载排序偏好
    self.currentSortPreference = [[NSUserDefaults standardUserDefaults] integerForKey:@"FeastSortPreference"];
    
    [self setupUI];
    [self setupRefreshControl];
    [self setupTotalCostLabel];
    
    // 初始化数据
    self.feasts = [NSMutableArray array];
    self.filteredFeasts = [NSMutableArray array];
    
    // 应用保存的排序方式
    [self applySavedSortPreference];
    
    // 立即更新空状态视图的可见性
    [self updateEmptyStateVisibility];
}

- (void)setupUI {
    // 设置导航栏
    self.title = @"My Feast";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                         target:self 
                                                                                         action:@selector(addButtonTapped)];
    
    // 设置排序按钮
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.up.arrow.down"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(sortButtonTapped)];
    self.navigationItem.leftBarButtonItem = sortButton;
    
    // 设置表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    [self.tableView registerClass:[FeastTableViewCell class] forCellReuseIdentifier:@"FeastCell"];
    
    // 创建顶部容器视图（只包含搜索栏）
    UIView *headerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    
    // 设置搜索栏
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width - 20, 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search for restaurants or dishes";
    self.searchBar.showsCancelButton = YES;
    [headerContainer addSubview:self.searchBar];
    
    // 设置表格头部视图
    self.tableView.tableHeaderView = headerContainer;
    
    // 设置空状态视图
    [self setupEmptyStateView];
    
    // 添加视图的顺序很重要
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyStateView];
}

- (void)applySavedSortPreference {
    switch (self.currentSortPreference) {
        case 0:
            [self sortByDate:YES];
            break;
        case 1:
            [self sortByDate:NO];
            break;
        case 2:
            [self sortByCost:YES];
            break;
        case 3:
            [self sortByCost:NO];
            break;
        default:
            [self sortByDate:YES]; // 默认按日期降序
            break;
    }
}

- (void)sortByDate:(BOOL)descending {
    self.currentSortPreference = descending ? 0 : 1;
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentSortPreference forKey:@"FeastSortPreference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.feasts sortUsingComparator:^NSComparisonResult(FeastModel *obj1, FeastModel *obj2) {
        return descending ? [obj2.diningDate compare:obj1.diningDate] : 
                          [obj1.diningDate compare:obj2.diningDate];
    }];
    [self updateFilteredFeasts];
}

- (void)sortByCost:(BOOL)descending {
    self.currentSortPreference = descending ? 2 : 3;
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentSortPreference forKey:@"FeastSortPreference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.feasts sortUsingComparator:^NSComparisonResult(FeastModel *obj1, FeastModel *obj2) {
        return descending ? (obj2.cost > obj1.cost ? NSOrderedAscending : NSOrderedDescending) :
                          (obj1.cost > obj2.cost ? NSOrderedAscending : NSOrderedDescending);
    }];
    [self updateFilteredFeasts];
}

- (void)sortButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sort by"
                                                                 message:nil
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *titles = @[@"Date (Latest First)", @"Date (Oldest First)", 
                       @"Cost (Highest First)", @"Cost (Lowest First)"];
    
    // 为当前选中的排序方式添加勾选标记
    for (NSInteger i = 0; i < 4; i++) {
        NSString *title = titles[i];
        if (i == self.currentSortPreference) {
            title = [NSString stringWithFormat:@"✓ %@", title];
        }
        
        [alert addAction:[UIAlertAction actionWithTitle:title
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {
            switch (i) {
                case 0:
                case 1:
                    [self sortByDate:i == 0];
                    break;
                case 2:
                case 3:
                    [self sortByCost:i == 2];
                    break;
            }
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setupEmptyStateView {
    self.emptyStateView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.emptyStateView.backgroundColor = [UIColor systemBackgroundColor]; // 添加背景色
    
    self.emptyStateView.hidden = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"fork.knife"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tintColor = [UIColor systemGrayColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"No food records have been added yet\nClick + Add in the upper right corner";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor systemGrayColor];
    
    [self.emptyStateView addSubview:imageView];
    [self.emptyStateView addSubview:label];
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [imageView.centerXAnchor constraintEqualToAnchor:self.emptyStateView.centerXAnchor],
        [imageView.centerYAnchor constraintEqualToAnchor:self.emptyStateView.centerYAnchor constant:-50],
        [imageView.widthAnchor constraintEqualToConstant:60],
        [imageView.heightAnchor constraintEqualToConstant:60],
        
        [label.topAnchor constraintEqualToAnchor:imageView.bottomAnchor constant:20],
        [label.centerXAnchor constraintEqualToAnchor:self.emptyStateView.centerXAnchor],
        [label.leadingAnchor constraintEqualToAnchor:self.emptyStateView.leadingAnchor constant:20],
        [label.trailingAnchor constraintEqualToAnchor:self.emptyStateView.trailingAnchor constant:-20]
    ]];
}

- (void)setupTotalCostLabel {
    self.totalCostLabel = [[UILabel alloc] init];
    self.totalCostLabel.textAlignment = NSTextAlignmentCenter;
    self.totalCostLabel.font = [UIFont boldSystemFontOfSize:16];
    self.totalCostLabel.textColor = [UIColor systemGrayColor];
    [self updateTotalCost];
}

- (void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search for restaurants or dishes";
    self.searchBar.showsCancelButton = YES;
    self.navigationItem.titleView = self.searchBar;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateFilteredFeasts) object:nil];
    [self performSelector:@selector(updateFilteredFeasts) withObject:nil afterDelay:0.3];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self updateFilteredFeasts];
}

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)refreshData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *allFeasts = [[FeastDataManager sharedManager] getAllFeasts];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.feasts = [allFeasts mutableCopy];
            [self updateFilteredFeasts];
            [self updateTotalCost];
            [self.refreshControl endRefreshing];
            [self applySavedSortPreference];
        });
    });
}

- (void)updateFilteredFeasts {
    if (self.searchBar.text.length > 0) {
        NSString *searchText = self.searchBar.text.lowercaseString;
        self.filteredFeasts = [self.feasts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FeastModel *feast, NSDictionary *bindings) {
            return [feast.restaurantName.lowercaseString containsString:searchText] ||
                   [feast.dishNames.lowercaseString containsString:searchText];
        }]].mutableCopy;
    } else {
        self.filteredFeasts = [self.feasts mutableCopy];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateEmptyStateVisibility];
        [self.tableView reloadData];
    });
}

- (void)updateEmptyStateVisibility {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL shouldShowEmptyState = (self.filteredFeasts == nil || self.filteredFeasts.count == 0);
        self.emptyStateView.hidden = !shouldShowEmptyState;
        self.tableView.tableFooterView = shouldShowEmptyState ? nil : self.totalCostLabel;
    });
}

- (void)updateTotalCost {
    CGFloat totalCost = 0;
    for (FeastModel *feast in self.feasts) {
        totalCost += feast.cost;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.totalCostLabel.text = [NSString stringWithFormat:@"Total Cost: ¥%.2f", totalCost];
        self.totalCostLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
    });
}

#pragma mark - Actions

- (void)addButtonTapped {
    AddFeastViewController *addVC = [[AddFeastViewController alloc] init];
    addVC.hidesBottomBarWhenPushed = YES;
    // 添加完成后的回调
    __weak typeof(self) weakSelf = self;
    addVC.completionHandler = ^{
        [weakSelf refreshData];
    };
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredFeasts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeastCell" forIndexPath:indexPath];
    
    FeastModel *feast = self.filteredFeasts[indexPath.row];
    [cell configureCellWithFeast:feast];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FeastModel *feast = self.filteredFeasts[indexPath.row];
    FeastDetailViewController *detailVC = [[FeastDetailViewController alloc] init];
    detailVC.feast = feast;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FeastModel *feast = self.filteredFeasts[indexPath.row];
        [[FeastDataManager sharedManager] deleteFeast:feast];
        [self.feasts removeObject:feast];
        [self.filteredFeasts removeObjectAtIndex:indexPath.row];
        [self updateTotalCost];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateEmptyStateVisibility];
    }
}

// 使用自动计算高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

@end
