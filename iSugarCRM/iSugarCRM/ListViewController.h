//
//  ListViewController.h
//  iSugarCRM
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ListViewController : UIViewController<UITabBarDelegate,UITableViewDataSource>
{
    @private
    UITableView *myTableView;
}

+(ListViewController*)listViewControllerForModule:(NSString*)moduleName;
@property(strong)NSString *moduleName;
@property(strong)NSArray *datasource;
@end
