//
//  DBMetadata.h
//  iSugarCRM
//
//  Created by Ved Surtani on 30/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataObjectMetadata.h"
@interface DBMetadata : NSObject
@property(strong)NSString *tableName;
@property(strong)NSSet  *columnNames; //everything is a varchar for the timebeing
@property(strong)NSDictionary *column_objectFieldMap; //objectField_columnName map also required

-(NSDictionary*)toDictionary;
+(DBMetadata*)objectFromDictionary:(NSDictionary*)dictionary;
@end
