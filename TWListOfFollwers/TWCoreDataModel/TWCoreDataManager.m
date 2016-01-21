//
//  TWCoreDataManager.m
//  TWListOfFollwers
//
//  Created by Nithin Bhaktha on 1/21/16.
//  Copyright © 2016 Nithin Bhaktha. All rights reserved.
//

#import "TWCoreDataManager.h"

@interface TWCoreDataManager()

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *mainUIContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *rootDataPersistingManagedObjectContext;
@property (nonatomic, strong) NSString *documentsPath;

@end

@implementation TWCoreDataManager

#pragma mark - Lifecycle

- (void)dealloc {
    _rootDataPersistingManagedObjectContext = nil;
    _mainUIContext = nil;
    _persistentStoreCoordinator = nil;
    _managedObjectModel = nil;
}

- (id)init {
    if ( self = [super init]) {
        
    }
    return self;
}

#pragma mark - Shared Instance

+ (TWCoreDataManager *)globalManager {
    static dispatch_once_t onceToken;
    static TWCoreDataManager *globalManager;
    dispatch_once(&onceToken, ^{
        globalManager = [[TWCoreDataManager alloc] init];
    });
    
    return globalManager;
}

#pragma mark - Public Accessors

- (NSManagedObjectContext *)mainUIManagedObjectContext {
    return self.mainUIContext;
}

- (NSManagedObjectContext *)newWorkerManagedObjectContext {
    NSManagedObjectContext *workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    workerContext.parentContext = [self mainUIContext];
    workerContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    return workerContext;
}

#pragma mark - Private Accessors

- (NSManagedObjectContext *)rootDataPersistingManagedObjectContext {
    if (!_rootDataPersistingManagedObjectContext) {
        _rootDataPersistingManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _rootDataPersistingManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        _rootDataPersistingManagedObjectContext.mergePolicy = NSOverwriteMergePolicy;
    }
    return _rootDataPersistingManagedObjectContext;
}


- (NSManagedObjectContext *)mainUIContext {
    if (!_mainUIContext) {
        _mainUIContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainUIContext.parentContext = [self rootDataPersistingManagedObjectContext];
    }
    return _mainUIContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSURL *documentsURL = [NSURL fileURLWithPath:[self documentsDirectoryPath]];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"TWListOfFollowers.sqlite"];
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @(YES),
                                  NSInferMappingModelAutomaticallyOption: @(YES)};
        NSError *error = nil;
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeURL
                                                             options:options
                                                               error:&error]) {
            NSLog(@"Unresolved error setting up persistent store. Error: %@, %@", error, [error userInfo]);
            abort();
        }
        
        NSDictionary *fileProtectionAttributes = @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication};
        
        [[NSFileManager defaultManager] setAttributes:fileProtectionAttributes
                                         ofItemAtPath:storeURL.path error:&error];
        if (error)
            NSLog(@"Error while applying file protection attributes: %@", error);
    }
    return _persistentStoreCoordinator;
}


#pragma mark - Private Methods

static inline NSString *directoryForSearchPath(NSSearchPathDirectory directory) {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    NSString *directoryPath = nil;
    
    if ([paths count])
        directoryPath = [paths objectAtIndex:0];
    
    return directoryPath;
    
}

- (NSString *)documentsDirectoryPath {
    
    if ([self documentsPath] == nil)
    {
        [self setDocumentsPath:directoryForSearchPath(NSDocumentDirectory)];
    }
    
    return [self documentsPath];
    
}


@end
