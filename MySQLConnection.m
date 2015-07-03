//
//  MySQLConnection.m
//  CDSQL
//
//  Created by shdwprince on 7/1/15.
//  Copyright (c) 2015 shdwprince. All rights reserved.
//

#import "MySQLConnection.h"

@interface MySQLConnection()
@property (readonly, assign) MYSQL *connection;
@end

@implementation MySQLConnection
@synthesize connection;

- (instancetype) init {
    self = [super init];

    self.encoding = NSUTF8StringEncoding;
    connection = mysql_init(0);

    return self;
}

- (BOOL) connectTo:(NSString *) _host
                as:(NSString *) _user
      withPassword:(NSString *) _password {

    return mysql_real_connect(self.connection,
                           [_host cStringUsingEncoding:self.encoding],
                           [_user cStringUsingEncoding:self.encoding],
                           [_password cStringUsingEncoding:self.encoding],
                               NULL, 0, NULL, 0) != NULL;
}

- (BOOL) selectDatabase:(NSString *)db {
    mysql_select_db(self.connection, [db cStringUsingEncoding:self.encoding]);
    return YES;
}

- (NSError *) lastError {
    const char *error_string = mysql_error(self.connection);
    int code = mysql_errno(self.connection);
    return [NSError
            errorWithDomain:@"mysql"
            code:code
            userInfo:@{
                       NSLocalizedDescriptionKey: [NSString stringWithCString:error_string encoding:self.encoding],
                       NSLocalizedFailureReasonErrorKey: @"",
                       NSLocalizedRecoverySuggestionErrorKey: @"",
                       }];
}

- (NSNumber *) affectedRows {
    return [NSNumber numberWithLong:mysql_affected_rows(self.connection)];
}

- (NSNumber *) lastInsertId {
    return [NSNumber numberWithLong:mysql_insert_id(self.connection)];
}


- (MySQLResult *) resultOfQuery:(NSString *) query, ... {
    va_list args;
    va_start(args, query);
    const char* compiledQuery = [[[NSString alloc] initWithFormat:query arguments:args]
                           cStringUsingEncoding:self.encoding];
    va_end(args);

    NSLog(@"%s", compiledQuery);

    return [[MySQLResult alloc]
            initWithConnection:self
            queryStatus:mysql_query(self.connection, compiledQuery)
            result:mysql_store_result(self.connection)];
}

- (MySQLResult *) select:(NSArray *)fields
                    from:(NSString *)table
                   where:(NSString *)clauses
                  offset:(int)offset
                   limit:(int)limit {
    NSMutableString *baseQuery = [NSMutableString
                                  stringWithFormat:@"SELECT %@ FROM %@",
                                  [fields componentsJoinedByString:@", "],
                                  table];
    if (clauses != nil)
        [baseQuery appendFormat:@" WHERE %@", clauses];

    if (offset != -1 && limit != -1)
        [baseQuery appendFormat:@" LIMIT %d,%d", offset, limit];

    return [self resultOfQuery:baseQuery];
}

- (MySQLResult *) select:(NSArray *)fields from:(NSString *)table where:(NSString *)clauses {
    return [self select:fields from:table where:clauses offset:-1 limit:-1];
}

- (MySQLResult *) select:(NSArray *)fields from:(NSString *)table {
    return [self select:fields from:table where:nil];
}

- (MySQLResult *) insertInto:(NSString *)table set:(NSDictionary *)values {
    return [self resultOfQuery:@"INSERT INTO %@ SET %@",
            table,
            [self constructSetClause:values]];
}

- (MySQLResult *) update:(NSString *)table set:(NSDictionary *)values where:(NSString *)clauses {
    return [self resultOfQuery:@"UPDATE %@ SET %@ WHERE %@",
            table,
            [self constructSetClause:values],
            clauses];
}

- (MySQLResult *) deleteFrom:(NSString *)table where:(NSString *)clauses {
    return [self resultOfQuery:@"DELETE FROM %@ WHERE %@",
            table,
            clauses];
}

# pragma mark private methods

- (NSString *) constructSetClause:(NSDictionary *) values {
    NSMutableString *setClause = [NSMutableString string];

    int i = 0;
    for (id key in values) {
        [setClause appendFormat:@"`%@` = %@", key, [self escape:values[key]]];

        if (++i != [values count])
            [setClause appendString:@", "];
    }

    return setClause;
}

- (NSString *) escape:(id) value {
    NSString *stringValue = [NSString stringWithFormat:@"%@", value];
    const char *from = [stringValue cStringUsingEncoding:self.encoding];
    char to[strlen(from)];
    mysql_real_escape_string(self.connection, to, from, strlen(from));
    return [NSString stringWithFormat:@"\"%@\"", [NSString stringWithCString:to encoding:self.encoding]];
}

@end
