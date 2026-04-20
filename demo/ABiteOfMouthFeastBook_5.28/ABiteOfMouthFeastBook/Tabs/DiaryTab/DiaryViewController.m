#import "DiaryViewController.h"
#import "AddDiaryViewController.h"
#import "DiaryModel.h"
#import "DiaryDataManager.h"
                                          #import "DiaryDetailViewController.h"

@interface DiaryViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView *emptyStateView;
@property (nonatomic, strong) NSArray<DiaryModel *> *diaries;
@property (nonatomic, strong) NSArray<DiaryModel *> *filteredDiaries;



@end

@implementation DiaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Food Diary";
    
    [self setupUI];
    [self setupSearchBar];
    [self setupRefreshControl];
    [self setupEmptyStateView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDiaries];
}

- (void)loadDiaries {
    self.diaries = [[DiaryDataManager sharedManager] getAllDiaries];
    self.filteredDiaries = [self.diaries copy];
    [self.tableView reloadData];
    self.emptyStateView.hidden = self.diaries.count > 0;
}

- (void)refreshData {
    [self loadDiaries];
    [self.refreshControl endRefreshing];
}


- (void)addDiary {
    AddDiaryViewController *addVC = [[AddDiaryViewController alloc] init];
    addVC.completionHandler = ^{
        [self loadDiaries];
    };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addVC];
    addVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)setupUI {
    // 添加新建日记按钮
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                            target:self
                                                                            action:@selector(addDiary)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // 设置表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 100;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DiaryModel *diary = self.filteredDiaries[indexPath.row];
        [[DiaryDataManager sharedManager] deleteDiary:diary];
        
        NSMutableArray *tempDiaries = [self.diaries mutableCopy];
        [tempDiaries removeObject:diary];
        self.diaries = [tempDiaries copy];
        
        NSMutableArray *tempFilteredDiaries = [self.filteredDiaries mutableCopy];
        [tempFilteredDiaries removeObjectAtIndex:indexPath.row];
        self.filteredDiaries = [tempFilteredDiaries copy];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        self.emptyStateView.hidden = self.filteredDiaries.count > 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DiaryModel *diary = self.filteredDiaries[indexPath.row];
    DiaryDetailViewController *detailVC = [[DiaryDetailViewController alloc] init];
    detailVC.diary = diary;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredDiaries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DiaryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        // 设置圆角和阴影
        cell.contentView.layer.cornerRadius = 10;
        cell.contentView.layer.masksToBounds = YES;
        
        cell.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.layer.shadowOffset = CGSizeMake(0, 2);
        cell.layer.shadowRadius = 4;
        cell.layer.shadowOpacity = 0.1;
        cell.layer.masksToBounds = NO;
        
        // 设置背景色
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor systemBackgroundColor];
        bgView.layer.cornerRadius = 10;
        bgView.layer.masksToBounds = YES;
        [cell.contentView addSubview:bgView];
        bgView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [bgView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:8],
            [bgView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
            [bgView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
            [bgView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-8]
        ]];
    }
    
    DiaryModel *diary = self.filteredDiaries[indexPath.row];
    
    // 限制内容文本长度
    NSString *content = diary.content;
    if (content.length > 50) {
        content = [[content substringToIndex:47] stringByAppendingString:@"..."];
    }
    cell.textLabel.text = content;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    
    // 优化日期显示格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM.dd HH:mm";
    cell.detailTextLabel.text = [formatter stringFromDate:diary.date];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor systemGrayColor];
    
    // 优化图片显示
    if (diary.photo) {
        cell.imageView.image = diary.photo;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.clipsToBounds = YES;
        
        // 设置图片大小和圆角
        cell.imageView.frame = CGRectMake(16, 8, 84, 84);
        cell.imageView.layer.cornerRadius = 8;
        
        // 调整文本标签位置
        cell.textLabel.frame = CGRectMake(116, 12, cell.contentView.bounds.size.width - 132, 40);
        cell.detailTextLabel.frame = CGRectMake(116, 52, cell.contentView.bounds.size.width - 132, 20);
    } else {
        cell.imageView.image = [UIImage systemImageNamed:@"photo"];
        cell.imageView.tintColor = [UIColor systemGrayColor];
    }
    
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        self.filteredDiaries = [[DiaryDataManager sharedManager] searchDiariesWithKeyword:searchText];
    } else {
        self.filteredDiaries = [self.diaries copy];
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    self.filteredDiaries = [self.diaries copy];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search for food diaries";
    self.searchBar.showsCancelButton = YES;
    self.tableView.tableHeaderView = self.searchBar;
}

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
}

- (void)setupEmptyStateView {
    self.emptyStateView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UIImageView *emptyImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"doc.text.image"]];
    emptyImageView.tintColor = [UIColor systemGrayColor];
    emptyImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.emptyStateView addSubview:emptyImageView];
    
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = @"There are no food diaries yet.\nClick to add in the upper right corner.";
    emptyLabel.numberOfLines = 0;
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor systemGrayColor];
    emptyLabel.font = [UIFont systemFontOfSize:16];
    [self.emptyStateView addSubview:emptyLabel];
    
    // 设置约束
    emptyImageView.translatesAutoresizingMaskIntoConstraints = NO;
    emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [emptyImageView.centerXAnchor constraintEqualToAnchor:self.emptyStateView.centerXAnchor],
        [emptyImageView.centerYAnchor constraintEqualToAnchor:self.emptyStateView.centerYAnchor constant:-50],
        [emptyImageView.widthAnchor constraintEqualToConstant:100],
        [emptyImageView.heightAnchor constraintEqualToConstant:100],
        
        [emptyLabel.topAnchor constraintEqualToAnchor:emptyImageView.bottomAnchor constant:20],
        [emptyLabel.centerXAnchor constraintEqualToAnchor:self.emptyStateView.centerXAnchor],
        [emptyLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.emptyStateView.leadingAnchor constant:20],
        [emptyLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.emptyStateView.trailingAnchor constant:-20]
    ]];
    
    self.tableView.backgroundView = self.emptyStateView;
    self.emptyStateView.hidden = YES;
}

@end
