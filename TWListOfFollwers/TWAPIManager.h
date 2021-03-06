//
//  TWAPIManager.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/14/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

typedef void(^TwitterWebServiceCompletionBlock)(id response, NSString *nextMaxTagID, NSError *error);

@class FavoriteAccount;
@interface TWAPIManager : NSObject

@property (nonatomic, strong) ACAccount *authenticatedAccount;

- (void)fetchListOfFollowingForTwitterAccount:(ACAccount *)account withNextCursor:(NSString *)nextCursor withCompletionBlock:(TwitterWebServiceCompletionBlock)completionBlock;

- (NSArray *)parseResponseFromWebService:(NSDictionary *)serviceResponse;
- (void)fetchRecentTweetsOfFavoriteAccount:(FavoriteAccount *)favorite withCompletionBlock:(TwitterWebServiceCompletionBlock)completionBlock;
@end
