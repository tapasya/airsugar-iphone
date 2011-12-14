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
@implementation SyncHandler
@synthesize delegate;
-(void)syncForModule
{
    
}

-(void)syncForModules:(NSArray*)modules
{
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
   // for(NSString *module in modules)
    //{
        WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore listServiceMetadataForModule:@"Accounts"]];
        session.delegate=self;
        [session startLoading ];
        
        
   // }
}

#pragma mark Webservice Session delegate methods
-(void)sessionWillStartLoading:(WebserviceSession*)session
{
    
}
-(void)session:(WebserviceSession*)session didCompleteWithResponse:(id)response
{  @synchronized([self class])
    {
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
        NSLog(@"table name %@",session.metadata.moduleName);
    DBSession *dbSession = [DBSession sessionWithMetadata:[sharedInstance dbMetadataForModule:session.metadata.moduleName]];
    dbSession.syncDelegate = self;
    [dbSession updateDBWithDataObjects:response];
    }
}
-(void)session:(WebserviceSession*)session didFailWithError:(NSError*)error
{
    NSLog(@"Error syncing data: %@",[error localizedDescription]);
}

#pragma mark Db Sync Session delegate methods
-(void)session:(DBSession*)session syncFailedWithError:(NSError*)error
{
     NSLog(@"Sync failed for module: %@ with error: %@",session.metadata.tableName,[error localizedDescription]);
}
-(void)sessionSyncSuccessful:(DBSession*)session;
{
    NSLog(@"Sync succesfull for module: %@",session.metadata.tableName);
    [delegate syncComplete:self];
}
@end
