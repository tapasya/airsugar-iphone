//
//  SynchSettingsViewController.m
//  iSugarCRM
//
//  Created by dayanand on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncSettingsViewController.h"
#import "SettingsStore.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "SyncHandler.h"
#import "ConnectivityChecker.h"
#import "DateUtils.h"

#define kEraseAlertViewTag 1001

@interface SyncSettingsViewController()
-(void) showDatePickerPopoverAtFrame:(CGRect) frame;
@property (nonatomic, retain) UIPopoverController* popoverController;
@end

@implementation SyncSettingsViewController

@synthesize settingsArray;
@synthesize pickerView; 
@synthesize actionSheet;
@synthesize startDate;
@synthesize endDate;
@synthesize popoverController;

BOOL isFirstTime;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteSync) name:@"SugarSyncComplete" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncFailed) name:@"SugarSyncFailed" object:nil];  
        startDate = [SettingsStore objectForKey:kStartDateIdentifier];
        endDate = [SettingsStore objectForKey:kStartDateIdentifier];
        if (!startDate && !endDate) {
            isFirstTime = true;
        }else{
            isFirstTime = false;
        }
    }
    return self;
}

-(NSArray*) settingsArray
{
    if(!settingsArray){
        NSArray *dateSettings,*syncSettings,*eraseSettings;
        if(isFirstTime){
            dateSettings = [[NSArray alloc] initWithObjects:kStartDateIdentifier,kEndDateIdentifier, nil];
        }else{
            dateSettings = [[NSArray alloc] initWithObjects:kStartDateIdentifier,kEndDateIdentifier, nil];
            syncSettings = [[NSArray alloc] initWithObjects:kSyncNowCellIdentifier, nil];
            eraseSettings = [[NSArray alloc] initWithObjects:kEraseAllCellIdentifier, nil];
        }
        settingsArray = [[NSArray alloc] initWithObjects:dateSettings, syncSettings,eraseSettings, nil];        
    }
    return settingsArray;
}

-(UIBarButtonItem *)addNextButton{
    UIBarButtonItem *barButton = nil;
    if(isFirstTime){
        barButton = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(showDashboard:)];
    }
    return barButton;
}

- (UIDatePicker*) pickerView
{
    if(!pickerView){
        pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
        [pickerView setDatePickerMode:UIDatePickerModeDate];
        [pickerView setBackgroundColor:[UIColor clearColor]];
        [pickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [pickerView addTarget:self action:@selector(dateSelectionDone:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return pickerView;
}

-(UIActionSheet*) actionSheet
{
    if(!actionSheet){
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick Date" delegate:nil cancelButtonTitle:nil
                                    destructiveButtonTitle:nil otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        UIToolbar* pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
        
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [barItems addObject:flexSpace];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dateSelectionDone:)];
        [barItems addObject:doneBtn];
        
        [pickerDateToolbar setItems:barItems animated:YES];
        
        [actionSheet addSubview:pickerDateToolbar];
        [actionSheet addSubview:self.pickerView]; 
    }
    return actionSheet;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [self addNextButton];
    
    self.tableView.tableFooterView.autoresizesSubviews = YES;
    //self.tableView.tableFooterView.frame = CGRectMake(10, 10, 70, 50);//(10, 10, 274, 144)
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, 20, 50)];//(230, 120, 270, 140)
    label.textAlignment = kAlignLeft;
    label.text = @"Sync Data by selecting startdate and enddate";
    label.font = [UIFont systemFontOfSize:15.0f];
    //label.adjustsFontSizeToFitWidth = NO;
    label.numberOfLines = 0;
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight |  UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [label setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = label;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SugarSyncComplete" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SugarSyncFailed" object:nil];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.settingsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.settingsArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString* cellIdentifier = [[self.settingsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
    NSString* value = [SettingsStore objectForKey:cellIdentifier];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if([cellIdentifier isEqualToString:kStartDateIdentifier])
    {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        startDate = [SettingsStore objectForKey:kStartDateIdentifier];
        [[cell textLabel] setText:@"Start Date"];
        if(!value){
            if(startDate == nil){
                value = [DateUtils stringFromDate:[NSDate date]];
                startDate = value;
            }else{
                value = startDate;
            }
        }
        cell.detailTextLabel.text = value;
        [cell detailTextLabel].tag = kStartDateTag;
    }
    else if( [cellIdentifier isEqualToString:kEndDateIdentifier])
    {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        endDate = [SettingsStore objectForKey:kEndDateIdentifier];
        [[cell textLabel] setText:@"End Date"];
        if(!value){
            if(endDate == nil){
                value = [DateUtils stringFromDate:[NSDate date]];
                endDate = value;
            }else{
                value = endDate;
            }
        }
        cell.detailTextLabel.text = value;
        [cell detailTextLabel].tag = kEndDateTag;
    }
    else if( [cellIdentifier isEqualToString:kSyncNowCellIdentifier])
    {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = kSyncNowCellIdentifier;
        cell.textLabel.textAlignment = kAlignCenter;
    }
    else if( [cellIdentifier isEqualToString:kEraseAllCellIdentifier])
    {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = kEraseAllCellIdentifier;
        cell.textLabel.textAlignment = kAlignCenter;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString* identifier = [[self.settingsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if([identifier isEqualToString:kStartDateIdentifier] || [identifier isEqualToString:kEndDateIdentifier])
    {
        UITableViewCell *targetCell = [tableView cellForRowAtIndexPath:indexPath];
        self.pickerView.date = [DateUtils dateFromString:targetCell.detailTextLabel.text];
        if( [identifier isEqualToString:kStartDateIdentifier])
        {
            self.pickerView.maximumDate = [DateUtils dateFromString:endDate];
            self.pickerView.minimumDate = nil;
        }
        
        if( [identifier isEqualToString:kEndDateIdentifier])
        {
            self.pickerView.minimumDate = [DateUtils dateFromString:startDate];
            self.pickerView.maximumDate = [NSDate date];
        }
        
        if(IS_IPAD)
        {
            [self showDatePickerPopoverAtFrame:targetCell.frame];
            //[tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        else
        {
            [self.actionSheet showInView:self.view];
            [self.pickerView setFrame:CGRectMake(0, 44, 320, 400)];
            [self.actionSheet setBounds:CGRectMake(0, 0, 320, 480)];
        }

    }
    else if([identifier isEqualToString:kSyncNowCellIdentifier])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSelectorOnMainThread:@selector(syncNow:) withObject:nil waitUntilDone:NO];
    }
    else if([identifier isEqualToString:kEraseAllCellIdentifier])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Do you really want to erase all data from database ?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", @"Cancel", nil];
        alertView.tag = kEraseAlertViewTag;
        [alertView show];
        return;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kEraseAlertViewTag && buttonIndex == 0)
    {
        [self performSelectorOnMainThread:@selector(eraseDBData:) withObject:nil waitUntilDone:NO];
    }
}

-(void) showDatePickerPopoverAtFrame:(CGRect)frame
{
    UIViewController* popoverContent = [[UIViewController alloc] init];
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 344)];
    popoverView.backgroundColor = [UIColor whiteColor];
    self.pickerView.frame = CGRectMake(0, 0, 320, 344);
    [popoverView addSubview:self.pickerView];
    popoverContent.view = popoverView;
    popoverContent.contentSizeForViewInPopover = CGSizeMake(320, 200);
    popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    [popoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)dateChanged:(id)sender
{
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.detailTextLabel.text = [DateUtils stringFromDate:self.pickerView.date];
    
    if (cell.detailTextLabel.tag == kStartDateTag) {
        startDate = cell.detailTextLabel.text;
    }else if(cell.detailTextLabel.tag == kEndDateTag){
        endDate = cell.detailTextLabel.text;
    }
    NSDate *dateStart = [DateUtils dateFromString:self.startDate];
    NSDate *dateEnd = [DateUtils dateFromString:self.endDate];
    if([dateStart compare:dateEnd] == NSOrderedDescending || [dateEnd compare:[NSDate date]] == NSOrderedDescending){
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)dateSelectionDone:(id)sender
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showDashboard:(id)sender
{
    if(!startDate){
        startDate = [DateUtils stringFromDate:[NSDate date]];
    }
    
    if(!endDate){
        endDate = [DateUtils stringFromDate:[NSDate date]];
    }
    
    [SettingsStore setObject:startDate forKey:kStartDateIdentifier];
    [SettingsStore setObject:endDate forKey:kEndDateIdentifier];
    [SettingsStore setObject:@"YES" forKey:@"hasDates"];
    AppDelegate* sharedDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedDelegate showDashboardController];
}

-(void)syncNow:(id)sender{
    
    //NSError* error;
    if([[ConnectivityChecker singletonObject] isNetworkReachable])
    {
        if(!startDate){
            startDate = [DateUtils stringFromDate:[NSDate date]];
        }
        
        if(!endDate){
            endDate = [DateUtils stringFromDate:[NSDate date]];
        }
        [SettingsStore setObject:startDate forKey:kStartDateIdentifier];
        [SettingsStore setObject:endDate forKey:kEndDateIdentifier];
        AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [sharedAppDelegate showWaitingAlertWithMessage:@"Please wait syncing"];
        //[sharedAppDelegate sync];
        [sharedAppDelegate performSelectorInBackground:@selector(completeSyncWithDateFilters) withObject:nil];
        //[sharedAppDelegate dismissWaitingAlert];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No interner connection. Please try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void) didCompleteSync
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;    
        [sharedAppDelegate dismissWaitingAlert];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sync Completed" message:@"Sync Completed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    });
}

-(void) syncFailed:(id) sender
{ 
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;    
        [sharedAppDelegate dismissWaitingAlert];
        NSError* error = (NSError*) sender;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];        
    });
}

-(void)eraseDBData:(id)sender{
    AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIAlertView *alert;
    window.userInteractionEnabled=NO;
    if(![sharedAppDelegate wipeDatabase]){
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Erase data" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Succesfully Erased data" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    window.userInteractionEnabled=YES;
}

@end
