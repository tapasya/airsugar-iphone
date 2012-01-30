//
//  ModuleSettingsObject.h
//  iSugarCRM
//
//  Created by pramati on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModuleSettingsObject : NSObject


@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *multipleTitles;

@end
