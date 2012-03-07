//
//  SplitViewC.m
//  iSugarCRM
//
//  Created by pramati on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplitViewController.h"

@implementation SplitViewController
@synthesize master=_mvc;
@synthesize detail=_dvc;

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

-(void) setDetail:(DetailViewController_pad *)dvc
{
    _dvc = dvc;
    self.delegate = dvc;
}

-(void) setMaster:(ListViewController_pad *)master
{
    _mvc = master;
    master.detailViewDelegate = self;
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    if (self.detail.popoverController != nil) {
        [self.detail.popoverController dismissPopoverAnimated:YES];
    }
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void) loadDetailViewWithBeanId:(NSString *)beanId :(NSString *)beanTitle
{
    if(!self.detail)
    {
        self.detail = [[DetailViewController_pad alloc] init];
    }
    
    if (self.detail.popoverController != nil) {
        [self.detail.popoverController dismissPopoverAnimated:YES];
    }

    self.detail.beanId = beanId;
    self.detail.beanTitle = beanTitle;
    self.detail.navigationItem.title = beanTitle;
    [self.detail loadDataFromDb];
}

@end
