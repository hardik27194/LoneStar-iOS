//
//  MobiusoShelfPlusViewController.h
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snaptica Pro-Bridging-Header.h"
#import "Snaptica_Pro-Swift.h"
#import "MoShelfPlusDataSource.h"
#import "MoShelfPlusStickyHeader.h"
#import "MobiusoBubblePopup.h"
#import "MoProgressView.h"

enum {
    ShelfLayoutGrid,
    ShelfLayoutLine,
    ShelfLayoutCoverFlow,
    ShelfLayoutStacks,
    ShelfLayoutSpiral,
    
    ShelfLayoutCount
} typedef ShelfLayout;

@class MoShelfPlusViewController;

@protocol MoShelfPlusViewControllerDelegate <NSObject>

@optional
// If the action is handled then return TRUE - in which case the viewController will not do anything further...
- (BOOL) shelfPlusController:(MoShelfPlusViewController *) viewController  didSelectItemAtPath: (NSIndexPath *) indexPath;

// Dismissing the view Controller
- (void) dismissedShelfPlusController:(MoShelfPlusViewController *) viewController;

// Return - title, image and action 
- (NSArray *) actionMenuItems;

@end




#define SEGMENT_CONTROL_TAG 7777

@interface MoShelfPlusViewController : UICollectionViewController <UICollectionViewDelegate, MoShelfPlusDataSourceDelegate, MoShelfPlusStickyHeaderDelegate, MobiusoBubblePopupDelegate>

@property (nonatomic, assign, readonly) ShelfLayout     layoutStyle;

@property  (nonatomic, retain) IBOutlet UIButton        *closeButton;

@property  (nonatomic, retain) NSString                 *helpInformation;

// Customization
@property  (nonatomic, retain) NSArray                  *dataSources;
@property  (nonatomic, retain) NSObject                 <MoShelfPlusViewControllerDelegate> *delegate;

@property  (nonatomic, retain) UIImage                  *background;
@property  (nonatomic, retain) MoShelfPlusStickyHeader  *stickyHeaderCell;
@property  (nonatomic, retain) MoProgressView           *hud;


-(IBAction) closeBtnClick:(id)sender;
- (NSUInteger) switchCount;
- (void) setupDataSourceAtIndex: (NSUInteger) dataSourceIndex;
- (void) reload;

@end
