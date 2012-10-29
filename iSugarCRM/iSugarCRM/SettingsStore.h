//
//  SettingsStore.h
//  iSugarCRM
//
//  Created by pramati on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStartDateIdentifier            @"key_sync_start_date" //move constants to implementation file
#define kEndDateIdentifier              @"key_sync_end_date"


@interface SettingsStore : NSObject
+ (void)setBool:(BOOL)value      forKey:(NSString*)key;
+ (void)setFloat:(float)value    forKey:(NSString*)key;
+ (void)setDouble:(double)value  forKey:(NSString*)key;
+ (void)setInteger:(int)value    forKey:(NSString*)key;
+ (void)setObject:(id)value      forKey:(NSString*)key;
+ (BOOL)boolForKey:(NSString*)key;
+ (float)floatForKey:(NSString*)key;
+ (double)doubleForKey:(NSString*)key;
+ (int)integerForKey:(NSString*)key;
+ (id)objectForKey:(NSString*)key;
+ (BOOL)synchronize; 
@end
