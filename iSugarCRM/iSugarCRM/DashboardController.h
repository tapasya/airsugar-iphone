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

@interface DashboardController : MyLauncherViewController
@property (strong) NSArray *moduleList;
-(void) performLoginAction;
@end
