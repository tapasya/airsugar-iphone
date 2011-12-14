//
//  SugarCRMMetadataStore.h
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetadataStore.h"
#import "WebserviceMetadata.h"
#import "DBMetadata.h"
#import "ListViewMetadata.h"

@interface SugarCRMMetadataStore : MetadataStore
@property(strong)  NSDictionary * moduleList;

+(SugarCRMMetadataStore*)sharedInstance;
-(void)configureMetadata;
-(WebserviceMetadata*)listServiceMetadataForModule:(NSString*)moduleId;
-(WebserviceMetadata*)detailServiceMetadataForModule:(NSString*)moduleId;
-(DBMetadata*)dbMetadataForModule:(NSString*)moduleId;
-(ListViewMetadata*)listViewMetadataForModule:(NSString*)moduleName;
@end
