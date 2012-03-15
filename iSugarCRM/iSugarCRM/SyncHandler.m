//
//  SyncHandler.m
//  iSugarCRM
//
//  Created by satyavrat-mac on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
/*
 1. Create operations with all dirty records in the db
 1. Upload the data in the queue
 2. Download the data
 */

#import "SyncHandler.h"
#import "SugarCRMMetadataStore.h"
#import "Reachability.h"
NSString* const NetworkRequestErrorDomain = @"HTTPRequestErrorDomain";
static SyncHandler *sharedInstance;
@interface SyncHandler ()
@property (strong) NSOperationQueue *requestQueue;
-(id)initPrivate;
-(NSString*)formatDate:(NSString*)date;
@property (assign) NSInteger requestCount;
@end

@implementation SyncHandler
@synthesize requestQueue = mRequestQueue;
@synthesize isCancelled;
@synthesize hadError;
@synthesize requestCount;
@synthesize delegate;
#pragma mark Singleton methods

-(id)init{
    NSAssert(NO, @"Cannot instantiate this directly, use sharedInstance");
    return nil;
}
+(SyncHandler*)sharedInstance{
    @synchronized(self){
        if(sharedInstance == nil){
            sharedInstance = [[SyncHandler alloc] initPrivate];
        }
        return sharedInstance;
    }
}

- (id)copyWithZone:(NSZone *)zone 
{ 
    return self; 
}

-(id)initPrivate{
    self = [super init];
    self.requestQueue = [[NSOperationQueue alloc] init];
    //self.requestQueue.maxConcurrentOperationCount = 8;
    return self;
}



#pragma mark Complete Sync Methods

//for all complete syn methods: create add functionality to take all the dirty records in db and sync
-(void)runCompleteSync
{   
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    for(NSString *module in metadataStore.modulesSupported)
    {
        [self runSyncForModule:module parent:nil];
    }
}

-(void)runCompleteSyncWithStartDate:(NSString*)startDate endDate:(NSString*)endDate
{
    
    startDate = [self formatDate:startDate];
    endDate = [self formatDate:endDate];
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    for(NSString *module in metadataStore.modulesSupported)
    {
        [self runSyncForModule:module startDate:startDate endDate:endDate parent:nil];
        
    }
}
-(void)runCompleteSyncWithTimestamp{
    
    //TODO:
    
}
-(void)runCompleteSyncWithTimestampAndStartDate:(NSString*)startDate endDate:(NSString*)endDate{
    
    //TODO:
}
#pragma mark Module Sync Methods
-(void)uploadData:(NSDictionary*)uploadData forModule:(NSString*)module parent:(id)parent{
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_writeMetadataForModule:module]];
    session.delegate = self;
    session.parent = parent;
    session.syncAction = kWrite;
    session.uploadData = uploadData;
    [session startUploading];
    
}
-(void)runSyncForModule:(NSString*)module parent:(id)parent
{
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_readMetadataForModule:module]];
    session.delegate = self;
    session.parent = parent;
    [session startLoading:nil];
}


-(void)runSyncForModule:(NSString*)module startDate:(NSString*)startDate endDate:(NSString*) endDate parent:(id)parent
{
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_readMetadataForModule:module]];
    session.syncAction = kRead;
    session.delegate = self;
    session.parent = parent;
    [session startLoadingWithStartDate:startDate endDate:endDate];    
}


-(void)runSyncWithTimestampForModule:(NSString*)module parent:(id)parent{
    //TODO:
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    DBSession *dbSession = [DBSession sessionWithMetadata:[metadataStore dbMetadataForModule:module]];
    NSString* deltaMark = [dbSession getLastSyncTimestamp];
    WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_readMetadataForModule:module]];
    session.delegate = self;
    session.parent = parent;
    [session startLoading:deltaMark];
}

-(void)runSyncWithTimestampForModule:(NSString*)module startDate:(NSString*)startDate endDate:(NSString*) endDate parent:(id)parent{
    //TODO:
}

-(void)addSyncSession:(WebserviceSession *)session{
    NSLog(@"operation count = %d",[self.requestQueue operationCount]);
    [self.requestQueue addOperation:session];
}

#pragma mark Db Sync Session delegate methods
-(void)session:(DBSession*)session syncFailedWithError:(NSError*)error
{
    @synchronized([self class]){
        if ([self.requestQueue operationCount]== 1) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SugarSyncComplete" object:nil];
            [delegate syncHandler:self failedWithError:error];
        }
        
        [session.parent syncHandler:self failedWithError:error];
    }
}

-(void)sessionSyncSuccessful:(DBSession*)session;
{   
    @synchronized([self class]){
        if ([self.requestQueue operationCount]== 1) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SugarSyncComplete" object:nil];
            [delegate syncComplete:self];
        }
        //ADD notification for each module.
        [session.parent syncComplete:self];
    }
}

#pragma mark Webservice Session delegate methods

-(void)session:(WebserviceSession*)session didCompleteDownloadWithResponse:(id)response
{  
    @synchronized([self class])
    {   
        SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
        DBMetadata *metadata = [sharedInstance dbMetadataForModule:session.metadata.moduleName];
        DBSession *dbSession = [DBSession sessionWithMetadata:metadata];
        dbSession.syncDelegate = self;
        dbSession.parent = session.parent;
        [dbSession insertDataObjects:response];
    }
}

-(void)session:(WebserviceSession*)session didFailWithError:(NSError*)error
{ @synchronized([self class]){
    NSLog(@"Error syncing data: %@",[error localizedDescription]);
    if (session.syncAction == kRead) {
        
    }
    else {
        SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
        DBMetadata *metadata = [sharedInstance dbMetadataForModule:session.metadata.moduleName];
        DBSession *dbSession = [DBSession sessionWithMetadata:metadata];
        dbSession.syncDelegate = self;
        dbSession.parent = session.parent;
        [dbSession insertDataObjects:nil];
        }
    }
}

#pragma mark Utility

//move this method to utils
-(NSString *) formatDate:(NSString *)date
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
- (BOOL)reachabilityCheck:(NSError**)error {
    
	BOOL reachable = YES;
	NSError* localError = nil;
    if ( NULL == error )
		*error = localError;
	/** Check first line of reachability **/
    NSString *hostName = [[NSUserDefaults standardUserDefaults] objectForKey:@"sugarEndPoint"];
	Reachability *internetReach = [Reachability reachabilityWithHostName:hostName];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    
	// No internet connection, die right away
	if ( netStatus == kNotReachable ) {
		*error = [NSError errorWithDomain:NetworkRequestErrorDomain 
                                     code:kNotReachable 
                                 userInfo:[NSDictionary 
                                           dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
		reachable = NO;
	}
    
	return reachable;
}
@end
