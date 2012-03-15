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
@protocol WebserviceSessionDelegate;
@interface WebserviceSession : NSOperation<NSURLConnectionDataDelegate>{
    @private
    BOOL _isExecuting;
    BOOL _isFinished;
}
@property (readonly) BOOL executing;
@property (readonly) BOOL finished;
@property(weak)id<WebserviceSessionDelegate> delegate;
@property(strong)WebserviceMetadata *metadata;
@property(assign)NSInteger syncAction;
@property(assign)id parent;
@property(strong)NSDictionary* uploadData;
+(WebserviceSession*)sessionWithMetadata:(WebserviceMetadata*)metadata;
-(void)startLoading:(NSString*)timestamp;
-(void)startLoadingWithStartDate:(NSString *)startDate endDate:(NSString *)endDate;
-(void)startUploading;
@end

@protocol WebserviceSessionDelegate <NSObject>

@optional
-(void)sessionWillStartLoading:(WebserviceSession*)session;
-(void)session:(WebserviceSession*)session didFailWithError:(NSError*)error;
-(void)sessionDidCompleteUploadSuccessfully:(WebserviceSession*)session;
-(void)session:(WebserviceSession*)session didCompleteDownloadWithResponse:(id)response;
@end