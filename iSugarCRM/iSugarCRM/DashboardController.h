//
//  DashboardController.h
//  iSugarCRM
//
//  Created by pramati on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLauncherViewController.h"
#import "SyncHandler.h"

@interface DashboardController : MyLauncherViewController <SyncHandlerDelegate>
@property (strong) NSArray *moduleList;
@property BOOL login;
-(void) startModuleSynchronization;
-(void) performLoginAction;
@end
