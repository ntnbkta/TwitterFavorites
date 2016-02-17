//
//  TWTwinderEngine.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/21/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWTwinderEngine.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "TWAccountManager.h"
#import "TWFavoritesManager.h"
#import "TWAPIManager.h"
#import "TWTweetFactory.h"

@interface TWTwinderEngine ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *twitterAccount;

@property (nonatomic, strong) TWTweetFactory *tweetFactory;
@property (nonatomic, strong) NSMutableArray *friendsList;
@end

@implementation TWTwinderEngine

- (instancetype)init
{
    if (self == [super init]) {
        [self setUpAccountStore];
        [self fetchTwitterAccountFromAccountStore];
    }
    return  self;
}

+ (TWTwinderEngine *)sharedManager
{
    static dispatch_once_t onceToken;
    static TWTwinderEngine *sharedManager = nil;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[TWTwinderEngine alloc] init];
    });
    return sharedManager;

}

- (void)setUpAccountStore
{
    if(!_accountStore)
    {
        _accountStore = [ACAccountStore new];
    }
    
    _accountManager = [TWAccountManager new];
    _favoritesManager = [TWFavoritesManager new];
    _apiManager = [TWAPIManager new];
    _tweetFactory = [TWTweetFactory new];
    
    [_tweetFactory setApiManager:_apiManager];
    [_accountManager setApiManager:_apiManager];
}

- (void)fetchTwitterAccountFromAccountStore
{
    ACAccountType *twitterAccountType = [self getAccountTypeFor:@"Twitter"];
    self.twitterAccount = [self fetchAccountInformationForAccountType:twitterAccountType];

    if (!self.twitterAccount) {
        [self requestAccessToTwitterAccountWithCompletionBlock:^(BOOL granted, NSError *error) {
            if (granted) {
                NSLog(@"******** ACCOUNT ACCESS GRANTED ********");
            }
            else{
                NSLog(@"******** ACCESS GRANT ERROR : %@ ********", [error localizedDescription]);
            }
        }];
    }
    else
    {
        [self.apiManager setAuthenticatedAccount:self.twitterAccount];
    }
}


- (void)requestAccessToTwitterAccountWithCompletionBlock:(void(^)(BOOL granted, NSError *error))completionBlock;
{
    __weak typeof(self) weakSelf = self;
    ACAccountType *twitterAccountType = [self getAccountTypeFor:@"Twitter"];
    [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:nil
                                            completion:^(BOOL granted, NSError *error) {
                                                if (granted) {
                                                    //Fetch Account information
                                                    weakSelf.twitterAccount = [weakSelf fetchAccountInformationForAccountType:twitterAccountType];
                                                    [weakSelf.apiManager setAuthenticatedAccount:weakSelf.twitterAccount];
                                                }
                                                else
                                                {
                                                    NSLog(@"******** ERROR : %@ **********",[error localizedDescription]);
                                                }
                                                completionBlock(granted,error);
                                            }];
}


#pragma mark - APIManager Methods

- (void)fetchTweetsOfFavoritesWithNewFetch:(BOOL)newFetch completionBlock:(void(^)(NSArray *tweetsList))completionBlock errorBlock:(void(^)(NSError *error))errorBlock
{
    NSArray *favoritesList = [self getUpdatedFavoritesHandlerList];
    
    if ([favoritesList count] == 0) {
        //No Favorites.
        completionBlock(nil);
    }else
    {
        [self.tweetFactory fetchTweetsOfFavorites:favoritesList
                                         newFetch:newFetch
                                 withSuccessBlock:^(NSArray *tweetsList) {
                                     completionBlock(tweetsList);
                                 } failureBlock:^(NSError *error) {
                                     NSLog(@"*********** TWEETS FETCHED ERROR : %@ ********** ",[error localizedDescription]);
                                     errorBlock(error);
                                 }];
    }
}

#pragma mark - Twitter Account Manager Methods

- (NSArray *)getFriendsList
{
    return self.friendsList;
}

- (void)fetchFollowingsOfCurrentTwitterAccountWithCompletionBlock:(ListOfFriendsCompletionBlock)completionBlock
{
    if (self.twitterAccount)
    {
        [self.accountManager getFriendsOf:self.twitterAccount onCompletion:^(NSArray *friendsList, BOOL isFetching) {
            if (!_friendsList) {
                _friendsList = [NSMutableArray new];
            }
            self.friendsList = [friendsList mutableCopy];
            completionBlock(self.friendsList,isFetching,nil);
        } error:^(NSError *error) {
            self.friendsList = nil;
            completionBlock(nil,NO,error);
        }];
    }
    else
    {
        NSLog(@"****** ERROR : NO TWITTER ACCOUNT *******");
    }
}


- (void)fetchNextSetOfFollowingsOfCurrentTwitterAccountWithCompletionBlock:(ListOfFriendsCompletionBlock)completionBlock
{
    [self.accountManager getNextPageFriendsListWithCompletion:^(NSArray *friendsList, BOOL isFetching) {
        completionBlock(friendsList,isFetching,nil);
    } error:^(NSError *error) {
        completionBlock(nil,NO,error);
    }];
}


#pragma mark - TWFavorite Manager Methods

- (NSArray *)getUpdatedFavoritesHandlerList
{
    return [self.favoritesManager getFavoritesList];
}


#pragma mark - Helper Methods

- (ACAccountType *)getAccountTypeFor:(NSString *)socialNetwork
{
    ACAccountType *accountType; //Default implementation
    if([socialNetwork isEqualToString:@"Twitter"])
    {
        accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    }
    return accountType;
}


- (ACAccount *)fetchAccountInformationForAccountType:(ACAccountType *)accountType
{
    ACAccount *account;
    NSArray *accountsArray = [self.accountStore accountsWithAccountType:accountType];
    
    if([accountsArray count])
    {
        account = [accountsArray objectAtIndex:0];
    }
    
    return account;
}


@end
