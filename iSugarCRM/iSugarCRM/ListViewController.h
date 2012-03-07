//
//  ListViewController.h
//  iSugarCRM
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewMetadata.h"
#import "DBSession.h"
#import "SyncHandler.h"
@interface ListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,DBLoadSessionDelegate, UISearchBarDelegate, SyncHandlerDelegate,UIActionSheetDelegate>
{
    @private
    UITableView *myTableView;
    UISearchBar *sBar;
    int *tableDataMask;
}

+(ListViewController*)listViewControllerWithMetadata:(ListViewMetadata*)metadata;
+(ListViewController*)listViewControllerWithModuleName:(NSString*)module;
@property(strong)NSString *moduleName;
@property(strong)NSArray *datasource;
@property(strong) NSMutableArray *tableData;
@property(strong)ListViewMetadata *metadata;
-(void)displayModuleSetting;
-(void)syncModule;
@end
