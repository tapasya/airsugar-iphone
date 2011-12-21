//
//  NearbyDealsListSectionItem.h
//  Deals
//
//  Created by Ved Surtani on 09/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableViewCellSectionItem.h"
@interface DetailViewSectionItem : NSObject<UITableViewCellSectionItem>
@property(strong)NSArray *rowItems;
@property(strong)NSString *sectionTitle;
@end
