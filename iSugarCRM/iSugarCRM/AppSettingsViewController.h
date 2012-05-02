//
//  AppSettingsViewController.h
//  iSugarCRM
//
//  Created by pramati on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#define kUsernameIdentifier             @"key_user_name" //why are these defined in header file? 
//#define kPasswordIdentifier             @"key_password"
//#define kRestUrlIdentifier              @"key_rest_url"
//

#define kSyncSettingsIdentifier         @"Sync Settings" //these too?

#define kUsernameTag                    1
#define kPasswordTag                    2
#define kURLTag                         3



@interface AppSettingsViewController : UITableViewController<UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
@end
