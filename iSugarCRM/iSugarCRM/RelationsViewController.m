//
//  RelationsViewController.m
//  iSugarCRM
//
//  Created by dayanand on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RelationsViewController.h"
#import "DetailViewController.h"
#import "DataObject.h"
#import "ListViewMetadata.h"

@interface RelationsViewController()
{
    NSDictionary *relationsDictionary;
}
    @property(strong) UITableView *_tableView;
-(ListViewMetadata *)metaDataForModule:(NSString*)modulename;
@end

@implementation RelationsViewController

@synthesize _tableView;

#pragma mark - init methods

-(id)initWithDataSource:(NSDictionary *)dataSource
{
    if(self = [super init])
    {
        relationsDictionary = dataSource;
    }
    return self;
}

-(ListViewMetadata *)metaDataForModule:(NSString *)modulename
{
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    return [sharedInstance listViewMetadataForModule:modulename];
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
    
    [self.view addSubview:_tableView];
    [self.view setAutoresizesSubviews:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - TableView DataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[relationsDictionary allKeys]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionName = [[relationsDictionary allKeys] objectAtIndex:section];
    NSArray* objectArray = [relationsDictionary objectForKey:sectionName];
    return [objectArray count];
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return [[relationsDictionary allKeys] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSString *sectionName = [[relationsDictionary allKeys]objectAtIndex:indexPath.section];
    NSArray* objectArray = [relationsDictionary objectForKey:sectionName];
    
    /*
     CODE RELATED TO ACTUAL DATA
     */
//    DataObject *dataObjectForRow = [objectArray objectAtIndex:indexPath.row];
//    ListViewMetadata *metadata = [self metaDataForModule:sectionName];
//    cell.textLabel.text = [dataObjectForRow objectForFieldName:metadata.primaryDisplayField.name];
     
//    for(DataObjectField *otherField in metadata.otherFields)
//    {
//        if ([dataObjectForRow objectForFieldName:otherField.name]) {
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",otherField.label,[dataObjectForRow objectForFieldName:otherField.name]];
//        }
//        else{
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: NA",otherField.label];
//        }
//    }
    
    /*
     CODE RELATED TO DUMMY DATA
     */
    NSString *value = [objectArray objectAtIndex:indexPath.row];
    cell.textLabel.text = value;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0F;
}

#pragma mark - TableView DataSource methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     CODE RELATED TO ACTUAL DATA
     */
//    NSString *sectionName = [[relationsDictionary allKeys]objectAtIndex:indexPath.section];
//    NSArray* objectArray = [relationsDictionary objectForKey:sectionName];
//    id beanTitle = [(DataObject *)[objectArray objectAtIndex:indexPath.row] objectForFieldName:@"name"];
//    id beanId =[(DataObject *)[objectArray objectAtIndex:indexPath.row]objectForFieldName:@"id"];
//    DetailViewController *detailViewController = [DetailViewController detailViewcontroller:[[SugarCRMMetadataStore sharedInstance] detailViewMetadataForModule:sectionName] beanId:beanId beanTitle:beanTitle];
//    [self.navigationController pushViewController:detailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
