//
//  NSDate+Helpers.m
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "NSDate+Helpers.h"

@implementation NSDate(Helpers)

+ (NSDate *)dateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:year];
    [dateComponents setMonth:month];
    [dateComponents setDay:day];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateFromComponents:dateComponents];
}

@end
