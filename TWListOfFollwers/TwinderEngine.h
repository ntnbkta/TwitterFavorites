//
//  TwinderEngine.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/21/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount;

typedef void(^ListOfFriendsCompletionBlock)(NSArray *followingsList, BOOL isFetching, NSError *error);

@interface TwinderEngine : NSObject

@property (nonatomic, assign) BOOL accessGranted;

+ (TwinderEngine *)sharedManager;
- (void)requestAccessToTwitterAccountWithCompletionBlock:(void(^)(BOOL granted, NSError *error))completionBlock;
- (void)fetchFollowingsOfCurrentTwitterAccountWithCompletionBlock:(ListOfFriendsCompletionBlock)completionBlock;
- (void)fetchNextSetOfFollowingsOfCurrentTwitterAccountWithCompletionBlock:(ListOfFriendsCompletionBlock)completionBlock;

- (void)addFollowingsToFavoritesList:(NSArray *)favoritesList;
- (void)removeAccountsFromFavorites:(NSArray *)unfavoritedList;
- (NSArray *)getUpdatedFavoritesHandlerList;

@end
