//
//  TWResultsTableViewController.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/19/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWResultsTableViewController.h"
#import "TWFollowingTableViewCell.h"
#import "TWTwitterAccount.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define CELL_REUSEIDENTIFIER @"TWUserCell"

@interface TWResultsTableViewController ()

@end

@implementation TWResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_searchedResults) {
        self.searchedResults = [NSArray new];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchedResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWFollowingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_REUSEIDENTIFIER];
    
    if (cell == nil) {
        cell = [[TWFollowingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_REUSEIDENTIFIER];
    }
    TWTwitterAccount *friend = [self.searchedResults objectAtIndex:indexPath.row];
    [cell.userName setText:[friend username]];
    [cell.handlerName setText:[friend handlerName]];
    [cell.userProfilePic sd_setImageWithURL:friend.profileImageURL placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    
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

@end
