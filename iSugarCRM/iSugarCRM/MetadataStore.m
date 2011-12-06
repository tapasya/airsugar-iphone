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
    keyedMetadata = [[NSDictionary alloc] init];
    keyedDbMetadata = [[NSDictionary alloc] init];
    return self;
    
}
-(id)metaDataForKey:(NSString*)key
{
    return [[keyedMetadata objectForKey:key] copy];
}

-(void)setMetaData:(id)metadata forKey:(NSString*)key
{
    NSMutableDictionary *copyOfKeyedMetadata = [keyedMetadata mutableCopy];
    [copyOfKeyedMetadata setObject:metadata forKey:key];
    keyedMetadata = copyOfKeyedMetadata;
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

@end
