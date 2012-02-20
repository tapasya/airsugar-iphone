//
//  WebserviceSession.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceMetadata.h"
@protocol WebserviceSessionDelegate;

@interface WebserviceSession : NSObject
{
 
}
@property(weak)id<WebserviceSessionDelegate> delegate;
@property(strong)WebserviceMetadata *metadata;


+(WebserviceSession*)sessionWithMetadata:(WebserviceMetadata*)metadata;
-(void)startLoading:(NSString*)timestamp;
-(void)startLoadingWithFilters:(NSString*) startDate: (NSString*) endDate;
@end



@protocol WebserviceSessionDelegate <NSObject>
@optional
-(void)sessionWillStartLoading:(WebserviceSession*)session;
-(void)session:(WebserviceSession*)session didFailWithError:(NSError*)error;
@required
-(void)session:(WebserviceSession*)session didCompleteWithResponse:(id)response;
@end