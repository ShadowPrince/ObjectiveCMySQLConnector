//
//  MySQLRow.m
//  CDSQL
//
//  Created by shdwprince on 7/3/15.
//  Copyright (c) 2015 shdwprince. All rights reserved.
//

#import "MySQLRow.h"

@implementation MySQLRow
@synthesize values;

- (instancetype) initRowWithConnection:(MySQLConnection *)connection
                              fieldSet:(NSDictionary *)fieldSet
                              mysqlRow:(MYSQL_ROW)row {
    self = [super init];

    NSMutableDictionary *_values = [[NSMutableDictionary alloc] init];

    int i = 0;
    for (NSString *name in fieldSet) {
        _values[name] = [self objectiveValue:row[i++] forType:(int) fieldSet[name] withEncoding:connection.encoding];
    }

    values = (NSDictionary *) _values;

    return self;
}

- (id) objectForKeyedSubscript:(id) key {
    return self.values[key];
}

- (id) objectiveValue:(char *) value forType:(int) type withEncoding:(NSStringEncoding) enc {
    if (value == nil)
        return [NSString string];

    return [NSString stringWithCString:value encoding:enc];
}


@end
