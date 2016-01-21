//
//  TWAccountManager.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/14/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWAccountManager.h"
#import "TWAPIManager.h"
#import "TwinderEngine.h"

@interface TWAccountManager ()

@property (nonatomic, strong) NSString *nextCursor;
@property (nonatomic, strong) ACAccount *currentUserAccount;
@property (nonatomic, assign) BOOL shouldStopFetchingNextPage;


@end

@implementation TWAccountManager

- (instancetype)init
{
    if (self == [super init]) {
        //Initialization code
    }
    return self;
}

- (void)getFriendsOf:(ACAccount *)userAccount onCompletion:(void (^)(NSArray *friendsList,BOOL isFetching))completionBlock error:(void (^)(NSError *error))errorBlock
{
    //Response is an array of InstagramMedia. Parse it
    if (!self.friendsList) {
        _friendsList = [NSMutableArray new];
    }
    else {
        [_friendsList removeAllObjects];
    }
    self.currentUserAccount = userAccount;
    [self getFriendsForAccount:userAccount withNextCursor:nil onCompletion:completionBlock error:errorBlock];

}

- (void)getNextPageFriendsListWithCompletion:(void (^)(NSArray *friendsList, BOOL isFetching))completionBlock error:(void (^)(NSError *error))errorBlock
{
    [self getFriendsForAccount:self.currentUserAccount withNextCursor:self.nextCursor onCompletion:completionBlock error:errorBlock];
}


- (void)getFriendsForAccount:(ACAccount *)userAccount withNextCursor:(NSString *)nextCursor onCompletion:(void (^)(NSArray *friendsList,BOOL isFetching))completionBlock error:(void (^)(NSError *))errorBlock
{
    [[TWAPIManager sharedManager] fetchListOfFollowingForTwitterAccount:userAccount withNextCursor:nextCursor withCompletionBlock:^(id response, NSString *nextCursor, NSError *error) {
        
        if (!response && !nextCursor && !error) {
            //Stop fetching. End of Results
            completionBlock(self.friendsList,NO);
        }
        else
        {
            [self.friendsList addObjectsFromArray:(NSArray *)response];
            if (!error) {
                self.nextCursor = nextCursor;
                completionBlock(self.friendsList,YES);
            }
            else {
                errorBlock(error);
            }

        }
    }];
}


@end
