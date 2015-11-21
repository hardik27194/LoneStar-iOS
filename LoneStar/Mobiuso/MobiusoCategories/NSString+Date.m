//
//  NSString+Date.m
//  SnapticaToo
//
//  Created by sandeep on 2/5/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

// NSString+Date.m

@import UIKit;

@implementation NSString (Date)


+ (NSDateFormatter*)stringDateFormatter
{
    NSDateFormatter* formatter = nil;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
    return formatter;
}

+ (NSDate*)stringDateFromString:(NSString*)string
{
    return [[NSString stringDateFormatter] dateFromString:string];
}

+ (NSString*)stringDateFromDate:(NSDate*)date
{
    return [[NSString stringDateFormatter] stringFromDate:date];
}

+ (NSDateFormatter*)stringDateNoYearFormatter
{
    NSDateFormatter* formatter = nil;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM"];
    return formatter;
}

+ (NSDateFormatter*)stringDateShortFormatter
{
    NSDateFormatter* formatter = nil;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-YY"];
    return formatter;
}

// 01-Jan, 4-Mar, 23-Dec, etc
+ (NSDate*) stringDateShortFromString:(NSString*)string
{
    NSDate * date = [[NSString stringDateShortFormatter] dateFromString:string];
    if (!date) {
        // try without the date first
        date = [[NSString stringDateNoYearFormatter] dateFromString:string];
    }
    return date;
}

+ (NSString*) stringDateShortFromDate:(NSDate*)date;
{
    return [[NSString stringDateShortFormatter] stringFromDate:date];
    
}

+ (NSDateFormatter*)stringDateFormatterCompact
{
    NSDateFormatter* formatter = nil;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    return formatter;
}

+ (NSString*)stringTimestampFromDate:(NSDate*)date
{
    return [[NSString stringDateFormatterCompact] stringFromDate:date];
}

+ (NSDateFormatter*)stringDateComponentFormatter
{
    NSDateFormatter* formatter = nil;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE:dd:MMM:yyyy:HH:mm:ss:ZZZ"];
    return formatter;
}

+ (NSDictionary *) stringDateComponents: (NSDate *) date
{
    NSString *componentString = [[NSString stringDateComponentFormatter] stringFromDate:date];
    NSArray *componentArray = [componentString componentsSeparatedByString: @":"];
    if ((componentArray == nil) || ([componentArray count] < 8))
        return nil;
    else
        return @{
                 @"year": componentArray[3],
                 @"month": componentArray[2],
                 @"date": componentArray[1],
                 @"day": componentArray[0],
                 @"hour": componentArray[4],
                 @"minute": componentArray[5],
                 @"seconds": componentArray[6],
                 @"microseconds": componentArray[7]
                 };
}

+ (NSDateFormatter*)stringDateMonthYearFormatter
{
    NSDateFormatter* formatter = nil;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM yyyy"];
    return formatter;
}

+ (NSString *) stringMonthYearFromDate: (NSDate *) date
{
    return [[NSString stringDateMonthYearFormatter] stringFromDate:date];
}

+ (NSDateFormatter*)stringDateCompactFormatter
{
    NSDateFormatter* formatter = nil;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    return formatter;
}

+ (NSDate*)stringDateCompactFromString:(NSString*)string
{
    return [[NSString stringDateCompactFormatter] dateFromString:string];
}

+ (NSString*)stringDateCompactFromDate:(NSDate*)date
{
    return [[NSString stringDateCompactFormatter] stringFromDate:date];
}

@end