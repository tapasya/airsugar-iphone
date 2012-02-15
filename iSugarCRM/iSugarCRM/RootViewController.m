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
- (id)init
{
    self = [super init];
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
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(40,self.view.frame.size.width/2-50,250,50)];
    loadingLabel.text = @"Please Wait Loading Data...";
    [self.view addSubview:loadingLabel];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(self.view.frame.size.width/2-10, self.view.frame.size.height/2-10, 20, 20);
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
    ListViewController *listViewController = [ListViewController listViewControllerWithMetadata:metadata];
    listViewController.title = metadata.moduleName;
    [self.navigationController pushViewController:listViewController animated:YES];
     
}

#pragma mark --

-(void)didCompleteSync
{   
    NSLog(@"sync complete");
    [self.spinner stopAnimating];
    [self.spinner setHidden:YES];
    myTableView = [[UITableView alloc] initWithFrame:self.view.frame];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    
}
@end
