//
//  ObjectMetadata.m
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataObjectMetadata.h"
#import "DataObjectField.h"
@implementation DataObjectMetadata
@synthesize fields,objectClassIdentifier;
-(BOOL)hasFieldWithName:(NSString*)fieldName
{
    for(DataObjectField *field in fields)
    {
        if (field.name == fieldName) {
            return YES;
        }
    }
    return NO;
}
@end
