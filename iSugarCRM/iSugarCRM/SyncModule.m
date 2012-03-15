//
//  SyncModule.m
//  iSugarCRM
//
//  Created by satyavrat-mac on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncModule.h"
#import "WebserviceSession.h"
#import "SyncHandler.h"
@implementation SyncModule
@synthesize action,moduleName,parent,data,startDate,endDate;

+(SyncModule*)syncModuleWithName:(NSString*)name action:(NSInteger)action data:(NSDictionary*)data parent:(id)parent startDate:(NSString*)startDate endDate:(NSString*)endDate
{
    SyncModule *syncModule = [[SyncModule alloc]init];
    syncModule.action = action;
    syncModule.data = data;
    syncModule.parent = parent;
    syncModule.moduleName = name;
    syncModule.startDate = startDate;
    syncModule.endDate = endDate;
    if (action==kRead) {
        
    }
    __weak SyncModule* sm = syncModule; //to break the retain cycle
    [syncModule setCompletionBlock:^(void){
        if (sm.isCancelled) {
            if ([parent respondsToSelector:@selector(operationCancelled)]) {
                [parent operationCancelled];   
            }    
        }
        if ([parent respondsToSelector:@selector(operationCompleted)]) {
            [parent operationCompleted];   
        }
    }];
    return syncModule;
}
-(void)main{
    if (action == kRead) {
        SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
        WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_readMetadataForModule:moduleName]];
        SyncHandler *syncHandler = [SyncHandler sharedInstance];
        session.delegate = syncHandler;
        //TODO: check for nil start & end date
        [session startLoadingWithStartDate:self.startDate endDate:self.endDate]; 
        
    }
    else if (action == kWrite){
        SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
        WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_writeMetadataForModule:moduleName]];
        SyncHandler *syncHandler = [SyncHandler sharedInstance];
        session.delegate = syncHandler;
        [session startLoadingWithData:data]; 
        
    }
}


#pragma mark Db Sync Session delegate methods
-(void)session:(DBSession*)session syncFailedWithError:(NSError*)error
{
    @synchronized([self class]){
        NSLog(@"Sync failed for module: %@ with error: %@",session.metadata.tableName,[error localizedDescription]);
      //  [parent syncHandler:self failedWithError:error];
       // [self.operationQueue cancelAllOperations];
    }
}

-(void)sessionSyncSuccessful:(DBSession*)session;
{   
    @synchronized([self class]){
        NSLog(@"Sync succesfull for module: %@",session.metadata.tableName);
       // [parent syncComplete:self];
    //    if (self.operationQueue.operationCount == 0) {
     //       [[NSNotificationCenter defaultCenter] postNotificationName:@"SugarSyncComplete" object:nil];
     //   }
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
    //[self.operationQueue cancelAllOperations];
}


-(void)cancel{
    [super cancel];
}
-(void)postSuccessNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@Success",moduleName] object:self];
}
-(void)postFailureNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@Failure",moduleName] object:self];
}
@end
