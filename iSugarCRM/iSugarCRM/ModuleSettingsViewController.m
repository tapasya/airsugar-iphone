//
//  ModuleSettingsViewController.m
//  iSugarCRM
//
//  Created by pramati on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModuleSettingsViewController.h"
#import "ModuleSettingsDataStore.h"
#import "ModuleSettingsObject.h"
#import "SettingsStore.h"

@implementation ModuleSettingsViewController
@synthesize moduleName=_moduleName;
@synthesize moduleSettingsStore= _moduleSetting;

-(ModuleSettingsDataStore*) moduleSettingsStore
{
    if(!_moduleSetting){
        _moduleSetting = [[ModuleSettingsDataStore alloc] initWithModuelName:_moduleName];
    }
    return _moduleSetting;
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
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    
    self.title = [NSString stringWithFormat:@"%@ Settings", self.moduleName];
    
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
    return YES;
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
    return [self.moduleSettingsStore.settingsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    ModuleSettingsObject* settingsObject = [self.moduleSettingsStore.settingsArray objectAtIndex:section];
    return [settingsObject.multipleTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if(!cell ){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Cell text";
        }
    }
   
    ModuleSettingsObject* settingsObject = [self.moduleSettingsStore.settingsArray objectAtIndex:indexPath.section];
    NSInteger selecedRow = [settingsObject.multipleTitles indexOfObject:settingsObject.value];
        if (indexPath.row == selecedRow) {
            [self selectCell:cell];
        } else {
            [self deselectCell:cell];
        }
    
        // Configure the cell...
    NSLog(@"Setting name is :%@  ,String is : %@", settingsObject.title, settingsObject.value);
    [cell.textLabel setText:[settingsObject.multipleTitles objectAtIndex:indexPath.row]];
    return cell;
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    ModuleSettingsObject* settingsObject = [self.moduleSettingsStore.settingsArray objectAtIndex:section];
    return settingsObject.title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModuleSettingsObject* settingsObject = [self.moduleSettingsStore.settingsArray objectAtIndex:indexPath.section];
    NSString* oldValue = settingsObject.value;
    NSInteger selecedRow = [settingsObject.multipleTitles indexOfObject:oldValue];
    if (indexPath.row == selecedRow) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }       
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSIndexPath* checkedItem = [NSIndexPath indexPathForRow:selecedRow inSection:indexPath.section];
    [self deselectCell:[tableView cellForRowAtIndexPath:checkedItem]];
    [self selectCell:[tableView cellForRowAtIndexPath:indexPath]];
    [SettingsStore setObject:[settingsObject.multipleTitles objectAtIndex:indexPath.row] forKey:settingsObject.key];
}

@end
