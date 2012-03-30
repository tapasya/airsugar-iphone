//
//  RelationsViewController.h
//  iSugarCRM
//
//  Created by dayanand on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataObject.h"
@interface RelationsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
-(id)initWithDataObject:(DataObject *)dataObject;
@end
