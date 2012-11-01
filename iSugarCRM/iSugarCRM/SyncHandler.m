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
#import "SettingsStore.h"
#import <dispatch/dispatch.h>

NSString* const NetworkRequestErrorDomain = @"HTTPRequestErrorDomain";

static SyncHandler *sharedInstance;

@interface SyncHandler ()
{
    dispatch_queue_t bgQueue;
}

-(id)initPrivate;

-(void)postSyncnotification;

-(NSString*)formatDate:(NSString*)date;

@property (strong) NSOperationQueue *requestQueue;

@property (assign) BOOL skipSeamlessLogin;

@property (assign) NSInteger requestCount;

/*
 Currently unused, may be useful in future
 
@property (nonatomic, strong) WebserviceSessionCompletionBlock websessionCompletionBlock;

@property (nonatomic, strong) WebserviceSessionErrorBlock websessionErrorBlock ;
 */

@property (nonatomic, strong) NSMutableArray* errors;

@property (nonatomic, strong) NSMutableArray* webServiceSessions;

-(BOOL) startUploadSessionforModule:(NSString*)module;

- (void) startDownloadSessionForModule:(NSString*) moduleName syncType:(enum SYNC_TYPE) syncType;

- (void) uploadFailedWithError:(NSError*) error forModule:(NSString*) moduleName;

- (void) uploadCompleteWithResponse:(id) response forModule:(NSString*) moduleName forObjects:(NSArray*) uploadedData;

- (void) downloadCompleteWithResponse:(id) response forModule:(NSString*) moduleName;

- (void) downloadFailedWithError:(NSError*) error forModule:(NSString*) moduleName;

@end

@implementation SyncHandler
@synthesize requestQueue = mRequestQueue;
@synthesize requestCount;
@synthesize skipSeamlessLogin;

/*
 Currently unused, may be useful in future
@synthesize websessionCompletionBlock = _websessionCompletionBlock;
@synthesize websessionErrorBlock = _websessionErrorBlock;
*/

@synthesize completionBlock = _completionBlock;
@synthesize errorBlock = _errorBlock;

@synthesize errors = _errors;

#pragma mark Singleton methods

-(id)init{
    NSAssert(NO, @"Cannot instantiate this directly, use sharedInstance");
    return nil;
}
+(SyncHandler*)sharedInstance
{
    @synchronized(self){
        if(sharedInstance == nil){
            sharedInstance = [[SyncHandler alloc] initPrivate];
        }
        //sharedInstance.skipSeamlessLogin = true;
        return sharedInstance;
    }
}

- (id)copyWithZone:(NSZone *)zone 
{ 
    return self; 
}

-(id)initPrivate
{
    self = [super init];
    bgQueue = dispatch_queue_create("com.imaginea.ios.pancake", NULL);
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

- (void) showNetworkError
{
    NSError* error = [NSError errorWithDomain:NetworkRequestErrorDomain
                                code:NotReachable
                            userInfo:[NSDictionary
                                      dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"No internet connection available."],NSLocalizedDescriptionKey,nil]];
    [self.errors addObject:error];
    
    if (self.errorBlock != nil) {
        self.errorBlock(self.errors);
    }
}

#pragma mark Complete Sync Methods

//for all complete syn methods: create add functionality to take all the dirty records in db and sync

- (void) runSyncforModules:(NSArray *)modules withSyncType:(enum SYNC_TYPE)syncType
{
    dispatch_async(bgQueue, ^(){
        self.errors = [[NSMutableArray alloc] initWithCapacity:modules.count];
        
        self.webServiceSessions = [[NSMutableArray alloc] initWithCapacity:modules.count];
        
        if (![[ConnectivityChecker singletonObject] isNetworkReachable])
        {
            [self showNetworkError];
        }
        else
        {
            if (![self isSeamlessloginSuccessfull])
                return;
            
            //SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
            
            for(NSString *moduleName in modules)
            {
                [self startUploadSessionforModule:moduleName];
                
                //create download session
                [self startDownloadSessionForModule:moduleName syncType:syncType];
            }
        }
    });
}

#pragma mark - Module Sync Methods
-(BOOL) startUploadSessionforModule:(NSString*)module
{
    BOOL isSessionStarted = NO;
    
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    DBSession *dbSession = [DBSession sessionForModule:module];
    NSArray* uploadData = [dbSession getUploadData];
    if ([uploadData count] > 0) {
        WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_writeMetadataForModule:module]];
        
//        session.completionBlock = ^(id response, NSString* moduleName, enum SyncAction syncAction, NSArray* dirtyData){
//            [self uploadCompleteWithResponse:response forModule:moduleName forObjects:dirtyData];
//        };
//        
//        session.errorBlock = ^ (NSError* error, NSString* moduleName){
//            [self uploadFailedWithError:error forModule:moduleName];
//        };
        
        session.delegate = self;
        
        session.syncAction = kWrite;    
        session.uploadDataObjects = uploadData;
        
        if (![[ConnectivityChecker singletonObject] isNetworkReachable])
        {
            [self showNetworkError];
        }
        else
        {  
            if ([self isSeamlessloginSuccessfull]) {
                session.queuePriority = NSOperationQueuePriorityHigh;
                [session constructSession];
                [self.requestQueue addOperation:session];
                isSessionStarted = YES;
                
            }
        }
    }
    
    return YES;
}

- (void) startDownloadSessionForModule:(NSString*) moduleName syncType:(enum SYNC_TYPE) syncType
{
    //create download session
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_readMetadataForModule:moduleName]];
    session.syncAction = kRead;
    
//    session.completionBlock = ^(id response, NSString* moduleName, enum SyncAction syncAction, NSArray* dirtyData){
//        // [self downloadCompleteWithResponse:response forModule:moduleName];
//        NSLog(@"Module Download complete");
//    };
//    
//    session.errorBlock = ^ (NSError* error, NSString* moduleName){
//        [self downloadFailedWithError:error forModule:moduleName];
//    };
    
    session.delegate = self;
    
    
    switch (syncType) {
        case SYNC_TYPE_WITH_DATES:
            {
                NSString *startDate = [self formatDate:[SettingsStore objectForKey:kStartDateIdentifier]];
                NSString *endDate = [self formatDate:[SettingsStore objectForKey:kEndDateIdentifier]];
                session.metadata.startDate = startDate;
                session.metadata.endDate = endDate;
            }
            break;
        case SYNC_TYPE_WITH_TIME_STAMP:
            {
                DBSession *dbSession = [DBSession sessionForModule:moduleName];
                NSString* deltaMark = [dbSession getLastSyncTimestamp];
//                if ( nil ==  deltaMark) {
//                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//                    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//                    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//                    
//                    deltaMark = [dateFormatter stringFromDate:[NSDate date]];
//                }
                
                session.metadata.timeStamp = deltaMark;
            }
            break;
            
        case SYNC_TYPE_WITH_TIME_STAMP_AND_DATES:
            {
                DBSession *dbSession = [DBSession sessionForModule:moduleName];
                NSString* deltaMark = [dbSession getLastSyncTimestamp];
                NSString *startDate = [self formatDate:[SettingsStore objectForKey:kStartDateIdentifier]];
                NSString *endDate = [self formatDate:[SettingsStore objectForKey:kEndDateIdentifier]];
                session.metadata.startDate = startDate;
                session.metadata.endDate = endDate;
                session.metadata.timeStamp = deltaMark;
            }
            break;
        
        default:
            break;
    }
    
    [session constructSession];
    [self.requestQueue addOperation:session];
    
     [self.webServiceSessions addObject:session];
}

- (void) downloadRecordWithIds:(NSArray* ) idsToDownload forModule:(NSString*) moduleName
{
    //create download session
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    WebserviceSession *session = [WebserviceSession sessionWithMetadata:[metadataStore webservice_readMetadataForModule:moduleName]];
    session.syncAction = kRead;
    
    session.delegate = self ;
    
    session.metadata.downlaodObjects = idsToDownload;
    
    [session constructSession];
    
    [self.requestQueue addOperation:session];

}

# pragma mark - Webservice session delegate methods

- (void) session:(WebserviceSession *)session didCompleteUploadSuccessfully:(id)response
{
    [self uploadCompleteWithResponse:response forModule:session.metadata.moduleName forObjects:session.uploadDataObjects];
}

- (void) session:(WebserviceSession *)session didCompleteDownloadWithResponse:(id)response shouldDownloadRemaining:(BOOL) downloadRemaining
{
    [self downloadCompleteWithResponse:response forModule:session.metadata.moduleName];
    
    // Check for more records and add a download session
    if ( downloadRemaining ) {
        WebserviceSession* downloadSession = [WebserviceSession sessionWithMetadata:session.metadata];
        downloadSession.syncAction = kRead;
        downloadSession.delegate = self;
        [downloadSession constructSession];
        [self.requestQueue addOperation:downloadSession];
    }
}

- (void) session:(WebserviceSession *)session didFailWithError:(NSError *)error
{
    if (session.syncAction == kWrite) {
        [self uploadFailedWithError:error forModule:session.metadata.moduleName];
    } else {
        [self downloadFailedWithError:error forModule:session.metadata.moduleName];
    }
}

# pragma mark - Webservice session completion block Methods

- (void) uploadCompleteWithResponse:(id) response forModule:(NSString*) moduleName forObjects:(NSArray*) uploadedData
{
    NSLog(@"session count is %d",self.requestQueue.operationCount);
    DBSession *dbSession = [DBSession sessionForModule:moduleName];
    //reset dirty flags
    if ([uploadedData isKindOfClass:[NSArray class]] && [response isKindOfClass:[NSArray class]]) {
        NSArray* idsToDownload = (NSArray*) response;
        if ([uploadedData count]>0 && [idsToDownload count] == [uploadedData count]) {
            for( DataObject* dataObject in uploadedData)
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
            if ( [idsToDownload count] > 0) {
                // Starting a download session once upload is successful
                [self downloadRecordWithIds:idsToDownload forModule:moduleName];
            }
        }
    }
}

- (void) downloadCompleteWithResponse:(id) response forModule:(NSString*) moduleName
{
    @synchronized([self class])
    {
        if ([response isKindOfClass:[NSArray class]]) {
            
            DBSession *dbSession = [DBSession sessionForModule:moduleName];
            
            dbSession.completionBlock = ^(NSArray* data)  {
                @synchronized([self class]){
                    [self postSyncnotification];
                }
            };
            
            dbSession.errorBlock = ^(NSError* error){
                @synchronized([self class]){
                    [self.errors addObject:error];
                    [self postSyncnotification];
                }
            };
            
            if ([response count]>0) {
                [dbSession insertDataObjectsInDb:response dirty:NO];
            }
            else{
                [self postSyncnotification];
            }
        }
        NSLog(@"session count is %d",self.requestQueue.operationCount);
    }
}

# pragma mark - Web service session error blocks

- (void) uploadFailedWithError:(NSError*) error forModule:(NSString*) moduleName
{
    @synchronized([self class]){
        NSLog(@"Error syncing data: %@ \nOperation Count = %d",[error localizedDescription],[self.requestQueue operationCount]);
        //write to local db with dirty flag
        DBSession *dbSession = [DBSession sessionForModule:moduleName];
        NSArray* uploadDataObjects = [dbSession getUploadData];
        NSMutableArray* dataObjects = [[NSMutableArray alloc] initWithCapacity:[uploadDataObjects count]];
        for(DataObject* dataObject in uploadDataObjects)
        {
            // Add a dummy id for new records this dummy id will not be sent to the server when syncing this record
            if( ![dataObject objectForFieldName:@"id"])
            {
                [dataObject setObject:[NSString stringWithFormat:@"%@%f", LOCAL_ID_PREFIX, [[NSDate date] timeIntervalSince1970]] forFieldName:@"id"];
            }
            
            [dataObjects addObject:dataObject];
        }
        [dbSession insertDataObjectsInDb:dataObjects dirty:YES];
        
        // Add error to the errors array
        [self.errors addObject:error];
    }
    NSLog(@"session count is %d",self.requestQueue.operationCount);
}

- (void) downloadFailedWithError:(NSError*) error forModule:(NSString*) moduleName
{
    @synchronized([self class]){
        NSLog(@"Error syncing data: %@ \nOperation Count = %d",[error localizedDescription],[self.requestQueue operationCount]);
        [self.errors addObject:error];
        [self postSyncnotification];
    }
}

-(void)postSyncnotification
{
    if ([self.requestQueue operationCount]<= 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SugarSyncComplete" object:nil];
        if ( self.errors.count > 0) {
            if ( nil != self.errorBlock ) {
                self.errorBlock(self.errors);
            }
        } else{
            if ( nil != self.completionBlock) {
                self.completionBlock();
            }
        }
        self.skipSeamlessLogin = NO;
    }
}

#pragma mark - Utility

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

@end
