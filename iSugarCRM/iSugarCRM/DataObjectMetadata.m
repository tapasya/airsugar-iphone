//
//  ObjectMetadata.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataObjectMetadata.h"
#import "DataObjectField.h"
@implementation DataObjectMetadata
@synthesize fields,objectClassIdentifier;
-(BOOL)hasFieldWithName:(NSString*)fieldName
{
    for(DataObjectField *field in fields)
    {
        if ([field.name isEqualToString:fieldName]) {
            return YES;
        }
    }
    return NO;
}
-(NSDictionary*)toDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:objectClassIdentifier forKey:@"class"];
    NSMutableArray *arrayOfFieldDictionaries = [[NSMutableArray alloc] init];
    for(DataObjectField *field in fields)
    {
        [arrayOfFieldDictionaries addObject:[field toDictionary]];
    }
    [dictionary setObject:arrayOfFieldDictionaries forKey:@"fields"];
    return dictionary;
}

+(DataObjectMetadata*)objectFromDictionary:(NSDictionary*)dictionary
{
    DataObjectMetadata *daoMetadata = [[DataObjectMetadata alloc] init];
    daoMetadata.objectClassIdentifier = [dictionary valueForKey:@"class"];
    NSSet *fieldDictionaries = [dictionary objectForKey:@"fields"];
    NSMutableSet *fields = [[NSMutableSet alloc] init];
    for(NSDictionary *field in fieldDictionaries)
    {
        [fields addObject:[DataObjectField objectFromDictionary:field]];
    }
    daoMetadata.fields = fields;
    return daoMetadata;
}
-(id)copyWithZone:(NSZone*)zone
{
    DataObjectMetadata *copy = [[[self class] allocWithZone:zone] init];
    copy.fields = self.fields;
    copy.objectClassIdentifier = self.objectClassIdentifier;
    return copy;
}

@end
