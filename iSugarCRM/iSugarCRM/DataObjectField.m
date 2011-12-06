//
//  ObjectField.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataObjectField.h"

@implementation DataObjectField
@synthesize name,dataType;
@synthesize sortable,filterable,editable;

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
- (id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] allocWithZone:zone] init];
    [copy setName:[self name]];
    [copy setDataType:[self dataType]];
    return copy;
}
@end
