//
//  LoginViewController.m
//  iSugarCRM
//
//  Created by pramati on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "LoginUtils.h"
#import "ApplicationKeyStore.h"
#import "SyncHandler.h"
#import "DashboardController.h"
#import "SugarCRMMetadataStore.h"

@implementation LoginViewController
@synthesize spinner;
@synthesize usernameField;
@synthesize passwordField;
@synthesize urlField;

ApplicationKeyStore *keyChain;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    //[spinner setHidden:YES];
    //usernameField.delegate = self;
    //passwordField.delegate = self;
    //passwordField.secureTextEntry = YES;
    
    NSLog(@"Viewdidload");
    // TODO should fetch the details from Account Manager
    keyChain = [[ApplicationKeyStore alloc]initWithName:@"iSugarCRM-keystore"];
    int usernameLength = [[keyChain objectForKey:(__bridge id)kSecAttrAccount] length];
    int passwordLength = [[keyChain objectForKey:(__bridge id)kSecValueData] length];
    NSString *urlString = [[NSUserDefaults standardUserDefaults]objectForKey:@"endpointURL"];
    if(usernameLength != 0){
        usernameField.text = [keyChain objectForKey:(__bridge id)kSecAttrAccount];
    }else{
        usernameField.text = @"";
    }
    if(passwordLength != 0){
        passwordField.text = [keyChain objectForKey:(__bridge id)kSecValueData];
    }else{
        passwordField.text = @"";
    }
    
    if(urlString){
        urlField.text = urlString;
    }else{
        //urlField.text = sugarEndpoint;
    }
    
    // TODO should fetch the details from Account Manager
    //usernameField.text = @"will";
    //passwordField.text = @"18218139eec55d83cf82679934e5cd75";
    //urlField.text = sugarEndpoint;
    // Do any additional setup after loading the view from its nib.
    if([LoginUtils keyChainHasUserData]){
        [spinner setHidden:NO];
        [spinner startAnimating];
    }else{
        [spinner setHidden:YES];
    }
}


- (void)viewDidUnload
{
    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}



-(void) showDashboard
{
    [spinner setHidden:YES];
    keyChain = [[ApplicationKeyStore alloc]initWithName:@"iSugarCRM-keystore"];
    [keyChain addObject:usernameField.text forKey:(__bridge id)kSecAttrAccount];
    [keyChain addObject:passwordField.text forKey:(__bridge id)kSecValueData];
    [[NSUserDefaults standardUserDefaults]setObject:urlField.text forKey:@"endpointURL"];
    [keyChain addObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    NSLog(@"added username and password");
    AppDelegate* sharedDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedDelegate showDashboardController];
}

-(void) authenicate
{
    // TODO should fetch the details from Account Manager
    
    int userNameLen = [usernameField.text length];
    int passwordLen = [passwordField.text length];
    int urlLen = [urlField.text length];
    
    if (userNameLen==0 || passwordLen==0 || urlLen == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your details and relogin" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [spinner setHidden:YES];
        return;
    }
    
    id response = [LoginUtils login:usernameField.text :passwordField.text];
    NSLog(@"RESPONSE OBJECT IS --------> %@",[response objectForKey:@"response"]);
    if([[response objectForKey:@"response"]objectForKey:@"id"]){
        session = [[response objectForKey:@"response"]objectForKey:@"id"];
        [self performSelectorOnMainThread:@selector(showDashboard) withObject:nil waitUntilDone:NO];
    }else{
        [spinner setHidden:YES];
        [LoginUtils displayLoginError:response];
    }
    
}

- (IBAction)onLoginClicked:(id)sender 
{
    [spinner setHidden:NO];
    [spinner startAnimating];
    [self performSelectorInBackground:@selector(authenicate) withObject:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
