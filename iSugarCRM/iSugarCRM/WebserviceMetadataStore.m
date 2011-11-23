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
+(WebserviceMetadataStore*)storeForModule:(NSString*)moduleId
{
        //for testing create a store for account module
    WebserviceMetadataStore *metadataStore = [[WebserviceMetadataStore alloc] init];
    
    metadataStore.moduleName = @"Accounts";
    return metadataStore;
}

-(NSURLRequest*)listRequest{
    
}
-(NSURLRequest*)detailRequest:(NSString*)beanId{
    
}

/*!
 @brief     returns a map  object keys and corresponding keyPath in list response dictionary
 */
-(NSDictionary*)listResponseKeyPaths{
    
}

/*!
 @brief     returns a map  object keys and corresponding keyPath in detail response dictionary
 */
-(NSDictionary*)detailResponseKeyPaths{
    
}
@end
