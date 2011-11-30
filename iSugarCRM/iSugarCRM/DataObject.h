//
//  DataObject.h
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataObjectMetadata.h"
#import "DataObjectField.h"
@interface DataObject : NSObject
{
    @private
    NSMutableDictionary *fieldValues;
}
@property(strong,readonly)DataObjectMetadata *metadata;
-(id)initWithMetadata:(DataObjectMetadata*)objectMetadata;
-(id)objectForFieldName:(NSString*)fieldName;
-(BOOL)setObject:(id)anObject forFieldName:(NSString *)fieldName;
@end
