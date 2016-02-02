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

#import "TWTwinderEngine.h"

#define CELL_REUSEIDENTIFIER @"TWUserCell"
#define kTWFavoritesListUpdated @"TWFavoritesListUpdated"

@interface TWFollowingsListViewController () <UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (strong, nonatomic) UISearchController *searchController;

@property (nonatomic, strong) NSMutableArray *followingsList;
@property (nonatomic, strong) NSMutableArray *favoritesList;
@property (nonatomic, strong) TWResultsTableViewController *resultsTVController;

@property (nonatomic, strong) TWTwinderEngine *twinderEngine;
@property (nonatomic, assign) BOOL shouldStopFetchingNextPage;


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
        
    [self loadFollowingsList];
}

- (void)loadFollowingsList
{
    self.twinderEngine = [TWTwinderEngine sharedManager];
    [self fetchFollowingsOfCurrentTwitterAccount];
}

- (void)fetchFollowingsOfCurrentTwitterAccount
{
    __weak typeof(self) weakSelf = self;
    
    [[TWTwinderEngine sharedManager] fetchFollowingsOfCurrentTwitterAccountWithCompletionBlock:^(NSArray *followingsList, BOOL isFetching, NSError *error)
     {
         if (error) {
             NSLog(@"****** ERROR FETCHING FOLLOWINGS : %@",[error localizedDescription]);
             return;
         }
         
         if (isFetching)
         {
             _shouldStopFetchingNextPage = NO;
             NSLog(@"****** FriendsList Count = %ld", followingsList.count);
             self.followingsList = [followingsList mutableCopy];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf.friendsTableView setHidden:NO];
                 [weakSelf.friendsTableView reloadData];
             });
         }
         else
         {
             _shouldStopFetchingNextPage = YES;
             [[self.friendsTableView footerViewForSection:1] setHidden:YES];
         }
         
     }];

}

- (void)loadNextFriendsList
{
    __weak typeof(self) weakSelf = self;
    
    [[TWTwinderEngine sharedManager] fetchNextSetOfFollowingsOfCurrentTwitterAccountWithCompletionBlock:^(NSArray *followingsList, BOOL isFetching, NSError *error) {
        
        if (error) {
            NSLog(@"********* ERROR FETCHING NEXT SET OF FOLLOWINGS LIST ********");
            return ;
        }
        
        if (isFetching)
        {
            _shouldStopFetchingNextPage = NO;
            NSLog(@"****** FriendsList Count = %ld", followingsList.count);
            weakSelf.followingsList = [followingsList mutableCopy];
            [weakSelf.friendsTableView reloadData];
        }
        else
        {
            _shouldStopFetchingNextPage = YES;
            [[weakSelf.friendsTableView viewWithTag:123] setHidden:YES];
        }
        
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

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


#pragma mark - IBAction Methods

- (IBAction)addToFavorites:(id)sender
{
    NSArray *selectedIndexPaths =  [self.friendsTableView indexPathsForSelectedRows];

    [selectedIndexPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = (NSIndexPath *)obj;
        [self.favoritesList addObject:[self.followingsList objectAtIndex:indexPath.row]];
    }];

    [self.twinderEngine.favoritesManager addToFavorites:self.favoritesList];
    [self.followingsList removeObjectsInArray:self.favoritesList];
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

#pragma  mark - FavoritesViewController Delegate Methods

- (void)favoritesViewController:(TWFavoritesTableViewController *)favoritesVC didFinishUnfavoriting:(NSArray *)unfavoritedList
{
    //Pass this message to Twinder Engine
    [self.twinderEngine removeAccountsFromFavorites:unfavoritedList];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.followingsList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWFollowingTableViewCell *cell = (TWFollowingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_REUSEIDENTIFIER forIndexPath:indexPath];
        
    TWTwitterAccount *friend = [self.followingsList objectAtIndex:indexPath.row];
    [cell.userName setText:[friend username]];
    [cell.handlerName setText:[friend handlerName]];
    [cell.userProfilePic sd_setImageWithURL:friend.profileImageURL placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    
    if (cell.isSelected) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];

    if (indexPath.row >= self.followingsList.count-1 && !_shouldStopFetchingNextPage) {
        //Get next setOfFriends
        [self loadNextFriendsList];
    }
    
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

#pragma mark - UISearchResultsUpdating Methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:nil];
    [self.friendsTableView reloadData];
}


- (void)searchForText:(NSString *)searchString scope:(NSString *)scope
{
    //Call the Twitter Search API
    
    self.resultsTVController = (TWResultsTableViewController *)self.searchController.searchResultsController;
    [self.resultsTVController.tableView reloadData];
}
@end
