//
//  RecentViewController_pad.m
//  iSugarCRM
//
//  Created by pramati on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentViewController_pad.h"
#import "AppDelegate.h"
#import "DashboardController.h"

@implementation RecentViewController_pad
@synthesize selectionBlock = _selectionBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Modules" style:UIBarButtonItemStyleBordered target:self  action:@selector(showDashboard:)];
    
}

-(IBAction) showDashboard:(id)sender
{
    AppDelegate* delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    DashboardController *dc = [[DashboardController alloc] init];
    dc.title = @"Modules";
    delegate.nvc = [[UINavigationController alloc] initWithRootViewController:dc];
    delegate.window.rootViewController = delegate.nvc;
    [delegate.window makeKeyAndVisible];
    //[delegate showDashboardController];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void) loadDetailviewWithBeanId:(NSString *)beanId beanTitle:(NSString *)beanTitle moduleName:(NSString *)moduleName
{
    if(self.selectionBlock)
    {
        self.selectionBlock(beanId, beanTitle, moduleName);
    }
}

@end
