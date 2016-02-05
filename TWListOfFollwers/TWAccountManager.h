//
//  TWAccountManager.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/14/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@class TWAPIManager;

@interface TWAccountManager : NSObject

@property (nonatomic, strong) NSMutableArray *friendsList;
@property (nonatomic, strong) TWAPIManager *apiManager;

- (void)getFriendsOf:(ACAccount *)userAccount onCompletion:(void (^)(NSArray *friendsList,BOOL isFetching))completionBlock error:(void (^)(NSError *error))errorBlock;

- (void)getNextPageFriendsListWithCompletion:(void (^)(NSArray *friendsList, BOOL isFetching))completionBlock error:(void (^)(NSError *error))errorBlock;

@end
