//
//  DBHelper.h
//  iSugarCRM
//
//  Created by pramati on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHelper : NSObject
+(void) updateUserTable:(NSArray*) userList;
+(NSArray*) loadUserList;
+(NSArray*) loadRecordsinModule:(NSString*) moduleName;
@end
