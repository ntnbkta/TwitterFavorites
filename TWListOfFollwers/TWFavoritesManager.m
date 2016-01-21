//
//  TWFavoritesManager.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/20/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWFavoritesManager.h"

#define kTWFavoritesListUpdated @"TWFavoritesListUpdated"

@interface TWFavoritesManager ()

@property (nonatomic, strong) NSMutableArray *favoritesList;

@end

@implementation TWFavoritesManager

+ (TWFavoritesManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static TWFavoritesManager *sharedManager = nil;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[TWFavoritesManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    if (self == [super init]) {
        if (!_favoritesList)
        {
            _favoritesList = [NSMutableArray new];
        }
    }
    return self;
}


- (void)addToFavorites:(NSArray *)favList
{
    [self.favoritesList addObjectsFromArray:favList];
}


- (void)removeAccountsFromFavorites:(NSArray *)unfavoritedList;
{
    [self.favoritesList removeObjectsInArray:unfavoritedList];
    //Send out UnfavoritedList
    [[NSNotificationCenter defaultCenter] postNotificationName:kTWFavoritesListUpdated object:self userInfo:@{@"unfavoritedList":unfavoritedList}];

}


- (NSArray *)getFavoritesList
{
    return self.favoritesList;
}

@end
