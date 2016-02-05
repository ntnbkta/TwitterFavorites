/*
 Copyright © 2014 AirWatch, LLC. All rights reserved. This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties. AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  TTController.h
//  Teacher App
//

#import <Foundation/Foundation.h>

@class FavoriteAccount, TWTwitterAccount;

@interface TTController : NSObject

@property(nonatomic, strong) NSManagedObjectContext *context;


#pragma mark - General Methods
/** Designated initializer
 @param context NSManagedObjectContext used for fetching, deleting, inserting, modifying core data objects.
 @return A TTController instance.
 */
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;
- (id)fetchEntity:(NSEntityDescription *)entity withPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)saveManagedObjectContext;

- (NSArray *)objectIdsFromObjects:(NSArray *)mObjects;
- (NSArray *)objectsFromObjectIds:(NSArray *)mObjectsIds;
- (NSManagedObjectID *)objectIdFromObject:(id)mObject;
- (id)objectFromObjectId:(NSManagedObjectID *)mobjectId;

@end

#pragma mark - Teacher Methods
@interface TTController (FavoriteAccount)

- (FavoriteAccount *)insertOrUpdateFavoriteAccountWithUnmanagedTwitterAccount:(TWTwitterAccount *)account;
- (void)deleteFavoriteAccount:(FavoriteAccount *)account;
- (FavoriteAccount *)accountWithIdentifier:(NSInteger)identifier;
- (NSArray *)allFavoriteAccounts;
@end



