//
//  SyncHandler.h
//  iSugarCRM
//
//  Created by satyavrat-mac on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBSession.h"
#import "DownloadOperation.h"
#import "UploadOperation.h"

enum SYNC_TYPE {
    SYNC_TYPE_DEFAULT = 0,
    SYNC_TYPE_WITH_TIME_STAMP,
    SYNC_TYPE_WITH_DATES,
    SYNC_TYPE_WITH_TIME_STAMP_AND_DATES
    };

typedef void (^SyncHandlerCompletionBlock) ();

typedef void (^SyncHandlerErrorBlock)(NSArray* errors);

@interface SyncHandler : NSObject< DownloadCompletionDelegate, UploadCompletionDelegate> {

@private
    NSOperationQueue        *mRequestQueue;
}

+ (SyncHandler*)sharedInstance;

// Complete app sync methods
-(void) runSyncforModules:(NSArray*) modules withSyncType:(enum SYNC_TYPE) syncType;

// Callback blocks
@property (nonatomic, copy) SyncHandlerCompletionBlock completionBlock;

@property (nonatomic, copy) SyncHandlerErrorBlock errorBlock;

@end
