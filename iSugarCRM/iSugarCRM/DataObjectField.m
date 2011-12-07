//
//  ObjectField.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataObjectField.h"
static inline NSString* toString(BOOL b){
    return b?@"1":@"0";
}
static inline BOOL boolValue(NSString *s){
    return (s == @"1")?YES:NO;
}

@implementation DataObjectField
@synthesize name,dataType;
@synthesize sortable,filterable,editable;
@synthesize label;
+(DataObjectField*)fieldWithName:(NSString*)name dataType:(ObjectFieldDataType)type
{
    DataObjectField *field = [[DataObjectField alloc] init];
    field.name = name;
    field.dataType = type;
    return field;
}


-(NSUInteger)hash
{
    return [name hash] + dataType;
}

-(BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if ([object isKindOfClass:[DataObjectField class]]) {
        DataObjectField *field = (DataObjectField*)object;
        if(field.name == name && field.dataType == dataType)
            return YES;
    }
    return NO;
}


-(NSDictionary*)toDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:name   forKey:@"name"];
    [dictionary setValue:label forKey:@"label"];
    [dictionary setValue:toString(sortable) forKey:@"sortable"];
    return dictionary;
}
+(DataObjectField*)objectFromDictionary:(NSDictionary*)dictionary
{
    DataObjectField *daoField = [[DataObjectField alloc]init];
    daoField.name = [dictionary valueForKey:@"name"];
    daoField.sortable = boolValue([dictionary valueForKey:@"sortable"]);
    return daoField;
}
- (id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] allocWithZone:zone] init];
    [copy setName:[self name]];
    [copy setDataType:[self dataType]];
    return copy;
}
@end
