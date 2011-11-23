//
//  DBSession.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBMetadataStore.h"
@protocol DBSessionDelegate;
@interface DBSession : NSObject
{
    @private
    DBMetadataStore *metadataStore;
}


@property(weak)id<DBSessionDelegate> delegate;
+(DBMetadataStore*)sessionForModule:(NSString*)moduleId;
-(void)startLoadingList;
-(void)startLoadingList:(NSUInteger)offset batchSize:(NSUInteger)batchSize;
-(void)startLoadingDetails:(NSArray*)beanIds;

@end



@protocol DBSessionDelegate <NSObject>
-(void)downloadedModuleList:(NSArray*)moduleList moreComing:(BOOL)moreComing;
-(void)listDownloadFailedWithError:(NSError*)error;
-(void)downloadedDetails:(NSArray*)details;
-(void)detailDownloadFailedWithError:(NSError*)error;

@end