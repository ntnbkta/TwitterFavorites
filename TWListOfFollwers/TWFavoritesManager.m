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
@property (nonatomic, strong) NSMutableArray *unFavoritedList;


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
        
        if(!_unFavoritedList)
        {
            _unFavoritedList = [NSMutableArray new];
        }
    }
    return self;
}


- (void)addToFavorites:(NSArray *)favList
{
    [self.favoritesList addObjectsFromArray:favList];
}

- (NSArray *)getFavoritesList
{
    return self.favoritesList;
}


- (void)unfavoriteObject:(TWUserAccount *)favorite
{
    [self.favoritesList removeObject:favorite];
    [self.unFavoritedList addObject:favorite];
}


- (void)saveChanges
{
    //Send out UnfavoritedList
    [[NSNotificationCenter defaultCenter] postNotificationName:kTWFavoritesListUpdated object:self userInfo:@{@"unfavoritedList":self.unFavoritedList}];
    [self.unFavoritedList removeAllObjects];
}

@end
