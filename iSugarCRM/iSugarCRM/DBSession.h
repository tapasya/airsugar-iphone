//
//  DBSession.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBMetadata.h"
@protocol DBLoadSessionDelegate;
@protocol DBSyncSessionDelegate;
@interface DBSession : NSObject
{
}


@property(weak)id<DBLoadSessionDelegate> delegate;
@property(weak)id<DBSyncSessionDelegate> syncDelegate;
@property(strong)DBMetadata *metadata;
+(DBSession*)sessionWithMetadata:(DBMetadata*)metadata;
-(void)startLoading;
-(void)updateDBWithDataObjects:(NSArray*)dataObjects;
@end



@protocol DBLoadSessionDelegate <NSObject>
@optional
-(void)session:(DBSession*)session downloadedModuleList:(NSArray*)moduleList moreComing:(BOOL)moreComing;
-(void)session:(DBSession*)session listDownloadFailedWithError:(NSError*)error;
-(void)session:(DBSession*)session downloadedDetails:(NSArray*)details;
-(void)session:(DBSession*)session detailDownloadFailedWithError:(NSError*)error;
@end

@protocol DBSyncSessionDelegate <NSObject>
@optional
-(void)session:(DBSession*)session syncFailedWithError:(NSError*)error;
-(void)sessionSyncSuccessful:(DBSession*)session;
@end