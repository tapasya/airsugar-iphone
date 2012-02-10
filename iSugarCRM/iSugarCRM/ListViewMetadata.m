//
//  ListViewMetadata.m
//  iSugarCRM
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ListViewMetadata.h"

@implementation ListViewMetadata
@synthesize primaryDisplayField,otherFields,iconImageName,moduleName;


-(NSDictionary*)toDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[primaryDisplayField toDictionary] forKey:@"primaryDisplayField"];
    if(otherFields != nil){
        NSMutableArray *arrayOfOtherFieldDictionaries = [[NSMutableArray alloc] init];
        for(DataObjectField *field in otherFields)
        {
            [arrayOfOtherFieldDictionaries addObject:[field toDictionary]];
        }
        [dictionary setObject:arrayOfOtherFieldDictionaries forKey:@"otherFields"];
    }
    [dictionary setObject:moduleName forKey:@"module_name"];
    if(iconImageName != nil)
    {
        [dictionary setValue:iconImageName forKey:@"icon"];
    }
    return dictionary;
        
}
+(ListViewMetadata*)objectFromDictionary:(NSDictionary*)dictionary
{
    ListViewMetadata *lViewMetadata = [[ListViewMetadata alloc]init];
    lViewMetadata.primaryDisplayField = [DataObjectField objectFromDictionary:[dictionary valueForKey:@"primaryDisplayField"]];
    NSArray *arrayOfOtherFieldDictionaries = [dictionary objectForKey:@"otherFields"];
    if (arrayOfOtherFieldDictionaries != nil) {
        NSMutableArray *otherFields = [[NSMutableArray alloc] init];
        for(NSDictionary *otherFieldDict in arrayOfOtherFieldDictionaries)
        {
            [otherFields addObject:[DataObjectField objectFromDictionary:otherFieldDict]];
        }
        lViewMetadata.otherFields = otherFields;
    }
    lViewMetadata.moduleName = [dictionary objectForKey:@"module_name"];
    NSString *iconImageName = [dictionary valueForKey:@"icon"];
    if (iconImageName != nil) {
        lViewMetadata.iconImageName = iconImageName;
    }
    return lViewMetadata;
}

-(id)copy
{
    ListViewMetadata *copy = [[ListViewMetadata alloc] init];
    copy.primaryDisplayField = primaryDisplayField;
    copy.otherFields = otherFields;
    copy.iconImageName = iconImageName;
    copy.moduleName = moduleName;
    return copy;
}

@end
