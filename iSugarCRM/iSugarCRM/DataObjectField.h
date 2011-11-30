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
    ObjectFieldDataTypeBool,
}ObjectFieldDataType;

@interface DataObjectField : NSObject

@property(strong)NSString *name;
@property(nonatomic)ObjectFieldDataType dataType;
+(DataObjectField*)fieldWithName:(NSString*)name dataType:(ObjectFieldDataType)type;
@end
