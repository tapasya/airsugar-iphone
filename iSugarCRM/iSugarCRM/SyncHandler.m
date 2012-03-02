//
//  SyncHandler.m
//  iSugarCRM
//
//  Created by satyavrat-mac on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SyncHandler.h"
#import "SugarCRMMetadataStore.h"
//static SyncHandler *sharedInstance;
NSInteger moduleCount = 1;
@implementation SyncHandler
@synthesize delegate;

-(void)syncForModule:(NSString*)module
{
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    DBSession *dbSession = [DBSession sessionWithMetadata:[metadataStore dbMetadataForModule:module]];
    NSString* deltaMark = [dbSession getLastSyncTimestamp];
    WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_ReadMetadataForModule:module]];
    session.delegate=self;
    [session startLoading:deltaMark];
}


-(void)syncAllModules
{   
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    moduleCount = [metadataStore.modulesSupported count];
    for(NSString *module in metadataStore.modulesSupported)
    {
        [self syncForModule:module];
    }
}

-(void)syncWithStartDate:(NSString*)startDate endDate:(NSString*)endDate;
{
    startDate = [self formatStartDate:startDate];
    endDate = [self formatStartDate:endDate];
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    moduleCount = [metadataStore.modulesSupported count];
    for(NSString *module in metadataStore.modulesSupported)
    {
        [self syncModule:module startDate:startDate endDate:endDate];
        
    }
}

-(void)syncModule:(NSString*)moduleName startDate:(NSString*)startDate endDate:(NSString*) endDate;
{
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_ReadMetadataForModule:moduleName]];
    session.delegate=self;
    [session startLoadingWithFilters:startDate :endDate];    
}

-(NSString *) formatStartDate:(NSString *)date
{    
    NSDateFormatter *dateFormatter;
    
    if(date == nil){
        date = [[[[NSDate date] description]componentsSeparatedByString:@" "] objectAtIndex:0];
    }else{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        NSLog(@"datefromString %@",[dateFormatter dateFromString:date]);
        date = [[[[dateFormatter dateFromString:date] description] componentsSeparatedByString:@" "] objectAtIndex:0];
    }
    
    return date;
}

#pragma mark Webservice Session delegate methods

-(void)session:(WebserviceSession*)session didCompleteWithResponse:(id)response
{  
    @synchronized([self class])
    {   
        SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
        DBMetadata *metadata = [sharedInstance dbMetadataForModule:session.metadata.moduleName];
        DBSession *dbSession = [DBSession sessionWithMetadata:metadata];
        dbSession.syncDelegate = self;
        [dbSession updateDBWithDataObjects:response];
    }
}

-(void)session:(WebserviceSession*)session didFailWithError:(NSError*)error
{
    NSLog(@"Error syncing data: %@",[error localizedDescription]);
    moduleCount--;
}

#pragma mark Db Sync Session delegate methods
-(void)session:(DBSession*)session syncFailedWithError:(NSError*)error
{
    @synchronized([self class]){
        NSLog(@"Sync failed for module: %@ with error: %@",session.metadata.tableName,[error localizedDescription]);
        moduleCount--;
        [delegate syncHandler:self failedWithError:error];
    }
}

-(void)sessionSyncSuccessful:(DBSession*)session;
{   
    @synchronized([self class]){
        NSLog(@"Sync succesfull for module: %@",session.metadata.tableName);
        [delegate syncComplete:self];
        NSLog(@"module count is %d",moduleCount);
        if (moduleCount==1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SugarSyncComplete" object:nil];
        }
        moduleCount--;
    }
}

@end
