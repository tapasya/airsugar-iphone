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
    NSMutableDictionary *relationships;
}
@property (strong)NSMutableDictionary *relationships;
@property(strong,readonly)DataObjectMetadata *metadata;
-(id)initWithMetadata:(DataObjectMetadata*)objectMetadata;
-(id)objectForFieldName:(NSString*)fieldName;
-(BOOL)setObject:(id)anObject forFieldName:(NSString *)fieldName;
-(void)addRelationshipWithModule:(NSString*)module andBeans:(NSArray*)relatedBeanIds;
-(NSArray*) nameValueArray;
-(NSArray*) nameValueArrayForDelete;
+(DataObject*) dataObjectFromNameValueArray:(NSArray*) nameValueArray andMetadata:(DataObjectMetadata*) objectMetadata;
@end
