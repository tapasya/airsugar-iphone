//
//  ObjectMetadata.h
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataObjectMetadata : NSObject
@property(strong)NSString *objectClassIdentifier;
@property(strong)NSSet *fields;

-(BOOL)hasFieldWithName:(NSString*)fieldName;
@end
