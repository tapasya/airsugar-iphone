//
//  AppDelegate.m
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONKit.h"
#import "RootViewController.h"
#import "OrderedDictionary.h"
#import "SugarCRMMetadataStore.h"
#import "WebserviceSession.h"
#import "DataObjectField.h"
#import "DataObjectMetadata.h"
#import "WebserviceMetadata.h"
#import "DBSession.h"
#import "DataObject.h"
#import "ListViewMetadata.h"
#import "SyncHandler.h"
NSString * session=nil;

@interface AppDelegate ()
-(id)login;
-(NSString*)urlStringForParams:(NSMutableDictionary*)params;
@end

@implementation AppDelegate
@synthesize window = _window;
@synthesize nvc;
@synthesize syncHandler;

-(id)login{
    
    NSMutableDictionary *authDictionary=[[NSMutableDictionary alloc]init];
    [authDictionary setObject:@"will" forKey:@"user_name"];
    [authDictionary setObject:@"18218139eec55d83cf82679934e5cd75" forKey:@"password"];
    NSMutableDictionary* restDataDictionary=[[NSMutableDictionary alloc]init];
    [restDataDictionary setObject:authDictionary forKey:@"user_auth"];
    [restDataDictionary setObject:@"soap_test" forKey:@"application"];
    NSMutableDictionary* urlParams=[[NSMutableDictionary alloc] init];
    [urlParams setObject:@"login" forKey:@"method"];
    [urlParams setObject:@"JSON" forKey:@"input_type"];
    [urlParams setObject:@"JSON" forKey:@"response_type"];
    [urlParams setObject:restDataDictionary forKey:@"rest_data"];
    NSString* urlString = [[NSString stringWithFormat:@"%@",[self urlStringForParams:urlParams]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];  
    NSURLResponse* response = [[NSURLResponse alloc] init]; 
    NSError* error=nil;  
    NSData* adata = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];     
    if (error) {
        return nil;
    }
    else{
        return [adata objectFromJSONData];;
    }
}

-(NSString*)urlStringForParams:(NSMutableDictionary*)params{
    NSString* urlString  =[NSString stringWithFormat:@"%@?",sugarEndpoint];
    
    bool is_first=YES;
    for(id key in [params allKeys])
    {
        if(![[key description] isEqualToString:@"rest_data"]){   
            
            if (is_first) {
                urlString=[urlString stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,[params objectForKey:key]]];
                is_first=NO;
            }
            else{
                urlString=[urlString stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",key,[params objectForKey:key]]];
            }
        }
        else{
            if (is_first) {
                urlString=[urlString stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,[[params objectForKey:key]JSONString ]]];
                is_first=NO;
            }
            else{
                urlString=[urlString stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",key,[[params objectForKey:key]JSONString]]];
            }
            
        }
    }
    NSLog(@"%@",urlString);
    return urlString;
} 

#pragma mark UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    
    if (!(session =[[self login] objectForKey:@"id"])) {
        NSLog(@"error loging in");     
        return NO;
    } 
    NSLog(@"session: %@",session);
    
    SugarCRMMetadataStore *sugarMetaDataStore = [SugarCRMMetadataStore sharedInstance];
    [sugarMetaDataStore configureMetadata];
    syncHandler = [[SyncHandler alloc] init];
    syncHandler.delegate = self;
    [syncHandler syncAllModules];
    RootViewController *rvc = [[RootViewController alloc] init];
    rvc.moduleList = [sugarMetaDataStore modulesSupported];   
    rvc.title = @"Modules";
    nvc = [[UINavigationController alloc] initWithRootViewController:rvc];
    self.window.rootViewController = self.nvc;
    [self.window makeKeyAndVisible];
    return YES;   
}

-(void)syncHandler:(SyncHandler*)syncHandler failedWithError:(NSError*)error
{
    
}
-(void)syncComplete:(SyncHandler*)syncHandler
{
    
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
