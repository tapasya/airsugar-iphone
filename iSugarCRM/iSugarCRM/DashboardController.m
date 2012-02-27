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

@interface DashboardController ()
-(void) loadModuleViews;
@property(strong)UIActivityIndicatorView *spinner;
@property(strong) UILabel *loadingLabel;
@end

@implementation DashboardController
@synthesize moduleList, spinner, loadingLabel;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteSync) name:@"SugarSyncComplete" object:nil];
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
    [self.view setBackgroundColor:[UIColor whiteColor]];
    loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(40,self.view.frame.size.width/2-50,250,50)];
    loadingLabel.text = @"Please wait loading data...";
    loadingLabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:loadingLabel];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(self.view.frame.size.width/2-10, self.view.frame.size.height/2-10, 20, 20);
    loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    [self clearSavedLauncherItems];
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
        [self.launcherView setPages:pageItems];
        
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
    ListViewController *listViewController = [ListViewController listViewControllerWithMetadata:metadata];
    listViewController.title = metadata.moduleName;
    [self.navigationController pushViewController:listViewController animated:YES];
}

-(void)didCompleteSync
{   
    NSLog(@"sync complete");
    [self.spinner stopAnimating];
    [self.spinner setHidden:YES];
    [self.loadingLabel setHidden:YES];
    [self performSelectorOnMainThread:@selector(loadModuleViews) withObject:nil waitUntilDone:NO];
    //[self loadModuleViews];
}

@end
