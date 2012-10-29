//
//  SplitViewC.h
//  iSugarCRM
//
//  Created by pramati on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController_pad.h"
#import "DetailViewController_pad.h"

@interface SplitViewController : UISplitViewController
@property (nonatomic, strong) UIViewController* master;
@property (nonatomic, strong) DetailViewController_pad* detail;
@end
