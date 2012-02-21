//
//  SynchSettingsViewController.h
//  iSugarCRM
//
//  Created by dayanand on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kStartDateIdentifier            @"key_sync_start_date"
#define kEndDateIdentifier              @"key_sync_end_date"

#define kSyncNowCellIdentifier          @"Sync Now"
#define kEraseAllCellIdentifier         @"Erase All"

#define kStartDateTag                   1
#define kEndDateTag                     2

@interface SyncSettingsViewController : UITableViewController

@property (nonatomic, strong) NSArray* settingsArray;
@property (nonatomic, retain) UIDatePicker *pickerView; 
@property (nonatomic, retain) NSDateFormatter *dateFormatter; 
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) NSString *startDate;
@property (nonatomic, retain) NSString *endDate;

-(UIBarButtonItem *)addNextButton;

@end
