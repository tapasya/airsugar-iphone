//
//  DetailViewMetadata.m
//  iSugarCRM
//
//  Created by Ved Surtani on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewMetadata.h"
#import "DetailViewSectionItem.h"
#import "DataObjectField.h"
@implementation DetailViewMetadata
@synthesize objectMetadata,moduleName,sections;

-(NSDictionary*)toDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:moduleName forKey:@"module_name"];
    [dictionary setObject:[objectMetadata toDictionary] forKey:@"objectMetadata"];
    NSMutableArray *sectionsArray = [NSMutableArray array];
    for(NSDictionary *sectionItem in sections)
    {
        NSArray* rows = [sectionItem objectForKey:@"rows"];
        NSString * sectionName = [sectionItem objectForKey:@"section_name"];
        NSMutableArray *rowItems = [NSMutableArray array];
        for (NSDictionary *rowItem in rows)
        {
            NSMutableArray *dataObjectFieldArray = [NSMutableArray array];
            for(DataObjectField *field in [rowItem objectForKey:@"fields"])
            {
                [dataObjectFieldArray addObject:[field toDictionary]];
            }
            NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dataObjectFieldArray,[rowItem objectForKey:@"label"],nil] forKeys:[NSArray arrayWithObjects:@"fields",@"label", nil]];
            [rowItems addObject:row];
        }
        NSMutableDictionary *sectionItemDictionary = [NSMutableDictionary dictionary];
        [sectionItemDictionary setObject:rowItems forKey:@"rows"];
        [sectionItemDictionary setObject:sectionName forKey:@"section_name"];
        [sectionsArray addObject:sectionItemDictionary];
    }
    [dictionary setObject:sectionsArray forKey:@"sections"];
    return dictionary;
}


+(DetailViewMetadata*)objectFromDictionary:(NSDictionary *)dictionary
{
    DetailViewMetadata *detailViewMetadata = [[DetailViewMetadata alloc] init];
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    NSMutableArray *sectionsArray = [dictionary objectForKey:@"sections"];
    for(NSDictionary *sectionDictionary in sectionsArray)
    {  
        NSMutableDictionary *sectionItem = [NSMutableDictionary dictionary];
        NSMutableArray *rows = [NSMutableArray array];
        NSString *sectionName = [sectionDictionary objectForKey:@"section_name"];
        NSArray *rowsArray = [sectionDictionary objectForKey:@"rows"];
        for(NSDictionary *rowItemDictionary in rowsArray)
        {
            NSMutableArray *fields = [NSMutableArray array];
            for(NSDictionary * field in [rowItemDictionary objectForKey:@"fields"])
            {
                [fields addObject:[DataObjectField objectFromDictionary:field]];
            }
            NSMutableDictionary *rowItem = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:fields,[rowItemDictionary objectForKey:@"label"], nil] forKeys:[NSArray arrayWithObjects:@"fields",@"label", nil]];
            [rows addObject:rowItem];
        }
        [sectionItem setObject:sectionName forKey:@"section_name"];
        [sectionItem setObject:rows forKey:@"rows"];
        [sections addObject:sectionItem];
    }    
    detailViewMetadata.sections = sections;
    detailViewMetadata.moduleName = [dictionary objectForKey:@"module_name"];
    detailViewMetadata.objectMetadata = [DataObjectMetadata objectFromDictionary:[dictionary objectForKey:@"objectMetadata"]];
    return detailViewMetadata ;
}

-(id)copy
{
    DetailViewMetadata *copy = [[DetailViewMetadata alloc] init];
    copy.sections = sections;
    copy.objectMetadata = objectMetadata;
    copy.moduleName = moduleName;
    return copy;
}

@end
