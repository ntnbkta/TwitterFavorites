//
//  TWFavoritesTableViewController.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/20/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TWFavoritesTableViewController;

@protocol FavoriteAccountsDelegate <NSObject>

- (void)favoritesViewController:(TWFavoritesTableViewController *)favoritesVC didFinishUnfavoriting:(NSArray *)unfavoritedList;

@end

@interface TWFavoritesTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *favoritesList;
@property (nonatomic, weak) id<FavoriteAccountsDelegate> delegate;

@end
