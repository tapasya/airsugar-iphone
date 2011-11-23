//
//  WebserviceMetadataStore.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebserviceMetadataStore : NSObject
{
    
}
@property(strong)NSString *moduleName;

+(WebserviceMetadataStore*)storeForModule:(NSString*)moduleId;

-(NSURLRequest*)listRequest;
-(NSURLRequest*)detailRequest:(NSString*)beanId;

/*!
 @brief     returns a map  object keys and corresponding keyPath in list response dictionary
 */
-(NSDictionary*)listResponseKeyPaths;

/*!
 @brief     returns a map  object keys and corresponding keyPath in detail response dictionary
 */
-(NSDictionary*)detailResponseKeyPaths;
@end
