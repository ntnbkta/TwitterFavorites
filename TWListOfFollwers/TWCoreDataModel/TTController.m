/*
 Copyright © 2014 AirWatch, LLC. All rights reserved. This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties. AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  TTController.m
//  Teacher App
//

#import "TTController.h"
#import "NSManagedObjectContext+Extensions.h"

@implementation TTController

@synthesize context = _context;

#pragma mark - Lifecycle

- (id)init {
	NSLog(@"%@: Use designated initializer initWithManagedObjectContext:", [self class]);
	@throw [NSException exceptionWithName:@"DesignatedInitializerRequired"
                                   reason:@"Use initWithManagedObjectContext:"
                                 userInfo:nil];
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
	self = [super init];
	if (self) {
		_context = context;
	}
	return self;
}

- (void)dealloc {
    
	_context = nil;
}

#pragma mark - Fetching Helper

- (id)fetchEntity:(NSEntityDescription *)entity withPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)context {
	__block id fetchedEntity = nil;
	[self.context performBlockAndWait:^{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
		[fetchRequest setFetchLimit:1];
		[fetchRequest setPredicate:predicate];
		[fetchRequest setEntity:entity];
		
		NSError *error = nil;
		NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
		if (!error) {
			if ([fetchedObjects count] > 0) {
				fetchedEntity = [fetchedObjects objectAtIndex:0];
			}
		} else {
			NSLog(@"Failed to fetch entity with error %@", error);
		}
		
	}];
    
	return fetchedEntity;
}


- (NSArray *)objectIdsFromObjects:(NSArray *)mObjects
{
    __block NSMutableArray *arrayOfMbjectIds = [NSMutableArray array];
    
    [self.context performBlockAndWait:^{
        
        for(id mObject in mObjects)
        {
            [arrayOfMbjectIds addObject:[mObject objectID]];
        }
    }];
    
    return arrayOfMbjectIds;
}


- (NSArray *)objectsFromObjectIds:(NSArray *)mObjectsIds;
{
    __block NSMutableArray *arrayOfMObjects = [NSMutableArray array];
    
    [self.context performBlockAndWait:^{
        
        for(NSManagedObjectID *mObjectId in mObjectsIds)
        {
            [arrayOfMObjects addObject:[self.context objectWithID:mObjectId]];
        }
    }];
    
    return arrayOfMObjects;
}


- (NSManagedObjectID *)objectIdFromObject:(id)mObject
{
    if(mObject == nil)
    {
        return nil;
    }
    
    NSArray *returedObjectIds = [self objectIdsFromObjects:@[mObject]];
    
    NSManagedObjectID *returnObjectId = nil;
    
    if([returedObjectIds count] > 0)
    {
        returnObjectId = [returedObjectIds objectAtIndex:0];
    }
    
    return returnObjectId;
}


- (id)objectFromObjectId:(NSManagedObjectID *)mobjectId
{
    NSArray *returnedObjects = [self objectsFromObjectIds:@[mobjectId]];
    
    id returnedObject = nil;
    
    if ([returnedObjects count] > 0) {
        returnedObject = [returnedObjects objectAtIndex:0];
    }
    
    return returnedObject;
}


#pragma mark - Save Helper

- (void)saveManagedObjectContext {
	[self.context performBlockAndWait:^{
        
        [self.context saveAndPropagateToStoreWithCompletion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error saving context in FLContentController. %@", [error description]);
            }
        }];
	}];
}


@end
