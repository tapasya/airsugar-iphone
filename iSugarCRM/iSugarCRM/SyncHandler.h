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
@interface SyncHandler : NSObject <WebserviceSessionDelegate,DBSyncSessionDelegate>
@property(weak)id <SyncHandlerDelegate>delegate;
-(void)syncForModule:(NSString*)module;
-(void)syncAllModules;
-(void)syncWithStartDate:(NSString*)startDate endDate:(NSString*)endDate;
-(void)syncModule:(NSString*)moduleName startDate:(NSString*)startDate endDate:(NSString*) endDate;
-(NSString *) formatStartDate:(NSString *)startDate;
@end

@protocol SyncHandlerDelegate
-(void)syncHandler:(SyncHandler*)syncHandler failedWithError:(NSError*)error;
-(void)syncComplete:(SyncHandler*)syncHandler;
@end