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

typedef enum ObjectFieldAction
{
    Phone,
    Date,
    Number,
    Bool
}ObjectFieldActionType;

@interface DataObjectField : NSObject

+(DataObjectField*)fieldWithName:(NSString*)name dataType:(ObjectFieldDataType)type andAction:(NSString*)action;
-(NSDictionary*)toDictionary;
+(DataObjectField*)objectFromDictionary:(NSDictionary*)dictionary;

@property(strong)NSString *name;
@property(nonatomic)ObjectFieldDataType dataType;
@property(nonatomic)BOOL sortable;//to go in crm specific model
@property(nonatomic)BOOL filterable;
@property(nonatomic)BOOL editable;
@property(nonatomic)BOOL mandatory;
@property(strong)NSString *action;
@property(strong)NSString *label;

@end
