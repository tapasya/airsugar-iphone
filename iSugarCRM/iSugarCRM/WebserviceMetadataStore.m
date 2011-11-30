//
//  WebserviceMetadataStore.m
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebserviceMetadataStore.h"

//Temprorary for testing skeleton
static NSString *sugarEndpoint = @"192.168.3.107:8888/sugarce6/service/v4/rest.php";
static NSString *session = @"addSomething";
@implementation WebserviceMetadataStore


-(id)init
{
    self = [super init];
    keyedMetadata = [[NSDictionary alloc] init];
    return self;
    
}
-(WebserviceMetadata*)metaDataForKey:(NSString*)key
{
    return [[keyedMetadata objectForKey:key] copy];
}

-(void)setMetaData:(WebserviceMetadata*)metadata ForKey:(NSString*)key
{
    NSMutableDictionary *copyOfKeyedMetadata = [keyedMetadata mutableCopy];
    [copyOfKeyedMetadata setObject:metadata forKey:key];
    keyedMetadata = copyOfKeyedMetadata;
}
@end
