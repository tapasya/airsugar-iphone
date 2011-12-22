//
//  NearbyDealsListViewController.m
//  Deals
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
//#import "NearbyDealsListItem.h"
#import "UITableViewCellSectionItem.h"
#import "UITableViewCellItem.h"
#import "SugarCRMMetadataStore.h"

@implementation DetailViewController
@synthesize datasource,metadata,beanId;
+(DetailViewController*)detailViewcontroller:(DetailViewMetadata*)metadata andBeanId:(NSString*)beanId
{
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.metadata = metadata;
    detailViewController.beanId = beanId;
    return detailViewController;
}

-(id)init{
    self = [super init];
    [self addObserver:self forKeyPath:@"datasource" options:NSKeyValueObservingOptionNew context:nil];
    self.title = metadata.moduleName;
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    DBMetadata *dbMetadata = [sharedInstance dbMetadataForModule:metadata.moduleName];
    DBSession * dbSession = [DBSession sessionWithMetadata:dbMetadata];
    dbSession.delegate = self;
    [dbSession detailsForId:self.beanId];
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - KVO
- (void)didChangeValueForKey:(NSString *)key
{
    if(key == @"datasource")
    {
        [self.tableView reloadData];
    }
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark DbSession Load Delegate methods

-(void)session:(DBSession *)session downloadedDetails:(NSArray *)details
{   
   // datasource = moduleList;
    [self.tableView reloadData];
}
-(void)session:(DBSession *)session detailDownloadFailedWithError:(NSError *)error
{
    NSLog(@"Error: %@",[error localizedDescription]);
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [datasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    id<UITableViewCellSectionItem> sectionItem = [datasource objectAtIndex:section];
    return [[sectionItem rowItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewCellSectionItem> sectionItem = [datasource objectAtIndex:indexPath.section];
    id<UITableViewCellRowItem> rowItem  = [[sectionItem rowItems] objectAtIndex:indexPath.row];
    return [rowItem reusableCellForTableView:tableView];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewCellSectionItem> sectionItem = [datasource objectAtIndex:indexPath.section];
    id<UITableViewCellRowItem> rowItem  = [[sectionItem rowItems] objectAtIndex:indexPath.row];
    return [rowItem heightForCell];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<UITableViewCellSectionItem> sectionItem = [datasource objectAtIndex:section];
    if ([sectionItem sectionTitle] != nil) {
        return [sectionItem sectionTitle];
    }
    return @"";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
