//
//  WebserviceSession.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceMetadataStore.h"

@protocol WebserviceSessionDelegate;

@interface WebserviceSession : NSObject
{
 @private
    WebserviceMetadataStore *metadataStore;
}
@property(weak)id<WebserviceSessionDelegate> delegate;
+(WebserviceSession*)sessionForModule:(NSString*)moduleId;
-(void)startLoadingList;
-(void)startLoadingList:(NSUInteger)offset batchSize:(NSUInteger)batchSize;
-(void)startLoadingDetails:(NSArray*)beanIds;

@end



@protocol WebserviceSessionDelegate <NSObject>
-(void)downloadedModuleList:(NSArray*)moduleList;
-(void)listDownloadFailedWithError:(NSError*)error;
-(void)downloadedDetails:(NSArray*)details;
-(void)detailDownloadFailedWithError:(NSError*)error;

@end