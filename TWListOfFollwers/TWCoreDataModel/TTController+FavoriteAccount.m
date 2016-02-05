//
//  TTController+FavoriteAccount.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/21/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TTController.h"
#import "FavoriteAccount.h"
#import "TWTwitterAccount.h"
#import "NSManagedObjectContext+Extensions.h"

@implementation TTController (FavoriteAccount)


#pragma mark - Inserting

- (FavoriteAccount *)insertFavoriteAccountWithUnmanagedTwitterAccount:(TWTwitterAccount *)account
{
    __block FavoriteAccount *favoriteAccount = nil;
    [self.context performBlockAndWait:^{
        
        favoriteAccount = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteAccount"
                                                        inManagedObjectContext:self.context];
        [favoriteAccount setAccountID:[NSNumber numberWithInteger:[account.userID integerValue]]];
        [favoriteAccount setScreenName:[account handlerName]];
        [favoriteAccount setUserName:[account username]];
        [favoriteAccount setProfileImageURL:[NSString stringWithFormat:@"%@",[account profileImageURL]]];
        
    }];
    
    return favoriteAccount;
}

- (FavoriteAccount *)insertOrUpdateFavoriteAccountWithUnmanagedTwitterAccount:(TWTwitterAccount *)account
{
    // Determine if the Account has already been added into this moc
    FavoriteAccount *favoriteAccount = [self accountWithIdentifier:[account.userID integerValue]];
    
    BOOL alreadyPersisted = (favoriteAccount == nil) ? NO : YES;
    if (alreadyPersisted) {
        [self updateFavoriteAccount:favoriteAccount withUnmanagedTwitterAccount:account];
    } else {
        favoriteAccount = [self insertFavoriteAccountWithUnmanagedTwitterAccount:account];
    }
    
    return favoriteAccount;
}

#pragma mark - Update

- (FavoriteAccount *)updateFavoriteAccount:(FavoriteAccount *)favoriteAccount withUnmanagedTwitterAccount:(TWTwitterAccount *)account
{
    [self.context performBlockAndWait:^{
        [favoriteAccount setScreenName:[account handlerName]];
        [favoriteAccount setUserName:[account username]];
        [favoriteAccount setProfileImageURL:[NSString stringWithFormat:@"%@",[account profileImageURL]]];
        //check for any dependency : like while updating teacher, do we need to update other attributes
        
    }];
    return favoriteAccount;
}


#pragma mark - Fetching

- (FavoriteAccount *)accountWithIdentifier:(NSInteger)identifier;
{
    __block FavoriteAccount *fetchedEntity = nil;
    [self.context performBlockAndWait:^{
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FavoriteAccount"
                                                  inManagedObjectContext:self.context];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setFetchLimit:1];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"accountID == %@", @(identifier)]];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [[self context] executeFetchRequest:fetchRequest error:&error];
        if (!error) {
            if ([fetchedObjects count] > 0) {
                fetchedEntity = fetchedObjects[0];
            }
        } else {
            NSLog(@"Failed to fetch entity with error %@", error);
        }
    }];
    
    return fetchedEntity;
}

- (NSArray *)allFavoriteAccounts
{
    __block NSArray *resultSet = nil;
    
    [self.context performBlockAndWait:^{
        
        //Setting Entity to be Queried
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FavoriteAccount"
                                                  inManagedObjectContext:self.context];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"screenName"
                                                                         ascending:YES];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        resultSet = [[self context] executeFetchRequest:fetchRequest error:nil];
    }];
    
    return resultSet;
}

- (void)deleteTwitterAccount:(TWTwitterAccount *)account
{
    FavoriteAccount *favoriteAccount = [self accountWithIdentifier:[account.userID integerValue]];
    
    BOOL alreadyPersisted = (favoriteAccount == nil) ? NO : YES;
    if (alreadyPersisted) {
        [self deleteFavoriteAccount:favoriteAccount];
        
    } else {
        NSLog(@"Failed to fetch entity.");
    }
}

- (void)deleteFavoriteAccount:(FavoriteAccount *)inFavoriteAccount
{
    __block FavoriteAccount *favoriteAccount = inFavoriteAccount;
    
    if (favoriteAccount)
    {
        [self.context performBlockAndWait:^{
            [self.context deleteObject:favoriteAccount];
            
            [self.context saveAndPropagateToStoreWithCompletion:^(BOOL success, NSError *error) {
                if(error)
                {
                    NSLog(@"Couldn't save: %@", [error localizedDescription]);
                }
            }];
        }];
    }
}

@end
