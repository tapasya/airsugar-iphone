//
//  SqliteObj.m
//  iSugarCRM
//
//  Created by satyavrat-mac on 05/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SqliteObj.h"
#import <sqlite3.h>


@interface SqliteObj ()
-(NSString *)pathToDatabase;
-(void)createEditableCopyOfDatabaseIfNeeded;
@property(assign)sqlite3* database;
@end

NSString* const errorDomain = @"SQLite Database Error Domain";
//static SqliteObj *sharedInstance = nil;
@implementation SqliteObj
@synthesize database;
/*
+(SqliteObj*)sharedInstance{
    if (!sharedInstance) {
        sharedInstance=[[SqliteObj alloc] initPrivate];
    }
    if (!sharedInstance.database) {
        NSError *error=nil;
        if(![sharedInstance initializeDatabaseWithError:&error]){
            NSLog(@"DB error: %@",[error localizedDescription]);
            return nil;
        }
        
    }
    return sharedInstance;
}
-(id)init
{
    NSAssert(NO, @"Cannot instantiate this directly, use sharedInstance");
    return nil;//for warning
}

-(id)initPrivate
{
    self = [super init];
    busyRetryTimeout=0x05;
    return self;
}
*/

-(id)init
{
    self = [super init];
    busyRetryTimeout=0x05;
    return self;
}

-(NSString *)pathToDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex: 0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"CRMDatabase.db"];
    return path;
}

-(void)createEditableCopyOfDatabaseIfNeeded
{
    BOOL success = FALSE;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *writeableDBPath = [self pathToDatabase];
    
    success = [fileManager fileExistsAtPath:writeableDBPath];
    if (!success )
    {
        // database doesn't exist, copy to the users folder 
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CRMDatabase.db"];
        success = [fileManager copyItemAtPath:defaultPath toPath:writeableDBPath error: &error];
        if( !success )
        {  
            NSLog(@"error :%@",[error localizedDescription]);
           // NSAssert1(0, @"failed to create database with err %s", [error localizedDescription]);
        }
    }
}

-(BOOL)initializeDatabaseWithError:(NSError**)error;
{  [self createEditableCopyOfDatabaseIfNeeded];
    NSString *path = [self pathToDatabase];
    int err=sqlite3_open([path UTF8String], &database);
    if ( err == SQLITE_OK)
    {  
        return true;
    }
    else 
    {    if ( NULL != error ) {
        NSString *localizedDescription = [NSString stringWithFormat:@"The database failed to open - sql error %d", err];
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:err], @"code", errorDomain, @"domain", localizedDescription, NSLocalizedDescriptionKey, nil];
        *error = [NSError errorWithDomain:errorDomain code:err userInfo:errorDict];
    }
        //redundant calls allowed
        //cleans up the code
        sqlite3_close(database);
        return false;
    }
}

-(void)closeDatabase
{
    if (database) {
        database=nil;
    }
     sqlite3_close(database);
}

-(sqlite3_stmt*)executeQuery:(NSString*)sql error:(NSError**)error;
{
    
    int rc                  = 0x00;;
    sqlite3_stmt *pStmt     = 0x00;;
    int numberOfRetries = 0;
    BOOL retry          = NO;
    
    if (!pStmt) {
        do {
            retry   = NO;
            rc      = sqlite3_prepare_v2(database, [sql UTF8String], -1, &pStmt, 0);
            
            if (SQLITE_BUSY == rc) {
                retry = YES;
                usleep(20);
                
                if (busyRetryTimeout && (numberOfRetries++ > busyRetryTimeout)) {
                    NSLog(@"Database busy");
                    sqlite3_finalize(pStmt);
                    return nil;
                }
            }
            else if (SQLITE_OK != rc) {
                
                NSString *localizedDescription = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
                NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:rc], @"code", errorDomain, @"domain", localizedDescription, NSLocalizedDescriptionKey, nil];
                *error = [NSError errorWithDomain:errorDomain code:rc userInfo:errorDict];
                    NSLog(@"DB Query: %@", sql);
                }
                
                sqlite3_finalize(pStmt);
            return nil;
        }
        while (retry);
    }
    
        return pStmt;
}

-(BOOL)executeUpdate:(NSString*)sql error:(NSError**)error
{
    int rc                   = 0x00;
    sqlite3_stmt *pStmt      = 0x00;
    int numberOfRetries = 0;
    BOOL retry          = NO;
    if (!pStmt) {
        const char * tempStr = [sql UTF8String];
		int len = strlen(tempStr) + 1;
		char * sqlCStr = malloc(len * (sizeof(char)));
		strcpy(sqlCStr, tempStr);
	        do {
            retry   = NO;
            rc      = sqlite3_prepare_v2(database, sqlCStr, -1, &pStmt, 0);
            if (SQLITE_BUSY == rc) {
                retry = YES;
                usleep(20);
                }
            else if (SQLITE_OK != rc) {
                if ( NULL != error ) {
                    NSString *localizedDescription = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
                    NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:rc], @"code", errorDomain, @"domain", localizedDescription, NSLocalizedDescriptionKey, nil];
                    *error = [NSError errorWithDomain:errorDomain code:rc userInfo:errorDict];
                }
                break;
            }
        }
        while (retry);
		free(sqlCStr);
		if ( SQLITE_OK != rc )
		{
			sqlite3_finalize(pStmt);
			return NO;
		}
    }
        
    numberOfRetries = 0;
    do {
        rc      = sqlite3_step(pStmt);
        retry   = NO;
        
        if (SQLITE_BUSY == rc) {
            retry = YES;
            usleep(20);
            NSLog(@"busy, retry??");
            if (busyRetryTimeout && (numberOfRetries++ > busyRetryTimeout)) {
                NSLog(@"Database busy");
                retry = NO;
            }
        }
        else if (SQLITE_DONE == rc || SQLITE_ROW == rc) {
            // all is well, let's return.
        }
        else if (SQLITE_ERROR == rc) {
            NSString *localizedDescription = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:rc], @"code", errorDomain, @"domain", localizedDescription, NSLocalizedDescriptionKey, nil];
            *error = [NSError errorWithDomain:errorDomain code:rc userInfo:errorDict];
        }
        else if (SQLITE_MISUSE == rc) {
            NSString *localizedDescription = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:rc], @"code", errorDomain, @"domain", localizedDescription, NSLocalizedDescriptionKey, nil];
            *error = [NSError errorWithDomain:errorDomain code:rc userInfo:errorDict];
        }
        else {
            NSString *localizedDescription = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:rc], @"code", errorDomain, @"domain", localizedDescription, NSLocalizedDescriptionKey, nil];
            *error = [NSError errorWithDomain:errorDomain code:rc userInfo:errorDict];
        }
        
    } while (retry);
    rc = sqlite3_finalize(pStmt);
    return (rc == SQLITE_OK);

}
@end
