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

enum SYNC_TYPE {
    SYNC_TYPE_DEFAULT = 0,
    SYNC_TYPE_WITH_TIME_STAMP,
    SYNC_TYPE_WITH_DATES,
    SYNC_TYPE_WITH_TIME_STAMP_AND_DATES
    };

typedef void (^SyncHandlerCompletionBlock) ();

typedef void (^SyncHandlerErrorBlock)(NSArray* errors);

@interface SyncHandler : NSObject<WebserviceSessionDelegate> {

@private
    NSOperationQueue        *mRequestQueue;
}

+ (SyncHandler*)sharedInstance;

- (void)addSyncSession:(WebserviceSession*)session;

// Complete app sync methods
-(void) runSyncforModules:(NSArray*) modules withSyncType:(enum SYNC_TYPE) syncType;

// Callback blocks
@property (nonatomic, strong) SyncHandlerCompletionBlock completionBlock;

@property (nonatomic, strong) SyncHandlerErrorBlock errorBlock;

@end
