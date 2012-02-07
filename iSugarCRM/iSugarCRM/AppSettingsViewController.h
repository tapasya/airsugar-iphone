//
//  AppSettingsViewController.h
//  iSugarCRM
//
//  Created by pramati on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kUsernameIdentifier             @"key_user_name"
#define kPasswordIdentifier             @"key_password"
#define kRestUrlIdentifier              @"key_rest_url"

#define kStartDateIdentifier            @"key_sync_start_date"
#define kEndDateIdentifier              @"key_sync_end_date"

#define kUsernameTag                    1
#define kPasswordTag                    2
#define kStartDateTag                   3
#define kEndDateTag                     4
#define kURLTag                         5


@interface AppSettingsViewController : UITableViewController<UITextFieldDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSArray* settingsArray;

@property (nonatomic, retain) UIDatePicker *pickerView; 
@property (nonatomic, retain) NSDateFormatter *dateFormatter; 
@property (nonatomic, retain) UIBarButtonItem *saveButton;
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *startDate;
@property (nonatomic, retain) NSString *endDate;
@end
