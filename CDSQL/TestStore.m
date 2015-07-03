//
//  TestStore.m
//  CDSQL
//
//  Created by shdwprince on 7/2/15.
//  Copyright (c) 2015 shdwprince. All rights reserved.
//

#import "TestStore.h"

@implementation TestStore

- (BOOL) loadMetadata:(NSError *__autoreleasing *)error {
    return YES;
}

- (id) executeRequest:(NSPersistentStoreRequest *)request
          withContext:(NSManagedObjectContext *)context
                error:(NSError *__autoreleasing *)error {
    NSLog(@"%@", request);

    if (request.requestType == NSFetchRequestType) {
        NSFetchRequest *r = (NSFetchRequest *)request;
        NSManagedObjectID *oid = [self newObjectIDForEntity:r.entity referenceObject:@100];

        return @[[context objectWithID:oid]];
    }


    return @[];
}


- (NSIncrementalStoreNode *) newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                          withContext:(NSManagedObjectContext *)context
                                                error:(NSError *__autoreleasing *)error {
    NSIncrementalStoreNode *node = [[NSIncrementalStoreNode alloc] initWithObjectID:objectID
                                                                         withValues:@{@"name": @"foobar", @"price": @123, @"id": @100}
                                                                            version:1];

    return node;
}


- (NSArray *) obtainPermanentIDsForObjects:(NSArray *)array error:(NSError *__autoreleasing *)error {
    return nil;
}
@end
