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
#import "SyncSettingsViewController.h"
@implementation LoginViewController
@synthesize spinner;
@synthesize usernameField;
@synthesize passwordField;
@synthesize urlField;
@synthesize loginButton;

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
    [spinner setHidesWhenStopped:YES];
    [spinner stopAnimating];
    loginButton.userInteractionEnabled = YES;
    urlField.delegate = self;
    usernameField.delegate = self;
    passwordField.delegate = self;
    passwordField.secureTextEntry = YES;
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
    //TODO: md5 hash for password
    usernameField.text = @"will";
    passwordField.text = @"will";
    urlField.text = sugarEndpoint;
    // Do any additional setup after loading the view from its nib.
    //[passwordField addTarget:<#(id)#> action:<#(SEL)#> forControlEvents:UIControlEvent]
    if([LoginUtils keyChainHasUserData]){
        [spinner setHidden:NO];
        [spinner startAnimating];
    }else{
        [spinner stopAnimating];
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



-(void) showSyncSettings
{
        
    [spinner stopAnimating];;
    keyChain = [[ApplicationKeyStore alloc]initWithName:@"iSugarCRM-keystore"];
    [keyChain addObject:usernameField.text forKey:(__bridge id)kSecAttrAccount];
    [keyChain addObject:[LoginUtils md5Hash:passwordField.text] forKey:(__bridge id)kSecValueData];
    [[NSUserDefaults standardUserDefaults]setObject:urlField.text forKey:@"endpointURL"];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:kAppAuthenticationState];
    [keyChain addObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    AppDelegate* sharedDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedDelegate showSyncSettingViewController];
}

-(void) authenicate
{
    
    int userNameLen = [usernameField.text length];
    int passwordLen = [passwordField.text length];
    int urlLen = [urlField.text length];
    
    if (userNameLen==0 || passwordLen==0 || urlLen == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your details and relogin" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [spinner stopAnimating];
        return;
    }
    
    id response = [LoginUtils login:usernameField.text :[LoginUtils md5Hash:passwordField.text]];
    NSLog(@"RESPONSE OBJECT IS --------> %@",[response objectForKey:@"response"]);
    if([[response objectForKey:@"response"]objectForKey:@"id"]){
        session = [[response objectForKey:@"response"]objectForKey:@"id"];
        [self performSelectorOnMainThread:@selector(showSyncSettings) withObject:nil waitUntilDone:NO];
    }else{
        [spinner stopAnimating];
        loginButton.userInteractionEnabled = YES;
        [LoginUtils displayLoginError:response];
    }
    
}

- (IBAction)onLoginClicked:(id)sender 
{
    [spinner setHidden:NO];
    [spinner startAnimating];
    loginButton.userInteractionEnabled = NO;
    [self performSelectorInBackground:@selector(authenicate) withObject:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == urlField)
        [usernameField becomeFirstResponder];
    else if(textField == usernameField){
        [passwordField becomeFirstResponder];
    }else if(textField == passwordField){
        [textField resignFirstResponder];
        [self performSelectorOnMainThread:@selector(onLoginClicked:) withObject:nil waitUntilDone:NO];
    }
    return YES;
}

@end
