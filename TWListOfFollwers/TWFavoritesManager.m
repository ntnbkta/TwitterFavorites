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
#define kFavoritesSinceMaxIDUpdated @"FavoritesSinceMaxIDUpdated"

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteModelUpdated:) name:kFavoritesSinceMaxIDUpdated object:nil];
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


- (NSArray *)getFavoritesList
{
    NSArray *favoritesList = [self.favoritesManagerController allFavoriteAccounts];
    return favoritesList;
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

- (void)deleteFavoriteAccount:(FavoriteAccount *)favorite;
{
    [self.favoritesManagerController deleteFavoriteAccount:favorite];
    [self.favoritesList removeObject:favorite];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTWFavoritesListUpdated object:self userInfo:@{@"unfavoritedList":[NSArray arrayWithObject:favorite]}];

}

- (void)saveFavoriteAccountsInDatabase
{
    //Save the favorite account list in coreData
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.favoritesManagerWorkerContext saveAndPropagateToStoreWithCompletion:^(BOOL success, NSError *error) {
            NSLog(@"Error while saving core data %@",error);
            NSLog(@"SUCCESS : %@", success ? @"Yes" : @"No");
        }];
        
    });
}


- (void)favoriteModelUpdated:(NSNotification *)notif
{
    [self saveFavoriteAccountsInDatabase];
}

@end
