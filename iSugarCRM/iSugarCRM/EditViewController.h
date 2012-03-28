//
//  EditViewController.h
//  iSugarCRM
//
//  Created by dayanand on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditViewRowItem.h"

@interface EditViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,EditViewRowItemDelegate>{
    @private
    NSIndexPath * selectedIndexPath;
    CGSize kbBeginSize;
}
@property(strong) DataObjectMetadata* metadata;
+(EditViewController*)editViewControllerWithMetadata:(DataObjectMetadata*)metadata;
+(EditViewController*)editViewControllerWithMetadata:(DataObjectMetadata*)metadata andDetailedData:(NSArray *)detailedData;
@end
