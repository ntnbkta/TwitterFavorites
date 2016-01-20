//
//  TWFavoritesManager.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/20/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWUserAccount;
@interface TWFavoritesManager : NSObject

+ (TWFavoritesManager *)sharedManager;

- (void)addToFavorites:(NSArray *)favList;
- (NSArray *)getFavoritesList;
- (void)unfavoriteObject:(TWUserAccount *)favorite;
- (void)saveChanges;
@end
