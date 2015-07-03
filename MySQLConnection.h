//
//  MySQLConnection.h
//  CDSQL
//
//  Created by shdwprince on 7/1/15.
//  Copyright (c) 2015 shdwprince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mysql.h"
#import "MySQLResult.h"
#import "MySQLRow.h"

@class MySQLResult;

@interface MySQLConnection : NSObject
@property (readwrite, assign) int encoding;

- (instancetype) init;

# pragma mark connection
- (BOOL) connectTo:(NSString *) _host
                as:(NSString *) _user
      withPassword:(NSString *) _password;

- (BOOL) selectDatabase:(NSString *)_db;

# pragma mark error handling

- (NSError *) lastError;
- (NSNumber *) affectedRows;
- (NSNumber *) lastInsertId;

# pragma mark querying

- (MySQLResult *) resultOfQuery:(NSString *) format, ...;

- (MySQLResult *) select:(NSArray *) fields
                    from:(NSString *) table
                   where:(NSString *) clauses
                  offset:(int) offset
                   limit:(int) limit;

- (MySQLResult *) select:(NSArray *) fields
                    from:(NSString *) table
                   where:(NSString *) clauses;

- (MySQLResult *) select:(NSArray *) fields
                    from:(NSString *) table;

- (MySQLResult *) insertInto:(NSString *) table
                         set:(NSDictionary *) values;

- (MySQLResult *) deleteFrom:(NSString *) table
                       where:(NSString *) clauses;

- (MySQLResult *) update:(NSString *) table
                     set:(NSDictionary *) values
                   where:(NSString *) clauses;

@end
