//
//  SugarCRMMetadataStore.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SugarCRMMetadataStore.h"
#import "DataObjectField.h"
#import "OrderedDictionary.h"
#import "JSONKit.h"
static SugarCRMMetadataStore *sharedInstance = nil;

@interface SugarCRMMetadataStore (Private)
-(id)initPrivate;
-(NSArray*)fieldsForModule:(NSString*)moduleName;
-(NSString*)webserviceResponseKeyPathForFieldName:(NSString*)name moduleName:(NSString*)moduleName;
-(void)initializeMetadataForModuleName:(NSString*)moduleName;
@end

@implementation SugarCRMMetadataStore

+(SugarCRMMetadataStore*)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[SugarCRMMetadataStore alloc] initPrivate];

        NSMutableDictionary *modules;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL success;
        NSString *rootPath= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSString* plistPath;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            plistPath = [rootPath stringByAppendingPathComponent:@"SugarModulesMetadata.plist"]; 
        } 
        success = [fileManager fileExistsAtPath:plistPath];
        //check if plist already exist
        if(success)
        {
            NSMutableDictionary *plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
            if (plistDictionary) {
                modules= [plistDictionary objectForKey:@"Modules"];
            } else {
                NSLog(@"Cannot read config file");
            }
        } else {
            NSLog(@"Config file doesnt exist");
        }
        
        for(NSString *module in modules){
            [sharedInstance initializeMetadataForModuleName:module];
        }
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


-(WebserviceMetadata*)listServiceMetadataForModule:(NSString*)moduleId{
    return [self metaDataForKey:[NSString stringWithFormat:@"list-%@",moduleId]];
    
}
-(WebserviceMetadata*)detailServiceMetadataForModule:(NSString*)moduleId{
    return [self metaDataForKey:[NSString stringWithFormat:@"detail-%@",moduleId]];
}




#pragma mark- private methods
-(void)initializeMetadataForModuleName:(NSString*)moduleName
{
    WebserviceMetadata *listServiceMetadata = [[WebserviceMetadata alloc] init];
    listServiceMetadata.endpoint = sugarEndpoint;
    
    NSMutableDictionary *restDataDictionary=[[OrderedDictionary alloc] init];
    [restDataDictionary setObject:session forKey:@"session"];
    [restDataDictionary setObject:moduleName forKey:@"module"];
    NSString* restDataString=[restDataDictionary JSONString];
    
    [listServiceMetadata setUrlParam:@"get_entry_list" forKey:@"method"];
    [listServiceMetadata setUrlParam:@"JSON" forKey:@"input_type"];
    [listServiceMetadata setUrlParam:@"JSON" forKey:@"response_type"];
    [listServiceMetadata setUrlParam:restDataString forKey:@"rest_data"];
    
    NSMutableDictionary *responseKeyPaths = [[NSMutableDictionary alloc] init];
    
    for(DataObjectField *field in [self fieldsForModule:moduleName])
    {
        [responseKeyPaths setObject:[self webserviceResponseKeyPathForFieldName:field.name moduleName:moduleName] forKey:field];
    }
    listServiceMetadata.responseKeyPaths=responseKeyPaths;
    
    [self setMetaData:listServiceMetadata forKey:[NSString stringWithFormat:@"list-%@",moduleName]];
    
    
    ///save webservicemetadata in plist????
}

-(NSArray*)fieldsForModule:(NSString *)moduleName
{  
    NSMutableDictionary *plistDictionary, *moduleFields;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success;
    NSString *rootPath= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString* plistPath;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil]) {
        plistPath = [rootPath stringByAppendingPathComponent:@"SugarModulesMetadata.plist"]; 
    } 
    success = [fileManager fileExistsAtPath:plistPath];
    //check if plist already exist
    if(success)
    {
        plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        if (plistDictionary) {
            moduleFields= [[plistDictionary objectForKey:@"ModuleFields"] objectForKey:moduleName];
        }
        else {
            NSLog(@"Cannot Read plist to generate metadata for module %@",moduleName);
            return nil;
        }
        NSMutableArray* dataObjectFieldArray=[[NSMutableArray alloc] init];
        
        for (NSString* field in moduleFields) {
            DataObjectField* dof=[[DataObjectField alloc] init];
            dof.name=field;
            dof.dataType=ObjectFieldDataTypeString;
            dof.sortable=NO;
            dof.filterable=NO;
            dof.editable=NO;
            [dataObjectFieldArray addObject:dof];
        }
        return dataObjectFieldArray;// should be saved?
        
    } else {
        NSLog(@"no plist found");
    }
    return nil;
}

-(NSString*)webserviceResponseKeyPathForFieldName:(NSString*)name moduleName:(NSString*)moduleName
{
    return [NSString stringWithFormat:@"module_fields.%@",name];
}
@end
