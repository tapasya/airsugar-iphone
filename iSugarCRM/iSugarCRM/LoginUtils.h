//
//  LoginUtils.h
//  iSugarCRM
//
//  Created by pramati on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginUtils : NSObject
+(id) loginWithUsername:(NSString*) username password:(NSString*) password andUrl:(NSString *)url;
+(id) login;
+(BOOL) seamLessLogin;
+(NSString*)urlString:(NSString *)url forParams:(NSMutableDictionary*)params;
+(BOOL)keyChainHasUserData;
+(void)displayLoginError:(id)response;
+(void) showError:(NSError *)error;
+ (NSString *)md5Hash:(NSString*)string;
@end
