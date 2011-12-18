//
//  WebserviceMetadata.h
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataObjectMetadata.h"
#import "OrderedDictionary.h"
typedef enum HTTPMethod{
    HTTPMethodGet,
    HTTPMethodPOST
}HTTPMethod;


@interface WebserviceMetadata : NSObject
@property(strong)NSString *moduleName;
@property(strong)DataObjectMetadata *objectMetadata;
@property(nonatomic)HTTPMethod method;
@property(strong)NSString *endpoint;
@property(strong)OrderedDictionary *urlParameters;
@property(strong)NSDictionary *postParameters;
@property(strong)NSDictionary *headers;
@property(strong)NSString *pathToObjectsInResponse;
@property(strong)NSDictionary *responseKeyPathMap;

-(void)setHeader:(NSString*)headerVal forKey:(NSString*)key;
-(void)setPostParam:(NSString*)postParam forKey:(NSString*)key;
-(void)setUrlParam:(NSString*)urlParam forKey:(NSString*)key;
-(NSDictionary*)toDictionary;
+(WebserviceMetadata*)objectFromDictionary:(NSDictionary*)dictionary;
-(NSURLRequest*)getRequest;

@end
