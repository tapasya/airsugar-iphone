//
//  ModuleSettingsViewController.h
//  iSugarCRM
//
//  Created by pramati on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleSettingsDataStore.h"

@protocol SortDelegate
-(void) sortSelectionChanged;
@end

@interface ModuleSettingsViewController : UITableViewController
{
    NSMutableArray* _moduleSettings;
}
@property (nonatomic, retain) NSString* moduleName;
@property (nonatomic, retain) ModuleSettingsDataStore *moduleSettingsStore;
@property (strong) id<SortDelegate> delegate;
@end
