//
//  DBMetadata.m
//  iSugarCRM
//
//  Created by Ved Surtani on 30/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DBMetadata.h"

@implementation DBMetadata
@synthesize tableName,columnNames,column_objectFieldMap,objectMetadata;


- (id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] allocWithZone:zone] init];
    [copy setTableName:[self tableName]];
    [copy setColumnNames:[self columnNames]];
    [copy setColumn_objectFieldMap:[self column_objectFieldMap]];
    [copy setObjectMetadata:[self objectMetadata]];
   
    
    return copy;
}

@end
