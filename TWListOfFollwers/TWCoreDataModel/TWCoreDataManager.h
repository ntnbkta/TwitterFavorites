//
//  TWCoreDataManager.h
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/21/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TWCoreDataManager : NSObject

+ (TWCoreDataManager *)globalManager;

- (NSManagedObjectContext *)newWorkerManagedObjectContext;
- (NSManagedObjectContext *)mainUIManagedObjectContext;

@end
