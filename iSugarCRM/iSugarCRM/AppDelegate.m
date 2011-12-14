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
-(NSDictionary*)generateConfig;
-(void)saveConfig:(NSMutableDictionary*)plistDictionary;
@property (strong) NSDictionary *moduleList;
@end

@implementation AppDelegate
@synthesize window = _window;
@synthesize nvc;
@synthesize moduleList;
@synthesize syncHandler;
/*
#pragma mark DbSessionSync delegate methods

-(void)syncFailedWithError:(NSError*)error{

}

-(void)syncSuccessful{
     SugarCRMMetadataStore * sugarMetaDataStore = [SugarCRMMetadataStore sharedInstance];
    DBSession *dbs = [DBSession sessionWithMetadata:[sugarMetaDataStore dbMetadataForModule:@"Accounts"]];
    dbs.delegate=self;
    dbs.syncDelegate=self;
    [dbs startLoading];
}
#pragma mark dbSessionLoad delegate methods

-(void)downloadedModuleList:(NSArray*)moduleList moreComing:(BOOL)moreComing{
    
}

-(void)listDownloadFailedWithError:(NSError*)error{

}

#pragma mark Webservice session delegate methods

-(void)sessionWillStartLoading:(WebserviceSession*)session{

}
-(void)session:(WebserviceSession*)session didCompleteWithResponse:(id)response{
    SugarCRMMetadataStore * sugarMetaDataStore = [SugarCRMMetadataStore sharedInstance];
    DBSession *dbs = [DBSession sessionWithMetadata:[sugarMetaDataStore dbMetadataForModule:@"Accounts"]];
    dbs.delegate=self;
    dbs.syncDelegate=self;
    [dbs updateDBWithDataObjects:response];
   
}
-(void)session:(WebserviceSession*)session didFailWithError:(NSError*)error{

    NSLog(@"failed with error: %@",[error localizedDescription]);
}
*/

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
//checks if config file exists or not. if not then create with a list of modules and their fields;
-(NSDictionary*)generateConfig 
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success;
    NSString *rootPath= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString* plistPath;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil]) {
        plistPath = [rootPath stringByAppendingPathComponent:@"SugarModulesMetadata.plist"]; 
    } 
    success = [fileManager fileExistsAtPath:plistPath];
    NSMutableDictionary* moduleKeyValuePairs;
    //check if config file already exist
    if(!success)
    {   //request for config details from server
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
            return nil;
        } 
        //strore details in config file
         moduleKeyValuePairs=[[NSMutableDictionary alloc] init];
        id moduleResponse=[adata objectFromJSONData];
        for(NSDictionary* module in [moduleResponse objectForKey:@"modules"] ){
            [moduleKeyValuePairs setObject:[module objectForKey:@"module_label"] forKey:[module objectForKey:@"module_key"]];
        }
        NSLog(@"modules in plist %@",moduleKeyValuePairs);
       // [self performSelectorInBackground:@selector(configForModules:) withObject:moduleKeyValuePairs];
    } else {
         moduleKeyValuePairs=[[NSMutableDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"Modules"];
    }
    self.moduleList = moduleKeyValuePairs;
    return moduleKeyValuePairs;
}

-(void)configForModules{//:(NSMutableDictionary*)moduleKeyValuePairs{
    
    //request for config details for each module from server
    NSMutableDictionary* restDataDictionary = [[OrderedDictionary alloc]init];
    [restDataDictionary setObject:session forKey:@"session"];
    
    NSMutableDictionary* urlParams=[[OrderedDictionary alloc] init];
    [urlParams setValue:@"get_module_fields" forKey:@"method"];
    [urlParams setObject:@"JSON" forKey:@"input_type"];
    [urlParams setObject:@"JSON" forKey:@"response_type"];
    [urlParams setObject:restDataDictionary forKey:@"rest_data"];
 
    NSMutableString *DataObjectMetadataConfig = [NSMutableString stringWithString:@""];
    NSMutableString *WebserviceMetadataConfig = [NSMutableString stringWithString:@""];
    NSMutableString *DBMetadataConfig = [NSMutableString stringWithString:@""];
    NSMutableString *ListViewMetadataConfig = [NSMutableString stringWithString:@""]; 
    
    for(NSString *module in [[moduleList objectForKey:@"Modules"]allKeys] ){
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
            NSMutableDictionary *moduleFields = [moduleFieldsResponse objectForKey:@"module_fields"];
               [moduleFields setValue:[[moduleFieldsResponse valueForKey:@"module_fields"] allKeys] forKey:module];
            //DataObjectMetadata
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
            
            [DataObjectMetadataConfig appendString:[NSString stringWithFormat:@"%@ = %@ \n",module,[daoMetadata toDictionary]]];
         
            
           //WebserviceMetadata
            WebserviceMetadata *wsMap = [[WebserviceMetadata alloc] init];
            wsMap.pathToObjectsInResponse = @"get_entry_list";
            wsMap.endpoint = sugarEndpoint;
            NSMutableDictionary *restDataDictionary=[[OrderedDictionary alloc] init];
            [restDataDictionary setObject:session forKey:@"session"];
            [restDataDictionary setObject:module forKey:@"module"];
            NSString* restDataString=[restDataDictionary JSONString];
            [wsMap setUrlParam:@"get_entry_list" forKey:@"method"];
            [wsMap setUrlParam:@"JSON" forKey:@"input_type"];
            [wsMap setUrlParam:@"JSON" forKey:@"response_type"];
            [wsMap setUrlParam:restDataString forKey:@"rest_data"];
            NSMutableDictionary *responseKeyPathMap = [[NSMutableDictionary alloc] init];
            for(DataObjectField *field in arrayOfDAOFields)
            {
                [responseKeyPathMap setObject:[NSString stringWithFormat:@"name_value_list.%@.value",field.name] forKey:field];
            }
            wsMap.responseKeyPathMap = responseKeyPathMap;
            wsMap.objectMetadata=daoMetadata;
            NSLog(@"%@ = %@",module,[wsMap toDictionary]);
            [WebserviceMetadataConfig appendString:[NSString stringWithFormat:@"%@ = %@ \n",module,[wsMap toDictionary]]];
            
           //DbMetadata 
            DBMetadata* dbMetadata = [[DBMetadata alloc] init];
            dbMetadata.objectMetadata = daoMetadata;
            dbMetadata.tableName = module;
            NSMutableSet *fieldsName=[[NSMutableSet alloc] init];
            NSMutableDictionary *col_fieldMap = [[NSMutableDictionary alloc] init];
            for(DataObjectField *field in [daoMetadata.fields allObjects])
            {   [col_fieldMap setObject:field.name forKey:field.name];
                [fieldsName addObject:[col_fieldMap objectForKey:field.name]];
            }
            dbMetadata.columnNames = fieldsName;
            dbMetadata.column_objectFieldMap = col_fieldMap;
            NSLog(@"%@ = %@",module,[dbMetadata toDictionary]);
            [DBMetadataConfig appendString:[NSString stringWithFormat:@"%@ = %@ \n",module,[dbMetadata toDictionary]]];
            
            //ListViewMetadata
            ListViewMetadata *lViewMetadata = [[ListViewMetadata alloc] init];
            DataObjectField *primaryField = [[DataObjectField alloc] init];
            primaryField.name = @"name";
            lViewMetadata.primaryDisplayField = primaryField; 
            lViewMetadata.otherFields = nil;
            lViewMetadata.iconImageName = nil;
            NSLog(@"%@ = %@",module,[lViewMetadata toDictionary]);
            [ListViewMetadataConfig appendString:[NSString stringWithFormat:@"%@ = %@ \n",module,[lViewMetadata toDictionary]]];
        }
    }
}

#pragma mark Utility methods

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
    [syncHandler syncForModules:[sugarMetaDataStore.moduleList allKeys]];
    RootViewController *rvc = [[RootViewController alloc] init];
    rvc.moduleList = sugarMetaDataStore.moduleList;   
    rvc.title = @"Modules";
    nvc = [[UINavigationController alloc] initWithRootViewController:rvc];

    self.window.rootViewController = self.nvc;
    [self.window makeKeyAndVisible];
   
   // [self.window addSubview:nvc.view];
  //  [self.window makeKeyAndVisible];
    
    
 //   WebserviceSession *wss = [WebserviceSession sessionWithMatadata:[sugarMetaDataStore listServiceMetadataForModule:@"Accounts"]]; 
    //wss.delegate=self;
  //  [wss startLoading];
    return YES;   
}

-(void)syncHandler:(SyncHandler*)syncHandler failedWithError:(NSError*)error
{
      
}
-(void)syncComplete:(SyncHandler*)syncHandler
{
    SugarCRMMetadataStore *sugarMetadataStore = [SugarCRMMetadataStore sharedInstance];
    RootViewController *rvc = [[RootViewController alloc] init];
    rvc.moduleList = sugarMetadataStore.moduleList;   
    rvc.title = @"Modules";
   // [self.nvc pushViewController:rvc animated:YES];

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
