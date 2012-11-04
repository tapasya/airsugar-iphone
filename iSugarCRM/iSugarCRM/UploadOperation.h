//
//  UploadOperation.h
//  iSugarCRM
//
//  Created by Tapasya on 04/11/12.
//
//

#import <Foundation/Foundation.h>

@protocol UploadCompletionDelegate;

@interface UploadOperation : NSOperation{
    // In concurrent operations, we have to manage the operation's state
    BOOL mExecuting;
    BOOL mFinished;
    
    // The actual NSURLConnection management
    NSURLRequest*       mRequest;
    NSURLConnection*    mConnection;
    NSMutableData*      mData;
    WebserviceMetadata* mMetadata;
}

@property (nonatomic, readonly) NSError* error;
@property (nonatomic, readonly) NSMutableData *data;
@property (nonatomic, readonly) WebserviceMetadata* metadata;
@property (nonatomic, readonly) NSURLRequest* request;

@property (weak) id<UploadCompletionDelegate> delegate;

@property (nonatomic, strong) NSMutableArray* downloadedObjects;
@property (nonatomic, strong) NSArray* uploadDataObjects;

- (id)initWithMetaData:(WebserviceMetadata*) metadata;

@end

@protocol UploadCompletionDelegate <NSObject>

@required
- (void) uploadCompletedWithDataObjects:(NSArray*) responseObjects forModule:(NSString*) moduleName uploadObjects:(NSArray*) uploadObjects;

@end
