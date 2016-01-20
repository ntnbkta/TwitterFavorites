//
//  ViewController.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/14/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "TWUserAccount.h"
#import "TWAccountManager.h"
#import "TableViewCell.h"
#import "TWResultsTableViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#define CELL_REUSEIDENTIFIER @"TWUserCell"
@interface ViewController () <UISearchResultsUpdating>
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (strong, nonatomic) UISearchController *searchController;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *twitterAccount;


@property (nonatomic, strong) NSMutableArray *followingsList;
@property (nonatomic, strong) NSArray *searchedList;
@property (nonatomic, strong) NSMutableArray *favoritesList;
@property (nonatomic, assign) BOOL shouldStopFetchingNextPage;
@property (nonatomic, strong) TWAccountManager *accountManager;
@property (nonatomic, strong) TWResultsTableViewController *resultsTVController;


@end

@implementation ViewController

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

    if(!_followingsList)
    {
        _followingsList = [NSMutableArray new];
    }
    
    if (!_favoritesList) {
        _favoritesList = [NSMutableArray new];
    }
    [self setUpAccountStore];
    [self requestAccessforTwitterAccount];
    
}

- (void)setUpAccountStore
{
    if(!_accountStore)
    {
        _accountStore = [ACAccountStore new];
    }
}

- (void)requestAccessforTwitterAccount
{
    ACAccountType *twitterAccountType = [self getAccountTypeFor:@"Twitter"];
    
    __weak typeof(self) weakSelf = self;
    if(twitterAccountType)
    {
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:nil
                                                completion:^(BOOL granted, NSError *error) {
                                                    if (granted) {
                                                        //Fetch Account information
                                                        weakSelf.twitterAccount = [weakSelf fetchAccountInformationForAccountType:twitterAccountType];
                                                        [weakSelf fetchFreiendsOfSourceTwitterAccount];
                                                    }
                                                    else
                                                    {
                                                        NSLog(@"******** ERROR : %@ **********",[error localizedDescription]);
                                                    }
                                                }];
    }

}
- (ACAccountType *)getAccountTypeFor:(NSString *)socialNetwork
{
    ACAccountType *accountType; //Default implementation
    if([socialNetwork isEqualToString:@"Twitter"])
    {
        accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    }
    return accountType;
}


- (ACAccount *)fetchAccountInformationForAccountType:(ACAccountType *)accountType
{
    ACAccount *account;
    NSArray *accountsArray = [self.accountStore accountsWithAccountType:accountType];

    if([accountsArray count])
    {
        account = [accountsArray objectAtIndex:0];
    }
    
    return account;
}


- (void)fetchFreiendsOfSourceTwitterAccount
{
    if (!_accountManager) {
        self.accountManager = [[TWAccountManager alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [weakSelf.accountManager getFriendsOf:self.twitterAccount onCompletion:^(NSArray *friendsList,BOOL isFetching) {

            if (isFetching) {
                _shouldStopFetchingNextPage = NO;
                NSLog(@"****** FriendsList Count = %ld", friendsList.count);
                self.followingsList = [friendsList mutableCopy];
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
            
        } error:^(NSError *error) {
            
            NSLog(@"Error : %@", [error localizedDescription]);
        }];
        
    });
}


- (void)loadNextFriendsList
{
    //Get the next cursor id and fetch the followings list from that ID.
    [self.accountManager getNextPageFriendsListWithCompletion:^(NSArray *friendsList, BOOL isFetching) {

        if (isFetching) {
            _shouldStopFetchingNextPage = NO;
            NSLog(@"****** FriendsList Count = %ld", friendsList.count);
            [self.friendsTableView reloadData];
        }
        else
        {
            _shouldStopFetchingNextPage = YES;
            [[self.friendsTableView viewWithTag:123] setHidden:YES];
        }

    } error:^(NSError *error) {
        NSLog(@"****** Next Page MediaList error = %@", [error localizedDescription]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addToFavorites:(id)sender
{
    NSArray *selectedIndexPaths =  [self.friendsTableView indexPathsForSelectedRows];

    [selectedIndexPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = (NSIndexPath *)obj;
        [self.favoritesList addObject:[self.followingsList objectAtIndex:indexPath.row]];
    }];
    NSLog(@"******* FAVORITES LIST : %@",self.favoritesList);

}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.followingsList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_REUSEIDENTIFIER forIndexPath:indexPath];
    
    TWUserAccount *friend = [self.followingsList objectAtIndex:indexPath.row];
    [cell.userName setText:[friend username]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    tableViewCell.accessoryView.hidden = NO;
    tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    tableViewCell.accessoryView.hidden = YES;
    tableViewCell.accessoryType = UITableViewCellAccessoryNone;
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
