//
//  WebOperation.m
//  iSugarCRM
//
//  Created by Tapasya on 03/11/12.
//
//

#import "DownloadOperation.h"
#import "JSONKit.h"
#import "DataObject.h"

@implementation DownloadOperation

@synthesize error = _error;
@synthesize data = mData;
@synthesize metadata = mMetadata;
@synthesize request = mRequest;

@synthesize delegate = _delegate;
@synthesize downloadedObjects = _downloadedObjects;

#pragma mark -
#pragma mark Initialization & Memory Management

- (id) initWithMetaData:(WebserviceMetadata *)metadata
{
    return [self initWithMetaData:metadata objectsToDownload:nil];
}

- (id) initWithMetaData:(WebserviceMetadata *)metadata objectsToDownload:(NSArray *)downloadIds
{
    if( (self = [super init]) ) {
        
        mMetadata = metadata;
        
        self.metadata.downlaodObjects = downloadIds;
        
        mRequest = [metadata constructRequest];
    }
    
    return self;
}

#pragma mark -
#pragma mark Start & Utility Methods

// This method is just for convenience. It cancels the URL connection if it
// still exists and finishes up the operation.
- (void)done
{
    if( mConnection ) {
        [mConnection cancel];
        mConnection = nil;
    }
    
    // Alert anyone that we are finished
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    mExecuting = NO;
    mFinished  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

-(void)canceled
{
	// Code for being cancelled
    _error = [[NSError alloc] initWithDomain:@"DownloadUrlOperation"
                                        code:123
                                    userInfo:nil];
    
    [self done];
    
}

- (void)start
{
    // Ensure that this operation starts on the main thread
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start)
                               withObject:nil waitUntilDone:NO];
        return;
    }
    
    // Ensure that the operation should exute
    if( mFinished || [self isCancelled] ) { [self done]; return; }
    
    // From this point on, the operation is officially executing--remember, isExecuting
    // needs to be KVO compliant!
    [self willChangeValueForKey:@"isExecuting"];
    mExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    // Create the NSURLConnection--this could have been done in init, but we delayed
    // until no in case the operation was never enqueued or was cancelled before starting
    mConnection = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self];
}

#pragma mark -
#pragma mark Overrides

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return mExecuting;
}

- (BOOL)isFinished
{
    return mFinished;
}

#pragma mark -
#pragma mark Delegate Methods for NSURLConnection

// The connection failed
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
		return;
    }
	else {
		mData = nil;
		[self done];
	}
}

// The connection received more data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
		return;
    }
    
    [mData appendData:data];
}

// Initial response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
		return;
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger statusCode = [httpResponse statusCode];
    if( statusCode == 200 ) {
        NSUInteger contentSize = [httpResponse expectedContentLength] > 0 ? [httpResponse expectedContentLength] : 0;
        mData = [[NSMutableData alloc] initWithCapacity:contentSize];
    } else {
        NSString* statusError  = [NSString stringWithFormat:NSLocalizedString(@"HTTP Error: %ld", nil), statusCode];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:statusError forKey:NSLocalizedDescriptionKey];
        _error = [[NSError alloc] initWithDomain:@"DownloadUrlOperation"
                                            code:statusCode
                                        userInfo:userInfo];
        [self done];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
		return;
    }
	else {
        // Parse the response
        
        NSDictionary *responseDictionary = [self.data objectFromJSONData]; //parse using some parser
        id responseObjects = [responseDictionary valueForKeyPath:self.metadata.pathToObjectsInResponse];
        id relationshipList = [responseDictionary valueForKeyPath:self.metadata.pathToRelationshipInResponse];
        
        if([responseObjects isKindOfClass:[NSDictionary class]])
            responseObjects = [NSArray arrayWithObject:responseObjects];
        
        
        if ( nil == self.downloadedObjects ) 
            _downloadedObjects = [[NSMutableArray alloc] init];
        
        int count = 0;
        
        for(NSDictionary *responseObject in responseObjects)
        {
            @try {
                
                DataObjectMetadata *objectMetadata = [[SugarCRMMetadataStore sharedInstance] objectMetadataForModule:self.metadata.moduleName];
                DataObject *dataObject = [[DataObject alloc] initWithMetadata:objectMetadata];
                
                for(DataObjectField *field in [[objectMetadata fields] allObjects])
                {
                    id value = [responseObject valueForKeyPath:[self.metadata.responseKeyPathMap objectForKey:field.name]];
                    if (value == nil) {
                        [dataObject setObject:@" " forFieldName:field.name];
                    } else {
                        [dataObject setObject:value forFieldName:field.name];
                    }
                    
                }
                
                if ([relationshipList count]>0) {
                    NSArray *relationships = [[relationshipList objectAtIndex:count] objectForKey:[self.metadata.responseKeyPathMap objectForKey:@"relation_list"]];
                    for(NSDictionary *relationship in relationships){
                        NSString* relatedModule = [relationship valueForKeyPath:[self.metadata.responseKeyPathMap objectForKey:@"related_module"]];
                        NSMutableArray *beanIds = [NSMutableArray array];
                        for(NSDictionary * bean in  [relationship valueForKeyPath:[self.metadata.responseKeyPathMap objectForKey:@"related_module_records"]]){
                            [beanIds addObject:[bean valueForKeyPath:[self.metadata.responseKeyPathMap objectForKey:@"related_record"]]];
                        }
                        if ([beanIds count]>0) {
                            [dataObject addRelationshipWithModule:relatedModule andBeans:beanIds];
                        }
                    }
                }
                [self.downloadedObjects addObject:dataObject];
                count++;
            }
            @catch (NSException *exception) {
                NSLog(@"Error Parsing Data with Exception = %@, %@",[exception name],[exception description]);
            }
        }
        
        NSInteger nextOffset = [[responseDictionary valueForKey:@"next_offset"] integerValue];
        
        NSInteger resultCount = [[responseDictionary valueForKey:@"result_count"] integerValue];
        
        self.metadata.offset = nextOffset;
        
        NSLog(@"Result count for module %@, %d", self.metadata.moduleName, resultCount);
        NSLog(@"Next offset for module %@, %d", self.metadata.moduleName, self.metadata.offset);
        
        
        // Add completion call back
        if ( nil != self.delegate && [self.delegate respondsToSelector:@selector(downloadCompletedWithDataObjects:forModule:)]) {
            [self.delegate downloadCompletedWithDataObjects:self.downloadedObjects forModule:self.metadata.moduleName];
        }
        
		[self done];
	}
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

@end