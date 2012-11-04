//
//  DateUtils.h
//  iSugarCRM
//
//  Created by Tapasya on 03/11/12.
//
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSOperation

+(NSString *) formatDate:(NSString *)date;

+(NSString*) stringFromDate:(NSDate*) date;

+(NSDate*) dateFromString:(NSString*) dateString;

+ (NSComparisonResult) compareDates:(NSString*) dateString otherDate:(NSString*) otherDateString;

@end
