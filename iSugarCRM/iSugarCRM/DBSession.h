//
//  DBSession.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBMetadata.h"
#import "DataObject.h"
@protocol DBLoadSessionDelegate;
@protocol DBSyncSessionDelegate;
@interface DBSession : NSObject
{
}

@property(weak)id parent;
@property(weak)id<DBLoadSessionDelegate> delegate;
@property(weak)id<DBSyncSessionDelegate> syncDelegate;
@property(strong)DBMetadata *metadata;
+(DBSession*)sessionWithMetadata:(DBMetadata*)metadata;
//reading
-(void)startLoading;
-(void)loadDetailsForId:(NSString*)beanId;
-(NSArray*)getUploadData;
//writing
-(void)insertDataObjectsInDb:(NSArray *)dataObjects dirty:(BOOL)dirty;
-(BOOL)resetDirtyFlagForId:(DataObject*)dObj;

-(NSString*)getLastSyncTimestamp;
-(BOOL) deleteRecord:(NSString *)beanId;
-(BOOL) deleteAllRecordsInTable;
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