//
//  RelationsViewController.m
//  iSugarCRM
//
//  Created by dayanand on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "DBSession.h"
#import "RelationsViewController.h"
#import "DetailViewController.h"
#import "DataObject.h"
#import "ListViewMetadata.h"

@interface RelationsViewController()
@property(strong) UITableView *_tableView;
@property(strong) NSMutableDictionary* dataObjectStore;
-(ListViewMetadata *)metaDataForModule:(NSString*)modulename;
-(void)fetchDataObjects;
@end

@implementation RelationsViewController

@synthesize _tableView,dataSourceDictionary,dataObjectStore;

#pragma mark - init methods

-(id)initWithDataObject:(DataObject *)dataObject
{
    if(self = [super init])
    {
        dataSourceDictionary = dataObject.relationships;
    }
    return self;
}

-(ListViewMetadata *)metaDataForModule:(NSString *)modulename
{
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    return [sharedInstance listViewMetadataForModule:[modulename capitalizedString]];
}
-(DBMetadata *)dbMetaDataForModule:(NSString *)modulename
{
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    id metadata = [sharedInstance dbMetadataForModule:[modulename capitalizedString]];
    return metadata;
}

#pragma mark - View lifecycle

- (void)loadView 
{
    [super loadView];
    CGRect mainFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat width = mainFrame.size.width;
    CGFloat height = mainFrame.size.height;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,width, height)];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissView:)];
    [self.view addSubview:_tableView];
    [self.view setAutoresizesSubviews:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchDataObjects];
}
-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [super viewDidAppear:animated];
    if([[dataSourceDictionary allKeys] count]==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"No RelationsShips" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)dismissView:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - TableView DataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[dataObjectStore allKeys]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionName = [[dataObjectStore allKeys] objectAtIndex:section];
    NSArray* objectArray = [dataObjectStore objectForKey:sectionName];
    return [objectArray count];
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[dataObjectStore allKeys] objectAtIndex:section] capitalizedString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSString *sectionName = [[[dataObjectStore allKeys]objectAtIndex:indexPath.section] capitalizedString];
    NSArray* objectArray = [dataObjectStore objectForKey:sectionName];
    
    DataObject *dataObjectForRow = [objectArray objectAtIndex:indexPath.row];
    ListViewMetadata *metadata = [self metaDataForModule:sectionName];
    cell.textLabel.text = [dataObjectForRow objectForFieldName:metadata.primaryDisplayField.name];
     
    for(DataObjectField *otherField in metadata.otherFields)
    {
        if ([dataObjectForRow objectForFieldName:otherField.name]) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",otherField.label,[dataObjectForRow objectForFieldName:otherField.name]];
        }
        else{
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: NA",otherField.label];
        }
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0F;
}

#pragma mark - TableView DataSource methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionName = [[dataObjectStore allKeys]objectAtIndex:indexPath.section];
    NSArray* objectArray = [dataObjectStore objectForKey:sectionName];
    sectionName = [sectionName capitalizedString];
    id beanId = [[objectArray objectAtIndex:indexPath.row] objectForFieldName:@"id"];
    id beanTitle;
    if ([[objectArray objectAtIndex:indexPath.row] objectForFieldName:@"name"] != nil)
        beanTitle = [[objectArray objectAtIndex:indexPath.row] objectForFieldName:@"name"];
    else
        beanTitle = @"Back";
    
    DetailViewController *detailViewController = [DetailViewController detailViewcontroller:[[SugarCRMMetadataStore sharedInstance] detailViewMetadataForModule:sectionName] beanId:beanId beanTitle:beanTitle];
    detailViewController.shouldCotainToolBar = NO;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark Utility methods
-(void)fetchDataObjects{
    dataObjectStore = [NSMutableDictionary dictionary];
    for(NSString* key in [dataSourceDictionary allKeys]){
        for(NSString *beanId in  [dataSourceDictionary objectForKey:key]){
            DBSession *session  = [DBSession sessionWithMetadata:[self dbMetaDataForModule:key]];
            session.delegate = self;
            [session loadDetailsForId:beanId];
        }
    }
}
#pragma mark DBSession Load delegate

-(void)session:(DBSession*)session downloadedDetails:(NSArray*)details{
    if([dataObjectStore objectForKey:session.metadata.tableName]){
     NSMutableArray *beans = [dataObjectStore objectForKey:session.metadata.tableName];
        [beans addObject:[details objectAtIndex:0]];
    } else {
        [dataObjectStore setObject:[NSMutableArray arrayWithObject:[details objectAtIndex:0]] forKey:session.metadata.tableName];
    }
}
@end
