//
//  MySQLResult.m
//  CDSQL
//
//  Created by shdwprince on 7/3/15.
//  Copyright (c) 2015 shdwprince. All rights reserved.
//

#import "MySQLResult.h"

@interface MySQLResult ()
@property (readonly, strong) MySQLConnection *connection;
@property (readonly, assign) MYSQL_RES *result;

@end

@implementation MySQLResult
@synthesize fields, affectedRows, insertId;
@synthesize connection, result;

- (instancetype) initWithConnection:(MySQLConnection *)_connection
                        queryStatus:(int) queryStatus
                            result:(MYSQL_RES *)_result {
    self = [super init];

    connection = _connection;
    result = nil;

    if (queryStatus != 0)
        return nil;

    affectedRows = [self.connection affectedRows];
    insertId = [self.connection lastInsertId];

    if (_result == nil)
        return self;

    result = _result;
    fields = [[NSMutableDictionary alloc] init];    

    MYSQL_FIELD *c_field;
    while ((c_field = mysql_fetch_field(result))) {
        NSString *name = [NSString stringWithCString:c_field->name encoding:self.connection.encoding];
        fields[name] = [NSNumber numberWithInteger:c_field->type];
    }
    free(c_field);

    return self;
}

- (MySQLRow *) nextObject {
    MYSQL_ROW row;

    if ((row = mysql_fetch_row(self.result))) {
        return [[MySQLRow alloc] initRowWithConnection:self.connection fieldSet:self.fields mysqlRow:row];
    } else {
        return nil;
    }
}

- (void) dealloc {
    if (self.result)
        mysql_free_result(self.result);
}

@end
