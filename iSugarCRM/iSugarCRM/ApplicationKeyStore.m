//
//  ApplicationKeyStore.m
//  iSugarCRM
//
//  Created by dayanand on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicationKeyStore.h"
#import <Security/Security.h>
#import "SyncSettingsViewController.h"
#import "SettingsStore.h"

@interface ApplicationKeyStore()
-(void) deleteDefaults;
@end

@implementation ApplicationKeyStore
@synthesize keyChainData;
@synthesize keyChainQuery;


-(id)initWithName:(NSString *)name{
    
    if(self = [super init]){
        [self loadKeyChainWithName:name];
    }
    return self;
}

-(void)deleteDefaults{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEndDateIdentifier];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStartDateIdentifier];
}

-(void)loadKeyChainWithName:name{
    
    CFMutableDictionaryRef attributes = NULL;
    CFDataRef data = NULL;
    keyChainQuery = [NSDictionary dictionaryWithObjectsAndKeys:
                    name,(CFTypeRef)kSecAttrGeneric, //Attribute key-value pair which uniquely identifies a keychainitem.
                    (CFTypeRef)kSecClassGenericPassword,(CFTypeRef)kSecClass, //Attribute class key-value pair
                    (CFTypeRef)kSecMatchLimitOne,(CFTypeRef)kSecMatchLimit, //Results key-value pair
                    (CFBooleanRef)kCFBooleanTrue,(CFTypeRef)kSecReturnAttributes, //Return type key-value pair
                    nil];
    
    //loading data from keychain
    if(SecItemCopyMatching((__bridge CFDictionaryRef)keyChainQuery, (CFTypeRef *)&attributes) == noErr){
        
        //Data in the keychain is queried with 'SecItemCopyMatching' If data already exists in keychain it will return results to attributes based on 'return key-value' pair in 'keyChainQuery'
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)attributes];
        [temp setObject:[keyChainQuery objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
        [temp setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
        
        //Data queried with SecItemCopyMatching is dictionary specifing Item class,Attribute items,return type,search keys returns password data from keychain into 'data'.
        if(SecItemCopyMatching((__bridge CFDictionaryRef)temp, (CFTypeRef *)&data) == noErr){
            
            [temp removeObjectForKey:(__bridge id)kSecReturnData];
            
            //Object of the key 'kSecValueData' should be UTF-8 encoded
            //Password data should be UTF-8 encoded
            NSString *password = [[NSString alloc] initWithBytes:[(__bridge NSData *)data bytes]
                                                           length:[(__bridge NSData *)data length] encoding:NSUTF8StringEncoding];
            [temp setObject:password forKey:(__bridge id)kSecValueData];
            keyChainData = temp;
        }else{
            NSLog(@"Key chain data is empty but not nil");
        }
    }else{
        
        //If data doesnt exists after quering keychain intializing keychaindata with defaults 
        if(!keyChainData)
            keyChainData = [[NSMutableDictionary alloc] init];
        else{
            SecItemDelete((__bridge CFDictionaryRef)keyChainData);
        }
        
        [keyChainData setObject:@"" forKey:(__bridge id)kSecAttrAccount];
        [keyChainData setObject:(id)name forKey:(__bridge id)kSecAttrGeneric];
        [keyChainData setObject:(__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
        [keyChainData setObject:@"" forKey:(__bridge id)kSecValueData];
    }
}

-(void)addObject:(id)object forKey:(id)key{
    
    if(object == nil){
        return;
    }
    
    
    id existingObject = [keyChainData objectForKey:key];
    NSLog(@"Existing object%@",existingObject);
    NSLog(@"inobject object%@",object);
    if(existingObject != object){
        [keyChainData setObject:object forKey:key];
        [self deleteDefaults];
    }
    [self updateKeyChain];
}

-(id)objectForKey:(id)key{
    
    return [keyChainData objectForKey:key];
}

-(void)updateKeyChain{
    
    CFDataRef result = NULL;
    NSMutableDictionary *query = nil;
    if(SecItemCopyMatching((__bridge CFDictionaryRef)keyChainQuery, (CFTypeRef *)&result) == noErr){
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:keyChainData];
        [attributes setObject:[keyChainQuery objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
        NSString *passwordString = [keyChainData objectForKey:(__bridge id)kSecValueData];
        [attributes setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        query = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSMutableDictionary *)result];
        [query setObject:[keyChainQuery objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
        [attributes removeObjectForKey:(__bridge id)kSecClass];
        
        if(SecItemUpdate((__bridge CFDictionaryRef)query,(__bridge CFDictionaryRef)attributes) == noErr){
            NSLog(@"keychaindata Updated");
        }
    }else{
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:keyChainData];
        [temp setObject:[keyChainQuery objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
        [temp setObject:[keyChainQuery objectForKey:(__bridge id)kSecAttrGeneric] forKey:(__bridge id)kSecAttrGeneric];
        
        NSString *password = [keyChainData objectForKey:(__bridge id)kSecValueData];
        
        //Value of the key 'kSecValueData' should be in UTF-8 format
        [temp setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        
        //Adding attribute or data to keychain if it doesnt exsists
        if(SecItemAdd((__bridge CFDictionaryRef) temp,NULL) == noErr){
            NSLog(@"Added attributes to keychain");
        }
    }
}

@end