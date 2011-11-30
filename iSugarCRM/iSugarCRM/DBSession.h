//
//  DBSession.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBMetadata.h"
@protocol DBSessionDelegate;
@interface DBSession : NSObject
{
}


@property(weak)id<DBSessionDelegate> delegate;
@property(strong)DBMetadata *metadata;
-(void)startLoading;
@end



@protocol DBSessionDelegate <NSObject>
-(void)downloadedModuleList:(NSArray*)moduleList moreComing:(BOOL)moreComing;
-(void)listDownloadFailedWithError:(NSError*)error;
-(void)downloadedDetails:(NSArray*)details;
-(void)detailDownloadFailedWithError:(NSError*)error;

@end