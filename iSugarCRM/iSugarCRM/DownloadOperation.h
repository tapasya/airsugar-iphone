//
//  WebOperation.h
//  iSugarCRM
//
//  Created by Tapasya on 03/11/12.
//
//

#import <Foundation/Foundation.h>
#import "WebserviceMetadata.h"

@protocol DownloadCompletionDelegate;

@interface DownloadOperation : NSOperation {
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

@property (weak) id<DownloadCompletionDelegate> delegate;

@property (nonatomic, strong) NSMutableArray* downloadedObjects;

- (id) initWithMetaData:(WebserviceMetadata*) metadata;

- (id) initWithMetaData:(WebserviceMetadata *)metadata objectsToDownload:(NSArray*) downloadIds;

@end

@protocol DownloadCompletionDelegate <NSObject>

@required
- (void) downloadCompletedWithDataObjects:(NSArray*) dataObjects forModule:(NSString*) moduleName;

@end