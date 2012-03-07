//
//  DetailViewController_pad.h
//  iSugarCRM
//
//  Created by pramati on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface DetailViewController_pad : DetailViewController<UISplitViewControllerDelegate>
@property (nonatomic, retain) UIPopoverController *popoverController;
@end
