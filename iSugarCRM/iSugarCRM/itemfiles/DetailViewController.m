//
//  NearbyDealsListViewController.m
//  Deals
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "UITableViewCellSectionItem.h"
#import "UITableViewCellItem.h"
#import "SugarCRMMetadataStore.h"
#import "DataObject.h"
#import "DetailViewRowItem.h"
#import "DetailViewSectionItem.h"
@implementation DetailViewController
@synthesize datasource,metadata,beanId,beanTitle;
+(DetailViewController*)detailViewcontroller:(DetailViewMetadata*)metadata beanId:(NSString*)beanId beanTitle:(NSString*)beanTitle
{
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.metadata = metadata;
    NSLog(@"module name %@",metadata.moduleName);
    detailViewController.beanId = beanId;
    detailViewController.beanTitle = beanTitle;
    return detailViewController;
}

-(id)init{
    self = [super init];
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


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark DbSession Load Delegate methods

-(void)session:(DBSession *)session downloadedDetails:(NSArray *)details
{   
    //    for(DataObject * row in details){
    //        NSLog(@"Details for id: %@ :%@",beanId,row);
    //    }
    NSMutableArray* sections = [[NSMutableArray alloc] init];
    for(NSDictionary *sectionItem_ in metadata.sections  )
    {   
        DetailViewSectionItem *sectionItem = [[DetailViewSectionItem alloc] init];
        sectionItem.sectionTitle = [sectionItem_ objectForKey:@"section_name"];
        NSLog(@"section name :%@",sectionItem.sectionTitle);
        NSMutableArray *rowItems = [[NSMutableArray alloc] init];
        NSArray *rows = [sectionItem_ objectForKey:@"rows"];
        for(NSDictionary *rowItem_ in rows)
        {
            DetailViewRowItem *rowItem = [[DetailViewRowItem alloc] init];
            rowItem.label = [rowItem_ objectForKey:@"label"];
            NSMutableArray *fields = [NSMutableArray array];
            for(DataObjectField *field in [rowItem_ objectForKey:@"fields"])
            {
                NSString *value = [[details objectAtIndex:0] objectForFieldName:field.name];
                if (value) 
                {
                    [fields addObject:value];    
                }
            }
            rowItem.values = fields;
            [rowItems addObject:rowItem];
        }
        sectionItem.rowItems = rowItems;
        [sections addObject:sectionItem];
    }
    self.datasource = sections;
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
    self.title = self.beanTitle;
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    DBMetadata *dbMetadata = [sharedInstance dbMetadataForModule:metadata.moduleName];
    DBSession * dbSession = [DBSession sessionWithMetadata:dbMetadata];
    dbSession.delegate = self;
    [dbSession detailsForId:self.beanId];

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
