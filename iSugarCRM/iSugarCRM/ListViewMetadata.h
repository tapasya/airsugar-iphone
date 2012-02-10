//
//  ListViewMetadata.h
//  iSugarCRM
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataObjectMetadata.h"
#import "DataObjectField.h"
@interface ListViewMetadata : NSObject
@property(strong)NSString *moduleName;
@property(strong)DataObjectField *primaryDisplayField;
@property(strong)NSArray *otherFields;
@property(strong)NSString *iconImageName;
-(NSDictionary*)toDictionary;
+(ListViewMetadata*)objectFromDictionary:(NSDictionary*)dictionary;
@end
