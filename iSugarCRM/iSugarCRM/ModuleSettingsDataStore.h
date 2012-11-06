//
//  ModuleSetting.h
//  iSugarCRM
//
//  Created by pramati on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataObjectMetadata.h"


@interface ModuleSettingsDataStore : NSObject

-(id) initWithModuelName:(NSString*) moduelName;

@property (nonatomic, strong) DataObjectMetadata* settingsDataObject;
@property (nonatomic, strong) NSString* moduleName;
@property (nonatomic, strong) NSArray* settingsArray;

@end
