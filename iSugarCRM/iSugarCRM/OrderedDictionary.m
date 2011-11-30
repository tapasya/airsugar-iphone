//
//  OrderedDictionary.m
//  zSugarCRM
//
//  Created by Ved Surtani on 19/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OrderedDictionary.h"

#import "JSONKit.h"

@implementation OrderedDictionary


-(id)init{
    self = [super init];
    orderedKeys = [[NSMutableArray alloc] init];
    actualDictionarry = [[NSMutableDictionary alloc] init];
    return self;
}


-(void)setValue:(id)value forKey:(NSString *)key
{
    if([actualDictionarry valueForKey:key] == nil)
    {
        [orderedKeys addObject:key];
    }
    [actualDictionarry setValue:value forKey:key];
}

-(void)setObject:(id)anObject forKey:(id)aKey
{
    if([actualDictionarry objectForKey:aKey] == nil)
    {
        [orderedKeys addObject:aKey];
    }
    [actualDictionarry setObject:anObject forKey:aKey];
}

-(void)removeObjectForKey:(id)aKey
{
    [orderedKeys removeObject:aKey];
    [actualDictionarry removeObjectForKey:aKey];
}

-(id)objectForKey:(id)aKey
{
    return [actualDictionarry objectForKey:aKey];
}

-(id)valueForKey:(NSString *)key
{
    return [actualDictionarry valueForKey:key];
}



-(NSEnumerator*)keyEnumerator
{
    return [orderedKeys objectEnumerator];
}

-(NSUInteger)count
{
    return  [orderedKeys count];
}
@end
