//
//  MobiusoBubblePopup.h
//  ShshDox
//
//  Created by sandeep on 7/13/14.
//  Copyright (c) 2014 Dropbox, Inc. All rights reserved.
//  Updated by Sandeep on 10/16/15 to add cleanup call
//

#import <UIKit/UIKit.h>

typedef enum  {
    MBOrientationTop = 1,   // top center
    MBOrientationLeft,  // middle left
    MBOrientationRight,  // middle right
    MBOrientationBottom, // bottom center
    MBOrientationSouthWest, // bottom towards left
    MBOrientationSouthEast, // bottom towards right
    MBOrientationNorthWest, // top towards right
    MBOrientationNorthEast, // top towards right
} MBOrientationType;

//#define TITLE_HEIGHT    36
//#define TITLE_HEIGHT_IPAD    60
#define SCROLL_HINT_ICON_SIZE   24

@protocol MobiusoBubblePopupDelegate <NSObject>

@optional

/**
 *  Called when the user starts swiping the cell.
 *
 *  @param cell `MoSwipeTableViewCell` currently swiped.
 */
- (void)didTapBubblePopup;
- (void)willCloseBubblePopup;

@end

@interface MobiusoBubblePopup : UIView

@property(nonatomic, retain) id <MobiusoBubblePopupDelegate>    delegate;

@property (nonatomic,assign) MBOrientationType                  touchOrientation;

@property (nonatomic,assign) CGFloat                            duration;

- (void) showMessage: (NSString *) messageStr withTitle: (NSString *) title;
- (void) showMessage: (NSString *) messageStr withTitle: (NSString *) title andSubtitle: (NSString *)subTitle;
- (void) showMessage: (NSString *) messageStr withTitle: (NSString *) title andSubtitle: (NSString *)subTitle andIcon: (UIImage *) icon;

- (id)initWithFrame:(CGRect)frame withOrientation: (MBOrientationType) type andDuration: (CGFloat) duration;

@end
