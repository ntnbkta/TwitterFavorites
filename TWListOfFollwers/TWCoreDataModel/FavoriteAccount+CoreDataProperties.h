//
//  FavoriteAccount+CoreDataProperties.h
//  
//
//  Created by Nithin Bhaktha on 1/21/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FavoriteAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface FavoriteAccount (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *accountID;
@property (nullable, nonatomic, retain) NSString *screenName;

@end

NS_ASSUME_NONNULL_END
