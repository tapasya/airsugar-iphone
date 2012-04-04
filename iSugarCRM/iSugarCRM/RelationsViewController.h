//
//  RelationsViewController.h
//  iSugarCRM
//
//  Created by dayanand on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataObject.h"
#import "DBSession.h"
@interface RelationsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,DBLoadSessionDelegate>{
//  NSMutableDictionary *dataSourceDictionary;
}
@property(strong)NSMutableDictionary *dataSourceDictionary;
-(id)initWithDataObject:(DataObject *)dataObject;
-(void) loadDetailviewWithBeanId:(NSString*) beanId beanTitle: (NSString*) beanTitle moduleName:(NSString*) moduleName;
@end
