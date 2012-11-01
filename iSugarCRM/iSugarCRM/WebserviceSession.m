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

#define HTTPStatusOK 200

@interface WebserviceSession()
@property (assign)BOOL done;
@property (strong)NSURLConnection *conn;
@property (strong)NSURLRequest *req;
@property (strong)NSMutableData *responseData;

@property (nonatomic, strong) NSMutableArray* downloadedObjects;
@property (nonatomic, assign) NSInteger totalDownloadCount;
@property (nonatomic, assign) NSInteger resultCount;

-(void) loadUrl:(NSURLRequest*) urlRequest;
-(void) finish;
@end

@implementation WebserviceSession
@synthesize uploadDataObjects;
@synthesize downloadedObjects;
@synthesize conn,req,responseData,done;
@synthesize metadata,syncAction;
@synthesize executing = _isExecuting;
@synthesize finished = _isFinished ;
@synthesize completionBlock = _completionBlock;
@synthesize errorBlock = _errorBlock;
@synthesize totalDownloadCount;
@synthesize resultCount;

+(WebserviceSession*)sessionWithMetadata:(WebserviceMetadata*)metadata
{
    WebserviceSession *session = [[WebserviceSession alloc] init];
    session.metadata = metadata;
    return session;
}

- (void) constructSession
{
    NSURLRequest* request = nil;
    
    if (self.syncAction == kRead) {
            
        request = [metadata constructRequest];
            
    } else if (self.syncAction == kWrite){
        if(self.uploadDataObjects != nil){
            // Converting Dataobject to Namevalue arrays before posting . This should happed only here.
            // Removed the conversion from one to other at all other places
            NSMutableArray* uploadObjects = [[NSMutableArray alloc] initWithCapacity:uploadDataObjects.count];
            for(DataObject* dataObject in uploadDataObjects)
            {
                [uploadObjects addObject:[dataObject nameValueArray]];
            }
            request = [metadata constructWriteRequestWithData:uploadObjects];
        }
        
    }
    
    if ( request != nil) {
        self.req = request;
    } else{
        NSLog(@"Unable to construct request for module %@", self.metadata.moduleName);
    }

}


#pragma mark - upload methods

-(void)startUploading
{ 
    if(self.uploadDataObjects != nil){
        // Converting Dataobject to Namevalue arrays before posting . This should happed only here. 
        // Removed the conversion from one to other at all other places
        NSMutableArray* uploadObjects = [[NSMutableArray alloc] initWithCapacity:uploadDataObjects.count];
        for(DataObject* dataObject in uploadDataObjects)
        {
            [uploadObjects addObject:[dataObject nameValueArray]];
        }
        NSURLRequest *request = [metadata constructWriteRequestWithData:uploadObjects];
        [self loadUrl:request]; 
    }
}


-(void) loadUrl:(NSURLRequest *)urlRequest
{
    self.req = urlRequest;
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
    if (self.errorBlock != nil ) {
        self.errorBlock(error, self.metadata.moduleName);
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
//            if (delegate != nil && [delegate respondsToSelector:@selector(sessionWillStartLoading:)]) {
//                [delegate sessionWillStartLoading:self];
//            }
        }
    } else {
            if ( self.errorBlock != nil ){
                self.errorBlock([NSError errorWithDomain:@"HTTP ERROR" code:errorCode userInfo:nil], self.metadata.moduleName);
           }
        self.done = YES;
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
    BOOL isPending = NO;
    
    if (syncAction == kWrite) {
        if (self.done == NO) {
            NSDictionary *responseDictionary = [self.responseData objectFromJSONData]; //parse using some parser
            id responseObjects = [responseDictionary valueForKeyPath:@"ids"];
            
            if ( nil != self.completionBlock) {
                    self.completionBlock((NSArray*)responseObjects, self.metadata.moduleName, self.syncAction, self.uploadDataObjects);
            }
            else if (self.delegate){
                    [self.delegate session:self didCompleteUploadSuccessfully:responseObjects];
            }
        }
        
        self.done = YES;
    }  
    else  
    {
        //read
        NSDictionary *responseDictionary = [self.responseData objectFromJSONData]; //parse using some parser
        id responseObjects = [responseDictionary valueForKeyPath:metadata.pathToObjectsInResponse];
        id relationshipList = [responseDictionary valueForKeyPath:metadata.pathToRelationshipInResponse];
      //    NSLog(@"response object for module: %@ data: %@",metadata.moduleName,responseObjects);
        

        if([responseObjects isKindOfClass:[NSDictionary class]]){
            responseObjects = [NSArray arrayWithObject:responseObjects];
        }
        
        if ( nil == self.downloadedObjects ) {
            
            downloadedObjects = [[NSMutableArray alloc] init];
            totalDownloadCount = [[responseDictionary valueForKey:@"total_count"] integerValue];
        }
        
        NSInteger nextOffset = [[responseDictionary valueForKey:@"next_offset"] integerValue];
        
        self.resultCount = [[responseDictionary valueForKey:@"result_count"] integerValue];
        
        self.metadata.offset = nextOffset;
        
        int count = 0;
        
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
                
                if ([relationshipList count]>0) {
                    NSArray *relationships = [[relationshipList objectAtIndex:count] objectForKey:[metadata.responseKeyPathMap objectForKey:@"relation_list"]];
                    for(NSDictionary *relationship in relationships){
                        NSString* relatedModule = [relationship valueForKeyPath:[metadata.responseKeyPathMap objectForKey:@"related_module"]];
                        NSMutableArray *beanIds = [NSMutableArray array];
                        for(NSDictionary * bean in  [relationship valueForKeyPath:[metadata.responseKeyPathMap objectForKey:@"related_module_records"]]){
                            [beanIds addObject:[bean valueForKeyPath:[metadata.responseKeyPathMap objectForKey:@"related_record"]]];
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
        
        if ( self.resultCount == 0 || self.totalDownloadCount <= self.downloadedObjects.count || self.totalDownloadCount == self.metadata.offset) {
            self.metadata.offset = -1;
        } else{
            isPending = YES;
        }
        
        NSLog(@"data objects for module %@, %d", self.metadata.moduleName, [self.downloadedObjects count]);
        NSLog(@"Result count for module %@, %d", self.metadata.moduleName, self.resultCount);
        NSLog(@"Next offset for module %@, %d", self.metadata.moduleName, self.metadata.offset);
        
        
        {
            if ( nil != self.completionBlock){
                self.completionBlock(self.downloadedObjects, self.metadata.moduleName, self.syncAction, nil);
            } else if (nil != self.delegate){
                [self.delegate session:self didCompleteDownloadWithResponse:self.downloadedObjects shouldDownloadRemaining:isPending];
            }
            self.done = YES;
        }
    }
}


@end
