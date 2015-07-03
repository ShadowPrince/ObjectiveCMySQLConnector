//
//  MySQLResult.h
//  CDSQL
//
//  Created by shdwprince on 7/3/15.
//  Copyright (c) 2015 shdwprince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MySQLRow.h"
#import "MySQLConnection.h"
#import "mysql.h"

@class MySQLConnection;
@class MySQLRow;

@interface MySQLResult : NSEnumerator
@property (readonly, strong) NSMutableDictionary *fields;
@property (readonly, strong) NSNumber *insertId, *affectedRows;

- (instancetype) initWithConnection:(MySQLConnection *) connection
                        queryStatus:(int) queryStatus
                             result:(MYSQL_RES *) result;

- (MySQLRow *) nextObject;

@end
