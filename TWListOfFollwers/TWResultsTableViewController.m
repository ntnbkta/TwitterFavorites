//
//  TWResultsTableViewController.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/19/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWResultsTableViewController.h"
#import "TableViewCell.h"
#import "TWUserAccount.h"

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
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_REUSEIDENTIFIER];
    
    if (cell == nil) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_REUSEIDENTIFIER];
    }
    TWUserAccount *friend = [self.searchedResults objectAtIndex:indexPath.row];
    [cell.textLabel setText:[friend username]];
    
    return cell;
}



@end
