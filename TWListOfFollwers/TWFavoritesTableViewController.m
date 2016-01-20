//
//  TWFavoritesTableViewController.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/20/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWFavoritesTableViewController.h"
#import "TableViewCell.h"
#import "TWUserAccount.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "TWFavoritesManager.h"

#define CELL_REUSEIDENTIFIER @"TWUserCell"

@interface TWFavoritesTableViewController ()

@property (nonatomic, strong) TWFavoritesManager *favoritesManager;
@property (nonatomic, strong) NSMutableArray *favoritesList;

@end

@implementation TWFavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_favoritesList) {
        _favoritesList = [NSMutableArray new];
    }
    
    self.favoritesManager = [TWFavoritesManager sharedManager];
    self.favoritesList = [[self.favoritesManager getFavoritesList] mutableCopy];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self.favoritesManager saveChanges];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favoritesList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_REUSEIDENTIFIER forIndexPath:indexPath];
    
    TWUserAccount *friend = [self.favoritesList objectAtIndex:indexPath.row];
    [cell.userName setText:[friend username]];
    [cell.handlerName setText:[friend handlerName]];
    [cell.userProfilePic sd_setImageWithURL:friend.profileImageURL placeholderImage:[UIImage imageNamed:@"placeholderImage"]];

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
        TWUserAccount *favorite = [self.favoritesList objectAtIndex:indexPath.row];
        [self.favoritesList removeObject:favorite];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.favoritesManager unfavoriteObject:favorite];
    }
}

@end
