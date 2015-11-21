//
//  NSString+Date.h
//  SnapticaToo
//
//  Created by sandeep on 2/5/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

// NSString+Date.h

@interface NSString (Date)

+ (NSDate*)stringDateFromString:(NSString*)string;
+ (NSString*)stringDateFromDate:(NSDate*)date;
+ (NSString*)stringTimestampFromDate:(NSDate*)date;
+ (NSString*)stringMonthYearFromDate:(NSDate*)date;
+ (NSDictionary *) stringDateComponents: (NSDate *) date;
+ (NSDate*) stringDateShortFromString:(NSString*)string;
+ (NSString*) stringDateShortFromDate:(NSDate*)date;
+ (NSDate*)stringDateCompactFromString:(NSString*)string;
+ (NSString*)stringDateCompactFromDate:(NSDate*)date;

@end
