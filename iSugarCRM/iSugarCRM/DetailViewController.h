//
//  DetailViewController.h
//  iSugarCRM
//
//  Created by Satyavrat Mudgil on 19/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewMetadata.h"
@interface DetailViewController : UIViewController{
@private UITableView *myTableView;
}
+(DetailViewController*)detailViewControllerWithMetadata:(DetailViewMetadata*)metadata andBeanId:(NSString*)beanId;
@property(strong)NSString *beanId;
@property(strong)NSArray *datasource;
@property(strong)DetailViewMetadata *metadata;
@end
