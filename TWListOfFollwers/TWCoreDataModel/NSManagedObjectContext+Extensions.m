/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
*/
//
//  NSManagedObjectContext+Extensions.m
//  FileLocker
//
//  Created by Robert Edwards on 9/13/13.
//  Copyright (c) 2013 AirWatch. All rights reserved.
//

#import "NSManagedObjectContext+Extensions.h"

@implementation NSManagedObjectContext (Extensions)

- (void)saveAndPropagateToStoreWithCompletion:(void(^)(BOOL success, NSError *error))completion {
    [self performBlockAndWait:^{
        NSError *saveError = nil;
        if ([self hasChanges]) {
            if (![self save:&saveError]) {
                NSLog(@"Save Error: %@", saveError);
                completion(NO, saveError);
            } else if ([self parentContext]) {
                __block NSManagedObjectContext *parentContext = self.parentContext;
                __block BOOL parentSuccess = YES;
                __block NSError *parentSaveError = nil;
                while (parentContext && (parentSuccess && !parentSaveError)) {
                    [parentContext performBlockAndWait:^{
                        NSError *contextSaveError = nil;
                        if (![parentContext save:&contextSaveError]) {
                            parentSuccess = NO;
                            NSLog(@"Save Error: %@", contextSaveError);
                        } else {
                            parentSuccess = YES;
                        }
                        parentContext = parentContext.parentContext;
                        parentSaveError = contextSaveError;
                    }];
                }
                completion(parentSuccess, parentSaveError);
            } else {
                completion(YES, nil);
            }
        } else {
            completion(YES, nil);
        }
    }];
}



@end
