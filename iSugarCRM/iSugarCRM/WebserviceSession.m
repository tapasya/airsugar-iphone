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
    //for testing return the ws session for accounts moule
    WebserviceSession *session = [[WebserviceSession alloc] init];
    WebserviceMetadataStore *metadataStore = [WebserviceMetadataStore storeForModule:moduleId];
    session.metadataStore = metadataStore;
    return session;
}


-(void)startLoadingList
{
    NSURLRequest *listRequest = [metadataStore listRequest];
    //load request and inform the delegate when done
    
}
@end
