//
//  RootViewController.h
//  iSugarCRM
//
//  Created by satyavrat-mac on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>
{
   @private UITableView *tableView;
}
@property (strong) NSArray *moduleList;
@end
