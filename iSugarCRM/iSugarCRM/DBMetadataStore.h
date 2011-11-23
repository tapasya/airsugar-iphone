//
//  DBMetadataStore.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBMetadataStore : NSObject


+(DBMetadataStore*)storeForModule:(NSString*)moduleId;

-(NSString*)listQuery;
-(NSString*)detailQuery:(NSString*)beanId;

/*!
 @brief     returns a map  object keys and corresponding keyPath in list response from db
 */
-(NSDictionary*)listResponseKeyPaths;

/*!
 @brief     returns a map  object keys and corresponding keyPath in detail response from db
 */
-(NSDictionary*)detailResponseKeyPaths;

@end
