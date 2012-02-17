//
//  AppSettingsViewController.m
//  iSugarCRM
//
//  Created by pramati on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppSettingsViewController.h"
#import "TextFieldTableCell.h"
#import "SettingsStore.h"
#import "ApplicationKeyStore.h"

@implementation AppSettingsViewController
@synthesize settingsArray=_settingsArray;
@synthesize pickerView;
@synthesize dateFormatter;
@synthesize saveButton;
@synthesize actionSheet;
@synthesize username,password,urlString,startDate,endDate;

ApplicationKeyStore *keyChain;
UIView *footerView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
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

-(UIBarButtonItem*) saveButton
{
    if(!saveButton){
        saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveSettings:)];
    }
    return saveButton;
}

-(UIActionSheet*) actionSheet
{
    if(!actionSheet){
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick Date" delegate:nil cancelButtonTitle:nil
                                    destructiveButtonTitle:nil otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        UIToolbar* pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
        [pickerDateToolbar sizeToFit];
        
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

-(NSArray*) settingsArray
{
    if(!_settingsArray){
        // To add new settings pupulate the array with the appropriate identifiers supply a table cell for that identifier
        NSArray* userSettings = [[NSArray alloc] initWithObjects:kRestUrlIdentifier,kUsernameIdentifier,kPasswordIdentifier, nil];
        NSArray* syncSettings = [[NSArray alloc] initWithObjects:kStartDateIdentifier, kEndDateIdentifier, nil];
        _settingsArray = [[NSArray alloc] initWithObjects:userSettings, syncSettings, nil];        
    }
    return _settingsArray;
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
    self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.navigationItem.rightBarButtonItem = self.saveButton;
    self.title = @"Settings";
    keyChain = [[ApplicationKeyStore alloc]initWithName:@"iSugarCRM-keystore"];
    NSLog(@"viewdidload");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewwillappear");
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
    
    // TODO should fetch the settings/preferences saved in the keychain implementation
    NSString* value = [SettingsStore objectForKey:cellIdentifier];
    
    if([cellIdentifier isEqualToString:kRestUrlIdentifier] || [cellIdentifier isEqualToString:kUsernameIdentifier] || [cellIdentifier isEqualToString:kPasswordIdentifier])
    {
        if (!cell) {
            cell = (TextFieldTableCell*) [[[NSBundle mainBundle] loadNibNamed:@"TextFieldTableCell"  owner:self options:nil] objectAtIndex:0];
            
            ((TextFieldTableCell*)cell).textField.textAlignment = UITextAlignmentRight;
            ((TextFieldTableCell*)cell).textField.returnKeyType = UIReturnKeyDone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            ((TextFieldTableCell*)cell).textField.delegate = self;
        }
        if([cellIdentifier isEqualToString:kRestUrlIdentifier])
        {
            [((TextFieldTableCell*)cell).label setText:@"Url"];
            NSString *url = [SettingsStore objectForKey:@"sugarEndpoint"];
            if(!value){
                if([url length] == 0)
                    value = sugarEndpoint;
                else
                    value = url;
            }
            [((TextFieldTableCell*)cell).textField setText:value];
            ((TextFieldTableCell*)cell).textField.tag = kURLTag;
            [((TextFieldTableCell*)cell).textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        }
        else if([cellIdentifier isEqualToString:kUsernameIdentifier])
        {
            [((TextFieldTableCell*)cell).label setText:@"Username"];
            if(!value){
                //value = @"will";
                value = [keyChain objectForKey:(__bridge id)kSecAttrAccount];
            }
            [((TextFieldTableCell*)cell).textField setText:value];
            ((TextFieldTableCell*)cell).textField.tag = kUsernameTag;
            [((TextFieldTableCell*)cell).textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        }
        else if([cellIdentifier isEqualToString:kPasswordIdentifier])
        {
            [((TextFieldTableCell*)cell).label setText:@"Password"];
            [((TextFieldTableCell*)cell).textField setSecureTextEntry:YES];
            if(!value){
                //value = @"18218139eec55d83cf82679934e5cd75";
                value = [keyChain objectForKey:(__bridge id)kSecValueData];//kSecValueData is to encrypt password
            }
            [((TextFieldTableCell*)cell).textField setText:value];
            ((TextFieldTableCell*)cell).textField.tag = kPasswordTag;
            [((TextFieldTableCell*)cell).textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        }
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        if([cellIdentifier isEqualToString:kStartDateIdentifier])
        {
           startDate = [SettingsStore objectForKey:kStartDateIdentifier];
            [[cell textLabel] setText:@"Start Date"];
            if(!value){
                if(startDate == nil){
                    value = [self.dateFormatter stringFromDate:[NSDate date]];
                }else{
                    value = startDate;
                }
            }
            [[cell detailTextLabel] setText:value];
            [cell detailTextLabel].tag = kStartDateTag;
            
        }
        else if( [cellIdentifier isEqualToString:kEndDateIdentifier])
        {
            endDate = [SettingsStore objectForKey:kEndDateIdentifier];
            [[cell textLabel] setText:@"End Date"];
            if(!value){
                if(endDate == nil){
                    value = [self.dateFormatter stringFromDate:[NSDate date]];
                }else{
                    value = endDate;
                }
            }
            [[cell detailTextLabel] setText:value];
            [cell detailTextLabel].tag = kEndDateTag;
        }
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
        self.pickerView.date = [self.dateFormatter dateFromString:targetCell.detailTextLabel.text];
        
        [self.actionSheet showInView:self.view];
        [self.actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }  
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if(footerView == nil) {
        //allocate the view if it doesn't exist yet
        footerView  = [[UIView alloc] init];
        
        //we would like to show a gloosy red button, so get the image first
        //UIImage *image = [[UIImage imageNamed:@"button_red.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        
        //create the button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setBackgroundColor:[UIColor clearColor]];
        
        //the button should be as big as a table view cell
        [button setFrame:CGRectMake(10, 3, 300, 44)];
        
        //set title, font size and font color
        [button setTitle:@"Synch Data" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //set action of the button
        [button addTarget:self action:@selector(synchModules:)
         forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlStateSelected];
        
        //add the button to the view
        [footerView addSubview:button];
    }
    
    //return the view for the footer
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat height;
    if(section == 1)
        height = 50.0f;
    return height;
}
-(void)synchModules:(id)sender{
    NSLog(@"SynchAll Modules");
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField 
{
	return YES;
}

- (void) textChanged:(id)sender {
    UITextField *textField = (UITextField *)sender;
    if(textField.tag == kUsernameTag){
        username = textField.text;
    }else if(textField.tag == kPasswordTag){
        password = textField.text;
    }else if(textField.tag ==  kURLTag){
        urlString = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
	return YES;
}

-(IBAction)saveSettings:(id)sender
{

    [keyChain addObject:username forKey:(__bridge id)kSecAttrAccount];
    [keyChain addObject:password forKey:(__bridge id)kSecValueData];
    [SettingsStore setObject:urlString forKey:@"sugarEndpoint"];
    [SettingsStore setObject:startDate forKey:kStartDateIdentifier];
    [SettingsStore setObject:endDate forKey:kEndDateIdentifier];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dateChanged:(id)sender
{
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.pickerView.date];
    if (cell.detailTextLabel.tag == kStartDateTag) {
        startDate = cell.detailTextLabel.text;
    }else if(cell.detailTextLabel.tag == kEndDateTag){
        endDate = cell.detailTextLabel.text;
    }
}

- (IBAction)dateSelectionDone:(id)sender
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
