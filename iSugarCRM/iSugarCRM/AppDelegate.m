//
//  AppDelegate.m
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONKit.h"
#import "ViewController.h"
#import "OrderedDictionary.h"
#import "SugarCRMMetadataStore.h"
#import "WebserviceSession.h"
#import "DataObjectField.h"
#import "DataObjectMetadata.h"
#import "WebserviceMetadata.h"
 NSString * session=nil;


@interface AppDelegate ()
-(id)login;
-(NSString*)urlStringForParams:(NSMutableDictionary*)params;
-(void)generateConfig;
-(void)saveConfig:(NSMutableDictionary*)plistDictionary;
@end

@implementation AppDelegate
@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    if (!(session =[[self login] objectForKey:@"id"])) {
     NSLog(@"error loging in");     
        return NO;
    } 
    
    NSLog(@"session: %@",session); 
    [self generateConfig];
    SugarCRMMetadataStore *metaDataStore =  [SugarCRMMetadataStore sharedInstance];
    WebserviceSession *wss=[WebserviceSession sessionWithMatadata:[metaDataStore listServiceMetadataForModule:[NSString stringWithFormat:@"list-%@",@"Accounts"]]]; 
    wss.startLoading;
    
    return YES;   
}


-(void)generateConfig{
    
    NSMutableDictionary* restDataDictionary=[[OrderedDictionary alloc]init];
    [restDataDictionary setObject:session forKey:@"session"];
    
    NSMutableDictionary* urlParams=[[OrderedDictionary alloc] init];
    [urlParams setObject:@"get_available_modules" forKey:@"method"];
    [urlParams setObject:@"JSON" forKey:@"input_type"];
    [urlParams setObject:@"JSON" forKey:@"response_type"];
    [urlParams setObject:restDataDictionary forKey:@"rest_data"];
    
    NSString* urlString=[[NSString stringWithFormat:@"%@",[self urlStringForParams:urlParams]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest* request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];  
    NSURLResponse* response = [[NSURLResponse alloc] init]; 
    NSError* error = nil;  
    NSData* adata = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error]; 
    if (error) {
        NSLog(@"Error Parsing Metadata");
        return;
    } 
    id moduleResponse=[adata objectFromJSONData];
    NSMutableDictionary* moduleKeyValuePairs=[[NSMutableDictionary alloc] init];
    for(NSDictionary* module in [moduleResponse objectForKey:@"modules"] ){
        
        [moduleKeyValuePairs setObject:[module objectForKey:@"module_label"] forKey:[module objectForKey:@"module_key"]];
    }
    NSLog(@"module list%@",moduleKeyValuePairs);
    [self performSelectorInBackground:@selector(configForModules:) withObject:moduleKeyValuePairs];
}

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

-(void)configForModules:(NSMutableDictionary*)moduleKeyValuePairs{
    
    NSMutableDictionary* restDataDictionary = [[OrderedDictionary alloc]init];
    [restDataDictionary setObject:session forKey:@"session"];
    
    NSMutableDictionary* urlParams=[[OrderedDictionary alloc] init];
    [urlParams setValue:@"get_module_fields" forKey:@"method"];
    [urlParams setObject:@"JSON" forKey:@"input_type"];
    [urlParams setObject:@"JSON" forKey:@"response_type"];
    [urlParams setObject:restDataDictionary forKey:@"rest_data"];
    
    NSMutableDictionary* plistDictionary = [[NSMutableDictionary alloc] init]; //plist dictionary
    [plistDictionary setValue:moduleKeyValuePairs forKey:@"Modules"];
    
    NSMutableDictionary* moduleFields = [[NSMutableDictionary alloc] init];
    
    for(NSString *module in [moduleKeyValuePairs allKeys] ){
        [restDataDictionary setValue:module  forKey:@"module_name"];
        NSString* urlString = [[NSString stringWithFormat:@"%@",[self urlStringForParams:urlParams]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];  
        NSURLResponse* response = [[NSURLResponse alloc] init]; 
        NSError* error = nil;  
        NSData* adata = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error]; 
        if (error) {
            NSLog(@"Error Parsing Metadata");
            return;
        } 
        id moduleFieldsResponse = [adata objectFromJSONData];
        NSMutableArray *arrayOfDAOFields = [[NSMutableArray alloc] init];
        if ([[[moduleFieldsResponse valueForKey:@"module_fields"] class] isSubclassOfClass:[NSDictionary class]]) {
            NSDictionary *moduleFields = [moduleFieldsResponse objectForKey:@"module_fields"];
            for(NSString *fieldName in [moduleFields allKeys])
            {
                NSDictionary *fieldDescription = [moduleFields objectForKey:fieldName];
                DataObjectField *daoField = [[DataObjectField alloc] init];
                daoField.name = fieldName;
                daoField.label = [fieldDescription valueForKey:@"label"];
                daoField.dataType = ObjectFieldDataTypeString;
                [arrayOfDAOFields addObject:daoField];
            }
            DataObjectMetadata *daoMetadata = [[DataObjectMetadata alloc] init];
            daoMetadata.objectClassIdentifier = module;
            daoMetadata.fields = [NSSet setWithArray:arrayOfDAOFields];
            NSLog(@"%@ = %@",module,[daoMetadata toDictionary]);
            [moduleFields setValue:[[moduleFieldsResponse valueForKey:@"module_fields"] allKeys] forKey:module];
           
            WebserviceMetadata *wsMap = [[WebserviceMetadata alloc] init];
//            wsMap.pathToObjectsInResponse = @"get_entry_list"
            
        }
    }
   // NSLog(@"module fields %@",moduleFields);
    //[plistDictionary setValue:moduleFields forKey:@"ModuleFields"];
    //[self saveConfig:plistDictionary];
}


-(void)saveConfig:(NSMutableDictionary*)plistDictionary{
    
    NSString *errorDescription=nil;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"SugarModulesMetadata.plist"];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDictionary
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&errorDescription];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else {
        NSLog(@"%@",errorDescription);
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
