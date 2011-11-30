//
//  WebserviceMetadata.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebserviceMetadata.h"
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
@synthesize urlParameters,postParameters,headers,endpoint,method;
@synthesize responseKeyPaths;

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
    
    //set url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlWithParams]];
    
    //set http method
    [request setHTTPMethod:httpMethodAsString(method)];
    
    //set http body if request is a post
    if(method == HTTPMethodPOST){
        NSMutableString *postData = [[NSMutableString alloc] init];
        index = 0;
        for(NSString *key in [postParameters allKeys])
        {
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
    return copy;
}

@end
