//
//  WebserviceSession.m
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebserviceSession.h"
#import "DataObject.h"
#import "DataObjectField.h"
#import "JSONKit.h"
#import "Reachability.h"
#import "SyncHandler.h"
#define HTTPStatusOK 200
@interface WebserviceSession()
@property (assign)BOOL done;
@property (strong)NSURLConnection *conn;
@property (strong)NSURLRequest *req;
@property (strong)NSMutableData *responseData;
-(void) loadUrl:(NSURLRequest*) urlRequest;
-(void) finish;
@end

@implementation WebserviceSession
@synthesize uploadDataObjects;
@synthesize delegate,conn,req,responseData,done;
@synthesize metadata,syncAction,parent;
@synthesize executing = _isExecuting;
@synthesize finished = _isFinished ;

+(WebserviceSession*)sessionWithMetadata:(WebserviceMetadata*)metadata
{
    WebserviceSession *session = [[WebserviceSession alloc] init];
    session.metadata = metadata;
    return session;
}

-(void)startLoading:(NSString*)timestamp
{
    NSURLRequest *request = [metadata getRequestWithLastSyncTimestamp:timestamp];
    [self loadUrl:request];    
}

-(void) startLoadingWithStartDate:(NSString *)startDate endDate:(NSString *)endDate
{
    NSURLRequest *request = [metadata getRequestWithStartDate:startDate endDate:endDate];
    [self loadUrl:request];
}

-(void) startLoadingWithTimestamp:(NSString *)timestamp startDate:(NSString*)startDate endDate:(NSString*)endDate{
    NSURLRequest *request = [metadata getRequestWithLastSyncTimestamp:timestamp startDate:startDate endDate:endDate];
    [self loadUrl:request];

}

-(NSArray*)geUploadData
{
    NSMutableArray *nameValueListArray = [NSMutableArray array]; 
    for(DataObject * dObj in uploadDataObjects){
        [nameValueListArray addObject:[dObj nameValueDictionary]];
    }
    return nameValueListArray;
}
-(void)startUploading
{ 
    if(self.uploadDataObjects != nil){
    NSURLRequest *request = [metadata getWriteRequestWithData:[self geUploadData]];
    [self loadUrl:request]; 
    }
}

-(void) loadUrl:(NSURLRequest *)urlRequest
{
    self.req = urlRequest;
    [[SyncHandler sharedInstance] addSyncSession:self];
}



- (void)finish
{   
    //clean up
    conn = nil;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark NSOperation main

- (void)main
{
    self.done = NO;
    
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn != nil) {
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }
    [self finish];
}

#pragma mark NSURLConnectionDataDelegate Methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{   
    if (delegate != nil && [delegate respondsToSelector:@selector(session:didFailWithError:)]) {
        [self.delegate session:self didFailWithError:error];
    }
    self.done = YES;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSInteger errorCode = [(NSHTTPURLResponse*)response statusCode];
    if (errorCode == HTTPStatusOK){
        if(syncAction == kWrite){
            //return success or should wait for the response?   
           // [delegate sessionDidCompleteUploadSuccessfully:self]; should send a call back or not?
        } else if (syncAction == kRead){
            if (delegate != nil && [delegate respondsToSelector:@selector(sessionWillStartLoading:)]) {
                [delegate sessionWillStartLoading:self];
            }
        }
    } else {
            if (delegate != nil && [delegate respondsToSelector:@selector(session:didFailWithError:)]){
                [self.delegate session:self didFailWithError:[NSError errorWithDomain:@"HTTP ERROR" code:errorCode userInfo:nil]];
           }
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.responseData == nil) {
        self.responseData = [NSMutableData data];
    }
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //parse only in data sync(download)
    
    if (syncAction == kWrite) {
        if (delegate != nil && [delegate respondsToSelector:@selector(sessionDidCompleteUploadSuccessfully:)]) {
            [delegate sessionDidCompleteUploadSuccessfully:self];
        }  
    }  
    else  
    { //read
        NSDictionary *responseDictionary = [self.responseData objectFromJSONData]; //parse using some parser
        id responseObjects = [responseDictionary valueForKeyPath:metadata.pathToObjectsInResponse];
        NSLog(@"response object for module: %@ data: %@",metadata.moduleName,responseObjects);
        if([responseObjects isKindOfClass:[NSDictionary class]]){
            responseObjects = [NSArray arrayWithObject:responseObjects];
        }
        NSMutableArray *arrayOfDataObjects = [[NSMutableArray alloc] init];
        for(NSDictionary *responseObject in responseObjects)
        { 
            @try {
                DataObjectMetadata *objectMetadata = [[SugarCRMMetadataStore sharedInstance] objectMetadataForModule:self.metadata.moduleName];
                DataObject *dataObject = [[DataObject alloc] initWithMetadata:objectMetadata];
                for(DataObjectField *field in [[objectMetadata fields] allObjects]) 
                {
                    id value = [responseObject valueForKeyPath:[metadata.responseKeyPathMap objectForKey:field.name]];
                    if (value == nil) {
                        [dataObject setObject:@" " forFieldName:field.name];
                    } else {
                        [dataObject setObject:value forFieldName:field.name];
                    }
                }
                [arrayOfDataObjects addObject:dataObject];
            }
            @catch (NSException *exception) {
                NSLog(@"Error Parsing Data with Exception = %@, %@",[exception name],[exception description]);
            }
        }
        [delegate session:self didCompleteDownloadWithResponse:arrayOfDataObjects];
    }
    self.done = YES;
}


@end
