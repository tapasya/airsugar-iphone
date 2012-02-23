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
#import "SyncSettingsViewController.h"
#import "AppDelegate.h"
#define kLogoutCell @"login"
@implementation AppSettingsViewController
@synthesize settingsArray=_settingsArray; //where is _settingsArray defined?
@synthesize pickerView;
@synthesize dateFormatter;
@synthesize saveButton;
@synthesize actionSheet;
@synthesize username;
@synthesize password;
@synthesize urlString;

ApplicationKeyStore *keyChain;  //Global objects? whats the use?
UIView *footerView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIBarButtonItem*) saveButton
{
    if(!saveButton){
        saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveSettings:)];
    }
    return saveButton;
}


-(NSArray*) settingsArray
{
    if(!_settingsArray){
        // To add new settings pupulate the array with the appropriate identifiers supply a table cell for that identifier
        NSArray* userSettings = [[NSArray alloc] initWithObjects:kRestUrlIdentifier,kUsernameIdentifier,kPasswordIdentifier, nil];
        NSArray* syncSettings = [[NSArray alloc] initWithObjects:kSyncSettingsIdentifier, nil];
        _settingsArray = [[NSArray alloc] initWithObjects:userSettings, syncSettings,[NSArray arrayWithObject:kLogoutCell],nil];        
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewwillappear"); //remove log
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
    
    NSString* cellIdentifier = [[self.settingsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSString* value = [SettingsStore objectForKey:cellIdentifier];
    if ([cellIdentifier isEqualToString:kLogoutCell]) 
    {
        if (cell==nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.text = @"Logout!";
        }
        return cell;
    }
    if([cellIdentifier isEqualToString:kRestUrlIdentifier] || [cellIdentifier isEqualToString:kUsernameIdentifier] || [cellIdentifier isEqualToString:kPasswordIdentifier])
    {
        if (!cell)
        {
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
        else
        {
            static NSString *CellIdentifier = @"Cell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            if([cellIdentifier isEqualToString:kSyncSettingsIdentifier])
            {
                cell.textLabel.text = kSyncSettingsIdentifier;
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
            return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = [[self.settingsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if([identifier isEqualToString:kSyncSettingsIdentifier])
    {
        SyncSettingsViewController *syncSettings = [[SyncSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:syncSettings animated:YES];
    }
    else if([[[_settingsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isEqualToString:kLogoutCell])
    {
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logout];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }  
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
    [self.navigationController popViewControllerAnimated:YES];
}

@end
