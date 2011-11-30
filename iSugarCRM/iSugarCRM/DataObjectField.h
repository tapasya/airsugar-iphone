//
//  ObjectField.h
//  iSugarCRM
//
//  Created by Ved Surtani on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ObjectFieldDataType
{
    ObjectFieldDataTypeString,
    ObjectFieldDataTypeInteger,
    ObjectFieldDataTypeFloat,
    ObjectFieldDataTypeBool
}ObjectFieldDataType;

@interface DataObjectField : NSObject

+(DataObjectField*)fieldWithName:(NSString*)name dataType:(ObjectFieldDataType)type;


@property(strong)NSString *name;
@property(nonatomic)ObjectFieldDataType dataType;
@property(nonatomic)BOOL sortable;//to go in crm specific model
@property(nonatomic)BOOL filterable;
@property(nonatomic)BOOL editable;



@end
