//
//  ListViewController.m
//  iSugarCRM
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "ListViewMetadata.h"
#import "SugarCRMMetadataStore.h"
#import "DBSession.h"
#import "DataObject.h"
#import "ModuleSettingsViewController.h"
#import "ModuleSettingsDataStore.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "stdlib.h"
#import "EditViewController.h"

#define kActionSheetAddButtonIndex            0
#define kActionSheetDeleteButtonIndex         1
#define kActionSheetCancelButtonIndex         2

#define kSegementedControlSettingsButtonIndex     0
#define kSegementedControlSyncButtonIndex         1
#define kSegementedControlTempButtonIndex         2

#define kEditToolbarTag                        1001

@interface ListViewController()
{
    UIActivityIndicatorView* activityIndicator;
    UILabel* syncLabel;
}
-(void) showProgress;
-(void) hideProgress;
-(void) loadData;
-(void) sortData;
-(void) showActionSheet;
-(void) markItemAsDelete;
-(void) intializeTableDataMask;//this function is to intialize an array of tableData size which contains values 1 or 0.
@property (strong) UIActionSheet *_actionSheet;
@property(nonatomic, retain) UISegmentedControl *segmentedControl;
@end

@implementation ListViewController
@synthesize moduleName,datasource,metadata, tableData;
@synthesize segmentedControl;
@synthesize _actionSheet;


+(ListViewController*)listViewControllerWithMetadata:(ListViewMetadata*)metadata
{
    ListViewController *lViewController = [[ListViewController alloc] init];
    lViewController.metadata = metadata;
    lViewController.moduleName = metadata.moduleName;
    return lViewController;

}

+(ListViewController*)listViewControllerWithModuleName:(NSString*)module
{
    ListViewController *lViewController = [[ListViewController  alloc] init];
    //lViewController.moduleName = module;
    return lViewController;
}

-(id)init{
    if (self=[super init]) {
        myTableView = [[UITableView alloc] init];
        tableData = [[NSMutableArray alloc] init];
    }
    return self;
}

-(UISegmentedControl *) segmentedControl{
    if (!segmentedControl) {
        segmentedControl = [[UISegmentedControl alloc] initWithItems:nil];
        [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"settings.png"] atIndex:kSegementedControlSettingsButtonIndex animated:YES];
        [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"sync.png"] atIndex:kSegementedControlSyncButtonIndex animated:YES];
        [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"sync.png"] atIndex:kSegementedControlTempButtonIndex animated:YES];
    }
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.frame = CGRectMake(0, 0, 90, 30);
    segmentedControl.momentary = YES;
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    return segmentedControl;
}

-(void)segmentAction:(id)sender{
    UISegmentedControl *segControl = (UISegmentedControl *)sender;
    if (segControl.selectedSegmentIndex == 0) {
        [self displayModuleSetting];
    }else if(segControl.selectedSegmentIndex == 1){
        [self syncModule];
    }else if(segControl.selectedSegmentIndex == 2){
        [self showActionSheet];
    }
}


-(void)displayModuleSetting{
    ModuleSettingsViewController *msvc = [[ModuleSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    msvc.moduleName = self.title;
    [self.navigationController pushViewController:msvc animated:YES];
}


-(void)syncModule{
    //TODO module synch code;
    [self showProgress];
  //  [self.navigationController setToolbarHidden:NO animated:YES];
    SyncHandler* syncHandler = [SyncHandler sharedInstance];
    [syncHandler runSyncForModule:moduleName parent:self];
}

-(void)showActionSheet{
    //[self.actionSheet showInView:self.view];
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [_actionSheet addButtonWithTitle:@"Add"];
    [_actionSheet addButtonWithTitle:@"Delete"];
    [_actionSheet addButtonWithTitle:@"Cancel"];
    _actionSheet.delegate = self;
    _actionSheet.destructiveButtonIndex = 1;
    [_actionSheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

#pragma mark UIActionSheet Delegate;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == kActionSheetAddButtonIndex) {
        SugarCRMMetadataStore *metadataStore= [SugarCRMMetadataStore sharedInstance];
        EditViewController *editViewController = [EditViewController editViewControllerWithMetadata:[metadataStore objectMetadataForModule:self.metadata.moduleName]];
        editViewController.title = @"Add Record";
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editViewController];
        navController.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:navController animated:YES];        
    }else if(buttonIndex == kActionSheetDeleteButtonIndex){
        [self markItemAsDelete];
    }else if(buttonIndex == kActionSheetCancelButtonIndex){
        //
    }
}

#pragma mark - Sync handler delegate methods

-(void)syncHandler:(SyncHandler*)syncHandler failedWithError:(NSError*)error
{
    [self performSelectorOnMainThread:@selector(showSyncAlert:) withObject:error waitUntilDone:NO];
}

-(void)syncComplete:(SyncHandler*)syncHandler
{   
    [self loadData];
    [self performSelectorOnMainThread:@selector(showSyncAlert:) withObject:nil waitUntilDone:NO];
}

-(IBAction)showSyncAlert:(id)sender
{
    //[self.navigationController setToolbarHidden:YES animated:YES];
    [self hideProgress];
    
    NSError* error = (NSError*) sender;
    if(error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sync Completed" message:@"Sync Completed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    CGRect mainFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat width = mainFrame.size.width;
    sBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0,width,30)];
    sBar.delegate = self;
    [sBar setAutoresizesSubviews:YES];
    [self.view addSubview:sBar];
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30,width, mainFrame.size.height-30)];
    myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    sBar.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    [sBar setAutoresizesSubviews:YES];
    [self.view addSubview:myTableView];
    [self.view setAutoresizesSubviews:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    datasource = [[NSMutableArray alloc] init];
    if (!metadata) {
      self.metadata = [[SugarCRMMetadataStore sharedInstance]listViewMetadataForModule:moduleName];
    }
    myTableView.delegate = self;
    myTableView.dataSource = self;
    CGFloat rowHeight = 20.f + [[metadata otherFields] count] *15 + 10;
    myTableView.rowHeight = rowHeight>51.0?rowHeight:51.0f;
    myTableView.allowsMultipleSelectionDuringEditing = YES;
    //myTableView.allowsSelectionDuringEditing = NO;
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    [self loadData];
    [self intializeTableDataMask];
  }

-(void) showProgress
{
    CGRect toolbarFrame = self.navigationController.toolbar.frame;
    activityIndicator = 
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(toolbarFrame.origin.x + toolbarFrame.size.width/2 -10, 0, 20, 20)];
    [activityIndicator startAnimating];
    [self.navigationController.toolbar addSubview:activityIndicator];
    
    syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(toolbarFrame.origin.x+toolbarFrame.size.width/2 - 50, 20, 100, 20)];
    [syncLabel setText:@"Sync Started"];
    if(IS_IPAD)
    {
        [syncLabel setTextColor:[UIColor grayColor]];
         activityIndicator.color = [UIColor grayColor];
    }
    else
    {
        [syncLabel setTextColor:[UIColor whiteColor]];
    }
    [syncLabel setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.toolbar addSubview:syncLabel];  
    [self.navigationController setToolbarHidden:NO animated:YES];
}

-(void) hideProgress
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [activityIndicator removeFromSuperview];
    activityIndicator = nil;
    [syncLabel removeFromSuperview];
    syncLabel = nil;
}

#pragma mark DBLoadSession Delegate;
-(void)session:(DBSession *)session downloadedModuleList:(NSArray *)moduleList moreComing:(BOOL)moreComing
{   
    datasource = moduleList;
    [tableData removeAllObjects];
    [tableData addObjectsFromArray:datasource];
    [self sortData];
    [myTableView reloadData];
    [self intializeTableDataMask];
}

-(void)session:(DBSession *)session listDownloadFailedWithError:(NSError *)error
{
    NSLog(@"Error: %@",[error localizedDescription]);
}

-(void) loadData
{
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    DBMetadata *dbMetadata = [sharedInstance dbMetadataForModule:metadata.moduleName];
    DBSession * dbSession = [DBSession sessionWithMetadata:dbMetadata];
    dbSession.delegate = self;
    [dbSession startLoading];
}

-(void) sortData
{
    NSString *name,*sortFieldLabel,*sortOrderValue;
    sortFieldLabel = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"key_%@_%@",moduleName,kSettingTitleForSortField]];
    sortOrderValue = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"key_%@_%@",moduleName,kSettingTitleForSortorder]];
    NSDictionary *lablenameDict = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_labelnameDict",moduleName]];
    
    if(sortFieldLabel != nil)
        name = [lablenameDict objectForKey:sortFieldLabel];
    else
        name = nil;
    
    
    self.tableData = [[tableData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *str1,*str2;
        if (name != nil) {
            str1 = [obj1 objectForFieldName:name];
            str2 = [obj2 objectForFieldName:name];
        }else{
            str1 = [obj1 objectForFieldName:metadata.primaryDisplayField.name];
            str2 = [obj2 objectForFieldName:metadata.primaryDisplayField.name];
        }
        if([sortOrderValue isEqualToString:@"Descending"])
            return[str2 compare:str1 options:NSCaseInsensitiveSearch | NSNumericSearch | NSWidthInsensitiveSearch | NSLiteralSearch];
        else
            return[str1 compare:str2 options:NSCaseInsensitiveSearch | NSNumericSearch | NSWidthInsensitiveSearch | NSLiteralSearch];
    }] mutableCopy];
}

-(void)intializeTableDataMask{
    tableDataMask = malloc(tableData.count*sizeof(int));//Values in this array are used change the font color of particular cell
    for(int i=0;i<tableData.count;i++){
        tableDataMask[i]=0;
    }
    //default value is 0
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect mainFrame = self.view.bounds;
    sBar.frame = CGRectMake(0,0,mainFrame.size.width,30);
    myTableView.frame = CGRectMake(0, 31, mainFrame.size.width, mainFrame.size.height-30);
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
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
    [self sortData];
    [myTableView reloadData];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    for(UIView *view in self.view.subviews)
    {
        if(view.tag == kEditToolbarTag)
        {
            view.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    id dataObjectForRow = [tableData objectAtIndex:indexPath.row];
    if(tableDataMask[indexPath.row] == 0){
        cell.textLabel.textColor = [UIColor blackColor];//default color is black
    }else{
        cell.textLabel.textColor = [UIColor grayColor];
    }
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [tableData removeObjectAtIndex:indexPath.row];
        [myTableView reloadData];
        //TODO also delete from deviceDB and merge if there is a connection
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    // Navigation logic may go here. Create and push another view controller.
    if(!self.editing)
    {        
        tableDataMask[indexPath.row] = 1;//changing the value of array at particular index to change font color of the cell.
        id beanTitle = [[tableData objectAtIndex:indexPath.row] objectForFieldName:@"name"];
        id beanId =[[tableData objectAtIndex:indexPath.row]objectForFieldName:@"id"];
                    
        DetailViewController *detailViewController = [DetailViewController detailViewcontroller:[[SugarCRMMetadataStore sharedInstance] detailViewMetadataForModule:metadata.moduleName] beanId:beanId beanTitle:beanTitle];
         [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //if (self.editing == NO || !indexPath) return UITableViewCellEditingStyleNone;
    if (self.editing && indexPath.row == ([tableData count])){
        return UITableViewCellEditingStyleNone;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

-(void) deleteButtonPressed
{
    NSArray *selectedRows = [[NSArray alloc] initWithArray: [myTableView indexPathsForSelectedRows]];
    
    NSMutableIndexSet *indexSetToDelete = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *dsIndexSetToDelete = [[NSMutableIndexSet alloc] init];
    NSMutableArray* copy = [self.datasource mutableCopy];
    for (NSIndexPath *indexPath in selectedRows)
    {
        [indexSetToDelete addIndex:indexPath.row];
        [dsIndexSetToDelete addIndex:[self.datasource indexOfObject:[self.tableData objectAtIndex:indexPath.row]]];
    }
    [self.tableData removeObjectsAtIndexes:indexSetToDelete];
    [copy removeObjectsAtIndexes:dsIndexSetToDelete];
    self.datasource = [[NSArray alloc] initWithArray:copy];
    [myTableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];    
    // TODO should update the db for the deleted flag and sync
    [myTableView reloadData];

}

- (void)markItemAsDelete{
    
    UIBarButtonItem *barButtonItem = nil;
    if(!self.editing){
        [super setEditing:YES animated:YES];
        [myTableView setEditing:YES animated:YES];
        [myTableView reloadData];
        self.navigationItem.rightBarButtonItem = nil;
        barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(markItemAsDelete)];
       // self.navigationItem.rightBarButtonItem = barButtonItem;
        
        UIToolbar *bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
        bottomToolbar.tag = kEditToolbarTag;
        
        UIBarButtonItem *delButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteButtonPressed)];
        [delButtonItem setTintColor:[UIColor redColor]];
        
        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [self.view addSubview:bottomToolbar];
        NSArray *items = [NSArray arrayWithObjects:flexButton, delButtonItem, barButtonItem, flexButton, nil];
        [bottomToolbar setItems:items];
    }else{
        [super setEditing:NO animated:YES];
        [myTableView setEditing:NO animated:YES];
        [myTableView reloadData];
        self.navigationItem.rightBarButtonItem = nil;
        barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
        self.navigationItem.rightBarButtonItem = barButtonItem;
        
        for(UIView *view in self.view.subviews)
        {
            if(view.tag == kEditToolbarTag)
                [view removeFromSuperview];
        }
    }
}

#pragma mark UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // only show the status bar’s cancel button while in edit mode
    sBar.showsCancelButton = YES;
    sBar.autocorrectionType = UITextAutocorrectionTypeNo;
    // flush the previous search content
    //[tableData removeAllObjects];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    sBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [tableData removeAllObjects];// remove all data that belongs to previous search
    if(searchText==nil || [searchText isEqualToString:@""]){
        [tableData addObjectsFromArray:datasource];
        [myTableView reloadData];
        [self intializeTableDataMask];
        return;
    }
    for(int i=0; i < [datasource count]; i++)
    {
        id dataObjectRow = [datasource objectAtIndex:i];
        NSString* name = [dataObjectRow objectForFieldName:metadata.primaryDisplayField.name];
        NSRange r = [[name lowercaseString] rangeOfString:[searchText lowercaseString]];
        if(r.location != NSNotFound)
        {
            [tableData addObject:dataObjectRow];
        }
    }
    [myTableView reloadData];
    [self intializeTableDataMask];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // if a valid search was entered but the user wanted to cancel, bring back the main list content
    [tableData removeAllObjects];
    [tableData addObjectsFromArray:datasource];
    @try{
        [self sortData];
        [myTableView reloadData];
        [self intializeTableDataMask];
    }
    @catch(NSException *e){
    }
    sBar.text = @"";
    [sBar resignFirstResponder];
}
// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)dealloc{
    free(tableDataMask);
}

@end
