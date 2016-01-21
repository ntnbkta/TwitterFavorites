//
//  TWFavoritesTableViewController.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/20/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWFavoritesTableViewController.h"
#import "TWFollowingTableViewCell.h"
#import "TWTwitterAccount.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TWTwinderEngine.h"

#define CELL_REUSEIDENTIFIER @"TWUserCell"

@interface TWFavoritesTableViewController ()

@property (nonatomic, strong) NSMutableArray *unfavoritedList;

@end

@implementation TWFavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_favoritesList) {
        _favoritesList = [NSMutableArray new];
    }
    _favoritesList = [[[TWTwinderEngine sharedManager] getUpdatedFavoritesHandlerList] mutableCopy];

    
    if (!_unfavoritedList) {
        _unfavoritedList = [NSMutableArray new];
    }
}

- (IBAction)doneButtonTapped:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(favoritesViewController:didFinishUnfavoriting:)]) {
        [self.delegate favoritesViewController:self didFinishUnfavoriting:self.unfavoritedList];
    }
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
    TWFollowingTableViewCell *cell = (TWFollowingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_REUSEIDENTIFIER forIndexPath:indexPath];
    
    TWTwitterAccount *friend = [self.favoritesList objectAtIndex:indexPath.row];
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
        TWTwitterAccount *favorite = [self.favoritesList objectAtIndex:indexPath.row];
        [self.favoritesList removeObject:favorite];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.unfavoritedList addObject:favorite];
    }
}

@end
