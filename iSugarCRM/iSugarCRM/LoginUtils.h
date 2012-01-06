//
//  LoginUtils.h
//  iSugarCRM
//
//  Created by pramati on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginUtils : NSObject
+(id) login:(NSString*) username:(NSString*) password;
+(NSString*)urlStringForParams:(NSMutableDictionary*)params;
@end
