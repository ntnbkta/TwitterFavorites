//
//  TWFavoritesTableViewController.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/20/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWFavoritesTableViewController.h"
#import "TWFollowingTableViewCell.h"
#import "FavoriteAccount.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TWTwinderEngine.h"
#import "TWFavoritesManager.h"

#define CELL_REUSEIDENTIFIER @"TWUserCell"
#define kTWFavoritesListUpdated @"TWFavoritesListUpdated"

@interface TWFavoritesTableViewController ()

@property (nonatomic, strong) NSMutableArray *favoritesList;
@property (nonatomic, strong) TWFavoritesManager *favoritesManager;

@end

@implementation TWFavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!_favoritesManager)
    {
        _favoritesManager = [[TWTwinderEngine sharedManager] favoritesManager];
    }
    
    if (!_favoritesList) {
        _favoritesList = [NSMutableArray new];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _favoritesList = [[_favoritesManager getFavoritesList] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favoritesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWFollowingTableViewCell *cell = (TWFollowingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_REUSEIDENTIFIER forIndexPath:indexPath];
    
    FavoriteAccount *favorite = [self.favoritesList objectAtIndex:indexPath.row];
    [cell.userName setText:[favorite userName]];
    [cell.handlerName setText:[favorite screenName]];
    [cell.userProfilePic sd_setImageWithURL:[NSURL URLWithString:[favorite profileImageURL]] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Remove From Favorites and Add them back in Friends
        FavoriteAccount *favorite = [self.favoritesList objectAtIndex:indexPath.row];
        [self.favoritesList removeObject:favorite];
        [self.favoritesManager deleteFavoriteAccount:favorite];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - IBAction Methods

- (IBAction)addMoreFavoritesToList:(id)sender
{
    
}

- (IBAction)done:(id)sender
{
    //Send notification of updated Favorites list
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTWFavoritesListUpdated object:self userInfo:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
