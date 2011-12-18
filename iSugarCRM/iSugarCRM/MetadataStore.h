//
//  WebserviceMetadataStore.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetadataStore : NSObject
{
    @private
    NSDictionary *keyedWebMetadata;
    NSDictionary *keyedDbMetadata;
    NSDictionary *keyedViewMetadata;
}


-(id)webMetaDataForKey:(NSString*)key;
-(void)setWebMetaData:(id)metadata forKey:(NSString*)key;
-(id)dbMetaDataForKey:(NSString*)key;
-(void)setDBMetaData:(id)metadata forKey:(NSString*)key;
-(id)viewMetaDataForKey:(NSString*)key;
-(void)setViewMetaData:(id)metadata forKey:(NSString*)key;
@end
