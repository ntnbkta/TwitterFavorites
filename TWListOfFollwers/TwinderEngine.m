//
//  TwinderEngine.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/21/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TwinderEngine.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "TWAccountManager.h"

@interface TwinderEngine ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *twitterAccount;

@property (nonatomic, strong) TWAccountManager *accountManager;

@end

@implementation TwinderEngine

- (instancetype)init
{
    if (self == [super init]) {
        [self setUpAccountStore];
        [self setAccessGranted:NO];
        [self fetchTwitterAccountFromAccountStore];
    }
    return  self;
}

+ (TwinderEngine *)sharedManager
{
    static dispatch_once_t onceToken;
    static TwinderEngine *sharedManager = nil;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[TwinderEngine alloc] init];
    });
    return sharedManager;

}

- (void)setUpAccountStore
{
    if(!_accountStore)
    {
        _accountStore = [ACAccountStore new];
    }
    
    if (!_accountManager) {
        _accountManager = [TWAccountManager new];
    }
}


- (BOOL)accessGranted
{
    if (self.twitterAccount) {
        return YES;
    }
    else
        return NO;
}

- (void)fetchTwitterAccountFromAccountStore
{
    ACAccountType *twitterAccountType = [self getAccountTypeFor:@"Twitter"];
    self.twitterAccount = [self fetchAccountInformationForAccountType:twitterAccountType];
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
                                                    weakSelf.accessGranted = granted;
                                                }
                                                else
                                                {
                                                    NSLog(@"******** ERROR : %@ **********",[error localizedDescription]);
                                                }
                                                completionBlock(granted,error);
                                            }];
}

#pragma mark - Twitter Account Manager Methods

- (void)fetchFollowingsOfCurrentTwitterAccountWithCompletionBlock:(ListOfFriendsCompletionBlock)completionBlock
{
    if (self.twitterAccount)
    {
        [self.accountManager getFriendsOf:self.twitterAccount onCompletion:^(NSArray *friendsList, BOOL isFetching) {
            completionBlock(friendsList,isFetching,nil);
        } error:^(NSError *error) {
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
