//
//  MySQLStore.m
//  CDSQL
//
//  Created by shdwprince on 6/30/15.
//  Copyright (c) 2015 shdwprince. All rights reserved.
//

#import "MySQLStore.h"

@interface MySQLStore ()
@property (readwrite, strong) MySQLConnection *connection;
@property (readwrite, strong) NSMutableDictionary *ids;
@end

@implementation MySQLStore
@synthesize connection, ids;

- (BOOL) loadMetadata:(NSError *__autoreleasing *)error {
    connection = [[MySQLConnection alloc] init];
    self.ids = [[NSMutableDictionary alloc] init];

    if (![connection connectTo:@"localhost" as:@"root" withPassword:@""]) {
        return [self failWithError:error];
    }

    if (![connection selectDatabase:@"testdb"]) {
        return [self failWithError:error];
    }

    return YES;
}

- (id) executeRequest:(NSPersistentStoreRequest *)request
          withContext:(NSManagedObjectContext *)context
                error:(NSError *__autoreleasing *)error {
    switch (request.requestType) {
        case NSFetchRequestType:
            return [self processFetchRequest:(NSFetchRequest *) request moc:context withError:error];
        case NSSaveRequestType:
            return [self processSaveRequest:(NSSaveChangesRequest *) request withError:error];
        default:
            return nil;
    }
}

- (NSIncrementalStoreNode *) newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                          withContext:(NSManagedObjectContext *)context
                                                error:(NSError *__autoreleasing *)error {
    NSNumber *rid = self.ids[objectID];
    MySQLResult *result = [self.connection select:@[@"*"]
                                             from:[self tableFor:objectID.entity]
                                            where:[NSString stringWithFormat:@"id = %@", rid]
                                           offset:0
                                            limit:1];

    NSDictionary *row = result ? [result nextObject].values : nil;
    return [[NSIncrementalStoreNode alloc] initWithObjectID:objectID
                                                 withValues:row
                                                    version:1];
}

- (NSArray *) obtainPermanentIDsForObjects:(NSArray *)array error:(NSError *__autoreleasing *)error {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (NSManagedObject *object in array) {
        __block NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
        [object.entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id value;
            if ((value = [object valueForKey:key]))
                [values setObject:value forKey:key];
        }];

        MySQLResult *result = [self.connection insertInto:[self tableFor:object.entity]
                                                      set:values];
        if (result) {
            [object setValue:result.insertId forKey:@"id"];
            [results addObject:[self newObjectIDForEntity:object.entity referenceObject:result.insertId]];
        } else {
            *error = [self.connection lastError];
            return nil;
        }
    }

    return results;
}

# pragma mark private methods

- (id) processFetchRequest:(NSFetchRequest *)request
                       moc:(NSManagedObjectContext *)context
                 withError:(NSError *__autoreleasing*) error {
    __block NSMutableArray *results = [[NSMutableArray alloc] init];

    MySQLResult *result = [self.connection select:@[@"*"]
                                             from:[self tableFor:request.entity]
                                            where:nil
                                           offset:-1
                                            limit:-1];

    if (result) for (MySQLRow *row in result) {
        NSManagedObjectID *oid = [self newObjectIDForEntity:request.entity referenceObject:row[@"id"]];
        [results addObject:[context objectWithID:oid]];
        [self.ids setObject:row[@"id"] forKey:oid];
    }

    return results;
}

- (id) processSaveRequest:(NSSaveChangesRequest *) request withError:(NSError *__autoreleasing*) error {
    for (NSManagedObject *object in [request deletedObjects]) {
        MySQLResult *result = [self.connection deleteFrom:[self tableFor:object.entity]
                                                    where:[NSString stringWithFormat:@"id = %@", [object valueForKey:@"id"]]];
        if (!result) {
            return [self failWithError:error];
        }
    }

    for (NSManagedObject *object in [request updatedObjects]) {
        __block NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
        [object.entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id value;
            if ((value = [object valueForKey:key]))
                [values setObject:value forKey:key];
        }];

        MySQLResult *result = [self.connection update:[self tableFor:object.entity]
                                                  set:values
                                                where:[NSString stringWithFormat:@"id = %@", [object valueForKey:@"id"]]];
        if (!result) {
            return [self failWithError:error];
        }
    }
    
    return @[];
}

- (NSString *) tableFor:(NSEntityDescription *) entity {
    return [entity.name lowercaseString];
}


- (id) failWithError:(NSError *__autoreleasing *) error {
    *error = [self.connection lastError];
    return nil;
}

@end
