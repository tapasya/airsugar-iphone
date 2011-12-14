//
//  WebserviceSession.m
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebserviceSession.h"
#import "DataObject.h"
#import "DataObjectField.h"
#import "JSONKit.h"
@implementation WebserviceSession
@synthesize delegate;
@synthesize metadata;
+(WebserviceSession*)sessionWithMetadata:(WebserviceMetadata*)metadata
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
        else
        {  
            NSDictionary *responseDictionary = [data objectFromJSONData]; //parse using some parser
            NSLog(@"delegate %@",delegate);
            id responseObjects = [responseDictionary valueForKeyPath:metadata.pathToObjectsInResponse];
            if([responseObjects isKindOfClass:[NSDictionary class]])
            {
                responseObjects = [NSArray arrayWithObject:responseObjects];
            }
            NSMutableArray *arrayOfDataObjects = [[NSMutableArray alloc] init];
            for(NSDictionary *responseObject in responseObjects)
            {
                DataObject *dataObject = [[DataObject alloc] initWithMetadata:metadata.objectMetadata];
                
                //dataobjectfields set from dataobjectmetadata in webservice metadata
                for(DataObjectField *field in [[metadata.objectMetadata fields] allObjects]) 
                {
                    id value = [responseObject valueForKeyPath:[metadata.responseKeyPathMap objectForKey:field]];
                    [dataObject setObject:value forFieldName:field.name];
                }
                [arrayOfDataObjects addObject:dataObject];
            }
            if(delegate!= nil){
                [delegate session:self didCompleteWithResponse:arrayOfDataObjects];
            }
        }
        
    };
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:completionHandler];
    
}
@end
