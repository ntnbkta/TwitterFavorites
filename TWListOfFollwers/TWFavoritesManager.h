//
//  TWFavoritesManager.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/20/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FavoriteAccount,TWTweet;
@interface TWFavoritesManager : NSObject

- (NSArray *)getFavoritesList;
- (void)addToFavorites:(NSArray *)favList;
- (void)deleteFavoriteAccount:(FavoriteAccount *)favorite;
- (void)saveFavoriteAccountsInDatabase;
- (void)lastReadTweet:(TWTweet *)readTweet;
- (void)saveLastReadTweetIDToFavoriteAccount;

@end
