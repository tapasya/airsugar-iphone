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

@interface DBSession()
-(void)getTableRows;
@end

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
    NSMutableArray *rows = nil;
    if(![db initializeDatabaseWithError:&error]){
        NSLog(@"%@",[error localizedDescription]);
        [delegate listDownloadFailedWithError:error];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ;",metadata.tableName];
    sqlite3_stmt *stmt =[db executeQuery:sql error:&error];
    if (error) {
        NSLog(@"error retrieving data from database: %@",[error localizedDescription]);
        [delegate listDownloadFailedWithError:error];
    }
    while(sqlite3_step(stmt)==SQLITE_ROW){
        DataObject *dataObject = [[DataObject alloc] initWithMetadata:metadata.objectMetadata];
        int columnCount = sqlite3_column_count(stmt);
        int columnIdx=0;
        for (columnIdx=0;columnIdx<columnCount;columnIdx++) 
        {
            NSString* fieldName = [metadata.column_objectFieldMap objectForKey:[[NSString stringWithUTF8String:sqlite3_column_name(stmt, columnIdx)] lowercaseString]];
            NSString *value = [NSString stringWithUTF8String:sqlite3_column_text16(stmt, columnIdx)];
            [dataObject setObject:value forFieldName:fieldName];
        }    
        [rows addObject:dataObject];
    }
    sqlite3_finalize(stmt);
    [db closeDatabase];
    [delegate downloadedModuleList:rows moreComing:NO];
}


-(void)updateDBWithDataObjects:(NSArray*)dataObjects
{
    
    NSError* error = nil;
    SqliteObj* db = [[SqliteObj alloc] init];
    if(![db initializeDatabaseWithError:&error])
    {
        NSLog(@"%@",[error localizedDescription]);
        [syncDelegate syncFailedWithError:error];
    }
  
        NSMutableDictionary* colName_idxMap = [[NSMutableDictionary alloc]init];
        NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",metadata.tableName];
        int index = 0;
        BOOL is_first = YES;
        for(NSString *column_name in [metadata.columnNames allObjects]){
            if (is_first) {
                [colName_idxMap setObject:column_name forKey:[NSNumber numberWithInt:++index]];
                [sql appendString:[NSString stringWithFormat:@"%@ VARCHAR(100)",column_name]];
                is_first = NO;
            }
            else{
            [colName_idxMap setObject:column_name forKey:[NSNumber numberWithInt:++index]];
            [sql appendString:[NSString stringWithFormat:@", %@ VARCHAR(100)",column_name]];
            }
        }
        [sql appendString:@");"];
        
        if(![db executeUpdate:sql error:&error]){
            NSLog(@"error creating database with sql:%@ and error: %@",sql,[error localizedDescription]);
            [syncDelegate syncFailedWithError:error];
        }
            metadata.column_columnIdxInTableMap=colName_idxMap;

    NSLog(@"column name number map: %@",metadata.column_columnIdxInTableMap);
    //ADD OBJECTS NOW
    for(DataObject *dObj in dataObjects){
        NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT INTO %@ (",metadata.tableName];
        NSMutableString *values =[NSMutableString stringWithString:@"VALUES ("];
        int count = 1;
        BOOL is_first=YES;
        for (count=1; count<[[[metadata columnNames]allObjects]count]; count++) {
            if (is_first) {
                NSString *column_name = [metadata.column_columnIdxInTableMap objectForKey:[NSNumber numberWithInt:count]];
                [sql appendString:[NSString stringWithFormat:@"%@",column_name]];
                [values appendString:[NSString stringWithFormat:@"'%@'",[dObj objectForFieldName:[metadata.column_objectFieldMap objectForKey:column_name]]]];
                is_first=NO;
            }
            else{
            NSString *column_name = [metadata.column_columnIdxInTableMap objectForKey:[NSNumber numberWithInt:count]];
            [sql appendString:[NSString stringWithFormat:@", %@",column_name]];
            [values appendString:[NSString stringWithFormat:@", '%@'",[dObj objectForFieldName:[metadata.column_objectFieldMap objectForKey:column_name]]]];
            }
        }
        [sql appendString:@")"];
        [values appendString:@");"];
        [sql appendString:values];
        [db executeUpdate:sql error:&error];
        if (error) {
            NSLog(@"error updating database: %@",[error localizedDescription]);
            [syncDelegate syncFailedWithError:error];
        }
    }
    [db closeDatabase];
    [syncDelegate syncSuccessful];
}    




@end
