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
    return [s isEqualToString:@"1"];
}

@implementation DataObjectField
@synthesize name,dataType;
@synthesize sortable,filterable;
@synthesize label,action;
@synthesize mandatory;
@synthesize editable;
@synthesize predefinedValues;
+(DataObjectField*)fieldWithName:(NSString*)name dataType:(ObjectFieldDataType)type andAction:(NSString*)action
{
    DataObjectField *field = [[DataObjectField alloc] init];
    field.name = name;
    field.action = action;
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
    [dictionary setValue:action forKey:@"action"];
    [dictionary setValue:toString(sortable) forKey:@"sortable"];
    [dictionary setValue:predefinedValues forKey:@"predefinedValues"];
    return dictionary;
}
+(DataObjectField*)objectFromDictionary:(NSDictionary*)dictionary
{
    DataObjectField *daoField = [[DataObjectField alloc]init];
    daoField.name = [dictionary valueForKey:@"name"];
    daoField.label = [dictionary valueForKey:@"label"];
    daoField.sortable =[[dictionary valueForKey:@"sortable"] boolValue];
    daoField.editable =[[dictionary valueForKey:@"editable"] boolValue];
    daoField.mandatory =[[dictionary valueForKey:@"mandatory"] boolValue];
    daoField.action = [dictionary valueForKey:@"action"];
    daoField.predefinedValues = [dictionary valueForKey:@"predefinedValues"];
    return daoField;
}
- (id)copyWithZone:(NSZone *)zone{
    DataObjectField *copy = [[[self class] allocWithZone:zone] init];
    [copy setName:[self name]];
    [copy setLabel:[self label]];
    copy.action = self.action;
    copy.editable = self.editable;
    copy.mandatory = self.mandatory;
    copy.predefinedValues = self.predefinedValues;
    [copy setDataType:[self dataType]];
    return copy;
}
@end
