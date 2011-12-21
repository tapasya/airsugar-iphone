//
//  WebserviceMetadataStore.m
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MetadataStore.h"

@implementation MetadataStore


-(id)init
{
    self = [super init];
    keyedWebMetadata = [[NSDictionary alloc] init];
    keyedDbMetadata = [[NSDictionary alloc] init];
    keyedViewMetadata = [[NSDictionary alloc] init];
    return self;
    
}
-(id)webMetaDataForKey:(NSString*)key
{
    return [[keyedWebMetadata objectForKey:key] copy];
}

-(void)setWebMetaData:(id)metadata forKey:(NSString*)key
{
    NSMutableDictionary *copyOfKeyedMetadata = [keyedWebMetadata mutableCopy];
    [copyOfKeyedMetadata setObject:metadata forKey:key];
    keyedWebMetadata = copyOfKeyedMetadata;
}
-(id)dbMetaDataForKey:(NSString*)key
{
    return [[keyedDbMetadata objectForKey:key] copy];
}

-(void)setDBMetaData:(id)metadata forKey:(NSString*)key
{
    NSMutableDictionary *copyOfKeyedDBMetadata = [keyedDbMetadata mutableCopy];
    [copyOfKeyedDBMetadata setObject:metadata forKey:key];
    keyedDbMetadata = copyOfKeyedDBMetadata;
}

-(void)setViewMetaData:(id)metadata forKey:(NSString*)key
{
    NSMutableDictionary *copyOfKeyedViewMetadata = [keyedViewMetadata mutableCopy];
    [copyOfKeyedViewMetadata setObject:metadata forKey:key];
    keyedViewMetadata = copyOfKeyedViewMetadata;
}

-(id)viewMetaDataForKey:(NSString*)key
{
   return [[keyedViewMetadata objectForKey:key] copy];
}

@end