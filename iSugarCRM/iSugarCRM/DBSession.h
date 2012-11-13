//
//  DBSession.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBMetadata.h"
#import "DataObject.h"

typedef void(^DBSessionCompletionBlock)(NSArray* data);

typedef void(^DBSessionErrorBlock)(NSError* error);

@interface DBSession : NSObject
{
}

@property(weak)id parent;

@property(strong)DBMetadata *metadata;

@property (nonatomic, copy) DBSessionCompletionBlock completionBlock;

@property (nonatomic, copy) DBSessionErrorBlock errorBlock;

+(DBSession*)sessionForModule:(NSString*) moduleName;
//reading
-(void)startLoading;
-(void)rowsFromDBWithLimit:(int)rowLimit andOffset:(int)offSet orderBy:(NSString*)orderField;
-(void)loadDetailsForId:(NSString*)beanId;
-(NSArray*)getUploadData;
//writing
-(void)insertDataObjectsInDb:(NSArray *)dataObjects dirty:(BOOL)dirty;
-(BOOL)resetDirtyFlagForId:(DataObject*)dObj;

-(NSString*)getLastSyncTimestamp;
-(BOOL) deleteRecord:(NSString *)beanId;
-(BOOL) deleteAllRecordsInTable;
@end
