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
#import "DataObject.h"
#import "LoginUtils.h"
#import "ConnectivityChecker.h"

NSString* const NetworkRequestErrorDomain = @"HTTPRequestErrorDomain";
static SyncHandler *sharedInstance;
@interface SyncHandler ()
@property (strong) NSOperationQueue *requestQueue;
-(id)initPrivate;
-(void)postSyncnotification;
-(NSString*)formatDate:(NSString*)date;
@property (assign) NSInteger requestCount;
@end

@implementation SyncHandler
@synthesize requestQueue = mRequestQueue;
@synthesize isCancelled;
@synthesize hadError;
@synthesize requestCount;
@synthesize delegate;
@synthesize skipSeamlessLogin;
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
        //sharedInstance.skipSeamlessLogin = true;
        sharedInstance.delegate = nil;
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
    //remove later
    self.requestQueue.maxConcurrentOperationCount = 1;
    return self;

}

-(BOOL) isSeamlessloginSuccessfull
{
    if (!self.skipSeamlessLogin) {
        self.skipSeamlessLogin = [LoginUtils seamLessLogin];
    }
    return self.skipSeamlessLogin;
}

#pragma mark Complete Sync Methods

//for all complete syn methods: create add functionality to take all the dirty records in db and sync
-(void)runCompleteSync
{   
    NSError* error;
    if (![[ConnectivityChecker singletonObject] isNetworkReachable]) 
    {
        error = [NSError errorWithDomain:NetworkRequestErrorDomain 
                                    code:NotReachable 
                                userInfo:[NSDictionary 
                                          dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
        [self session:nil didFailWithError:error];
        return ;
    }
    else
    {    
        if (![self isSeamlessloginSuccessfull]) 
            return;
        
        SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
        for(NSString *module in metadataStore.modulesSupported)
        {
            [self runSyncForModule:module parent:nil];
        }
    }
}

-(void)runCompleteSyncWithStartDate:(NSString*)startDate endDate:(NSString*)endDate
{
    NSError* error;
    if (![[ConnectivityChecker singletonObject] isNetworkReachable]) 
    {
        error = [NSError errorWithDomain:NetworkRequestErrorDomain 
                                    code:NotReachable 
                                userInfo:[NSDictionary 
                                          dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
        [self session:nil didFailWithError:error];
        return ;
    }
    else
    {  
        if (![self isSeamlessloginSuccessfull]) 
            return;
        
        startDate = [self formatDate:startDate];
        endDate = [self formatDate:endDate];
        SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
        for(NSString *module in metadataStore.modulesSupported){
            [self runSyncForModule:module startDate:startDate endDate:endDate parent:nil];
        }
    }
}
-(void)runCompleteSyncWithTimestamp{
    
    //TODO:
    
}
-(void)runCompleteSyncWithTimestampAndStartDate:(NSString*)startDate endDate:(NSString*)endDate{
    NSError* error;
    if (![[ConnectivityChecker singletonObject] isNetworkReachable]) 
    {
        error = [NSError errorWithDomain:NetworkRequestErrorDomain 
                                    code:NotReachable 
                                userInfo:[NSDictionary 
                                          dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
        [self session:nil didFailWithError:error];
        return ;
    }
    else
    {  
        if (![self isSeamlessloginSuccessfull]) 
            return;
        
        startDate = [self formatDate:startDate];
        endDate = [self formatDate:endDate];
        SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
        for(NSString *module in metadataStore.modulesSupported){
            [self runSyncWithTimestampForModule:module startDate:startDate endDate:endDate parent:nil];
        }
    }
}
#pragma mark Module Sync Methods
-(void)uploadData:(NSArray*)uploadData forModule:(NSString*)module parent:(id)parent
{     
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_writeMetadataForModule:module]];
    session.delegate = self;
    session.parent = parent;
    session.syncAction = kWrite;    
    session.uploadDataObjects = uploadData;
    NSError* error;
    if (![[ConnectivityChecker singletonObject] isNetworkReachable]) 
    {
        error = [NSError errorWithDomain:NetworkRequestErrorDomain 
                                    code:NotReachable 
                                userInfo:[NSDictionary 
                                          dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
        [self session:session didFailWithError:error];
        return ;
    }
    else
    {  
        if (![self isSeamlessloginSuccessfull]) 
            return;
        
        session.queuePriority = NSOperationQueuePriorityHigh;
        [session startUploading];
    }
}
-(void)runSyncForModule:(NSString*)module parent:(id)parent
{
    NSError* error;
    if (![[ConnectivityChecker singletonObject] isNetworkReachable]) 
    {
        error = [NSError errorWithDomain:NetworkRequestErrorDomain 
                                    code:NotReachable 
                                userInfo:[NSDictionary 
                                          dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
        [parent syncHandler:self failedWithError:error];
        return ;
    }
    else
    {  
        if (![self isSeamlessloginSuccessfull]) 
            return;
        
        SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
        //create upload session
        
        DBSession *dbSession = [DBSession sessionWithMetadata:[metadataStore dbMetadataForModule:module]];
        NSArray* uploadData = [dbSession getUploadData];
        if ([uploadData count] > 0) {
        [self uploadData:uploadData forModule:module parent:parent];    
        }
        
        //create download session
        WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_readMetadataForModule:module]];
        session.delegate = self;
        session.parent = parent;
        [session startLoading:nil];
    }
}


-(void)runSyncForModule:(NSString*)module startDate:(NSString*)startDate endDate:(NSString*) endDate parent:(id)parent
{
    NSError* error;
    if (![[ConnectivityChecker singletonObject] isNetworkReachable]) 
    {
        error = [NSError errorWithDomain:NetworkRequestErrorDomain 
                                    code:NotReachable 
                                userInfo:[NSDictionary 
                                          dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
        [parent syncHandler:self failedWithError:error];
        return ;
    }
    else
    {  
        if (![self isSeamlessloginSuccessfull]) 
            return;

        SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
        //create upload session
        DBSession *dbSession = [DBSession sessionWithMetadata:[metadataStore dbMetadataForModule:module]];
        NSArray* uploadData = [dbSession getUploadData];
        if ([uploadData count]>0) {
            [self uploadData:uploadData forModule:module parent:parent];    
        }

        //create download session
        WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_readMetadataForModule:module]];
        session.syncAction = kRead;
        session.delegate = self;
        session.parent = parent;
        [session startLoadingWithStartDate:startDate endDate:endDate];    
    }
}


-(void)runSyncWithTimestampForModule:(NSString*)module parent:(id)parent
{
    NSError* error;
    if (![[ConnectivityChecker singletonObject] isNetworkReachable]) 
    {
        error = [NSError errorWithDomain:NetworkRequestErrorDomain 
                                    code:NotReachable 
                                userInfo:[NSDictionary 
                                          dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
        [parent syncHandler:self failedWithError:error];        
        return ;
    }
    else
    {  
        if (![self isSeamlessloginSuccessfull]) 
            return;
        
        SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
        DBSession *dbSession = [DBSession sessionWithMetadata:[metadataStore dbMetadataForModule:module]];
        
        NSString* deltaMark = [dbSession getLastSyncTimestamp];
        
        //create upload session
        NSArray* uploadData = [dbSession getUploadData];
        if ([uploadData count]>0) {
            [self uploadData:uploadData forModule:module parent:parent];    
        }
        //create download session
        WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_readMetadataForModule:module]];
        session.delegate = self;
        session.parent = parent;
        session.syncAction = kRead;
        [session startLoading:deltaMark];
    }
}

-(void)runSyncWithTimestampForModule:(NSString*)module startDate:(NSString*)startDate endDate:(NSString*) endDate parent:(id)parent
{
    NSError* error;
    if (![[ConnectivityChecker singletonObject] isNetworkReachable]) 
    {
        error = [NSError errorWithDomain:NetworkRequestErrorDomain 
                                    code:NotReachable 
                                userInfo:[NSDictionary 
                                          dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
        [parent syncHandler:self failedWithError:error];
        return;
    }
    else
    {  
        if (![self isSeamlessloginSuccessfull]) 
            return;
        
        SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
        DBSession *dbSession = [DBSession sessionWithMetadata:[metadataStore dbMetadataForModule:module]];

        NSString* deltaMark = [dbSession getLastSyncTimestamp];
        //create upload session
        NSArray* uploadData = [dbSession getUploadData];
        if ([uploadData count]>0) {
            [self uploadData:uploadData forModule:module parent:parent];    
        }
        //create download session
        WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_readMetadataForModule:module]];
        session.delegate = self;
        session.parent = parent;
        session.syncAction = kRead;
        [session startLoadingWithTimestamp:deltaMark startDate:startDate endDate:endDate];
    }
}

-(void)addSyncSession:(WebserviceSession *)session{
    NSLog(@"operation count = %d",[self.requestQueue operationCount]);
    [self.requestQueue addOperation:session];
}

#pragma mark Db Sync Session delegate methods
-(void)session:(DBSession*)session syncFailedWithError:(NSError*)error
{
    @synchronized([self class]){
        [self postSyncnotification];
        [session.parent syncHandler:self failedWithError:error];
    }
}

-(void)sessionSyncSuccessful:(DBSession*)session;
{   
    @synchronized([self class]){
         [self postSyncnotification];
        [session.parent syncComplete:self];
    }
}

#pragma mark Webservice Session delegate methods

//write method, once the write is successfull run sync for the module
-(void)sessionDidCompleteUploadSuccessfully:(WebserviceSession*)session{
    NSLog(@"session count is %d",self.requestQueue.operationCount);
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    DBSession *dbSession = [DBSession sessionWithMetadata:[metadataStore dbMetadataForModule:session.metadata.moduleName]];
    
    //reset dirty flags
    NSArray* uploadData = [dbSession getUploadData];
    if ([uploadData count]>0) {
        for( DataObject* dataObject in uploadData)
        {
           // Delete the records with dummy ids. Records with actual ids will be downloaded 
            if([[dataObject objectForFieldName:@"id"] hasPrefix:LOCAL_ID_PREFIX])
            {
                [dbSession deleteRecord:[dataObject objectForFieldName:@"id"]];
            }
            else
            {
                [dbSession resetDirtyFlagForId:dataObject];
            }

        }        
    }
    [self runSyncWithTimestampForModule:session.metadata.moduleName parent:session.parent];
}

-(void)session:(WebserviceSession*)session didCompleteDownloadWithResponse:(id)response
{  
    @synchronized([self class])
    {  SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
        DBMetadata *metadata = [sharedInstance dbMetadataForModule:session.metadata.moduleName];
        DBSession *dbSession = [DBSession sessionWithMetadata:metadata];
        dbSession.syncDelegate = self;
        dbSession.parent = session.parent;
        if ([response count]>0) {
        [dbSession insertDataObjectsInDb:response dirty:NO];
        }
        else{
            [session.parent syncComplete:self];
          [self postSyncnotification];
        }
        NSLog(@"session count is %d",self.requestQueue.operationCount);
    }
        
}

-(void)session:(WebserviceSession*)session didFailWithError:(NSError*)error
{   
    @synchronized([self class]){
        NSLog(@"Error syncing data: %@ \nOperation Count = %d",[error localizedDescription],[self.requestQueue operationCount]);
        if (session.syncAction == kRead) {
            [session.parent syncHandler:self failedWithError:error];
              [self postSyncnotification];
        }
        else {
            //write to local db with dirty flag
            SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
            DBMetadata *metadata = [sharedInstance dbMetadataForModule:session.metadata.moduleName];
            DBSession *dbSession = [DBSession sessionWithMetadata:metadata];
            //dbSession.syncDelegate = self;
            dbSession.parent = session.parent;
            NSMutableArray* dataObjects = [[NSMutableArray alloc] initWithCapacity:[session.uploadDataObjects count]];
            for(DataObject* dataObject in session.uploadDataObjects)
            {                
                // Add a dummy id for new records this dummy id will not be sent to the server when syncing this record
                if( ![dataObject objectForFieldName:@"id"])
                {
                    [dataObject setObject:[NSString stringWithFormat:@"%@%f", LOCAL_ID_PREFIX, [[NSDate date] timeIntervalSince1970]] forFieldName:@"id"];
                }
                
                [dataObjects addObject:dataObject];
            }
            [dbSession insertDataObjectsInDb:dataObjects dirty:YES];
            [session.parent syncHandler:self failedWithError:error];
        }
    }
    NSLog(@"session count is %d",self.requestQueue.operationCount);   
}

-(void)postSyncnotification{
    if ([self.requestQueue operationCount]<= 1) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SugarSyncComplete" object:nil];
        [delegate syncComplete:self];
        self.skipSeamlessLogin = NO;
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
        date = [[[[dateFormatter dateFromString:date] description] componentsSeparatedByString:@" "] objectAtIndex:0];
    }
    
    return date;
}

/*
+ (BOOL)isReachable:(NSError**)error {
    
	BOOL reachable = YES;
	NSError* localError = nil;
    if ( nil == error )
		*error = localError;
	//[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    NSRange range = [[[NSUserDefaults standardUserDefaults] objectForKey:@"endpointURL"] rangeOfString:@"://"];
    if(range.location == NSNotFound)
    {
        range.location = 0;
    }
    NSString *hostname = [[[NSUserDefaults standardUserDefaults] objectForKey:@"endpointURL"] substringWithRange:NSMakeRange(range.location+range.length, [[[NSUserDefaults standardUserDefaults] objectForKey:@"endpointURL"] rangeOfString:@"/"].location)];
    Reachability *internetReach = [Reachability reachabilityWithHostName: hostname];
    //OR below method
    //Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    
	// No internet connection, die right away
	if ( netStatus == NotReachable ) {
		*error = [NSError errorWithDomain:NetworkRequestErrorDomain 
                                     code:NotReachable 
                                 userInfo:[NSDictionary 
                                           dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
		reachable = NO;
	}
    [internetReach stopNotifier];
	return reachable;
}
 */

@end
