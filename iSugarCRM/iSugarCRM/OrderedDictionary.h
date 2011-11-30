//
//  OrderedDictionary.h
//  zSugarCRM
//
//  Created by Ved Surtani on 19/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderedDictionary : NSMutableDictionary
{
    NSMutableDictionary *actualDictionarry;
    NSMutableArray *orderedKeys;

}
@end
