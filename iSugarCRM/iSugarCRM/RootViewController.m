//
//  RootViewController.m
//  iSugarCRM
//
//  Created by satyavrat-mac on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ListViewController.h"
#import "SugarCRMMetadataStore.h"
@interface RootViewController()
@property(strong)UIActivityIndicatorView *spinner;
@end

@implementation RootViewController
@synthesize moduleList,spinner;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteSync) name:@"SugarSyncComplete" object:nil];
       
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.tableView.userInteractionEnabled = NO;
    spinner = [[UIActivityIndicatorView alloc] init];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [moduleList  count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [moduleList objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    NSString *modulename = [moduleList objectAtIndex:indexPath.row];
    ListViewMetadata *metadata = [sharedInstance listViewMetadataForModule:modulename];
    NSLog(@"metadata module name %@",metadata.moduleName);
    ListViewController *listViewController = [ListViewController listViewControllerWithMetadata:metadata];
    listViewController.title = metadata.moduleName;
    [self.navigationController pushViewController:listViewController animated:YES];
     
}

#pragma mark --

-(void)didCompleteSync
{   
    NSLog(@"sync complete");
    self.tableView.userInteractionEnabled = YES;
    [self.spinner stopAnimating];
    [self.spinner setHidden:YES];
    
}
@end
