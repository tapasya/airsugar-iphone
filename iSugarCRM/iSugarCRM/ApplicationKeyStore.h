//
//  ApplicationKeyStore.h
//  iSugarCRM
//
//  Created by dayanand on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationKeyStore : NSObject
{
    @private
    NSDictionary *keyChainQuery;
    NSMutableDictionary *keyChainData;
}

@property (nonatomic,retain) NSDictionary *keyChainQuery;
@property (nonatomic,retain) NSMutableDictionary *keyChainData;


-(id)initWithName:(NSString *)name;
-(void)loadKeyChainWithName:(NSString *)name;
-(void)addObject:(id)object forKey:(id)key;
-(id)objectForKey:(id)key;
-(void)updateKeyChain;
@end
