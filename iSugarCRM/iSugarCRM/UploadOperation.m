//
//  UploadOperation.m
//  iSugarCRM
//
//  Created by Tapasya on 04/11/12.
//
//

#import "UploadOperation.h"
#import "DataObject.h"
#import "JSONKit.h"

@implementation UploadOperation

@synthesize error = _error;
@synthesize data = mData;
@synthesize metadata = mMetadata;
@synthesize request = mRequest;

@synthesize delegate = _delegate;
@synthesize downloadedObjects = _downloadedObjects;
@synthesize uploadDataObjects = _uploadDataObjects;
#pragma mark -
#pragma mark Initialization & Memory Management

- (id) initWithMetaData:(WebserviceMetadata *)metadata
{
    if( (self = [super init]) ) {
        
        mMetadata = metadata;
        
        if(self.uploadDataObjects != nil){
            // Converting Dataobject to Namevalue arrays before posting . This should happed only here.
            // Removed the conversion from one to other at all other places
            NSMutableArray* uploadObjects = [[NSMutableArray alloc] initWithCapacity:self.uploadDataObjects.count];
            for(DataObject* dataObject in self.uploadDataObjects)
            {
                [uploadObjects addObject:[dataObject nameValueArray]];
            }
            mRequest = [metadata constructWriteRequestWithData:uploadObjects];
        }

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
    
    if(self.uploadDataObjects != nil){
        // Converting Dataobject to Namevalue arrays before posting . This should happed only here.
        // Removed the conversion from one to other at all other places
        NSMutableArray* uploadObjects = [[NSMutableArray alloc] initWithCapacity:self.uploadDataObjects.count];
        for(DataObject* dataObject in self.uploadDataObjects)
        {
            [uploadObjects addObject:[dataObject nameValueArray]];
        }
        mRequest = [self.metadata constructWriteRequestWithData:uploadObjects];
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
        id responseObjects = [responseDictionary valueForKeyPath:@"ids"];
        
        if ( nil != self.delegate && [self.delegate respondsToSelector:@selector(uploadCompletedWithDataObjects:forModule:uploadObjects:)]){
            [self.delegate uploadCompletedWithDataObjects:responseObjects forModule:self.metadata.moduleName uploadObjects:self.uploadDataObjects];
        }

        [self done];
	}
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end
