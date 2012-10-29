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

typedef void(^WebserviceSessionCompletionBlock)(id response, NSString* moduleName, enum SyncAction syncAction, NSArray* uploadData );

typedef void(^WebserviceSessionErrorBlock)(NSError* error, NSString* moduleName);


@interface WebserviceSession : NSOperation<NSURLConnectionDataDelegate>{
    @private
    BOOL _isExecuting;
    BOOL _isFinished;
}
@property (readonly) BOOL executing;
@property (readonly) BOOL finished;
@property(strong)WebserviceMetadata *metadata;
@property(assign)NSInteger syncAction;
@property(weak)id parent;
@property(strong)NSArray* uploadDataObjects;

@property (nonatomic, strong) WebserviceSessionCompletionBlock completionBlock;

@property (nonatomic, strong) WebserviceSessionErrorBlock errorBlock;

+(WebserviceSession*)sessionWithMetadata:(WebserviceMetadata*)metadata;
-(void)startLoading:(NSString*)timestamp;
-(void)startLoadingWithStartDate:(NSString *)startDate endDate:(NSString *)endDate;
-(void)startLoadingWithTimestamp:(NSString *)timestamp startDate:(NSString*)startDate endDate:(NSString*)endDate;
-(void)startUploading;
@end

@protocol WebserviceSessionDelegate <NSObject>

@optional
-(void)sessionWillStartLoading:(WebserviceSession*)session;
-(void)session:(WebserviceSession*)session didFailWithError:(NSError*)error;
-(void)sessionDidCompleteUploadSuccessfully:(WebserviceSession*)session;
-(void)session:(WebserviceSession*)session didCompleteDownloadWithResponse:(id)response;
@end