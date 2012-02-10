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
#import "DetailViewMetadata.h"
#import "DataObjectMetadata.h"
@interface SugarCRMMetadataStore : MetadataStore

+(SugarCRMMetadataStore*)sharedInstance;

-(BOOL)configureMetadata;
-(NSArray*)modulesSupported;
-(DataObjectMetadata*)objectMetadataForModule:(NSString*)moduleId;
-(WebserviceMetadata*)listWebserviceMetadataForModule:(NSString*)moduleId;
-(WebserviceMetadata*)detailWebserviceMetadataForModule:(NSString*)moduleId;
-(DBMetadata*)dbMetadataForModule:(NSString*)moduleId;
-(ListViewMetadata*)listViewMetadataForModule:(NSString*)moduleName;
-(DetailViewMetadata*)detailViewMetadataForModule:(NSString*)moduleName;
@end
