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
    BOOL searchCancelled;
}
-(void) showProgress;
-(void) hideProgress;
-(void) loadData;
-(void) addRows;
-(void) sortData;
-(void) showActionSheet;
//-(void) intializeTableDataMask;//this function is to intialize an array of tableData size which contains values 1 or 0.

-(void) syncFailedWithError:(NSError*)error;
-(void) syncComplete;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"ReloadRecords" object:nil];
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
        [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"manage.png"] atIndex:kSegementedControlTempButtonIndex animated:YES];
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


-(void)syncModule
{
    sBar.text = @"";
    [sBar resignFirstResponder];
    [self showProgress];
    SyncHandler* syncHandler = [SyncHandler sharedInstance];
    
    __weak ListViewController* lvc = self;
    
    syncHandler.completionBlock = ^(){
        [lvc loadData];
        [lvc performSelectorOnMainThread:@selector(showSyncAlert:) withObject:nil waitUntilDone:NO];
    };
    
    syncHandler.errorBlock = ^(NSArray* errors){
        [lvc performSelectorOnMainThread:@selector(showSyncAlert:) withObject:[errors objectAtIndex:0]  waitUntilDone:NO];
    };
    
    [syncHandler runSyncforModules:[NSArray arrayWithObject:moduleName] withSyncType:SYNC_TYPE_WITH_TIME_STAMP];
}

-(void)showActionSheet
{
    //[self.actionSheet showInView:self.view];
    [sBar resignFirstResponder];
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
        [self toggleEditing];
    }else if(buttonIndex == kActionSheetCancelButtonIndex){
        //
        myTableView.contentInset = UIEdgeInsetsZero;
    }
}

#pragma mark - Sync handler delegate methods

-(void)syncFailedWithError:(NSError*)error
{
    [self performSelectorOnMainThread:@selector(showSyncAlert:) withObject:error waitUntilDone:NO];
}

-(void)syncComplete
{
    [self loadData];
    [self performSelectorOnMainThread:@selector(showSyncAlert:) withObject:nil waitUntilDone:NO];
}

-(IBAction)showSyncAlert:(id)sender
{
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
    [self hideProgress];
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
  }

-(void) showProgress
{
    AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedAppDelegate showWaitingAlertWithMessage:@"Please wait syncing"];
}

-(void) hideProgress
{
    AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedAppDelegate dismissWaitingAlert];
}

-(void)loadData
{
    DBSessionCompletionBlock completionBlock = ^(NSArray* records){
        NSMutableArray* visibleRecords = [[NSMutableArray alloc] init];
        for(DataObject* dataObject in records)
        {
            if(![[dataObject objectForFieldName:@"deleted"] isEqualToString:@"1"])
            {
                [visibleRecords addObject:dataObject];
            }
        }
        datasource = visibleRecords;
        [tableData removeAllObjects];
        [tableData addObjectsFromArray:datasource];
        //[self sortData];
        
        NSLog(@"Number of records in module %@ : %d", self.moduleName, records.count);
        // Load UI on mail queue
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [myTableView reloadData];
        });
    };
    
    DBSessionErrorBlock errorBlock = ^(NSError* error){
        NSLog(@"Error: %@",[error localizedDescription]);
    };
    
    DBSession* dbSession = [DBSession sessionForModule:self.moduleName];
    dbSession.completionBlock = completionBlock;
    dbSession.errorBlock = errorBlock;
//    [dbSession startLoading];
    NSString *orderField = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"key_%@_%@",moduleName,kSettingTitleForSortField]];
    [dbSession rowsFromDBWithLimit:kRowLimit andOffset:0 orderBy:orderField];
}

-(void)addRows
{
    __weak ListViewController *lvc = self;
    DBSessionCompletionBlock completionBlock = ^(NSArray* records){
        __block int newRowCount = [records count];
        [lvc.tableData removeAllObjects];
        [lvc.tableData addObjectsFromArray:lvc.datasource];
        lvc.datasource = nil;
        for(DataObject* dataObject in records)
        {
            if(![[dataObject objectForFieldName:@"deleted"] isEqualToString:@"1"])
            {
                [lvc.tableData addObject:dataObject];
            }
        }
        lvc.datasource = [lvc.tableData copy];
        if ([records count]>0) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [myTableView beginUpdates];
                NSMutableArray* newRecords = [[NSMutableArray alloc] init];
                for (int i=0; i<newRowCount; i++) {
                    [newRecords addObject:[NSIndexPath indexPathForRow:[lvc.tableData count]-newRowCount+i inSection:0]];
                }
                [myTableView insertRowsAtIndexPaths:newRecords withRowAnimation:UITableViewRowAnimationLeft];
                [myTableView endUpdates];
            });
        }
    };
    
    DBSessionErrorBlock errorBlock = ^(NSError* error){
        NSLog(@"Error: %@",[error localizedDescription]);
    };
    
    DBSession* dbSession = [DBSession sessionForModule:self.moduleName];
    dbSession.completionBlock = completionBlock;
    dbSession.errorBlock = errorBlock;
    NSString *orderField = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"key_%@_%@",moduleName,kSettingTitleForSortField]];
    [dbSession rowsFromDBWithLimit:kRowLimit andOffset:[datasource count] orderBy:orderField];
}

-(void)sortData
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
    searchCancelled = TRUE;
//    [self sortData];
    [myTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    self->tableDataMask = NULL;
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
    static NSString *moreCellIdentifier = @"newCell";
    UITableViewCell *cell = nil;
    
    NSUInteger row = [indexPath row]+1;
    NSUInteger count = [tableData count];
    if (row == count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:moreCellIdentifier];
        }
        if (!searchCancelled) {
            id dataObjectForRow = [tableData objectAtIndex:indexPath.row];
            cell.textLabel.text = [dataObjectForRow objectForFieldName:metadata.primaryDisplayField.name];
            NSLog(@"primary text   :%@",cell.textLabel.text);
            for(DataObjectField *otherField in metadata.otherFields)
            {
                NSString* value = [dataObjectForRow objectForFieldName:otherField.name];
                if (value && [value length] >0) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",otherField.label,value];
                }
                else{
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: NA",otherField.label];
                }
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        else
        {
            [self addRows];
            id dataObjectForRow = [tableData objectAtIndex:indexPath.row];
            cell.textLabel.text = [dataObjectForRow objectForFieldName:metadata.primaryDisplayField.name];
            NSLog(@"primary text   :%@",cell.textLabel.text);
            for(DataObjectField *otherField in metadata.otherFields)
            {
                NSString* value = [dataObjectForRow objectForFieldName:otherField.name];
                if (value && [value length] >0) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",otherField.label,value];
                }
                else{
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: NA",otherField.label];
                }
            }
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        id dataObjectForRow = [tableData objectAtIndex:indexPath.row];
        cell.textLabel.text = [dataObjectForRow objectForFieldName:metadata.primaryDisplayField.name];
        NSLog(@"primary text:%@",cell.textLabel.text);
        for(DataObjectField *otherField in metadata.otherFields)
        {
            NSString* value = [dataObjectForRow objectForFieldName:otherField.name];
            if (value && [value length] >0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",otherField.label,value];
            }
            else{
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: NA",otherField.label];
            }
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
        id beanTitle = [[tableData objectAtIndex:indexPath.row] objectForFieldName:@"name"];
        id beanId =[[tableData objectAtIndex:indexPath.row]objectForFieldName:@"id"];
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if ([appDelegate.recentItems objectForKey:moduleName]) {
            NSMutableArray *beanIds = [appDelegate.recentItems objectForKey:moduleName];
            if ([beanIds count]>=5) {
                [beanIds removeObjectAtIndex:0];
            }
             [beanIds addObject:beanId];
        } else {
            [appDelegate.recentItems setObject:[NSMutableArray arrayWithObject:beanId] forKey:moduleName];
        }
        DetailViewController *detailViewController = [DetailViewController detailViewcontroller:[[SugarCRMMetadataStore sharedInstance] detailViewMetadataForModule:metadata.moduleName] beanId:beanId beanTitle:beanTitle];
        detailViewController.shouldCotainToolBar = YES;
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
    NSMutableArray* dbData = [[NSMutableArray alloc] initWithCapacity:[selectedRows count]];
    
    for (NSIndexPath *indexPath in selectedRows)
    {
        [indexSetToDelete addIndex:indexPath.row];
        [dsIndexSetToDelete addIndex:[self.datasource indexOfObject:[self.tableData objectAtIndex:indexPath.row]]];
        
        DataObject* dataObject = (DataObject *)[self.tableData objectAtIndex:indexPath.row];
        [dataObject setObject:@"1" forFieldName:@"deleted"];
        [dbData addObject:dataObject];
    }
    
    [self.tableData removeObjectsAtIndexes:indexSetToDelete];
    [copy removeObjectsAtIndexes:dsIndexSetToDelete];
    self.datasource = [[NSArray alloc] initWithArray:copy];
    [myTableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];    
    
    __weak ListViewController* lvc = self;
   
    DBSession * dbSession = [DBSession sessionForModule:self.moduleName];
    
    dbSession.completionBlock = ^(NSArray* data){
        [lvc syncModule];
    };
    
    dbSession.errorBlock = ^(NSError* error){
        NSLog(@"Handle database error while saving a record : %@", [error localizedDescription]);
    };
    
    [dbSession insertDataObjectsInDb:dbData dirty:YES];
    
    [self toggleEditing];
    myTableView.contentInset = UIEdgeInsetsZero;
    [myTableView reloadData];
}

- (void)toggleEditing{
    
    UIBarButtonItem *barButtonItem = nil;
    if(!self.editing){
        [super setEditing:YES animated:YES];
        [myTableView setEditing:YES animated:YES];
        [myTableView reloadData];
        self.navigationItem.rightBarButtonItem = nil;
        barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(toggleEditing)];
       // self.navigationItem.rightBarButtonItem = barButtonItem;
        
        UIToolbar *bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
        bottomToolbar.tag = kEditToolbarTag;
        UIBarButtonItem *delButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteButtonPressed)];
        [delButtonItem setTintColor:[UIColor redColor]];
        
        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        myTableView.contentInset = UIEdgeInsetsMake(0, 0, bottomToolbar.frame.size.height, 0);
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
        myTableView.contentInset = UIEdgeInsetsZero;
    }
}

#pragma mark UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // only show the status bar’s cancel button while in edit mode
    searchCancelled = FALSE;
    sBar.showsCancelButton = YES;
    sBar.autocorrectionType = UITextAutocorrectionTypeNo;
    // flush the previous search content
    //[tableData removeAllObjects];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchCancelled = TRUE;
    sBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchCancelled = FALSE;
    [tableData removeAllObjects];// remove all data that belongs to previous search
    if(searchText==nil || [searchText isEqualToString:@""]){
        searchCancelled = TRUE;
        [tableData addObjectsFromArray:datasource];
        [myTableView reloadData];
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
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // if a valid search was entered but the user wanted to cancel, bring back the main list content
    [self.tableData removeAllObjects];
    [self.tableData addObjectsFromArray:self.datasource];
    @try{
        searchCancelled = TRUE;
        [myTableView reloadData];
    }
    @catch(NSException *e){
    }
    sBar.text = @"";
    [sBar resignFirstResponder];
}
// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchCancelled = FALSE;
    [searchBar resignFirstResponder];
}

-(void)dealloc{

}

@end
