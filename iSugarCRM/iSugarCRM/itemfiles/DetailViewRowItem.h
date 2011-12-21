//
//  NearbyDealsListItem.h
//  Deals
//
//  Created by Ved Surtani on 07/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableViewCellItem.h"

@interface DetailViewRowItem : NSObject<UITableViewCellRowItem>


@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@end
