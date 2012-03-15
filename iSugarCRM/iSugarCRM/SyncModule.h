//
//  SyncModule.h
//  iSugarCRM
//
//  Created by satyavrat-mac on 07/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SyncModuleDelegate;
@interface SyncModule : NSOperation
@property (assign)NSInteger action;
@property (strong)NSString *moduleName;
@property (strong)NSDictionary *data;
@property (strong)NSString *startDate;
@property (strong)NSString *endDate;
@property (assign)id<SyncModuleDelegate> parent;

+(SyncModule*)syncModuleWithName:(NSString*)name action:(NSInteger)action data:(NSDictionary*)data parent:(id)parent startDate:(NSString*)startDate endDate:(NSString*)endDate;
@end
@protocol SyncModuleDelegate<NSObject>
-(void)operationCompleted;
-(void)operationCancelled;
@end