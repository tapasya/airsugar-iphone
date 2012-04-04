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
}
@end
@implementation ListViewController_pad
@synthesize detailViewDelegate=_delegate;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
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
            if ([beanIds count]>=2) {
                [beanIds removeObjectAtIndex:0];
            }
            [beanIds addObject:beanId];
        } else {
            [appDelegate.recentItems setObject:[NSMutableArray arrayWithObject:beanId] forKey:self.moduleName];
        }
        if(self.detailViewDelegate)
        {
            [self.detailViewDelegate loadDetailViewWithBeanId:beanId beanTitle:beanTitle moduleName:self.moduleName];
        }
    }
}

-(void)showActionSheet{
    //[self.actionSheet showInView:self.view];
    UIActionSheet *_actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [_actionSheet addButtonWithTitle:@"Add"];
    [_actionSheet addButtonWithTitle:@"Delete"];
    [_actionSheet addButtonWithTitle:@"Cancel"];
    _actionSheet.delegate = self;
    _actionSheet.destructiveButtonIndex = 1;
    [_actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

-(void) displayModuleSetting
{
    ModuleSettingsViewController *msvc = [[ModuleSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    msvc.moduleName = self.title;
    msvc.delegate = self;
    popOver = [[UIPopoverController alloc] initWithContentViewController:msvc];
    [popOver presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void) sortSelectionChanged
{
    [super sortData];
    [myTableView reloadData];
}
@end
