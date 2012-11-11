//
//  DateUtils.m
//  iSugarCRM
//
//  Created by Tapasya on 03/11/12.
//
//

#import "DateUtils.h"

@implementation DateUtils

+ (NSString *)getCurrentDate
{
    return [[DateUtils getDefaultFormatter] stringFromDate:[NSDate date]];
}

+ (NSDateFormatter*) getDefaultFormatter
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
   
    return dateFormatter;
}

+ (NSString*) formatDate:(NSString *) dateString
{
    NSDate* date = (dateString != nil) ? [[DateUtils getDefaultFormatter] dateFromString:dateString] : [NSDate date] ;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* formattedDate = [formatter stringFromDate:date];
    
    return formattedDate;
}

+ (NSString*) stringFromDate:(NSDate *)date
{
    return [[DateUtils getDefaultFormatter] stringFromDate:date];
}

+ (NSDate*) dateFromString:(NSString *)dateString
{
    return [[DateUtils getDefaultFormatter] dateFromString:dateString];
}

+ (NSComparisonResult) compareDates:(NSString *)dateString otherDate:(NSString *)otherDateString
{
    NSDateFormatter* dateFormatter = [DateUtils getDefaultFormatter];
   
    NSDate* date1 = [dateFormatter dateFromString:dateString];
    
    NSDate* date2 = [dateFormatter dateFromString:otherDateString];
    
    NSComparisonResult result = [date1 compare:date2];
    
    return result;
}

@end
