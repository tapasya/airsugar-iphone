//
//  WebserviceMetadata.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebserviceMetadata.h"
#import "OrderedDictionary.h"
#import "JSONKit.h"
#import "SettingsStore.h"
#import "DateUtils.h"

# define kMaxRecords        @"1000"

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
@interface WebserviceMetadata ()
-(NSURLRequest*)formatRequest;
@end

@implementation WebserviceMetadata
@synthesize urlParameters,postParameters,headers,endpoint,method,moduleName,pathToRelationshipInResponse;
@synthesize pathToObjectsInResponse,responseKeyPathMap,data_key;
@synthesize offset;
@synthesize timeStamp = _timeStamp;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize downlaodObjects;

-(id)init{
    
    if (self=[super init]) {
        headers=[[OrderedDictionary alloc]init];
        urlParameters=[[NSMutableArray alloc]init];
        postParameters=[[OrderedDictionary alloc]init];
        offset = 0;
    }
    return  self;
}

-(void)setHeader:(NSString*)headerVal forKey:(NSString*)key
{
    NSMutableDictionary *headerCopy =  [headers mutableCopy];
    [headerCopy setValue:headerVal forKey:key];
    headers = headerCopy;
}

-(void)setPostParam:(NSString*)postParam forKey:(NSString*)key
{
    NSMutableDictionary *postParamsCopy =  [postParameters mutableCopy];
    [postParamsCopy setValue:postParam forKey:key];
    postParameters = postParamsCopy;
}

-(void)setUrlParam:(NSString*)urlParam forKey:(NSString*)key{
    //OrderedDictionary *urlParamsCopy =  [urlParameters mutableCopy];
    //[urlParamsCopy setValue:urlParam forKey:key];
    //urlParameters = urlParamsCopy;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:urlParam forKey:key];
    self.urlParameters = [self.urlParameters mutableCopy];
    [urlParameters addObject:dictionary];
}

- (void) addSelectFieldsAndLinkFields:(NSMutableDictionary*) dict
{
    [dict  setObject:[NSArray array] forKey:@"select_fields"];
    NSMutableArray *relationshipList = [NSMutableArray array];
    NSArray *moduleList = [[SugarCRMMetadataStore sharedInstance] modulesSupported];
    for(NSString *module in moduleList){
        [relationshipList addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:@"id"],@"value",[module lowercaseString],@"name",nil]];
    }
    
    [dict  setObject:relationshipList forKey:@"link_name_to_fields_array"];
}

- (void) addTimeQuery:(NSMutableDictionary*) dict
{
    // if time stamp is available query for modified records after timestamp
    if ( nil != self.timeStamp) {
        [dict  setObject:[NSString stringWithFormat:@"%@.date_modified>'%@'",[moduleName lowercaseString],self.timeStamp ? self.timeStamp : @""]  forKey:@"query"];
        
    } else if ( nil != self.startDate && nil != self.endDate){
        [dict  setObject:[NSString stringWithFormat:@"%@.date_modified>'%@' AND %@.date_modified<'%@'",[moduleName lowercaseString],self.startDate, [moduleName lowercaseString], self.endDate] forKey:@"query"];
    } else {
        [dict setObject:@"" forKey:@"query"];
    }

}

-(NSURLRequest*) constructRequest
{
    //append url parameters
    NSMutableDictionary *restDataDictionary = [[OrderedDictionary alloc] init];
    [restDataDictionary setObject:session forKey:@"session"];
    [restDataDictionary  setObject:moduleName forKey:@"module_name"];
    
    if (self.downlaodObjects && self.downlaodObjects.count > 0) {
        
        [restDataDictionary setObject:self.downlaodObjects forKey:@"ids"];
        
        for (int i = 0; i < [self.downlaodObjects count] ; i ++) {
            if (i == [self.downlaodObjects count]-1) {
                [restDataDictionary  setObject:[NSString stringWithFormat:@"%@.id='%@' ",[moduleName lowercaseString],[self.downlaodObjects objectAtIndex:i]] forKey:@"query"];
            }else{
                [restDataDictionary  setObject:[NSString stringWithFormat:@"%@.id='%@' OR ",[moduleName lowercaseString],[self.downlaodObjects objectAtIndex:i]] forKey:@"query"];
            }
        }
    } else{
    
        [self addTimeQuery:restDataDictionary];
    }
    
    // Order by Modified date
    [restDataDictionary  setObject:@"date_modified ASC" forKey:@"order_by"];
    
    if ( self.offset != -1) {
        [restDataDictionary  setObject:[NSString stringWithFormat:@"%d", self.offset] forKey:@"offset"];
    } else{
        [restDataDictionary  setObject:@"" forKey:@"offset"];
    }
    
    [self addSelectFieldsAndLinkFields:restDataDictionary];
    
    [restDataDictionary setObject:kMaxRecords forKey:@"max_results"];
    
    [self setUrlParam:[restDataDictionary JSONString] forKey:@"rest_data"];
    
    return [self formatRequest];

}

-(NSURLRequest*) constructWriteRequestWithData:(NSArray*)data
{
    //append url parameters
    NSMutableDictionary *restDataDictionary = [[OrderedDictionary alloc] init];
    [restDataDictionary setObject:session forKey:@"session"];
    [restDataDictionary  setObject:moduleName forKey:@"module_name"];
    if (data && data_key) {
    [restDataDictionary  setObject:data forKey:data_key];
    }
    NSString *restDataString = [restDataDictionary JSONString];
    [self setUrlParam:restDataString forKey:@"rest_data"];
    return [self formatRequest];
}

-(NSURLRequest*)formatRequest
{
    NSMutableString *urlWithParams = [[NSMutableString alloc] init];
    [urlWithParams appendString:[SettingsStore objectForKey:@"endpointURL"]];
    //[urlWithParams appendString:endpoint];
    int index = 0;
    if(method == HTTPMethodGet){
        for(NSDictionary *urlParam in urlParameters)
        {
            NSString *key = [[urlParam allKeys] objectAtIndex:0];
            if(index++ == 0)
            {
                [urlWithParams appendString:[NSString stringWithFormat:@"?%@=%@",key,[urlParam valueForKey:key]]];
            }
            else
            {
                [urlWithParams appendString:[NSString stringWithFormat:@"&%@=%@",key,[urlParam valueForKey:key]]];
            }
        }
    }
    NSLog(@"url string: %@",urlWithParams);
    //set url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlWithParams stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    
    //set http method
    [request setHTTPMethod:httpMethodAsString(method)];
    
    //set http body if request is a post
    if(method == HTTPMethodPOST){
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
        
        NSMutableString * postData = [[NSMutableString alloc] init ];
        for (NSDictionary *param in urlParameters) {
            NSString *key = [[param allKeys] objectAtIndex:0];
            [postData appendString:[NSString stringWithFormat:@"%@=%@&",key,[param valueForKey:key]]];
        }
        
        if(postData.length > 0){
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
    copy.method=method;
    copy.moduleName=moduleName;
    copy.data_key = data_key;
    copy.pathToRelationshipInResponse = pathToRelationshipInResponse;
    return copy;
}

-(NSDictionary*)toDictionary
{       
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:endpoint forKey:@"endpoint"];
    [dictionary setObject:urlParameters forKey:@"urlParameters"];
    [dictionary setObject:pathToObjectsInResponse forKey:@"pathToObjectsInResponse"];
    [dictionary setObject:[NSNumber numberWithInt:method] forKey:@"method"];
    [dictionary setObject:moduleName forKey:@"module_name"];
    [dictionary setObject:data_key forKey:@"data_key"];
    [dictionary setObject:responseKeyPathMap forKey:@"responseKeyPathMap"];
    [dictionary setObject:pathToRelationshipInResponse forKey:@"pathToRelationshipInResponse"];
    if (postParameters) {
        [dictionary setObject:postParameters forKey:@"postParameters"];
    }
    if (headers) {
        [dictionary setObject:headers forKey:@"headers"];
    }
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
    metadata.moduleName = [dictionary objectForKey:@"module_name"];
    metadata.data_key = [dictionary objectForKey:@"data_key"];
    metadata.pathToRelationshipInResponse = [dictionary objectForKey:@"pathToRelationshipInResponse"];
    return metadata;
}

@end
