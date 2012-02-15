//
//  SugarCRMMetadataStore.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SugarCRMMetadataStore.h"
#import "DataObjectField.h"
#import "DataObjectMetadata.h"
#import "WebserviceMetadata.h"
#import "DBMetadata.h"
#import "SqliteObj.h"
#import "OrderedDictionary.h"
#import "JSONKit.h"
static SugarCRMMetadataStore *sharedInstance = nil;

@interface SugarCRMMetadataStore ()
-(id)initPrivate;
-(void)loadModuleList;
-(BOOL)loadMetadata;
-(NSString*)urlStringForParams:(NSMutableDictionary*)params;
/**only to generate and save config file*/
-(void)saveConfig:(NSMutableDictionary*)plistDictionary;
-(NSDictionary*)generateConfiguration;
/****/
@property(strong)NSMutableDictionary *moduleList;
@property(strong)NSDictionary *metadataDictionary;
@end

@implementation SugarCRMMetadataStore
@synthesize metadataDictionary,moduleList;
+(SugarCRMMetadataStore*)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[SugarCRMMetadataStore alloc] initPrivate];
    }
    return sharedInstance;
}

-(id)init
{
    NSAssert(NO, @"Cannot instantiate this directly, use sharedInstance");
    return nil;//for warning
}

-(id)initPrivate
{
    self = [super init];
    return self;
}

-(NSArray*)modulesSupported
{
    return [metadataDictionary allKeys];
}

-(WebserviceMetadata*)listWebserviceMetadataForModule:(NSString*)moduleId{
    return [self webMetaDataForKey:[NSString stringWithFormat:@"list-%@",moduleId]];    
}

-(WebserviceMetadata*)detailWebserviceMetadataForModule:(NSString*)moduleId{
    return [self webMetaDataForKey:[NSString stringWithFormat:@"detail-%@",moduleId]];
}

-(DBMetadata*)dbMetadataForModule:(NSString*)moduleId
{
    return [self dbMetaDataForKey:moduleId];
}

-(DataObjectMetadata*)objectMetadataForModule:(NSString*)moduleId
{
    return [self objectMetadataForKey:moduleId];
}
-(ListViewMetadata*)listViewMetadataForModule:(NSString*)moduleName
{
    return [self viewMetaDataForKey:[NSString stringWithFormat:@"list-%@",moduleName]];
}

-(DetailViewMetadata*)detailViewMetadataForModule:(NSString *)moduleName{
    id metadata = [self viewMetaDataForKey:[NSString stringWithFormat:@"detail-%@",moduleName]];
    return metadata;
}

-(BOOL)configureMetadata
{  
    
    [self loadModuleList];
    if (![self loadMetadata]) 
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CRMMetadata" ofType:@"plist"];  
        if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:@"SugarMetadata" ofType:@"plist"]])
        {  
            self.metadataDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];  
        }
        else
        {
            NSLog(@"Unable to generate Config file..Returning..");
        }
        return false;
    }
    
    for(NSString *module in [metadataDictionary allKeys])
    {
        if([[moduleList allKeys] containsObject:module])
        {   
            WebserviceMetadata *webserviceMetadata = [WebserviceMetadata objectFromDictionary:[[metadataDictionary objectForKey:module] objectForKey:@"WebserviceMetadata"]];
            DBMetadata *dbMetadata = [DBMetadata objectFromDictionary:[[metadataDictionary objectForKey:module] objectForKey:@"DbMetadata"]]; 
                DataObjectMetadata *objectMetadata = [DataObjectMetadata objectFromDictionary:[[metadataDictionary objectForKey:module] objectForKey:@"DataObjectMetadata"]]; 
            ListViewMetadata *listViewMetadata = [ListViewMetadata objectFromDictionary:[[metadataDictionary objectForKey:module] objectForKey:@"ListViewMetadata"]];
            DetailViewMetadata *detailViewMetadata = [DetailViewMetadata objectFromDictionary:[[metadataDictionary objectForKey:module] objectForKey:@"DetailViewMetadata"]];
            [self setWebMetaData:webserviceMetadata forKey:[NSString stringWithFormat:@"list-%@",module]];
            [self setObjectMetaData:objectMetadata forKey:module];
            [self setDBMetaData:dbMetadata forKey:module];
            [self setViewMetaData:listViewMetadata forKey:[NSString stringWithFormat:@"list-%@",module]];
            [self setViewMetaData:detailViewMetadata forKey:[NSString stringWithFormat:@"detail-%@",module]];
        }
    }
    return true;
}



#pragma mark- private methods


-(BOOL)loadMetadata
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CRMMetadata" ofType:@"plist"];  
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:@"CRMMetadata" ofType:@"plist"]])
    {  NSLog(@"Config file found, loading metadata!");
        self.metadataDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSLog(@"metadata: %@",metadataDictionary);
        return YES;
    }
    else
    {
        NSLog(@"Config file not found, generating again.");
        [self generateConfiguration];
        return NO;
    }
}

-(void)loadModuleList 
{
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
    NSMutableDictionary *moduleKeyValuePairs=[[NSMutableDictionary alloc] init];
    id moduleResponse=[adata objectFromJSONData];
    for(NSDictionary* module in [moduleResponse objectForKey:@"modules"] ){
        [moduleKeyValuePairs setObject:[module objectForKey:@"module_label"] forKey:[module objectForKey:@"module_key"]];
    }
    NSLog(@"modules in plist %@",moduleKeyValuePairs);
    
    self.moduleList = moduleKeyValuePairs;
}



-(NSDictionary*)generateConfiguration 
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
        moduleKeyValuePairs=[[NSMutableDictionary alloc] init];
        id moduleResponse=[adata objectFromJSONData];
        for(NSDictionary* module in [moduleResponse objectForKey:@"modules"] ){
            [moduleKeyValuePairs setObject:[module objectForKey:@"module_label"] forKey:[module objectForKey:@"module_key"]];
        }
        NSLog(@"modules in plist %@",moduleKeyValuePairs);
    } else {
        moduleKeyValuePairs=[[NSMutableDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"Modules"];
    }
    self.moduleList = moduleKeyValuePairs;
    return moduleKeyValuePairs;
}

-(void)configForModules{
    
    //request for config details for each module from server
    NSMutableDictionary* restDataDictionary = [[OrderedDictionary alloc]init];
    [restDataDictionary setObject:session forKey:@"session"];
    NSMutableDictionary* urlParams=[[OrderedDictionary alloc] init];
    [urlParams setValue:@"get_module_fields" forKey:@"method"];
    [urlParams setObject:@"JSON" forKey:@"input_type"];
    [urlParams setObject:@"JSON" forKey:@"response_type"];
    [urlParams setObject:restDataDictionary forKey:@"rest_data"];
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc]init];
    for(NSString *module in [moduleList allKeys] ){
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
     
            //WebserviceMetadata
            WebserviceMetadata *wsMap = [[WebserviceMetadata alloc] init];
            wsMap.pathToObjectsInResponse = @"entry_list";
            wsMap.endpoint = sugarEndpoint;
            //NSMutableDictionary *restDataDictionary=[[OrderedDictionary alloc] init];
            //[restDataDictionary setObject:session forKey:@"session"];
            //[restDataDictionary setObject:module forKey:@"module"];
          //  NSString* restDataString=[restDataDictionary JSONString];
            [wsMap setUrlParam:@"get_entry_list" forKey:@"method"];
            [wsMap setUrlParam:@"JSON" forKey:@"input_type"];
            [wsMap setUrlParam:@"JSON" forKey:@"response_type"];
          //  [wsMap setUrlParam:restDataString forKey:@"rest_data"];
            NSMutableDictionary *responseKeyPathMap = [[NSMutableDictionary alloc] init];
            for(DataObjectField *field in [daoMetadata.fields allObjects]){
                [responseKeyPathMap setObject:[NSString stringWithFormat:@"name_value_list.%@.value",field.name] forKey:field.name];
            }
            wsMap.responseKeyPathMap = responseKeyPathMap;
            wsMap.moduleName = module;
       
            //DbMetadata 
            DBMetadata* dbMetadata = [[DBMetadata alloc] init];
            dbMetadata.tableName = module;
            NSMutableSet *fieldsName=[[NSMutableSet alloc] init];
            NSMutableDictionary *col_fieldMap = [[NSMutableDictionary alloc] init];
            for(DataObjectField *field in [daoMetadata.fields allObjects]){
                [col_fieldMap setObject:field.name forKey:field.name];
                [fieldsName addObject:[col_fieldMap objectForKey:field.name]];
            }
            dbMetadata.columnNames = fieldsName;
            dbMetadata.column_objectFieldMap = col_fieldMap;
            
            //ListViewMetadata
            ListViewMetadata *lViewMetadata = [[ListViewMetadata alloc] init];
            DataObjectField *primaryField = [[DataObjectField alloc] init];
            primaryField.name = @"name";
            primaryField.label = @"Name";
            lViewMetadata.primaryDisplayField = primaryField; 
            DataObjectField *otherField = [[DataObjectField alloc] init];
            otherField.name = @"id";
            otherField.label = @"id";
            lViewMetadata.otherFields = [NSArray arrayWithObject:otherField];
            lViewMetadata.iconImageName = nil;
            lViewMetadata.moduleName = module;
            
            //DetailviewMetadata
            DetailViewMetadata *detailViewMetadata = [[DetailViewMetadata alloc] init];
            NSMutableArray *sections  = [NSMutableArray array];
            NSMutableDictionary *sectionItem = [NSMutableDictionary dictionary];
            [sectionItem setObject:@"Basic Info" forKey:@"section_name"];
            NSMutableArray *rows = [NSMutableArray array];
            [rows addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSArray arrayWithObjects:[DataObjectField fieldWithName:@"name" dataType:0 andAction:@""], nil],@"Name",nil] forKeys:[NSArray arrayWithObjects:@"fields",@"label",nil]]];
            [rows addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSArray arrayWithObjects:[DataObjectField fieldWithName:@"mobile_office" dataType:0 andAction:@"number"], [DataObjectField fieldWithName:@"phone_alternate" dataType:0 andAction:@"number"], nil],@"Phone",nil] forKeys:[NSArray arrayWithObjects:@"fields",@"label",nil]]];
            [sectionItem setObject:rows forKey:@"rows"];
            [sections addObject:sectionItem];
            
            sectionItem = [NSMutableDictionary dictionary];
            [sectionItem setObject:@"Additional Info" forKey:@"section_name"];
            rows = [NSMutableArray array]; 
            [rows addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSArray arrayWithObjects:[DataObjectField fieldWithName:@"billing_address_street" dataType:0 andAction:@""],[DataObjectField fieldWithName:@"billing_address_street_2" dataType:0 andAction:@""],[DataObjectField fieldWithName:@"billing_address_street_3" dataType:0 andAction:@""],[DataObjectField fieldWithName:@"billing_address_street_4" dataType:0 andAction:@""],[DataObjectField fieldWithName:@"billing_address_city" dataType:0 andAction:@""],[DataObjectField fieldWithName:@"billing_address_state" dataType:0 andAction:@""],[DataObjectField fieldWithName:@"billing_address_postalcode" dataType:0 andAction:@""],[DataObjectField fieldWithName:@"billing_address_country" dataType:0 andAction:@""], nil],@"Billing Address",nil] forKeys:[NSArray arrayWithObjects:@"fields",@"label",nil]]];
            [rows addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSArray arrayWithObjects:[DataObjectField fieldWithName:@"email" dataType:0 andAction:@"email"], nil],@"Email",nil] forKeys:[NSArray arrayWithObjects:@"fields",@"label",nil]]];
            [rows addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSArray arrayWithObjects:[DataObjectField fieldWithName:@"date_entered" dataType:0 andAction:@"date"], nil],@"Date Created",nil] forKeys:[NSArray arrayWithObjects:@"fields",@"label",nil]]];
            [sectionItem setObject:rows forKey:@"rows"];
            [sections addObject:sectionItem];
            
            detailViewMetadata.sections = sections;
            detailViewMetadata.moduleName = module;
            
            NSMutableDictionary *moduleMetadataDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[daoMetadata toDictionary],@"DataObjectMetadata",[wsMap toDictionary],@"WebserviceMetadata",[dbMetadata toDictionary],@"DbMetadata",[lViewMetadata toDictionary],@"ListViewMetadata",[detailViewMetadata toDictionary],@"DetailViewMetadata",nil];
            
            [metadata setObject:moduleMetadataDictionary forKey:module];
        }
    }
    [self saveConfig:metadata];
}

#pragma mark Utility methods

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

@end
