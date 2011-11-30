//
//  WebserviceMetadataStore.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceMetadata.h"

@interface MetadataStore : NSObject
{
    @private
    NSDictionary *keyedMetadata;
}


-(id)metaDataForKey:(NSString*)key;
-(void)setMetaData:(id)metadata ForKey:(NSString*)key;

@end
