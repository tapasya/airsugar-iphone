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
    WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore listWebserviceMetadataForModule:module]];
    session.delegate=self;
    [session startLoading];
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
        if (--moduleCount==0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SugarSyncComplete" object:nil];
        }
    }
}
@end
