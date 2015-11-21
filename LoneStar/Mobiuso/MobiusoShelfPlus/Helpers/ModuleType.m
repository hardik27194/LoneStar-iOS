//
//  Conference.m
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "ModuleType.h"

@interface ModuleType()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDate* startDate;
@property (nonatomic, assign) NSUInteger durationDays;  // THis does not have any significance -
@property (nonatomic, strong) NSMutableArray *shelfItems;
@property (nonatomic, strong) NSMutableArray *deletedSpeakers;

@end

@implementation ModuleType

- (id)initWithName:(NSString *)name publicationDate:(NSDate *)startDate author:(NSUInteger)durationDays modules:(NSArray *)shelfItems
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _startDate = [startDate copy];
        _durationDays = durationDays;
        _shelfItems = [[shelfItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *nameObj1 = [obj1 objectForKey:@"name"];
            NSString *nameObj2 = [obj2 objectForKey:@"name"];
            return [nameObj1 caseInsensitiveCompare:nameObj2];
        }] mutableCopy];
        _deletedSpeakers = [NSMutableArray array];
    }
    return self;
}

- (id)initWithName:(NSString *)name publicationDate:(NSDate *)startDate author:(NSUInteger)durationDays modules:(NSArray *)shelfItems sortComparator: (NSComparator) comparator
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _startDate = [startDate copy];
        _durationDays = durationDays;
        _shelfItems = (comparator? [[shelfItems sortedArrayUsingComparator: comparator] mutableCopy] : shelfItems);
        _deletedSpeakers = [NSMutableArray array];
    }
    return self;
}

+ (ModuleType *)moduleWithName:(NSString *)name publicationDate:(NSDate *)startDate author:(NSUInteger)durationDays modules:(NSArray *)shelfItems
{
    return [[ModuleType alloc] initWithName:name publicationDate:startDate author:durationDays modules:shelfItems];
}
+ (ModuleType *)moduleWithName:(NSString *)name publicationDate:(NSDate *)startDate author:(NSUInteger)durationDays modules:(NSArray *)shelfItems sortComparator: (NSComparator) comparator
{
    return [[ModuleType alloc] initWithName:name publicationDate:startDate author:durationDays modules:shelfItems sortComparator:comparator];
}

- (BOOL)deleteSpeakerAtIndex:(NSUInteger)index
{
    if (index >= self.shelfItems.count)
        return NO;
    
    [self.deletedSpeakers addObject:self.shelfItems[index]];
    [self.shelfItems removeObjectAtIndex:index];
    
    return YES;
}

- (BOOL)restoreSpeaker
{
    if (self.deletedSpeakers.count == 0)
        return NO;

    [self.shelfItems addObject:self.deletedSpeakers[0]];    
    [self.deletedSpeakers removeObjectAtIndex:0];

    return YES;
}


@end
