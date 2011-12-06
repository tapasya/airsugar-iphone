//
//  AppDelegate.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceSession.h"
#import "DBSession.h"
@class ViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate,WebserviceSessionDelegate,DBLoadSessionDelegate,DBSyncSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
