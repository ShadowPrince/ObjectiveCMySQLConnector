//
//  MySQLRow.h
//  CDSQL
//
//  Created by shdwprince on 7/3/15.
//  Copyright (c) 2015 shdwprince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MySQLConnection.h"
#import "mysql.h"

@class MySQLConnection;

@interface MySQLRow : NSEnumerator
@property (readonly, copy) NSDictionary *values;

- (instancetype) initRowWithConnection:(MySQLConnection *) connection
                              fieldSet:(NSDictionary *) fieldSet
                              mysqlRow:(MYSQL_ROW) row;

- (id) objectForKeyedSubscript:(id) key;

@end
