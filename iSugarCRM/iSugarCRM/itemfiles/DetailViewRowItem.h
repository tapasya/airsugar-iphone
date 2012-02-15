
//  Created by Ved Surtani on 07/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableViewCellItem.h"
#import "DataObject.h"
@interface DetailViewRowItem : NSObject<UITableViewCellRowItem>
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSArray *values;
@end
