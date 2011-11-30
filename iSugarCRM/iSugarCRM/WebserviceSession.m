//
//  WebserviceSession.m
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebserviceSession.h"


@implementation WebserviceSession
@synthesize delegate;
@synthesize metadata;
+(WebserviceSession*)sessionWithMatadata:(WebserviceMetadata*)metadata
{
    WebserviceSession *session = [[WebserviceSession alloc] init];
    session.metadata = metadata;
    return session;
}


-(void)startLoading
{
    NSURLRequest *request = [metadata getRequest];
    id completionHandler = ^(NSURLResponse *response, NSData *data, NSError* error){
        if (error) {
            [delegate session:self didFailWithError:error];
        }
        else if(delegate!= nil){
            [delegate session:self didCompleteWithResponse:nil];
        }
    };
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:completionHandler];
    
}
@end
