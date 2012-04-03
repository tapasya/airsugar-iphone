//
//  RecentViewController.m
//  iSugarCRM
//
//  Created by satyavrat-mac on 03/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentViewController.h"

@implementation RecentViewController
-(id)initWithRecentItems:(NSMutableDictionary*)recentItems{
    if (self = [super init]) {
         self.dataSourceDictionary = recentItems;
    }
    return self;
}
@end
