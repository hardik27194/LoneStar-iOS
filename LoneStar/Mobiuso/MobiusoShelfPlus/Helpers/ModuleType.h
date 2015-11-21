//
//  Conference.h
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ModuleType : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSDate* startDate;
@property (nonatomic, assign, readonly) NSUInteger durationDays;
@property (nonatomic, strong, readonly) NSMutableArray *shelfItems;

- (id)initWithName:(NSString *)name publicationDate:(NSDate *)startDate author:(NSUInteger)durationDays modules:(NSArray *)speakers;

// sort using custom comparator
- (id)initWithName:(NSString *)name publicationDate:(NSDate *)startDate author:(NSUInteger)durationDays modules:(NSArray *)shelfItems sortComparator: (NSComparator) comparator;


+ (ModuleType *)moduleWithName:(NSString *)name publicationDate:(NSDate *)startDate author:(NSUInteger)durationDays modules:(NSArray *)shelfItems;
+ (ModuleType *)moduleWithName:(NSString *)name publicationDate:(NSDate *)startDate author:(NSUInteger)durationDays modules:(NSArray *)shelfItems sortComparator: (NSComparator) comparator;

- (BOOL)deleteSpeakerAtIndex:(NSUInteger)index;
- (BOOL)restoreSpeaker;

@end
