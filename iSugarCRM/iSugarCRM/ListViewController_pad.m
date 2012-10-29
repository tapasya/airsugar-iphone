//
//  ListViewController_pad.m
//  iSugarCRM
//
//  Created by pramati on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListViewController_pad.h"
#import "DetailViewController.h"
#import "DataObject.h"
#import "AppDelegate.h"
#import "DashboardController.h"
#import "ModuleSettingsViewController.h"

@interface ListViewController_pad()
{
    @private
    UIPopoverController *popOver;
    UIActionSheet *_actionSheet;
    UIBarButtonItem* modulesButton;
}
@end
@implementation ListViewController_pad
@synthesize selectionBlock = _selectionBlock;

+(ListViewController_pad*)listViewControllerWithMetadata:(ListViewMetadata*)metadata
{
    ListViewController_pad *lViewController = [[ListViewController_pad alloc] init];
    lViewController.metadata = metadata;
    lViewController.moduleName = metadata.moduleName;
    return lViewController;
}

+(ListViewController_pad*)listViewControllerWithModuleName:(NSString*)module
{
    ListViewController_pad *lViewController = [[ListViewController_pad alloc] init];
    //lViewController.moduleName = module;
    return lViewController;
}

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
    modulesButton = [[UIBarButtonItem alloc] initWithTitle:@"Modules" style:UIBarButtonItemStyleBordered target:self  action:@selector(showDashboard:)];
    self.navigationItem.leftBarButtonItem = modulesButton;
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        self.navigationItem.rightBarButtonItem.customView.hidden = YES;
    }
    
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? nil : modulesButton;
    [super viewWillAppear:animated];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(popOver)
    {
        [popOver dismissPopoverAnimated:YES];
        popOver = nil;
    }
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(self.editing)
    {
        [self toggleEditing];
    }
    if(_actionSheet && [_actionSheet isVisible])
    {
        [_actionSheet dismissWithClickedButtonIndex:2 animated:YES];
        _actionSheet = nil;
    }
    self.navigationItem.leftBarButtonItem = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? nil : modulesButton;
    
    if(self.navigationItem.rightBarButtonItem.customView)
    {
        self.navigationItem.rightBarButtonItem.customView.hidden = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    if(!myTableView.editing)
    {
        //tableDataMask[indexPath.row] = 1;//changing the value of array at particular index to change font color of the cell.
        id beanTitle = [[self.tableData objectAtIndex:indexPath.row] objectForFieldName:@"name"];
        id beanId =[[self.tableData objectAtIndex:indexPath.row] objectForFieldName:@"id"];
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if ([appDelegate.recentItems objectForKey:self.moduleName]) {
            NSMutableArray *beanIds = [appDelegate.recentItems objectForKey:self.moduleName];
            if ([beanIds count]>=5) {
                [beanIds removeObjectAtIndex:0];
            }
            [beanIds addObject:beanId];
        } else {
            [appDelegate.recentItems setObject:[NSMutableArray arrayWithObject:beanId] forKey:self.moduleName];
        }
        if(nil !=self.selectionBlock)
        {
            self.selectionBlock(beanId, beanTitle, self.moduleName);
        }
    }
}   

-(void)showActionSheet{
    [sBar resignFirstResponder];
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [_actionSheet addButtonWithTitle:@"Add"];
    [_actionSheet addButtonWithTitle:@"Delete"];
    _actionSheet.delegate = self;
    _actionSheet.destructiveButtonIndex = 1;
    CGRect frame = self.navigationItem.rightBarButtonItem.customView.frame;
    [_actionSheet showFromRect:CGRectMake(frame.origin.x + 2*frame.size.width/3, 1, frame.size.width/3, 1) inView:self.view animated:YES];
}

-(void) displayModuleSetting
{
   [sBar resignFirstResponder];
    ModuleSettingsViewController *msvc = [[ModuleSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    msvc.moduleName = self.title;
    msvc.delegate = self;
    popOver = [[UIPopoverController alloc] initWithContentViewController:msvc];
    CGRect frame = self.navigationItem.rightBarButtonItem.customView.frame;
    [popOver presentPopoverFromRect:CGRectMake(frame.origin.x, 1, frame.size.width/3, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void) sortSelectionChanged
{
    [super sortData];
    [myTableView reloadData];
}
@end
