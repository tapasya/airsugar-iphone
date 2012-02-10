//
//  ModuleSetting.m
//  iSugarCRM
//
//  Created by pramati on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModuleSettingsDataStore.h"
#import "SugarCRMMetadataStore.h"
#import "ModuleSettingsObject.h"

@interface ModuleSettingsDataStore()
-(NSString*) keyForSetting:(NSString*) settingTitle;
-(NSArray*) sortableFields;
-(NSArray*) sortOrderOptions;
@end

@implementation ModuleSettingsDataStore
@synthesize settingsDataObject=_settingsDataObject;
@synthesize moduleName=_moduleName;
@synthesize settingsArray=_moduleSettings;

-(id) initWithModuelName:(NSString *)moduelName
{
    self = [super init];
    if(self){
        self.moduleName = moduelName;
        self.settingsDataObject = [[SugarCRMMetadataStore sharedInstance] objectMetadataForModule:moduelName];
    }
    return self;
}

-(NSArray*) settingsArray
{
    if(!_moduleSettings){
        NSMutableArray* settings = [[NSMutableArray alloc] init];
        ModuleSettingsObject* sortFieldSettings = [[ModuleSettingsObject alloc] init];
        sortFieldSettings.title = kSettingTitleForSortField;
        sortFieldSettings.key = [self keyForSetting:sortFieldSettings.title];
        sortFieldSettings.multipleTitles = [self sortableFields];
        [settings addObject:sortFieldSettings];
        
        ModuleSettingsObject* sortOrderSettings = [[ModuleSettingsObject alloc] init];
        sortOrderSettings.title = kSettingTitleForSortorder;
        sortOrderSettings.key = [self keyForSetting:sortOrderSettings.title];
        sortOrderSettings.multipleTitles = [self sortOrderOptions];
        [settings addObject:sortOrderSettings];
        
        _moduleSettings = [[NSArray alloc] initWithArray:settings];
    }
    return _moduleSettings;
}

-(NSArray*) sortableFields
{
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    NSArray *sections = [[[SugarCRMMetadataStore sharedInstance] detailViewMetadataForModule:self.moduleName] sections];
    for(NSDictionary *sectionItem in sections)
    {
        NSArray* rows = [sectionItem objectForKey:@"rows"];
        for (NSDictionary *rowItem in rows)
        {
            NSArray* fieldItems = [rowItem objectForKey:@"fields"];
            for(DataObjectField *field in fieldItems)
            {
                if(field.sortable)
                {
                    NSString* label = [rowItem objectForKey:@"label"];
                    if([fields indexOfObject:label] == NSNotFound)
                    {
                     [fields addObject:label];   
                    }
                }
            }
        }
    }
    return fields;
}


-(NSArray*) sortOrderOptions
{
    return [[NSArray alloc] initWithObjects:kOptionAscending, kOptionDescending ,nil];
}

-(NSString*) keyForSetting:(NSString *)settingTitle
{
    return [[NSString alloc] initWithFormat:@"key_%@_%@" , self.moduleName, settingTitle];
}

@end
