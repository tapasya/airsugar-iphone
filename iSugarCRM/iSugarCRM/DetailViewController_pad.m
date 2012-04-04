//
//  DetailViewController_pad.m
//  iSugarCRM
//
//  Created by pramati on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController_pad.h"
#import "EditViewController.h"

@implementation DetailViewController_pad
@synthesize popoverController;
@synthesize defaultView;
@synthesize createButton;
@synthesize infoLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.shouldCotainToolBar = YES;
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

-(void)viewDidLoad
{
    if(self.shouldCotainToolBar == YES)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidUnload
{
    [self setDefaultView:nil];
    [self setCreateButton:nil];
    [self setInfoLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    if(!self.beanId)
    {   
        if(self.metadata)
        {
            [[NSBundle mainBundle] loadNibNamed:@"DefaultDetailView" owner:self options:nil];
            [self.createButton addTarget:self action:@selector(createButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.tableView addSubview:defaultView];    
        }
        self.tableView.separatorColor = [UIColor clearColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void) addToolbar
{
    if(self.shouldCotainToolBar)
    {
        CGRect toolbarFrame = self.navigationController.toolbar.frame;
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 200, toolbarFrame.size.height)];
        
        UIBarButtonItem* composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createButtonClicked:)];
        UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editDetails)];
        UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonClicked:)];
        UIBarButtonItem* relatedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(relatedButtonClicked:)];
        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSMutableArray *barItems = [[NSMutableArray alloc] initWithObjects:composeButton, flexButton, editButton, flexButton, deleteButton, flexButton, relatedButton, nil];
        [toolbar setItems:barItems];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    }
}

-(void)session:(DBSession *)session downloadedDetails:(NSArray *)details
{
    [super session:session downloadedDetails:details];
    if(self.beanId)
    {
        if(defaultView){
            [defaultView removeFromSuperview];
            defaultView = nil;
        }
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
        self.tableView.separatorColor = [UIColor lightGrayColor];
        [self addToolbar];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)splitViewController: (UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.metadata.moduleName;
    if(!barButtonItem.title)
    {
        barButtonItem.title = aViewController.title;
    }
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:NO];
    self.popoverController = pc;
}


// called when the view is shown again in the split view, invalidating the button and popover controller
//
- (void)splitViewController: (UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    self.popoverController = nil;
}

- (BOOL)splitViewController:(UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation 
{
    //NSLog(@"Orientation is portrait %@", UIInterfaceOrientationIsPortrait(orientation) ? @"YES" : @"NO");
    return UIInterfaceOrientationIsPortrait(orientation);
    //return NO;
}


@end
