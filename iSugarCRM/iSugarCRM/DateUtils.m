//
//  DateUtils.m
//  iSugarCRM
//
//  Created by Tapasya on 03/11/12.
//
//

#import "DateUtils.h"

@implementation DateUtils

+ (NSDateFormatter*) getDefaultFormatter
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
   
    return dateFormatter;
}

+ (NSString*) formatDate:(NSString *)date
{
    
    if(date == nil){
        date = [[[[NSDate date] description]componentsSeparatedByString:@" "] objectAtIndex:0];
    }else{
        date = [[[[[DateUtils getDefaultFormatter] dateFromString:date] description] componentsSeparatedByString:@" "] objectAtIndex:0];
    }
    
    return date;
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
