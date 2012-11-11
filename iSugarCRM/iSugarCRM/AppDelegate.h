//
//  AppDelegate.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "SyncHandler.h"
@class ViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong) SyncHandler *syncHandler;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *nvc;
@property (strong) NSMutableDictionary *recentItems;

-(void) syncWithType:(enum SYNC_TYPE) type completionBlock:(SyncHandlerCompletionBlock) completionBlock errorBlock:(SyncHandlerErrorBlock) errorBlock;

-(void)logout;
-(BOOL)wipeDatabase;
-(void)resetApp;

-(void)showDashboardController;
-(void)showSyncSettingViewController;

//what are these for?
-(void)showWaitingAlertWithMessage:(NSString *)message;
-(void)dismissWaitingAlert;
@end
