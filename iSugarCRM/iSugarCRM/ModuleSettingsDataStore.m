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
        self.settingsDataObject = [[[SugarCRMMetadataStore sharedInstance] detailViewMetadataForModule:moduelName] objectMetadata];
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
    for(DataObjectField* field in [self.settingsDataObject fields]){
       // NSLog(@"%@ %@ %@", field.name, field.label, field.sortable);
        if(field.sortable)
        {
            [fields addObject:field.label];
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
    return [[NSString alloc] initWithFormat:@"key_%@%@%@" , self.moduleName, @"_", settingTitle];
}

@end
