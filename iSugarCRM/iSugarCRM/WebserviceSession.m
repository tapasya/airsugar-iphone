//
//  WebserviceSession.m
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebserviceSession.h"

@interface WebserviceSession()
@property(strong)WebserviceMetadataStore *metadataStore;
@end

@implementation WebserviceSession
@synthesize delegate;
@synthesize metadataStore;
+(WebserviceSession*)sessionForModule:(NSString*)moduleId
{

}


-(void)startLoadingList
{

    
}
@end
