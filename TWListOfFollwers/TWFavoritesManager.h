//
//  TWFavoritesManager.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/20/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWFavoritesManager : NSObject

+ (TWFavoritesManager *)sharedManager;

- (NSArray *)getFavoritesList;

- (void)addToFavorites:(NSArray *)favList;
- (void)removeAccountsFromFavorites:(NSArray *)unfavoritedList;

@end
