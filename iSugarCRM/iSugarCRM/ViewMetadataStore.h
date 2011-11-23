//
//  ViewMetadataStore.h
//  iSugarCRM
//
//  Created by Ved Surtani on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewMetadataStore : NSObject

+(ViewMetadataStore*)storeForModule:(NSString*)moduleId;


/*!
 @brief     returns the information for rendering list view.
 */
-(NSDictionary*)listViewMap;

/*!
 @brief     returns the information for rendering detail view
 */
-(NSDictionary*)detailResponseKeyPaths;


@end
