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


-(void)startLoading:(NSString*)timestamp
{
    NSURLRequest *request = [metadata getRequestWithLastSyncTimestamp:timestamp];
    id completionHandler = ^(NSURLResponse *response, NSData *data, NSError* error){
        if (error) {
            [delegate session:self didFailWithError:error];
        }
        else
        {  
            NSDictionary *responseDictionary = [data objectFromJSONData]; //parse using some parser
            id responseObjects = [responseDictionary valueForKeyPath:metadata.pathToObjectsInResponse];
            NSLog(@"response object for module: %@ data: %@",metadata.moduleName,responseObjects);
            if([responseObjects isKindOfClass:[NSDictionary class]]){
                responseObjects = [NSArray arrayWithObject:responseObjects];
            }
            NSMutableArray *arrayOfDataObjects = [[NSMutableArray alloc] init];
            for(NSDictionary *responseObject in responseObjects)
            {
                DataObjectMetadata *objectMetadata = [[SugarCRMMetadataStore sharedInstance] objectMetadataForModule:self.metadata.moduleName];
                DataObject *dataObject = [[DataObject alloc] initWithMetadata:objectMetadata];
                //dataobjectfields set from dataobjectmetadata in webservice metadata
                for(DataObjectField *field in [[objectMetadata fields] allObjects]) 
                {
                    id value = [responseObject valueForKeyPath:[metadata.responseKeyPathMap objectForKey:field.name]];
                    if (value == nil) {
                        [dataObject setObject:@" " forFieldName:field.name];
                    } else {
                    [dataObject setObject:value forFieldName:field.name];
                    }
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
