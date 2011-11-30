//
//  WebserviceMetadata.h
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum HTTPMethod{
    HTTPMethodGet,
    HTTPMethodPOST
}HTTPMethod;


@interface WebserviceMetadata : NSObject
@property(nonatomic)HTTPMethod method;
@property(strong)NSString *endpoint;
@property(strong)NSDictionary *urlParameters;
@property(strong)NSDictionary *postParameters;
@property(strong)NSDictionary *headers;
@property(strong)NSDictionary *responseKeyPaths;
-(void)setHeader:(NSString*)headerVal forKey:(NSString*)key;
-(void)setPostParam:(NSString*)postParam forKey:(NSString*)key;
-(void)setUrlParam:(NSString*)urlParam forKey:(NSString*)key;

@end
