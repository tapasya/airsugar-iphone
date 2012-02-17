//
//  UITableViewItem.h

//
//  Created by Ved Surtani on 07/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 @protocol		UITableViewCellRowItem
 @brief			protocol for the items which map the data model objects to the UITableViewCells
 @details		Any item that maps the data model objects to the UITableViewCells implements this protocol to define the 
 height for the UITableViewCell, to give the resusable identifier for the cell and to give the reusable UITableViewCell 
 for UITableView with the reusableCellIdentifier.
 */
@protocol UITableViewCellRowItem

@required

/*!
 @brief		Called from tableView:heightForRowAtIndexPath: to get the height for the UITableViewCell
 @details	tableView:heightForRowAtIndexPath: calls the item's heightForCell method to get the height for the 
 UITableViewCell
 */
-(CGFloat)heightForCell:(UITableView*)tableView;

/*!
 @brief         Use this method to get a reusable UITableViewCell
 @param         @ref UITableView
 @details       Use this method to get a reusable UITableViewCell for the given UITableView with the reusableCellIdentifier
 */
-(UITableViewCell*)reusableCellForTableView:(UITableView*)tableView;

/*!
 @brief		reusable cell identifier for the UITableViewCell in UITableView
 */
-(NSString*)reusableCellIdentifier;

@end
