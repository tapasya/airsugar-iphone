//
//  WebserviceSession.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceMetadata.h"

enum SyncAction{
    kRead = 0 ,
    kWrite
};

typedef void (^WebserviceSessionCompletionBlock)(NSArray* downloadedData, NSString* moduleName, enum SyncAction syncAction, NSArray* uploadData );

typedef void(^WebserviceSessionErrorBlock)(NSError* error, NSString* moduleName);

// Switichig back to delegation for NSOperation objects
@protocol WebserviceSessionDelegate;

@interface WebserviceSession : NSOperation<NSURLConnectionDataDelegate>{
    @private
    BOOL _isExecuting;
    BOOL _isFinished;
}
@property (readonly) BOOL executing;
@property (readonly) BOOL finished;

@property(strong)WebserviceMetadata *metadata;

@property(assign)NSInteger syncAction;

@property(nonatomic, strong) NSArray* uploadDataObjects;

@property (nonatomic, copy) WebserviceSessionCompletionBlock completionBlock;

@property (nonatomic, copy) WebserviceSessionErrorBlock errorBlock;

@property (weak) id<WebserviceSessionDelegate> delegate;

+(WebserviceSession*)sessionWithMetadata:(WebserviceMetadata*)metadata;

- (void) constructSession;

@end

@protocol WebserviceSessionDelegate <NSObject>

@optional
-(void)sessionWillStartLoading:(WebserviceSession*)session;
-(void)session:(WebserviceSession*)session didFailWithError:(NSError*)error;
-(void)session:(WebserviceSession*)session didCompleteUploadSuccessfully:(id)response;
-(void)session:(WebserviceSession*)session didCompleteDownloadWithResponse:(id)response shouldDownloadRemaining:(BOOL) downloadRemaining;
@end