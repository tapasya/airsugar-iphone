//
//  DashboardController.m
//  iSugarCRM
//
//  Created by pramati on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DashboardController.h"
#import "SugarCRMMetadataStore.h"
#import "MyLauncherItem.h"
#import "ListViewController.h"
#import "AppSettingsViewController.h"
#import "SyncHandler.h"
#import "LoginUtils.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "DetailViewController.h"
#import "ListViewController_pad.h"
#import "SplitViewController.h"

#define kIpadLabelWidth         400
#define kIphoneLabelWidth       250
#define kLabelHeight             50
#define kIpadSpinnerSize         80
#define kIphoneSpinnerSize       20

@interface DashboardController ()
-(void) loadModuleViews;
@property(strong)UIActivityIndicatorView *spinner;
@property(strong) UILabel *loadingLabel;
@end

@implementation DashboardController
@synthesize moduleList, spinner, loadingLabel;
bool isSyncEnabled ;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteSync) name:@"SugarSyncComplete" object:nil];
        isSyncEnabled = false;
    }
    return self;
}

-(id) initAndSync
{
    self = [super init];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteSync) name:@"SugarSyncComplete" object:nil];
        isSyncEnabled = true;
        [self performSelectorInBackground:@selector(performLoginAction) withObject:nil]; //blocking sync view
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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    // comment the line below to enable editing (moving/deleting)!
    [self.launcherView setEditingAllowed:NO];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];  
    if(isSyncEnabled){
        [self.view setBackgroundColor:[UIColor whiteColor]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - kIpadLabelWidth/2 ,self.view.frame.size.height/2-kLabelHeight,kIpadLabelWidth ,kLabelHeight)];
            loadingLabel.font = [UIFont systemFontOfSize:32];
            spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            spinner.color = [UIColor grayColor];
            spinner.frame = CGRectMake(self.view.frame.size.width/2-kIpadSpinnerSize/2, self.view.frame.size.height/2+10, kIpadSpinnerSize, kIpadSpinnerSize);
        }
        else
        {
            loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - kIphoneLabelWidth/2,self.view.frame.size.height/2-kLabelHeight,kIphoneLabelWidth,kLabelHeight)];
            spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.frame = CGRectMake(self.view.frame.size.width/2-kIphoneSpinnerSize/2, self.view.frame.size.height/2, kIphoneSpinnerSize, kIphoneSpinnerSize);
        }
        loadingLabel.text = @"Please wait loading data...";
        loadingLabel.textAlignment = UITextAlignmentCenter;
        loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:loadingLabel];
        [self.view addSubview:spinner];
        [spinner startAnimating];
        [self clearSavedLauncherItems];
    }
    else{
        [self clearSavedLauncherItems];
        [self loadModuleViews];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(IBAction)showSettings:(id)sender
{
    AppSettingsViewController* svc = [[AppSettingsViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

-(void)performLoginAction{
//    id response = [LoginUtils login];
//    session = [[response objectForKey:@"response"]objectForKey:@"id"];
    id response;
    
    if(session){
        AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [sharedAppDelegate sync];
    }else{
        session = nil;
        response = [LoginUtils login];
        session = [[response objectForKey:@"response"]objectForKey:@"id"];
        if(!session){
            LoginViewController *lvc = [[LoginViewController alloc] init];
            UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
            appKeyWindow.rootViewController=lvc;
            [lvc.spinner setHidden:YES];
            [LoginUtils displayLoginError:response];
        }else{
            AppDelegate *sharedAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [sharedAppDelegate sync];
        }
    }
}



-(void) loadModuleViews
{
    [self loadView];
    SugarCRMMetadataStore *sugarMetaDataStore = [SugarCRMMetadataStore sharedInstance];
    moduleList = [sugarMetaDataStore modulesSupported];
    self.title = @"Modules";
	if(![self hasSavedLauncherItems]){
        NSInteger pageCount = moduleList.count / self.launcherView.maxItemsPerPage;
        if(moduleList.count % self.launcherView.maxItemsPerPage != 0){
            pageCount++;
        }
        NSMutableArray *pageItems = [[NSMutableArray alloc] initWithCapacity:pageCount];
        for(int i =0; i<pageCount; i++){
            [pageItems addObject:[[NSMutableArray alloc] init]];
            NSInteger limit = MIN(moduleList.count, (i+1)*self.launcherView.maxItemsPerPage);
            for(int j=i*self.launcherView.maxItemsPerPage; j< limit; j++){
                NSString *moduleName = [moduleList objectAtIndex:j];
                NSString *imagename = [[sugarMetaDataStore listViewMetadataForModule:moduleName] iconImageName];
                if(!imagename || [imagename isEqualToString:@""])
                {
                    imagename = @"itemImage";
                }
                [[pageItems objectAtIndex:i] addObject:[[MyLauncherItem alloc] initWithTitle:moduleName image:imagename target:nil deletable:NO]];
            }
        }
        [self.launcherView setPages:pageItems animated:(BOOL) isSyncEnabled];
        
        UIBarButtonItem* settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
        self.navigationItem.rightBarButtonItem = settingsButton;
    }
}

-(void)launcherViewItemSelected:(MyLauncherItem*)item 
{
    SugarCRMMetadataStore *sharedInstance = [SugarCRMMetadataStore sharedInstance];
    NSString *modulename = [item title];
    ListViewMetadata *metadata = [sharedInstance listViewMetadataForModule:modulename];
    NSLog(@"metadata module name %@",metadata.moduleName); //remove debug logs
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        ListViewController_pad* lvc_pad = [ListViewController_pad listViewControllerWithMetadata:metadata];
        lvc_pad.title = metadata.moduleName;
        
        DetailViewController_pad* dvc_pad = [[DetailViewController_pad alloc] init];
        dvc_pad.metadata = [sharedInstance detailViewMetadataForModule:lvc_pad.metadata.moduleName];
        
        SplitViewController* spvc = [[SplitViewController alloc] init];
        spvc.master = lvc_pad;
        spvc.detail = dvc_pad;
        spvc.viewControllers = [NSArray arrayWithObjects:[[UINavigationController alloc] initWithRootViewController:lvc_pad],[[UINavigationController alloc] initWithRootViewController:dvc_pad], nil];
        
        AppDelegate* delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        delegate.window.rootViewController = spvc ;
    }
    else
    {
        ListViewController *listViewController = [ListViewController listViewControllerWithMetadata:metadata];
        listViewController.title = metadata.moduleName;
        [self.navigationController pushViewController:listViewController animated:YES];   
    }
}

-(void)didCompleteSync
{   
    NSLog(@"sync complete");
    [self.spinner stopAnimating];
    [self.spinner setHidden:YES];
    [self.loadingLabel setHidden:YES];
    [self performSelectorOnMainThread:@selector(loadModuleViews) withObject:nil waitUntilDone:NO];
    //[self loadModuleViews];
    
    /*
     This piece of code needs to be handled in different way in appropriate place
     
     This piece of code is to dismiss the alert shown while syncing the app in sync settings
     */
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate performSelectorOnMainThread:@selector(dismissWaitingAlert) withObject:nil waitUntilDone:NO];
}

@end
