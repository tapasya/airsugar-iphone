//
//  NearbyDealsListItem.m
//  Deals
//
//  Created by Ved Surtani on 07/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewRowItem.h"

@implementation DetailViewRowItem
@synthesize label,value;

-(CGFloat)heightForCell
{
    return 50.0f;
}


-(UITableViewCell*)reusableCellForTableView:(UITableView*)tableView{
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:[self reusableCellIdentifier]];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                                                reuseIdentifier:[self reusableCellIdentifier]];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",label,value];
    return cell;
    
}

-(NSString*)reusableCellIdentifier
{
    return [[self class] description];
}
@end
