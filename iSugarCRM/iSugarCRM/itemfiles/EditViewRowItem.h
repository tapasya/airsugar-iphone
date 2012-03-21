//
//  EditViewRowItem.h
//  iSugarCRM
//
//  Created by dayanand on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableViewCellItem.h"
#import "DataObject.h"

@interface EditViewRowItem :  NSObject<UITableViewCellRowItem>
@property (strong) NSString *type;
@property (strong) NSString *action;
@property (strong) NSString *label;
@property (strong) NSString *value;
@property (strong) id delegate;
@end

@protocol EditViewRowItemDelegate <NSObject>
@end
