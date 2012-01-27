//
//  ModuleSettingsObject.m
//  iSugarCRM
//
//  Created by pramati on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModuleSettingsObject.h"
#import "SettingsStore.h"

@implementation ModuleSettingsObject
@synthesize key=_key;
@synthesize type=_type;
@synthesize title=_title;
@synthesize value=_value;
@synthesize multipleTitles=_multipleTitles;

-(NSString*) value
{
    NSString* value = [SettingsStore objectForKey:self.key];
    if(!value){
        value = [self.multipleTitles objectAtIndex:0];
        NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:value forKey:self.key];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults]; 
    }
    return value;    
}

@end
