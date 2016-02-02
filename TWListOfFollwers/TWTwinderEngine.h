//
//  TWTwinderEngine.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/21/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount, TWAccountManager, TWFavoritesManager, TWAPIManager;

typedef void(^ListOfFriendsCompletionBlock)(NSArray *followingsList, BOOL isFetching, NSError *error);

@interface TWTwinderEngine : NSObject

@property (nonatomic, strong) TWAccountManager *accountManager;
@property (nonatomic, strong) TWFavoritesManager *favoritesManager;
@property (nonatomic, strong) TWAPIManager *apiManager;


+ (TWTwinderEngine *)sharedManager;
- (void)fetchFollowingsOfCurrentTwitterAccountWithCompletionBlock:(ListOfFriendsCompletionBlock)completionBlock;
- (void)fetchNextSetOfFollowingsOfCurrentTwitterAccountWithCompletionBlock:(ListOfFriendsCompletionBlock)completionBlock;
- (void)fetchTweetsOfFavoritesWithCompletionBlock:(void(^)(NSArray *tweetsList))completionBlock errorBlock:(void(^)(NSError *error))errorBlock;

- (void)removeAccountsFromFavorites:(NSArray *)unfavoritedList;

@end
