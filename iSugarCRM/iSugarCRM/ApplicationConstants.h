//
//  ApplicationConstants.h
//  iSugarCRM
//
//  Created by Dayanand on 02/11/12.
//
//

#import <Foundation/Foundation.h>

@interface ApplicationConstants

/*
 DEPRECATED ENUMS or CONSTANTS prior in iOS6 version
 */
#if __IPHONE_6_0
    #define kAlignCenter            NSTextAlignmentCenter
    #define kAlignLeft                NSTextAlignmentLeft
    #define kAlignRight              NSTextAlignmentRight
    #define kTruncatingTail         NSLineBreakByTruncatingTail
    #define kTruncatingMiddle   NSLineBreakByTruncatingMiddle
    #define kWordWrapping       NSLineBreakByWordWrapping
    #define kCharWrapping       NSLineBreakByCharWrapping
#else
    #define kAlignCenter            UITextAlignmentCenter
    #define kAlignLeft                 UITextAlignmentLeft
    #define kAlignRight               UITextAlignmentRight
    #define kTruncatingTail         UILineBreakModeTailTruncation
    #define kTruncatingMiddle   UILineBreakModeMiddleTruncation
    #define kWordWrapping       UILineBreakModeWordWrap
    #define kCharWrapping       UILineBreakModeCharacterWrap
#endif

#define kRowLimit 50

#pragma mark modulesettings constants
//Module specific settings constants
#define kSettingTitleForSortField       @"Sort by"
#define kSettingTitleForSortorder       @"Sort Order"
#define kOptionAscending                @"Ascending"
#define kOptionDescending               @"Descending"
@end
