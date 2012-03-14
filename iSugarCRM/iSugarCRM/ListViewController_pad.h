//
//  ListViewController_pad.h
//  iSugarCRM
//
//  Created by pramati on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"
#import "ModuleSettingsViewController.h"

@protocol DetailViewDelegate;
@interface ListViewController_pad : ListViewController<SortDelegate>
+(ListViewController_pad*)listViewControllerWithMetadata:(ListViewMetadata*)metadata;
+(ListViewController_pad*)listViewControllerWithModuleName:(NSString*)module;
@property (weak) id<DetailViewDelegate> detailViewDelegate;
@end

@protocol DetailViewDelegate
-(void) loadDetailViewWithBeanId:(NSString*) beanId:(NSString*) beanTitle;
@end
