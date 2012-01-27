//
//  ModuleSettingsViewController.m
//  iSugarCRM
//
//  Created by pramati on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModuleSettingsViewController.h"
#import "ModuleSettingsDataStore.h"
#import "SettingsStore.h"

#define kPSGroupSpecifier                 @"PSGroupSpecifier"
#define kPSToggleSwitchSpecifier          @"PSToggleSwitchSpecifier"
#define kPSMultiValueSpecifier            @"PSMultiValueSpecifier"
#define kPSSliderSpecifier                @"PSSliderSpecifier"
#define kPSTitleValueSpecifier            @"PSTitleValueSpecifier"
#define kPSTextFieldSpecifier             @"PSTextFieldSpecifier"
#define kPSChildPaneSpecifier             @"PSChildPaneSpecifier"

@implementation ModuleSettingsViewController
@synthesize moduleName=_moduleName, moduleSettings=_moduleSettings;

-(NSMutableArray*) moduleSettings
{
    if (!_moduleSettings) {
        ModuleSettingsDataStore* plistReader = [[ModuleSettingsDataStore alloc] initWithFile:@"ModuleSettingData"];
        _moduleSettings = [plistReader getSettingsForModule:_moduleName];
    }
    return _moduleSettings;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    
    self.title = [NSString stringWithFormat:@"%@ Settings", self.moduleName];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    self.navigationItem.rightBarButtonItem = doneButton;

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

- (void)selectCell:(UITableViewCell *)cell {
	[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	[[cell textLabel] setTextColor:[UIColor colorWithRed:0.318 green:0.4 blue:0.569 alpha:1.0]];
}

- (void)deselectCell:(UITableViewCell *)cell {
	[cell setAccessoryType:UITableViewCellAccessoryNone];
	[[cell textLabel] setTextColor:[UIColor darkTextColor]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.moduleSettings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([[self.moduleSettings objectAtIndex:section ] multipleTitles]){
        return [[[self.moduleSettings objectAtIndex:section ] multipleTitles] count];
    }
    else{
        return 1;
    }
    //return [self.moduleSettings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SettingsObject* specifier = [self.moduleSettings objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [SetttingsViewFactory getTableCellForSetting:specifier];
        if(!cell ){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Cell text";
        }
    }
    
    if ([[specifier type] isEqualToString:kPSTextFieldSpecifier]) {
        
    }
    else if([[specifier type] isEqualToString:kPSToggleSwitchSpecifier]){
      
        
    }
    else if ([[specifier type] isEqualToString:kPSMultiValueSpecifier]) {
        NSInteger selecedRow = [specifier.multipleTitles indexOfObject:specifier.value];
        if (indexPath.row == selecedRow) {
            [self selectCell:cell];
        } else {
            [self deselectCell:cell];
        }
        // Configure the cell...
        [cell.textLabel setText:[specifier.multipleTitles objectAtIndex:indexPath.row]];
    }
    else if ([[specifier type] isEqualToString:kPSChildPaneSpecifier]) {
    
    }     
    return cell;
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    SettingsObject* specifier = [self.moduleSettings objectAtIndex:section];
    return [specifier title];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsObject* specifier = [self.moduleSettings objectAtIndex:indexPath.section];
    if ([[specifier type] isEqualToString:kPSMultiValueSpecifier]) {
           NSString* oldValue = [SettingsStore objectForKey:specifier.key];
        NSIndexPath* checkedItem = [NSIndexPath indexPathForRow:[specifier.multipleTitles indexOfObject:oldValue]                  inSection:indexPath.section];
        NSInteger selecedRow = [specifier.multipleTitles indexOfObject:oldValue];
        if (indexPath.row == selecedRow) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self deselectCell:[tableView cellForRowAtIndexPath:checkedItem]];
        [self selectCell:[tableView cellForRowAtIndexPath:indexPath]];
        
        [SettingsStore setObject:[specifier.multipleTitles objectAtIndex:indexPath.row] forKey:[specifier key]];
    }
}

@end
