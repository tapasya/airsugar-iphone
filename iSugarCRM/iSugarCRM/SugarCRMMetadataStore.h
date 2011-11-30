//
//  SugarCRMMetadataStore.h
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetadataStore.h"
@interface SugarCRMMetadataStore : MetadataStore


+(SugarCRMMetadataStore*)sharedInstance;
-(WebserviceMetadata*)listServiceMetadataForModule:(NSString*)moduleId;
-(WebserviceMetadata*)detailServiceMetadataForModule:(NSString*)moduleId;
@end
