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
@interface DBSession ()

-(BOOL)checkIfBeanExists:(DataObject*)bean inDatabase:(SqliteObj*)db;
@end
@implementation DBSession
@synthesize delegate,metadata,syncDelegate,parent;

+(DBSession*)sessionWithMetadata:(DBMetadata*)metadata
{
    DBSession *session=[[DBSession alloc] init];
    session.metadata=metadata;
    return session;
}

#pragma mark Read Methods
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
        DataObject *dataObject = [[DataObject alloc] initWithMetadata:[[SugarCRMMetadataStore sharedInstance] objectMetadataForModule:self.metadata.tableName]];
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
                if(![dataObject setObject:value forFieldName:[metadata.column_objectFieldMap objectForKey:fieldName]]){
                    NSLog(@"No %@ field in data object with specified metadata",fieldName);
                }
            }
        }    
        [rows addObject:dataObject];
    }
    sqlite3_finalize(stmt);
    [db closeDatabase];
    [delegate session:self downloadedModuleList:rows moreComing:NO];
}

-(void)loadDetailsForId:(NSString *)beanId
{
    SqliteObj* db = [[SqliteObj alloc] init];
    NSError* error = nil;
    NSMutableArray *rows = [[NSMutableArray alloc]init];
    if(![db initializeDatabaseWithError:&error]){
        NSLog(@"%@",[error localizedDescription]);
        [delegate session:self detailDownloadFailedWithError:error];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id is '%@';",metadata.tableName,beanId];
    sqlite3_stmt *stmt =[db executeQuery:sql error:&error];
    if (error) {
        NSLog(@"error retrieving data from database: %@",[error localizedDescription]);
        [delegate session:self detailDownloadFailedWithError:error];
    }
    while(sqlite3_step(stmt)==SQLITE_ROW){
        DataObject *dataObject = [[DataObject alloc] initWithMetadata:[[SugarCRMMetadataStore sharedInstance] objectMetadataForModule:self.metadata.tableName]];
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
            if(![dataObject setObject:value forFieldName:[metadata.column_objectFieldMap objectForKey:fieldName]]){
                NSLog(@"No %@ field in data object with specified metadata",fieldName);
            }
            }    
        }
        [rows addObject:dataObject];
    }
    sqlite3_finalize(stmt);
    [db closeDatabase];
    [delegate session:self downloadedDetails:rows];
    
}
#pragma mark Write Methods
//remove method, will be used only in case of custom modules.
-(BOOL)checkAndCreateTable:(SqliteObj*)db{
    
    NSError* error = nil;
    if(![db initializeDatabaseWithError:&error])
    {
        NSLog(@"%@",[error localizedDescription]);
        [syncDelegate session:self syncFailedWithError:error];
    }
    NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",metadata.tableName];
    BOOL is_first = YES;
    for(NSString *column_name in [metadata.columnNames allObjects])
    {
        if (is_first) 
        {
            [sql appendString:[NSString stringWithFormat:@"%@ VARCHAR(100)",column_name]];
            is_first = NO;
        } else {
            [sql appendString:[NSString stringWithFormat:@", %@ VARCHAR(100)",column_name]];
        }
    }
    [sql appendString:@", dirty INTEGER"];
    [sql appendString:@", PRIMARY KEY (id));"];
    
    if(![db executeUpdate:sql error:&error]){
        NSLog(@"error creating database with sql:%@ and error: %@",sql,[error localizedDescription]);
        [syncDelegate session:self syncFailedWithError:error];
        return NO;
    }
    return YES;
}

-(BOOL)checkIfBeanExists:(DataObject*)bean inDatabase:(SqliteObj*)db{
    BOOL beanExists = YES;
    NSError* error = nil;
    NSLog(@"check bean for id: %@",[bean objectForFieldName:@"id"]);
    NSMutableString *sql = [NSMutableString stringWithFormat:@"Select * from %@ where id = '%@';",metadata.tableName,[bean objectForFieldName:@"id"]];
    
    sqlite3_stmt *stmt =[db executeQuery:sql error:&error];
    if (error) {
        beanExists = NO;
        NSLog(@"error retrieving data from database: %@",[error localizedDescription]);
        [delegate session:self listDownloadFailedWithError:error];
    }
    
    if(sqlite3_step(stmt)==SQLITE_ROW){
        beanExists = YES;  
        NSLog(@"bean exist in db. updating now.");
    }
    else{
        NSLog(@"bean does not exist in db. inserting now.");
        beanExists = NO;
    }
    sqlite3_finalize(stmt);
    return beanExists;
}

-(BOOL)updateDatabase:(SqliteObj*)db withBean:(DataObject*)bean error:(NSError*)error dirty:(BOOL)dirty
{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ set",metadata.tableName];
    int count = 0;
    for(NSString *column in metadata.columnNames){
        if (++count==1) {
            [sql appendFormat:@"%@ = %@",column,[bean objectForFieldName:[[metadata column_objectFieldMap]objectForKey:column]]];      
        }
        else{
            [sql appendFormat:@",%@ = %@",column,[bean objectForFieldName:[[metadata column_objectFieldMap]objectForKey:column]]];
        }
    }
    [sql appendString:[NSString stringWithFormat:@"dirty = %@;",dirty]];
    BOOL success = [db executeUpdate:sql error:&error];
    if (success) {
        NSLog(@"error updating database: %@",[error localizedDescription]);
        // [syncDelegate session:self syncFailedWithError:error];
    }
    return success;
}
-(BOOL)insertBean:(DataObject*)bean inDatabase:(SqliteObj*)db error:(NSError*)error dirty:(BOOL)dirty{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ (",metadata.tableName];
    NSMutableString *values = [NSMutableString stringWithString:@"VALUES ("];
    BOOL is_first=YES;
    for(NSString *column_name in [[metadata columnNames]allObjects]){
        NSString* value = [bean objectForFieldName:column_name];
        if ([column_name isEqualToString:@"date_modified"]) {
            if(!value){
                //TODO add current timestamp;
            }
        }
        if (is_first) 
        {
            [sql appendString:[NSString stringWithFormat:@"%@",column_name]];
            [values appendString:[NSString stringWithFormat:@"'%@'",value]];
            is_first = NO;
        } else {
            [sql appendString:[NSString stringWithFormat:@", %@",column_name]];
            [values appendString:[NSString stringWithFormat:@", '%@'",value]];
        }
    }
    if (dirty) {
        [sql appendString:@"dirty"];
        [values appendString:[NSString stringWithFormat:@"%@",[NSNumber numberWithBool:dirty]]];
    }
    [sql appendString:@")"];
    [values appendString:@");"];
    [sql appendString:values];
    BOOL success = [db executeUpdate:sql error:&error];
    if (success) {
        NSLog(@"error inserting in database: %@",[error localizedDescription]);
        // [syncDelegate session:self syncFailedWithError:error];
    }
    return success;
    
}

//fails if even one of the updates/inserts fail
-(void)insertDataObjectsInDb:(NSArray *)dataObjects dirty:(BOOL)dirty
{
    BOOL success = NO;
    NSError *error = nil;
    SqliteObj* db = [[SqliteObj alloc] init];
    if ([self checkAndCreateTable:db]){
        for (DataObject *bean in dataObjects)
        {
            if( [self checkIfBeanExists:bean inDatabase:db]){
                success = [self updateDatabase:db withBean:bean error:error dirty:dirty];
                if (success == NO) {
                    break;
                }
            } else {  
                //ADD OBJECTS NOW
                success = [self insertBean:bean inDatabase:db error:error dirty:dirty];
                if (success == NO) {
                    break;
                }
            }
        }
        if (success == NO) {
            [syncDelegate session:self syncFailedWithError:error];
        } else {
            [syncDelegate sessionSyncSuccessful:self];    
        }
        [db closeDatabase];
    } else {
        [db closeDatabase]; //is really open? check?
    }
}

-(NSString*)getLastSyncTimestamp
{
    SqliteObj* db = [[SqliteObj alloc] init];
    NSError* error = nil;
    NSString *deltaMark;
    if(![db initializeDatabaseWithError:&error])
    {
        NSLog(@"%@",[error localizedDescription]);
        [delegate session:self listDownloadFailedWithError:error];
    }
    //TODO: use mapping b/w fields and column name
    NSString *sql = [NSString stringWithFormat:@"SELECT date_modified FROM %@ ORDER BY date_modified DESC LIMIT 1;",metadata.tableName];
    sqlite3_stmt *stmt =[db executeQuery:sql error:&error];
    if (error) {
        NSLog(@"error retrieving timestamp from database: %@",[error localizedDescription]);
    }
    if(sqlite3_step(stmt)==SQLITE_ROW)
    {
        char *field_value = (char*)sqlite3_column_text(stmt, 0);
        if (field_value!=NULL) 
        {
            deltaMark = [NSString stringWithFormat:@"%s",field_value];
        }
    }    
    sqlite3_finalize(stmt);
    [db closeDatabase];
    return deltaMark;
}

-(BOOL) deleteRecord:(NSString *)beanId
{
    NSError* error = nil;
    SqliteObj* db = [[SqliteObj alloc] init];
    if(![db initializeDatabaseWithError:&error]){
        NSLog(@"%@",[error localizedDescription]);
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE id is '%@'",metadata.tableName, beanId];
    [db executeUpdate:sql error:&error];
    if(error)
    {
        NSLog(@"error deleting record in table: %@",[error localizedDescription]);
    }
    else
    {
        NSLog(@"deleted record with beanId: %@" , beanId);
    }
    return error == nil ;
}

-(BOOL) deleteAllRecordsInTable
{
    NSError* error = nil;
    SqliteObj* db = [[SqliteObj alloc] init];
    if(![db initializeDatabaseWithError:&error]){
        NSLog(@"%@",[error localizedDescription]);
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@",metadata.tableName];
    [db executeUpdate:sql error:&error];
    if(error)
    {
        NSLog(@"error deleting records in table: %@",[error localizedDescription]);
    }
    return error == nil ;
}
@end
