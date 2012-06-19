//
//  DataObject.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataObject.h"

@implementation DataObject
@synthesize metadata,relationships;

-(id)initWithMetadata:(DataObjectMetadata*)objectMetadata
{
    self = [super init];
    metadata = objectMetadata;
    fieldValues = [[NSMutableDictionary alloc]init];
    relationships = [[NSMutableDictionary alloc]init];
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
-(void)addRelationshipWithModule:(NSString*)module andBeans:(NSArray*)relatedBeanIds{


    if ([relationships objectForKey:module]) {
      [[relationships objectForKey:module] addObjectsFromArray:relatedBeanIds];
    }
    else [relationships setObject:[relatedBeanIds mutableCopy] forKey:module];
    
}
-(NSArray*)nameValueArray
{
    NSMutableArray *nameValueArray = [[NSMutableArray alloc] init];
    for(DataObjectField* field in self.metadata.fields)
    {
        NSString* value = [self objectForFieldName:field.name];
        // Preventing the dummy local id from the name value array
        if(value && !([field.name isEqualToString:@"id"]&& [value hasPrefix:LOCAL_ID_PREFIX]))
        {
            NSMutableDictionary* nameValuePair = [[NSMutableDictionary alloc] init];
            [nameValuePair setObject:field.name forKey:@"name"];
            [nameValuePair setObject:[self objectForFieldName:field.name] forKey:@"value"];
            [nameValueArray addObject:nameValuePair];
        }
    }
    return nameValueArray;
}

+(NSArray*) removeLocalId:(NSArray *)nameValueArray
{
    NSMutableArray* temp = [nameValueArray mutableCopy];
    for(NSDictionary* nameValueDictionary in temp)
    {
        NSString* name = [nameValueDictionary objectForKey:@"name"];
        NSString* value = [nameValueDictionary objectForKey:@"value"];
        if([name isEqualToString:@"id"] && [value hasPrefix:LOCAL_ID_PREFIX])
        {
            [temp removeObject:nameValueDictionary];
        }
    }
    return temp;
}

+(DataObject*) dataObjectFromNameValueArray:(NSArray *)nameValueArray andMetadata:(DataObjectMetadata *)objectMetadata
{
    DataObject* dataObject = [[DataObject alloc] initWithMetadata:objectMetadata];
    for(NSDictionary* nameValuePair in nameValueArray)
    {
        [dataObject setObject:[nameValuePair objectForKey:@"value"] forFieldName:[nameValuePair objectForKey:@"name"]];
    }    
    return dataObject;
}

-(NSArray*) nameValueArrayForDelete
{
    NSMutableArray *nameValueArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary* idValuePair = [[NSMutableDictionary alloc] init];
    [idValuePair setObject:@"id" forKey:@"name"];
    [idValuePair setObject:[self objectForFieldName:@"id"] forKey:@"value"];
    [nameValueArray addObject:idValuePair];
   
    NSMutableDictionary* deleteValuePair = [[NSMutableDictionary alloc] init];
    [deleteValuePair setObject:@"deleted" forKey:@"name"];
    [deleteValuePair setObject:[self objectForFieldName:@"deleted"] forKey:@"value"];
    [nameValueArray addObject:deleteValuePair];
    
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
//add relationship to description
    return description;
}
@end
