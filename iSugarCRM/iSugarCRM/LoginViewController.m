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
#import <QuartzCore/QuartzCore.h>

#define kOFFSET_FOR_KEYBOARD 60.0
@interface LoginViewController()
-(void)registerForKeyboardNotifications;
-(void)unRegisterForKeyboardNotifications;
-(void)setViewMovedUp:(BOOL)movedUp;
@end
@implementation LoginViewController
@synthesize spinner;
@synthesize loginButton;
@synthesize scrollView;
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
    
    // customizing the button
    CALayer *layer = loginButton.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.4f alpha:0.2f].CGColor;
    
    // Create a shiny layer that goes on top of the button
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = loginButton.layer.bounds;
    // Set the gradient colors
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    // Set the relative positions of the gradien stops
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    // Add the layer to the button
    [loginButton.layer addSublayer:shineLayer];
    
    [loginButton setBackgroundColor:COLOR(0, 120, 255)];
    
    [spinner setHidesWhenStopped:YES];
    [spinner stopAnimating];
    urlField.delegate = self;
    usernameField.delegate = self;
    passwordField.delegate = self;
    passwordField.secureTextEntry = YES;
    passwordField.returnKeyType = UIReturnKeyDefault;
    
    //TODO: md5 hash for password
    usernameField.text = @"will";
    passwordField.text = @"will";
    urlField.text = sugarEndpoint;

    if([LoginUtils keyChainHasUserData]){
        [spinner setHidden:NO];
        [spinner startAnimating];
    }else{
        [spinner stopAnimating];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidLoad];
    
    // register for keyboard notifications
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // unregister for keyboard notifications while not visible.
    [self unRegisterForKeyboardNotifications];
}

- (void)viewDidUnload
{
    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [self setSpinner:nil];
    [self setScrollView:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [urlField resignFirstResponder];
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    return YES;    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        // adding extra height to display login button
        CGFloat width = fmaxf(self.view.window.frame.size.width, self.view.window.frame.size.height) ;
        CGFloat height = fminf(self.view.window.frame.size.width, self.view.window.frame.size.height) ;
        [scrollView setContentSize:CGSizeMake( width , height + 100)];
    }
    else
    {
        // remove the extra height used by the status bar
        CGFloat width = fminf(self.view.window.frame.size.width, self.view.window.frame.size.height) ;
        CGFloat height = fmaxf(self.view.window.frame.size.width, self.view.window.frame.size.height) ;
        [scrollView setContentSize:CGSizeMake(width , height - 50)];
    }
}

-(void) showSyncSettings
{
        
    [spinner stopAnimating];;
    keyChain = [[ApplicationKeyStore alloc]initWithName:@"iSugarCRM-keystore"];
    [keyChain addObject:usernameField.text forKey:(__bridge id)kSecAttrAccount];
    [keyChain addObject:passwordField.text forKey:(__bridge id)kSecValueData];
    [[NSUserDefaults standardUserDefaults]setObject:urlField.text forKey:@"endpointURL"];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:kAppAuthenticationState];
    [keyChain addObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    AppDelegate* sharedDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [sharedDelegate dismissWaitingAlert];
    [sharedDelegate showSyncSettingViewController];
}

-(void) onLoginFailed:(id) response
{
    [spinner stopAnimating];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] dismissWaitingAlert];
    [LoginUtils displayLoginError:response];
}

-(void) authenicate
{
    int userNameLen = [usernameField.text length];
    int passwordLen = [passwordField.text length];
    int urlLen = [urlField.text length];
    
    if (userNameLen==0 || passwordLen==0 || urlLen == 0) {
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] dismissWaitingAlert];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your details and relogin" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [spinner stopAnimating];
        return;
    }
    id response = [LoginUtils loginWithUsername:usernameField.text password:[LoginUtils md5Hash:passwordField.text] andUrl:urlField.text];
    //id response = [LoginUtils login:usernameField.text :[LoginUtils md5Hash:passwordField.text]];
    NSLog(@"RESPONSE OBJECT IS --------> %@",[response objectForKey:@"response"]);
    if([[response objectForKey:@"response"]objectForKey:@"id"]){
        session = [[response objectForKey:@"response"]objectForKey:@"id"];
        [self performSelectorOnMainThread:@selector(showSyncSettings) withObject:nil waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(onLoginFailed:) withObject:response waitUntilDone:NO];
    }
    
}

- (IBAction)onLoginClicked:(id)sender 
{
    [spinner stopAnimating];
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] showWaitingAlertWithMessage:nil];
    [self performSelectorInBackground:@selector(authenicate) withObject:nil];
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{   
    activeField = sender;
}
-(void)textFieldDidEndEditing:(UITextField *)sender
{   
    activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == urlField || textField == usernameField)
    {
        [textField resignFirstResponder];
    }
    else if(textField == passwordField){
        [textField resignFirstResponder];
        //[self performSelectorOnMainThread:@selector(onLoginClicked:) withObject:nil waitUntilDone:NO];
    }
    return YES;
}

-(void)dismissKeyboard:(id)sender
{
    if([urlField respondsToSelector:@selector(resignFirstResponder)]){
        [urlField resignFirstResponder];
    }
    if([usernameField respondsToSelector:@selector(resignFirstResponder)])
    {
        [usernameField resignFirstResponder];
    }
    if([passwordField respondsToSelector:@selector(resignFirstResponder)]){
        [passwordField resignFirstResponder];
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)unRegisterForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShown:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight)
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your application might not need or want this behavior.
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        CGPoint origin = activeField.frame.origin;
        origin.y -= scrollView.contentOffset.y;
        if (!CGRectContainsPoint(aRect, origin) )
        {
            CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-(aRect.size.height)); 
            [scrollView setContentOffset:scrollPoint animated:YES];
        }
    }else //if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        [self setViewMovedUp:YES];
    }
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight)
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
    }else if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    CGRect rect = self.view.frame;
    CGRect rect1 = self.view.bounds;
    if (movedUp)
    {
        NSLog(@"y origin of rect view frame %f",rect.origin.y);
        NSLog(@"y origin of rect view bound %f",rect1.origin.y);
        NSLog(@"height of rect view frame %f",rect.size.height);
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    NSLog(@"y origin of view %f",self.view.frame.origin.y);
    [UIView commitAnimations];
}
@end
