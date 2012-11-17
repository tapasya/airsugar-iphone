//
//  SynchSettingsViewController.h
//  iSugarCRM
//
//  Created by dayanand on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSyncNowCellIdentifier          @"Sync Now"
#define kEraseAllCellIdentifier         @"Erase All"

#define kMaxRecordsCellIdentifier       @"Max Records"

#define kStartDateTag                   1
#define kEndDateTag                     2

@interface SyncSettingsViewController : UITableViewController<UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray* settingsArray;       //move these to class extenstion
@property (nonatomic, retain) UIDatePicker *pickerView; 
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) NSString *startDate;
@property (nonatomic, retain) NSString *endDate;

-(UIBarButtonItem *)addNextButton;

@end
