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
#import "JSONKit.h"
#import "DateUtils.h"

NSString* const NetworkRequestErrorDomain = @"HTTPRequestErrorDomain";

static SyncHandler *sharedInstance;

@interface SyncHandler ()
{
    dispatch_queue_t bgQueue;

}

-(id)initPrivate;

-(void)postSyncnotification;

@property (strong) NSOperationQueue *requestQueue;

@property (assign) BOOL skipSeamlessLogin;

@property (assign) NSInteger requestCount;

@property (nonatomic, strong) NSMutableArray* errors;

- (void) startUploadOperationsForModule:(NSString*) moduleName;

- (void) startDownloadOperationsForModule:(NSString*) moduleName syncType:(enum SYNC_TYPE) syncType;

- (void) uploadFailedWithError:(NSError*) error forModule:(NSString*) moduleName;

- (void) uploadCompleteWithResponse:(id) response forModule:(NSString*) moduleName forObjects:(NSArray*) uploadedData;

- (void) downloadCompleteWithResponse:(id) response forModule:(NSString*) moduleName;

- (void) downloadFailedWithError:(NSError*) error forModule:(NSString*) moduleName;

@end

@implementation SyncHandler
@synthesize requestQueue = mRequestQueue;
@synthesize requestCount;
@synthesize skipSeamlessLogin;

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
        
        if (![[ConnectivityChecker singletonObject] isNetworkReachable])
        {
            [self showNetworkError];
        }
        else
        {
            if (![self isSeamlessloginSuccessfull])
                return;
            
            // Add observer for operation queue changes
            
            [self.requestQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
            
            for(NSString *moduleName in modules)
            {
                [self startUploadOperationsForModule:moduleName];
                
                [self startDownloadOperationsForModule:moduleName syncType:syncType];
            }
            
            [self postSyncnotification];
        }
    });
}

- (void) startUploadOperationsForModule:(NSString*) moduleName
{
    SugarCRMMetadataStore *metadataStore = [SugarCRMMetadataStore sharedInstance];
    DBSession *dbSession = [DBSession sessionForModule:moduleName];
    NSArray* uploadData = [dbSession getUploadData];
    if ([uploadData count] > 0) {
        
        UploadOperation* uploadOperation  = [[UploadOperation alloc] initWithMetaData:[metadataStore webservice_writeMetadataForModule:moduleName]];
        uploadOperation.uploadDataObjects = uploadData;
        uploadOperation.delegate = self;
        
        [self.requestQueue addOperation:uploadOperation];
        
    }
}

- (void) downloadRecordWithIds:(NSArray* ) idsToDownload forModule:(NSString*) moduleName
{
    WebserviceMetadata* metadata = [[SugarCRMMetadataStore sharedInstance] webservice_readMetadataForModule:moduleName];
    metadata.downlaodObjects = idsToDownload;
    
    DownloadOperation* downloadOperation = [[DownloadOperation alloc] initWithMetaData:metadata];
    downloadOperation.delegate = self;
    [self.requestQueue addOperation:downloadOperation];

}

- (void) startDownloadOperationsForModule:(NSString*) moduleName syncType:(enum SYNC_TYPE) syncType
{
    WebserviceMetadata* webMetaData = [[SugarCRMMetadataStore sharedInstance] webservice_readMetadataForModule:moduleName];
    
    switch (syncType) {
        case SYNC_TYPE_WITH_DATES:
        {
            NSString *startDate = [DateUtils formatDate:[SettingsStore objectForKey:kStartDateIdentifier]];
            NSString *endDate = [DateUtils formatDate:[SettingsStore objectForKey:kEndDateIdentifier]];
            webMetaData.startDate = startDate;
            webMetaData.endDate = endDate;
        }
            break;
        case SYNC_TYPE_WITH_TIME_STAMP:
        {
            DBSession *dbSession = [DBSession sessionForModule:moduleName];
            NSString* deltaMark = [dbSession getLastSyncTimestamp];
            webMetaData.timeStamp = deltaMark;
        }
            break;
            
        case SYNC_TYPE_WITH_TIME_STAMP_AND_DATES:
        {
            DBSession *dbSession = [DBSession sessionForModule:moduleName];
            NSString* deltaMark = [dbSession getLastSyncTimestamp];
            NSString *startDate = [DateUtils formatDate:[SettingsStore objectForKey:kStartDateIdentifier]];
            NSString *endDate = [DateUtils formatDate:[SettingsStore objectForKey:kEndDateIdentifier]];
            webMetaData.startDate = startDate;
            webMetaData.endDate = endDate;
            webMetaData.timeStamp = deltaMark;
        }
            break;
            
        default:
            break;
    }
    
    // First get the total record count and then queue download operations
    
    // TODO not a nice way to construct the request
    [webMetaData setUrlParam:@"get_entries_count" forKey:@"method"];
    
    NSURLResponse* response;
    NSError* error = nil;
    
    NSData* resultData = [NSURLConnection sendSynchronousRequest:[webMetaData constructRequest] returningResponse:&response error:&error];
    
    NSDictionary* responseDict = [resultData objectFromJSONData];
    
    NSInteger totalRecords = [[responseDict objectForKey:@"result_count"] integerValue];
    
    NSLog(@"Records is for module %@ - %d", moduleName, totalRecords);

    if ( totalRecords > 0) {
        // TODO change the max condition
        for (int offset = 0 ; offset < totalRecords; offset +=1000) {
            // Add request queues to download the remaining data
            WebserviceMetadata* metadata = [[SugarCRMMetadataStore sharedInstance] webservice_readMetadataForModule:moduleName];
            
            metadata.timeStamp = webMetaData.timeStamp;
            metadata.startDate = webMetaData.startDate;
            metadata.endDate = webMetaData.endDate;
            
            metadata.offset = offset;
            
            DownloadOperation* downloadOperation = [[DownloadOperation alloc] initWithMetaData:metadata];
            downloadOperation.delegate = self;
            [self.requestQueue addOperation:downloadOperation];
        }
    } else{
        NSLog(@"No Records in module %@", moduleName);
     }
}

# pragma mark - Download Operation delegate

- (void) downloadCompletedWithDataObjects:(NSArray *)dataObjects forModule:(NSString *)moduleName
{
    [self downloadCompleteWithResponse:dataObjects forModule:moduleName];
}

# pragma mark = Upload Operation delegate
- (void) uploadCompletedWithDataObjects:(NSArray *)dataObjects forModule:(NSString *)moduleName uploadObjects:(NSArray *)uploadObjects
{
    [self uploadCompleteWithResponse:dataObjects forModule:moduleName forObjects:uploadObjects];
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

// Get this working instead of using postSyncNotificationMethod

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.requestQueue && [keyPath isEqualToString:@"operations"]) {
        if ([self.requestQueue.operations count] == 0) {
            // Do something here when your queue has completed
            NSLog(@"queue has completed");
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"SugarSyncComplete" object:nil];
//            if ( self.errors.count > 0) {
//                if ( nil != self.errorBlock ) {
//                    self.errorBlock(self.errors);
//                }
//            } else{
//                if ( nil != self.completionBlock) {
//                    self.completionBlock();
//                }
//            }
//            self.skipSeamlessLogin = NO;

        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)postSyncnotification
{
    if ([self.requestQueue operationCount]<= 1 ) {
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
@end
