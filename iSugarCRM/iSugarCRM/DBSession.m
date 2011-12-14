//
//  DBSession.m
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DBSession.h"
#import "SqliteObj.h"
#import "DataObject.h"

@implementation DBSession
@synthesize delegate,metadata,syncDelegate;

+(DBSession*)sessionWithMetadata:(DBMetadata*)metadata
{
    DBSession *session=[[DBSession alloc] init];
    session.metadata=metadata;
    return session;
}

-(void)startLoading
{
    SqliteObj* db = [[SqliteObj alloc] init];
    NSError* error = nil;
    NSMutableArray *rows = [[NSMutableArray alloc]init];
    if(![db initializeDatabaseWithError:&error]){
        NSLog(@"%@",[error localizedDescription]);
        [delegate session:self listDownloadFailedWithError:error];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ;",metadata.tableName];
    sqlite3_stmt *stmt =[db executeQuery:sql error:&error];
    if (error) {
        NSLog(@"error retrieving data from database: %@",[error localizedDescription]);
        [delegate session:self listDownloadFailedWithError:error];
    }
    while(sqlite3_step(stmt)==SQLITE_ROW){
        DataObject *dataObject = [[DataObject alloc] initWithMetadata:metadata.objectMetadata];
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
            
            if(![dataObject setObject:value forFieldName:[metadata.column_objectFieldMap objectForKey:fieldName]]){
                NSLog(@"No %@ field in data object with specified metadata",fieldName);
            }
        }    
        [rows addObject:dataObject];
    }
    sqlite3_finalize(stmt);
    [db closeDatabase];
    [delegate session:self downloadedModuleList:rows moreComing:NO];
}


-(void)updateDBWithDataObjects:(NSArray*)dataObjects
{
    NSError* error = nil;
    SqliteObj* db = [[SqliteObj alloc] init];
    if(![db initializeDatabaseWithError:&error])
    {
        NSLog(@"%@",[error localizedDescription]);
        [syncDelegate session:self syncFailedWithError:error];
    }
    NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",metadata.tableName];
    BOOL is_first = YES;
    for(NSString *column_name in [metadata.columnNames allObjects]){
        if (is_first) {
            [sql appendString:[NSString stringWithFormat:@"%@ VARCHAR(100)",column_name]];
            is_first = NO;
        }
        else {
            [sql appendString:[NSString stringWithFormat:@", %@ VARCHAR(100)",column_name]];
        }
    }
    [sql appendString:@");"];
    
    if(![db executeUpdate:sql error:&error]){
        NSLog(@"error creating database with sql:%@ and error: %@",sql,[error localizedDescription]);
        [syncDelegate session:self syncFailedWithError:error];
    }
    //ADD OBJECTS NOW
    for(DataObject *dObj in dataObjects){
        NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT INTO %@ (",metadata.tableName];
        NSMutableString *values = [NSMutableString stringWithString:@"VALUES ("];
        BOOL is_first=YES;
        for(NSString *column_name in [[metadata columnNames]allObjects]){
            if (is_first) {
                
                [sql appendString:[NSString stringWithFormat:@"%@",column_name]];
                [values appendString:[NSString stringWithFormat:@"'%@'",[dObj objectForFieldName:column_name]]];
                is_first = NO;
            }
            else{
                [sql appendString:[NSString stringWithFormat:@", %@",column_name]];
                [values appendString:[NSString stringWithFormat:@", '%@'",[dObj objectForFieldName:column_name]]];
            }
        }
        [sql appendString:@")"];
        [values appendString:@");"];
        [sql appendString:values];
        [db executeUpdate:sql error:&error];
        if (error) {
            NSLog(@"error updating database: %@",[error localizedDescription]);
            [syncDelegate session:self syncFailedWithError:error];
        }
    }
    [db closeDatabase];
    [syncDelegate sessionSyncSuccessful:self];
}    




@end
