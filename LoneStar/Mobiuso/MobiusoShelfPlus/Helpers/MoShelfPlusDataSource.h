//
//  CocoaConf.h
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StacksLayout.h"
#import "Snaptica_Pro-Swift.h"
#import "MoProgressView.h"
#import "MoRippleTap.h"
#import "MoShelfPlusStickyHeader.h"

#define kShelfSectionHeaderID       @"ConferenceHeader" // Kept for historical reasons... ToDo
#define kShelfSectionHeaderSmallID  @"ConferenceHeaderSmall"
#define kShelfItemCellID            @"ShelfItemCell"
#define kStarRatingFooterID         @"StarRatingFooter"
#define kCalendarItemCellID         @"CalendarItemCell"
#define kUserItemCellID             @"UserItemCell"


@protocol MoShelfPlusSelectionDelegate <NSObject>

@property (nonatomic, retain) MoRippleTap *selectButton;
@property (nonatomic, retain) id          itemReference;

@end

@protocol MoShelfPlusDataSourceDelegate <NSObject>

@optional
- (NSArray *) dataSources;
- (void) reload;
- (void) setSwitchControl: (ADVSegmentedControl *) segmentControl;
- (void) cellWillAppear: (UICollectionViewCell <MoShelfPlusSelectionDelegate> *) cell atIndexPath: (NSIndexPath *) indexPath;

@property  (nonatomic, retain) MoProgressView           *hud;
@property  (nonatomic, retain) MoShelfPlusStickyHeader             *stickyHeaderCell;

@end

@interface MoShelfPlusDataSource : NSObject<UICollectionViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *shelfItemsBySections;
@property  (nonatomic, retain) NSMutableArray           *filteredIndexArray;

// Returns a list of sections containing Shelf Items
//+ (instancetype)combined;
+ (instancetype)all;
+ (instancetype)instance;

//+ (instancetype)currentModuleType;
//+ (instancetype)recent;

+ (NSString *)smallHeaderReuseID;


- (void) refresh;
+ (void) purge;     // clean up

// Each Section is a type.  For each type (section), there will be one or more "modules" or items which is a basic unit
- (id)initWithShelfItemsBySections: (NSArray *)arrayOfSectionDictionary;
- (BOOL)deleteModuleAtPath: (NSIndexPath *)indexPath;
- (BOOL)restoreModuleInSection: (int)section;
- (NSDictionary *) itemAtIndexPath: (NSIndexPath *) indexPath;
- (NSDictionary *) itemAtSection: (NSUInteger) section andRow: (NSUInteger) row;
- (void) replaceItemAtIndexPath: (NSIndexPath *) indexPath withObject: (NSDictionary *) item;


// All Module Count 
- (NSInteger) count;

// This Data Manager Title
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *shortTitle;

// ViewController asssociated with this
@property (nonatomic, retain) UIViewController <MoShelfPlusDataSourceDelegate> *viewController;



@end
