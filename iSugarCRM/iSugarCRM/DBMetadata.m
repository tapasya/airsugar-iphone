//
//  DBMetadata.m
//  iSugarCRM
//
//  Created by Ved Surtani on 30/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DBMetadata.h"

@implementation DBMetadata
@synthesize tableName,columnNames,column_objectFieldMap;


- (id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] allocWithZone:zone] init];
    [copy setTableName:[self tableName]];
    [copy setColumnNames:[self columnNames]];
    [copy setColumn_objectFieldMap:[self column_objectFieldMap]];
    return copy;
}
-(NSDictionary*)toDictionary
{       
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *arrayOfColumnNames = [[NSMutableArray alloc] init];
    for(NSString *columnName in [columnNames allObjects])
    {
        [arrayOfColumnNames addObject:columnName];
    
    }
    [dictionary setObject:arrayOfColumnNames forKey:@"columnNames"];
    [dictionary setObject:column_objectFieldMap forKey:@"column_objectFieldMap"];
    [dictionary setObject:tableName forKey:@"tableName"];
    return dictionary;
}

+(DBMetadata*)objectFromDictionary:(NSDictionary*)dictionary
{
    DBMetadata *metadata = [[DBMetadata alloc] init];
    metadata.tableName = [dictionary objectForKey:@"tableName"];
    metadata.columnNames = [dictionary objectForKey:@"columnNames"];
    metadata.column_objectFieldMap = [dictionary objectForKey:@"column_objectFieldMap"];
    return metadata;
}

-(id)copy
{
    DBMetadata *copy = [[DBMetadata alloc] init];
    copy.tableName = tableName;
    copy.column_objectFieldMap = column_objectFieldMap;
    copy.columnNames = columnNames;
    return copy;
}

@end
