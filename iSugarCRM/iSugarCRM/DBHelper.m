//
//  DBHelper.m
//  iSugarCRM
//
//  Created by pramati on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBHelper.h"
#import "SqliteObj.h"
#import "DataObject.h"

@implementation DBHelper
+(void) updateUserTable:(NSArray*) userList
{
    SqliteObj* db = [[SqliteObj alloc] init];
    NSError* error = nil;
    if([db initializeDatabaseWithError:&error])
    {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS USERS (name VARCHAR(100), id VARCHAR(100), PRIMARY KEY (id));"];
        
        if(![db executeUpdate:sql error:&error])
        {
            NSLog(@"error creating database with sql:%@ and error: %@",sql,[error localizedDescription]);
        }
        else
        {
            for(NSDictionary* userInfo in userList)
            {
                NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO USERS (id, name)"];
                NSString* userId = [userInfo objectForKey:@"id"];
                NSString* name = [[[userInfo objectForKey:@"name_value_list"] objectForKey:@"name"] objectForKey:@"value"];
                NSMutableString *values = [NSMutableString stringWithFormat:@"VALUES ('%@', '%@');",userId, name];      
                [sql appendString:values];
                BOOL success = [db executeUpdate:sql error:&error];
                if(success)
                {
                    NSLog(@"succesfull updated list");
                }
            }
        }
    }
    return ;    
}

+(NSArray*) loadUserList
{
    SqliteObj* db = [[SqliteObj alloc] init];
    NSError* error = nil;
    NSMutableArray *rows = [[NSMutableArray alloc]init];
    if(![db initializeDatabaseWithError:&error]){
        NSLog(@"%@",[error localizedDescription]);
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM USERS ;"];
    sqlite3_stmt *stmt =[db executeQuery:sql error:&error];
    if (error) {
        NSLog(@"error retrieving data from database: %@",[error localizedDescription]);
    }
    while(sqlite3_step(stmt)==SQLITE_ROW){
        int columnCount = sqlite3_column_count(stmt);
        int columnIdx=0;
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        for (columnIdx=0;columnIdx<columnCount;columnIdx++) 
        {
            NSString* fieldName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, columnIdx)];
            NSString *value;
            
            char *field_value = (char*)sqlite3_column_text(stmt, columnIdx);
            //  NSLog(@"%s",field_value);
            if (field_value!=NULL) {
                value = [NSString stringWithFormat:@"%s",field_value];
            }
            else value = @"";
            [userInfo setObject:value forKey:fieldName];                       
        }      
        [rows addObject:userInfo]; 
    }
    sqlite3_finalize(stmt);
    [db closeDatabase];
    return rows;
}

+(NSArray*) loadRecordsinModule:(NSString*) moduleName
{
    SqliteObj* db = [[SqliteObj alloc] init];
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    DBMetadata *dbMetadata = [sharedInstance dbMetadataForModule:moduleName];
    NSError* error = nil;
    NSMutableArray *rows = [[NSMutableArray alloc]init];
    if(![db initializeDatabaseWithError:&error]){
        NSLog(@"%@",[error localizedDescription]);
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ;",dbMetadata.tableName];
    sqlite3_stmt *stmt =[db executeQuery:sql error:&error];
    if (error) {
        NSLog(@"error retrieving data from database: %@",[error localizedDescription]);
    }
    while(sqlite3_step(stmt)==SQLITE_ROW){
        DataObject *dataObject = [[DataObject alloc] initWithMetadata:[sharedInstance objectMetadataForModule:dbMetadata.tableName]];
        int columnCount = sqlite3_column_count(stmt);
        int columnIdx=0;
        for (columnIdx=0;columnIdx<columnCount;columnIdx++) 
        {
            NSString* fieldName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, columnIdx)];
            NSString *value;
            
            char *field_value = (char*)sqlite3_column_text(stmt, columnIdx);
            //  NSLog(@"%s",field_value);
            if (field_value!=NULL) {
                value = [NSString stringWithFormat:@"%s",field_value];
            }
            else value = @"";
            if (![fieldName isEqualToString:@"dirty"]) {
                if(![dataObject setObject:value forFieldName:[dbMetadata.column_objectFieldMap objectForKey:fieldName]]){
                    NSLog(@"No %@ field in data object with specified metadata",fieldName);
                }
            }
        }    
        [rows addObject:dataObject];
    }
    sqlite3_finalize(stmt);
    [db closeDatabase];
    return rows;
 }
@end
