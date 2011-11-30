//
//  WebserviceMetadataStore.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceMetadata.h"

@interface WebserviceMetadataStore : NSObject
{
    @private
    NSDictionary *keyedMetadata;
}


-(WebserviceMetadata*)metaDataForKey:(NSString*)key;
-(void)setMetaData:(WebserviceMetadata*)metadata ForKey:(NSString*)key;

@end
