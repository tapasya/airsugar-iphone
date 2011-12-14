//
//  WebserviceMetadata.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebserviceMetadata.h"
#import "OrderedDictionary.h"
static inline NSString* httpMethodAsString(HTTPMethod method){
    switch (method) {
        case HTTPMethodGet:
            return @"GET";
            break;
        case HTTPMethodPOST:
            return @"POST";
        default:
            return @"GET";
            break;
    }
};

@implementation WebserviceMetadata
@synthesize urlParameters,postParameters,headers,endpoint,method,moduleName;
@synthesize pathToObjectsInResponse,responseKeyPathMap,objectMetadata;
-(id)init{
    if (self=[super init]) {
        headers=[[OrderedDictionary alloc]init];
        urlParameters=[[OrderedDictionary alloc]init];
        postParameters=[[OrderedDictionary alloc]init];
    }
    return  self;
}
-(void)setHeader:(NSString*)headerVal forKey:(NSString*)key
{
    NSMutableDictionary *headerCopy =  [headers mutableCopy];
    [headerCopy setValue:headerVal forKey:key];
    headers = headerCopy;
}

-(void)setPostParam:(NSString*)postParam forKey:(NSString*)key{
    NSMutableDictionary *postParamsCopy =  [postParameters mutableCopy];
    [postParamsCopy setValue:postParam forKey:key];
    postParameters = postParamsCopy;
}

-(void)setUrlParam:(NSString*)urlParam forKey:(NSString*)key{
    NSMutableDictionary *urlParamsCopy =  [urlParameters mutableCopy];
    [urlParamsCopy setValue:urlParam forKey:key];
    urlParameters = urlParamsCopy;
}

-(NSURLRequest*)getRequest
{
    //append url parameters
    NSMutableString *urlWithParams = [[NSMutableString alloc] init];
    [urlWithParams appendString:endpoint];
    int index = 0;
    for(NSString *key in [urlParameters allKeys])
    {
        if(index++ == 0)
        {
            [urlWithParams appendString:[NSString stringWithFormat:@"?%@=%@",key,[urlParameters valueForKey:key]]];
        }
        else
        {
            [urlWithParams appendString:[NSString stringWithFormat:@"&%@=%@",key,[urlParameters valueForKey:key]]];
        }
    }
    NSLog(@"url string: %@",urlWithParams);
    //set url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlWithParams stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    
    //set http method
    [request setHTTPMethod:httpMethodAsString(method)];
    
    //set http body if request is a post
    if(method == HTTPMethodPOST){
        NSMutableString *postData = [[NSMutableString alloc] init];
        index = 0;
        for(NSString *key in [postParameters allKeys]){  
                if(index++ == 0)
                {
                    [postData appendString:[NSString stringWithFormat:@"%@=%@",key,[postParameters valueForKey:key]]];
                }
                else
                {
                    [postData appendString:[NSString stringWithFormat:@"&%@=%@",key,[postParameters valueForKey:key]]];
                }
            }
        
        if (postData.length > 0) {
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    //set the headers
    for(NSString *headerKey in [headers allKeys])
    {
        [request setValue:headerKey forHTTPHeaderField:[headers valueForKey:headerKey]];
    }
    
    return request;
    
}

-(id)copy
{
    WebserviceMetadata *copy = [[WebserviceMetadata alloc] init];
    copy.endpoint = endpoint;
    copy.urlParameters = urlParameters;
    copy.headers = headers;
    copy.postParameters = postParameters;
    copy.pathToObjectsInResponse = pathToObjectsInResponse;
    copy.responseKeyPathMap=responseKeyPathMap;
    copy.objectMetadata=objectMetadata;
    copy.method=method;
    copy.moduleName=moduleName;
    return copy;
}

-(NSDictionary*)toDictionary
{       
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:endpoint forKey:@"endpoint"];
    [dictionary setObject:urlParameters forKey:@"urlParameters"];
    [dictionary setObject:headers forKey:@"headers"];
    [dictionary setObject:pathToObjectsInResponse forKey:@"pathToObjectsInResponse"];
    [dictionary setObject:[NSNumber numberWithInt:method] forKey:@"method"];
    [dictionary setObject:[objectMetadata toDictionary] forKey:@"objectMetadata"];

    return dictionary;
}

+(WebserviceMetadata*)objectFromDictionary:(NSDictionary*)dictionary
{
    WebserviceMetadata *metadata = [[WebserviceMetadata alloc] init];
    metadata.endpoint = [dictionary objectForKey:@"endpoint"];
    metadata.headers = [dictionary objectForKey:@"headers"];
    metadata.postParameters = [dictionary objectForKey:@"postParameters"];
     metadata.pathToObjectsInResponse = [dictionary objectForKey:@"pathToObjectsInResponse"];
     metadata.urlParameters = [dictionary objectForKey:@"urlParameters"];
     metadata.responseKeyPathMap = [dictionary objectForKey:@"responseKeyPathMap"];
     metadata.method = [[dictionary objectForKey:@"method"] intValue];
    metadata.objectMetadata = [DataObjectMetadata objectFromDictionary:[dictionary objectForKey:@"objectMetadata"]];
    metadata.moduleName = [dictionary objectForKey:@"module_name"];
    return metadata;
}

@end
