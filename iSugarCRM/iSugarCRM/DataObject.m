//
//  DataObject.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataObject.h"

@implementation DataObject
@synthesize metadata;

-(id)initWithMetadata:(DataObjectMetadata*)objectMetadata
{
    self = [super init];
    metadata = objectMetadata;
    fieldValues = [[NSMutableDictionary alloc]init];
    return self;
}
-(id)objectForFieldName:(NSString*)fieldName{
    
    //NSAssert([metadata hasFieldWithName:fieldName], @"Object does not have a field with this name in metadata fieldName = %@ metadata= %@", fieldName,metadata);
    return [fieldValues objectForKey:fieldName];//TODO: throw error if unsupported field is sent
}
-(BOOL)setObject:(id)anObject forFieldName:(NSString *)fieldName{
    if([metadata hasFieldWithName:fieldName])
    {  
        [fieldValues setObject:anObject forKey:fieldName];
        return YES;
    }
    return NO;
}

-(NSArray*) getNameValueArray
{
    NSMutableArray *nameValueArray = [[NSMutableArray alloc] init];
    for(DataObjectField* field in self.metadata.fields)
    {
        NSMutableDictionary* nameValuePair = [[NSMutableDictionary alloc] init];
        [nameValuePair setObject:field.name forKey:@"name"];
        [nameValuePair setObject:[self objectForFieldName:field.name] forKey:@"value"];
        [nameValueArray addObject:nameValuePair];
    }
    return nameValueArray;
}

-(NSString*)description
{
    NSMutableString *description = [[NSMutableString alloc] init];
    [description appendString:metadata.objectClassIdentifier];
    [description appendString:@" *********** \n"];
    for(DataObjectField *field in metadata.fields)
    {
        [description appendString:[NSString stringWithFormat:@"%@ : %@ \n",field.name, [self objectForFieldName:field.name]]];
    }
    return description;
}
@end
