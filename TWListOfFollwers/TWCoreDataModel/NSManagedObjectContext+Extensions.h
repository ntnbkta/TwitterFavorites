/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
*/
//
//  NSManagedObjectContext+Extensions.h
//  FileLocker
//
//  Created by Robert Edwards on 9/13/13.
//  Copyright (c) 2013 AirWatch. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Extensions)

- (void)saveAndPropagateToStoreWithCompletion:(void(^)(BOOL success, NSError *error))completion;

@end
