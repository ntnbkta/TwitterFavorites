//
//  TWFavoritesManager.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/20/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWFavoritesManager.h"
#import "TWCoreDataManager.h"
#import "TTController.h"
#import "NSManagedObjectContext+Extensions.h"
#import "TWTwitterAccount.h"
#import "FavoriteAccount.h"

#define kTWFavoritesListUpdated @"TWFavoritesListUpdated"

@interface TWFavoritesManager ()

@property (nonatomic, strong) NSMutableArray *favoritesList;
@property (nonatomic, strong) TTController *favoritesManagerController;
@property (nonatomic, strong) NSManagedObjectContext *favoritesManagerWorkerContext;


@end

@implementation TWFavoritesManager


- (instancetype)init
{
    if (self == [super init]) {
        if (!_favoritesList)
        {
            _favoritesList = [NSMutableArray new];
        }

        _favoritesManagerWorkerContext = [[TWCoreDataManager globalManager] newWorkerManagedObjectContext];
        _favoritesManagerController = [[TTController alloc] initWithManagedObjectContext:self.favoritesManagerWorkerContext];

    }
    return self;
}

- (void)addToFavorites:(NSArray *)favList
{
    [favList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TWTwitterAccount *twitterAccount = (TWTwitterAccount*)obj;
        FavoriteAccount *favoriteAccount = [self.favoritesManagerController insertOrUpdateFavoriteAccountWithUnmanagedTwitterAccount:twitterAccount];
        [self.favoritesList addObject:favoriteAccount];
    }];
    [self saveFavoriteAccountsInDatabase];
}

- (void)removeAccountsFromFavorites:(NSArray *)unfavoritedList;
{
    [unfavoritedList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FavoriteAccount *favoriteAccount = (FavoriteAccount *)obj;
        [self.favoritesManagerController deleteFavoriteAccount:favoriteAccount];
        [self.favoritesList removeObject:favoriteAccount];
    }];
    
    //Send out UnfavoritedList
    [[NSNotificationCenter defaultCenter] postNotificationName:kTWFavoritesListUpdated object:self userInfo:@{@"unfavoritedList":unfavoritedList}];

}

- (NSArray *)getFavoritesList
{
    NSMutableArray *favoriteTwitterAccount = [NSMutableArray new];
    NSArray *favoritesList = [self.favoritesManagerController allFavoriteAccounts];
    [favoritesList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //Create TWTwitterAccount of each account
        FavoriteAccount *favoriteAccount = (FavoriteAccount *)obj;
        TWTwitterAccount *twitterAccount = [self getTwitterAccountForFavoriteAccount:favoriteAccount];
        [favoriteTwitterAccount addObject:twitterAccount];
    }];
    return favoriteTwitterAccount;
}

- (TWTwitterAccount *)getTwitterAccountForFavoriteAccount:(FavoriteAccount *)favoriteAccount
{
    TWTwitterAccount *twitterAccount = [TWTwitterAccount new];
    [twitterAccount setUserID:[NSString stringWithFormat:@"%@",favoriteAccount.accountID]];
    [twitterAccount setHandlerName:[favoriteAccount screenName]];
    [twitterAccount setUsername:[favoriteAccount userName]];
    [twitterAccount setProfileImageURL:[NSURL URLWithString:[favoriteAccount profileImageURL]]];
    return twitterAccount;
}


- (void)saveFavoriteAccountsInDatabase
{
    //Save the favorite account list in coreData
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [self.favoritesList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            
//            __block TWTwitterAccount *twitterAccount = (TWTwitterAccount *)obj;
//            
//            FavoriteAccount *newFavoriteAccount = [self.favoritesManagerController insertOrUpdateFavoriteAccountWithUnmanagedTwitterAccount:twitterAccount];
//            
//            NSLog(@"**** NEW FAVORITE ACCOUNT : %@ *** ",newFavoriteAccount);
//        }];
//        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.favoritesManagerWorkerContext saveAndPropagateToStoreWithCompletion:^(BOOL success, NSError *error) {
                NSLog(@"Error while saving core data %@",error);
                NSLog(@"SUCCESS : %@", success ? @"Yes" : @"No");
            }];
            
        });
    });
}

@end
