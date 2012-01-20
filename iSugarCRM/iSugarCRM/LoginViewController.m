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

@implementation LoginViewController
@synthesize spinner;
@synthesize usernameField;
@synthesize passwordField;

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
    [spinner setHidden:YES];
    usernameField.delegate = self;
    passwordField.delegate = self;
    passwordField.secureTextEntry = YES;
    
    // TODO should fetch the details from Account Manager
    usernameField.text = @"will";
    passwordField.text = @"18218139eec55d83cf82679934e5cd75";
    // Do any additional setup after loading the view from its nib.
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

-(void) showError:(NSError *)error
{
    [spinner setHidden:YES];
    
    NSString *messageString = [error localizedDescription];//customize this message with error.code;
    NSLog(@"Code-->%d",[error code]);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:messageString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void) showDashboard
{
    [spinner setHidden:YES];
    AppDelegate *appDelegate = (AppDelegate* ) [UIApplication sharedApplication].delegate;
    [appDelegate showDashboard];
}

-(void) authenicate
{
    // TODO should fetch the details from Account Manager
    NSString *userName = usernameField.text;
    NSString *password = passwordField.text;
    id response = [LoginUtils login:userName :password];
    if ([response  objectForKey:@"Error"]) {
        [self performSelectorOnMainThread:@selector(showError:) withObject:(NSError *)[response  objectForKey:@"Error"] waitUntilDone:NO];
    } else{
        session = [[response objectForKey:@"response"]objectForKey:@"id"];
        [self performSelectorOnMainThread:@selector(showDashboard) withObject:nil waitUntilDone:NO];
    }
}

- (IBAction)onLoginClicked:(id)sender 
{
    [spinner setHidden:NO];
    [spinner startAnimating];
    [self performSelectorInBackground:@selector(authenicate) withObject:nil];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
