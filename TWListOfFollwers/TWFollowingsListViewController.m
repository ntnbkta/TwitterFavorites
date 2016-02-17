//
//  TWFollowingsListViewController.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/14/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWFollowingsListViewController.h"

#import "TWTwitterAccount.h"
#import "TWFollowingTableViewCell.h"
#import "TWResultsTableViewController.h"
#import "TWFavoritesTableViewController.h"
#import "TWFavoritesManager.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "MMPulseView.h"
#import "TWTwinderEngine.h"

#define CELL_REUSEIDENTIFIER @"TWUserCell"
#define kTWFavoritesListUpdated @"TWFavoritesListUpdated"

@interface TWFollowingsListViewController () <UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (strong, nonatomic) UISearchController *searchController;

@property (nonatomic, strong) NSMutableArray *followingsList;
@property (nonatomic, strong) NSMutableArray *collatedFollowings;
@property (nonatomic, strong) NSMutableArray *favoritesList;
@property (nonatomic, strong) TWResultsTableViewController *resultsTVController;

@property (nonatomic, strong) TWTwinderEngine *twinderEngine;
@property (nonatomic, assign) BOOL shouldStopFetchingNextPage;

@property (nonatomic, strong) MMPulseView *pulseView;


@end

@implementation TWFollowingsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.friendsTableView setBackgroundColor:[UIColor lightGrayColor]];
    [self.friendsTableView setHidden:YES];

    UIStoryboard *storyBoard= [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.resultsTVController =   [storyBoard instantiateViewControllerWithIdentifier:@"ResultsTableViewController"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTVController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];

    self.friendsTableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUnfavoritedList:) name:kTWFavoritesListUpdated object:nil];
    
    if(!_followingsList)
    {
        _followingsList = [NSMutableArray new];
    }
    
    if (!_favoritesList) {
        _favoritesList = [NSMutableArray new];
    }
    
    self.twinderEngine = [TWTwinderEngine sharedManager];
    self.followingsList = [[self.twinderEngine getFriendsList] mutableCopy];
    if (!self.followingsList) {
        [self fetchFollowingsOfCurrentTwitterAccount];
    }
    else
    {
        [self.friendsTableView setHidden:NO];
        [self collateFollowingListAlphabetically];
        [[self.friendsTableView viewWithTag:123] setHidden:YES];
        [self.friendsTableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    if (!self.followingsList) {
        [self setUpPulseLoadingView];
    }
    
}

- (void)fetchFollowingsOfCurrentTwitterAccount
{
    __weak typeof(self) weakSelf = self;

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.twinderEngine fetchFollowingsOfCurrentTwitterAccountWithCompletionBlock:^(NSArray *followingsList, BOOL isFetching, NSError *error)
     {
         if (error) {
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [self.pulseView stopAnimation];
             [self.pulseView removeFromSuperview];
             
             NSLog(@"****** ERROR FETCHING FOLLOWINGS : %@",[error localizedDescription]);
             return;
         }
         
         self.followingsList = [followingsList mutableCopy];
         NSLog(@"****** FriendsList Count = %ld", followingsList.count);
         if (isFetching)
         {
             _shouldStopFetchingNextPage = NO;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf loadNextFriendsList];
             });
         }
         else
         {
             _shouldStopFetchingNextPage = YES;
             [weakSelf collateFollowingListAlphabetically];
             [weakSelf.friendsTableView reloadData];
             [[self.friendsTableView footerViewForSection:1] setHidden:YES];
         }
         
     }];
}

- (void)loadNextFriendsList
{
    __weak typeof(self) weakSelf = self;
    [[TWTwinderEngine sharedManager] fetchNextSetOfFollowingsOfCurrentTwitterAccountWithCompletionBlock:^(NSArray *followingsList, BOOL isFetching, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.pulseView stopAnimation];
        [self.pulseView removeFromSuperview];
        
        if (error) {
            NSLog(@"********* ERROR FETCHING NEXT SET OF FOLLOWINGS LIST ********");
            return ;
        }
        
        weakSelf.followingsList = [followingsList mutableCopy];
        NSLog(@"****** FriendsList Count = %ld", followingsList.count);

        NSArray *sortedArray;
        sortedArray = [weakSelf.followingsList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(TWTwitterAccount *)a username];
            NSString *second = [(TWTwitterAccount *)b username];
            return [first compare:second];
        }];
        weakSelf.followingsList = [sortedArray mutableCopy];
        [weakSelf.friendsTableView setHidden:NO];

        if (isFetching)
        {
            _shouldStopFetchingNextPage = NO;
            [weakSelf loadNextFriendsList];
        }
        else
        {
            _shouldStopFetchingNextPage = YES;
            [weakSelf collateFollowingListAlphabetically];
            [weakSelf.friendsTableView reloadData];
            [[weakSelf.friendsTableView viewWithTag:123] setHidden:YES];
        }
    }];
}

- (void)collateFollowingListAlphabetically
{
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];

    if(!_collatedFollowings)
        _collatedFollowings = [NSMutableArray new];
    // (1)
    for (TWTwitterAccount *account in self.followingsList) {
        NSInteger sect = [theCollation sectionForObject:account collationStringSelector:@selector(username)];
        account.sectionNumber = sect;
    }
    // (2)
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i < highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    // (3)
    for (TWTwitterAccount *account in self.followingsList) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:account.sectionNumber] addObject:account];
    }
    // (4)
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray
                                            collationStringSelector:@selector(username)];
        [self.collatedFollowings addObject:sortedSection];
    }
    NSLog(@"********* COLLATED : %@ *********",self.collatedFollowings);
}


- (void)handleUnfavoritedList:(NSNotification *)notif
{
    NSDictionary *userInfo = [notif userInfo];
    NSArray *unfavoritedList = userInfo[@"unfavoritedList"];
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                           NSMakeRange(0,[unfavoritedList count])];
    [self.followingsList insertObjects:unfavoritedList atIndexes:indexes];

    [self.friendsTableView reloadData];
}

- (void)setUpPulseLoadingView
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    if(!_pulseView)
    {
        _pulseView = [[MMPulseView alloc] init];
        _pulseView.frame = CGRectMake(CGRectGetWidth(screenRect)/1,
                                      CGRectGetHeight(screenRect)/2*0,
                                      CGRectGetWidth(screenRect)/1,
                                      CGRectGetHeight(screenRect)/1);
        
        _pulseView.center = self.view.center;
        [self.view addSubview:_pulseView];
        
        _pulseView.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        _pulseView.colors = @[(__bridge id)[UIColor colorWithRed:0.996 green:0.647 blue:0.008 alpha:1].CGColor,(__bridge id)[UIColor colorWithRed:1 green:0.31 blue:0.349 alpha:1].CGColor,(__bridge id)[UIColor colorWithRed:41.0/255.0 green:161.0/255.0 blue:236.0/255.0 alpha:1.0].CGColor];
        
        CGFloat posY = (CGRectGetHeight(screenRect)-320)/2/CGRectGetHeight(screenRect);
        _pulseView.startPoint = CGPointMake(0.5, posY);
        _pulseView.endPoint = CGPointMake(0.5, 1.0f - posY);
        
        _pulseView.minRadius = 40;
        _pulseView.maxRadius = 150;
        
        _pulseView.duration = 4;
        _pulseView.count = 6;
        _pulseView.lineWidth = 2.0f;
    }
    [self.pulseView startAnimation];
}


#pragma mark - IBAction Methods

- (IBAction)addToFavorites:(id)sender
{
    NSArray *selectedIndexPaths =  [self.friendsTableView indexPathsForSelectedRows];

    [selectedIndexPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = (NSIndexPath *)obj;
        [self.favoritesList addObject:[[self.collatedFollowings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    }];

    [self.twinderEngine.favoritesManager addToFavorites:self.favoritesList];
    [self.followingsList removeObjectsInArray:self.favoritesList];
    [self.collatedFollowings removeAllObjects];
    [self collateFollowingListAlphabetically];
    [self.favoritesList removeAllObjects];
    
    [self.friendsTableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationTop];
}


#pragma mark - Seque Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showFavorites"])
    {
//        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
//        TWFavoritesTableViewController *favoritesViewController = (TWFavoritesTableViewController *)[navController topViewController];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.collatedFollowings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.collatedFollowings objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWFollowingTableViewCell *cell = (TWFollowingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_REUSEIDENTIFIER forIndexPath:indexPath];
        
    TWTwitterAccount *friend = [[self.collatedFollowings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell.userName setText:[friend username]];
    [cell.handlerName setText:[friend handlerName]];
    [cell.userProfilePic sd_setImageWithURL:friend.profileImageURL placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    
    if (cell.isSelected) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];

//    if (indexPath.row >= self.followingsList.count-1 && !_shouldStopFetchingNextPage) {
//        //Get next setOfFriends
//        [self loadNextFriendsList];
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    tableViewCell.accessoryView.hidden = NO;
    tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if ([[tableView indexPathsForSelectedRows] count] > 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    tableViewCell.accessoryView.hidden = YES;
    tableViewCell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([[tableView indexPathsForSelectedRows] count] == 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    
    // 2. Set a custom background color and a border
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.layer.borderColor = [UIColor whiteColor].CGColor;
    headerView.layer.borderWidth = 1.0;
    
    // 3. Add a label
    UILabel* headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5, 18);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = TW_BACKGROUND_COLOR;
    headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
    headerLabel.text = ([[self.collatedFollowings objectAtIndex:section] count] > 0)?[[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section]:nil;
    headerLabel.textAlignment = NSTextAlignmentLeft;
    
    // 4. Add the label to the header view
    [headerView addSubview:headerLabel];
    
    // 5. Finally return
    return headerView;

}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - UISearchResultsUpdating Methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:nil];
    [self.friendsTableView reloadData];
}

- (void)searchForText:(NSString *)searchString scope:(NSString *)scope
{
    
    // Search API to Twitter, we have to use the API cos we wont be having all the followings list updated because of pagination
    
    self.resultsTVController = (TWResultsTableViewController *)self.searchController.searchResultsController;

    NSPredicate *searchPredicate1 = [NSPredicate predicateWithFormat:@"username CONTAINS[cd] %@",searchString];
    NSPredicate *searchPredicate2 = [NSPredicate predicateWithFormat:@"handlerName CONTAINS[cd] %@",searchString];

    NSCompoundPredicate *searchPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[searchPredicate1,searchPredicate2]];
    NSArray *searchedArray = [self.followingsList filteredArrayUsingPredicate:searchPredicate];
    [self.resultsTVController setSearchedResults:searchedArray];
    [self.resultsTVController.tableView reloadData];
}
@end
