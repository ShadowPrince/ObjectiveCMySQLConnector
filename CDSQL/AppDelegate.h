//
//  AppDelegate.h
//  CDSQL
//
//  Created by shdwprince on 6/28/15.
//  Copyright (c) 2015 shdwprince. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MySQLStore.h"
#import "TestStore.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

