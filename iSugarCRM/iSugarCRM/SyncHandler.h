//
//  SyncHandler.h
//  iSugarCRM
//
//  Created by satyavrat-mac on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceSession.h"
#import "DBSession.h"

@protocol SyncHandlerDelegate;
@interface SyncHandler : NSObject<WebserviceSessionDelegate,DBSyncSessionDelegate> {
@private
    NSOperationQueue        *mRequestQueue;
}
@property (assign) id<SyncHandlerDelegate>delegate;
@property (assign) BOOL isCancelled;
@property (assign) BOOL hadError;
@property (assign) BOOL seamlessSessionFalg;

+ (SyncHandler*)sharedInstance;
- (void)addSyncSession:(WebserviceSession*)session;
/*
write methods
 */
 -(void)uploadData:(NSArray*)uploadData forModule:(NSString*)module parent:(id)parent;
/*
 Complete app sync methods
 */
-(void)runCompleteSync;
-(void)runCompleteSyncWithStartDate:(NSString*)startDate endDate:(NSString*)endDate;
-(void)runCompleteSyncWithTimestamp;
-(void)runCompleteSyncWithTimestampAndStartDate:(NSString*)startDate endDate:(NSString*)endDate;
/*
 Per module sync methods
 */
-(void)runSyncForModule:(NSString*)module parent:(id)parent;
-(void)runSyncForModule:(NSString*)moduleName startDate:(NSString*)startDate endDate:(NSString*) endDate parent:(id)parent;
-(void)runSyncWithTimestampForModule:(NSString*)moduleName parent:(id)parentl;
-(void)runSyncWithTimestampForModule:(NSString*)module startDate:(NSString*)startDate endDate:(NSString*) endDate parent:(id)parent;
@end

@protocol SyncHandlerDelegate
-(void)syncHandler:(SyncHandler*)syncHandler failedWithError:(NSError*)error;
-(void)syncComplete:(SyncHandler*)syncHandler;
@end