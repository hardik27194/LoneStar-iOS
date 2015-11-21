//
//  NSDate+Compare.h
//  SnapticaToo
//
//  Created by sandeep on 2/5/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Compare)

-(BOOL) isLaterThanOrEqualTo:(NSDate*)date;
-(BOOL) isEarlierThanOrEqualTo:(NSDate*)date;
-(BOOL) isLaterThan:(NSDate*)date;
-(BOOL) isEarlierThan:(NSDate*)date;
//- (BOOL)isEqualToDate:(NSDate *)date; already part of the NSDate API

@end