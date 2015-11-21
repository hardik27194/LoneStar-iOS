//
//  CSAlwaysOnTopHeader.h
//
//

#import "MoEmptyCell.h"
#import "Snaptica_Pro-Swift.h"

@class MoShelfPlusStickyHeader;

@protocol MoShelfPlusStickyHeaderDelegate <NSObject>

- (void) infoButtonPressed: (id) sender;
- (void) searchButtonPressed: (id) sender;
@optional
- (void) selectorControlTapped: (id) sender;

@property  (nonatomic, retain) MoShelfPlusStickyHeader  *stickyHeaderCell;

@end

@interface MoShelfPlusStickyHeader : MoEmptyCell

+ (NSString *)kind;
+ (CGFloat) maxHeight;
+ (CGFloat) minHeight;


@property (retain, nonatomic) IBOutlet UIImageView *bkg;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UIButton *prominentButton;
@property (retain, nonatomic) IBOutlet UILabel *supplementaryInfoLabel;
@property (retain, nonatomic) IBOutlet UILabel *supplementaryInfoLabel2;
@property (retain, nonatomic) IBOutlet ADVSegmentedControl *selectorControl;
@property (retain, nonatomic) IBOutlet UIButton *infoButton;
@property (retain, nonatomic) IBOutlet UIButton *searchButton;
@property (retain, nonatomic) IBOutlet UIButton *selectorButton;

@property (retain, nonatomic) NSObject <MoShelfPlusStickyHeaderDelegate> *delegate;


@end
