//
//  ConnectivityChecker.m
//  iSugarCRM
//
//  Created by Apple on 27/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConnectivityChecker.h"
@class Reachability;

@interface ConnectivityChecker()
-(id) initPrivate;
-(void)updateReachability:(Reachability *)reachability;
-(void)reachabilityNotifier:(id)reachability;
@end

@implementation ConnectivityChecker

static ConnectivityChecker *_singleton = nil;

@synthesize isNetworkReachable;

-(id)init
{
    return nil;
}

-(id)initPrivate
{
    if(self = [super init]){
        self.isNetworkReachable = YES;
        return self;
    }
    return nil;
}

+(ConnectivityChecker *)singletonObject
{
    @synchronized(self){
        if (_singleton == nil) {
            _singleton = [[ConnectivityChecker alloc] initPrivate];
        }
        return _singleton;
    }
}

-(void)startReaching
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityNotifier:) name:kReachabilityChangedNotification object:nil];
    
    NSRange range = [[[NSUserDefaults standardUserDefaults] objectForKey:@"endpointURL"] rangeOfString:@"://"];
    if(range.location == NSNotFound)
    {
        range.location = 0;
    }
    NSString *hostname = [[[NSUserDefaults standardUserDefaults] objectForKey:@"endpointURL"] substringWithRange:NSMakeRange(range.location+range.length, [[[NSUserDefaults standardUserDefaults] objectForKey:@"endpointURL"] rangeOfString:@"/"].location)];
    _hostReach = [Reachability reachabilityWithHostName:hostname];
    [_hostReach startNotifier];
    [self updateReachability:_hostReach];
}
-(void)updateReachability:(Reachability *)reachability
{
    BOOL connected = NO;
    if(reachability == nil){
        self.isNetworkReachable = NO;
    }
    else if(reachability == _hostReach)
	{
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
		
		if(netStatus == ReachableViaWWAN || netStatus == ReachableViaWiFi)
        {
            connected = YES;
        }
		
		if(self.isNetworkReachable != connected)
		{
			self.isNetworkReachable = connected;
		}
    }
}

-(void)reachabilityNotifier:(NSNotification *)notification
{
    Reachability *reachability = [notification object];
    if ([reachability isKindOfClass:[Reachability class]]) {
        [self updateReachability:reachability];
    }
    else {
        [self updateReachability:nil];
    }
    
}
@end
