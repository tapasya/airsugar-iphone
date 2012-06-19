//
//  ConnectivityChecker.h
//  iSugarCRM
//
//  Created by Apple on 27/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@interface ConnectivityChecker : NSObject
{
    Reachability * _hostReach;
}

+(ConnectivityChecker *) singletonObject;
-(void)startReaching;
@property (nonatomic,assign) BOOL isNetworkReachable;
@end
