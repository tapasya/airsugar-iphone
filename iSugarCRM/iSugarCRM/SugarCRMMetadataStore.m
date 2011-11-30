//
//  SugarCRMMetadataStore.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SugarCRMMetadataStore.h"
#import "DataObjectField.h"
static SugarCRMMetadataStore *sharedInstance = nil;

@interface SugarCRMMetadataStore (Private)
-(id)initPrivate;
-(NSArray*)fieldsForAccounts;
-(NSString*)webserviceResponseKeyPathForFieldName:(NSString*)name moduleName:(NSString*)moduleName;
@end

@implementation SugarCRMMetadataStore

+(SugarCRMMetadataStore*)sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[SugarCRMMetadataStore alloc] initPrivate];
        
        //initialize
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
    listServiceMetadata.endpoint = @"http://shit";
    [listServiceMetadata setUrlParam:@"session" forKey:@"session"];
    NSMutableDictionary *responseKeyPaths = [[NSMutableDictionary   alloc] init];

    for(DataObjectField *field in [self fieldsForAccounts])
    {
        [responseKeyPaths setObject:[self webserviceResponseKeyPathForFieldName:field.name moduleName:moduleName] forKey:field];
    }
    
    
    [self setMetaData:listServiceMetadata ForKey:@"list-moduleid"];
}

-(NSArray*)fieldsForAccounts
{
    return nil;
}

-(NSString*)webserviceResponseKeyPathForFieldName:(NSString*)name moduleName:(NSString*)moduleName
{
    return nil;
}
@end
