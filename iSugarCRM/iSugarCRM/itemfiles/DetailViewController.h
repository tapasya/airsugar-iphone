//
//  NearbyDealsListViewController.h
//  Deals
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewMetadata.h"
#import "DBSession.h"
@interface DetailViewController : UITableViewController<DBLoadSessionDelegate>

@property(strong)NSArray *datasource;
@property(strong)DetailViewMetadata *metadata;
@property(strong)NSString *beanId;
+(DetailViewController*)detailViewcontroller:(DetailViewMetadata*)metadata andBeanId:(NSString*)beanId;
@end
