
//  Created by Ved Surtani on 09/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UITableViewCellSectionItem <NSObject>
@required
/*!
 @property      rowItems
 @brief         Array containing @ref UITableViewCellRow items
 */
@property(strong)NSArray *rowItems;
@optional 
@property(strong)NSString *sectionTitle;
@end
