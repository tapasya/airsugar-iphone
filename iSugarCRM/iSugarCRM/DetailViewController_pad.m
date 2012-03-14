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
        [[NSBundle mainBundle] loadNibNamed:@"DefaultDetailView" owner:self options:nil];
        [self.createButton addTarget:self action:@selector(createButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:defaultView];    
        self.tableView.separatorColor = [UIColor clearColor];
    }
}

-(IBAction)createButtonClicked:(id)sender
{
    SugarCRMMetadataStore *metadataStore= [SugarCRMMetadataStore sharedInstance];
    EditViewController *editViewController = [EditViewController editViewControllerWithMetadata:[metadataStore objectMetadataForModule:self.metadata.moduleName]];
    editViewController.title = @"Add Record";
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editViewController];
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentModalViewController:navController animated:YES];        
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
