//
//  SqliteObj.h
//  iSugarCRM
//
//  Created by satyavrat-mac on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface SqliteObj : NSObject{
    @private
    sqlite3 *database;
    int busyRetryTimeout;
}
//+(SqliteObj*)sharedInstance;
-(BOOL)initializeDatabaseWithError:(NSError**)error;
-(void)closeDatabase;
-(sqlite3_stmt*)executeQuery:(NSString*)sql error:(NSError**)error;
-(BOOL)executeUpdate:(NSString*)sql error:(NSError**)error;
@end
