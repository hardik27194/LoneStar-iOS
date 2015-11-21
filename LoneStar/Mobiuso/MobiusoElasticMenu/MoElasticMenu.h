//
//  MoElasticMenu.h
//  MoElasticMenu
//
//  Based on Harvindar WaveToolbar (WaveCustomView) design - modified by Sandeep Dec 2013.
//  Copyright 2012-2014 Mobiuso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+StringSizeWithFont.h"

typedef enum  {
    EMOrientationTop = 1,   // top center
    EMOrientationLeft,  // middle left
    EMOrientationRight,  // middle right
    EMOrientationBottom, // bottom center
} EMOrientationType;

// Front and Behind refers to how the 'fold' of the strip is viewed when the strip is unfolded
// to show more items 'front' means the unfolded more icons appear to be in the 'front' in z-order
// and 'back' means they appear to be set in the 'back' in the z-order
typedef enum  {
    EMDirectionHorizontalFront = 0,   // default is left to right
    EMDirectionHorizontalBehind,
    EMDirectionVerticalFront,  // top to bottom
    EMDirectionVerticalBehind
} EMDirectionType;

#define stripHorizontal(xyz)  ((xyz == EMDirectionHorizontalFront) || (xyz == EMDirectionHorizontalBehind))
#define stripVertical(xyz)    ((xyz == EMDirectionVerticalFront) || (xyz == EMDirectionVerticalBehind))

#define TOUCH_WINDOW_DIMENSION  16      // the starting area that is active (if not supplied)
#define MAXMENUITEMWIDTH        42      // maximum (or optimum) icon size - width
#define MAXMENUITEMHEIGHT       42      // maximum (or optimum) icon size - height
#define MINMENUITEMWIDTH        36      // min icon size we would like to see - width
#define MINMENUITEMHEIGHT       36      // min icon size we would like to see - height
#define MINMENUITEMMARGIN       6       // margin between the menu items
#define MARGIN                  6       // left and right of the menu strip
#define FONTSIZE                16      // For the bubble text
#define MAXTOTALWIDTH           360     // Not used anymore
#define ELASTIC_MENU_MARGIN     10      // above and below the icon boundaries
#define ELASTIC_MENU_DELTA      30      // above the finger (for the strip to be visible)
#define ELASTIC_MENU_BUBBLE_GAP 5       // Above the top part of the menu strip

#define REDZONEOFFSET           60      // From the bottom edge, the area where we cancel the menu
#define ORANGEZONEOFFSET        40      // When second layer (overflow) is active, the size
#define MOVE_THRESHOLD          10      // how much is considered too much movement
#define SECONDLAYER_OFFSET      20      // How much is the strip displacement on overflow
#define SECONDLAYER_OVERLAP     0.20f   // % of the size of icon width that seems to overlap in overflow
#define SECONDLAYER_POPUP_DELAY 1.2f    // How much to wait before popping the layer on "more" item
#define MENUSTRIP_CORNER_RADIUS 6.0f    // corner rounding for the menu

#define SLIDEOUT_ANIMATION_DURATION 2.0f    // animation for the strip to drop off
#define DEFAULT_DEMO_DELAY          5.0f    // if in 5 seconds the user does not do anything, fire up the demo

#define BASELAYER_INACTIVE_OPACITY  0.4f
#define BASELAYER_ACTIVE_OPACITY    0.80f

#ifndef RADIANS
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#endif

#ifndef IS_IOS7
#define IS_IOS7 ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1))
#endif


@class CAShapeLayer;
@class CATextLayer;


@protocol MoElasticMenuDelegate

- (NSInteger)   menuItemCount;
- (id)          menuItemImageForIndex: (NSInteger) index;
- (id)          menuItemHighlightImageForIndex: (NSInteger) index;
- (NSString *)  menuItemTitleForIndex: (NSInteger) index;
- (void)        didSelectMenuItem: (NSInteger) index;

@optional
- (void)        didFireDemoHelp;

// If the parent view needs any adjustments during the elastic Menu
- (void)        menuTouchesBegan: (NSSet *) touches withEvent: (UIEvent *)event;
- (void)        menuTouchesEnded: (NSSet *) touches withEvent: (UIEvent *)event;


@end

@interface MoElasticMenuItem : NSObject

@property (nonatomic,assign) NSString       *menuTitle;
@property (nonatomic,assign) NSString       *menuImageName;
@property (nonatomic,assign) NSString       *menuHighlightImageName;
@property (nonatomic,assign) UIImage        *defaultImage;
@property (nonatomic,assign) BOOL           shouldVisible;
@property (nonatomic,assign) SEL            action;
@property (nonatomic,assign) id             target;
@property (nonatomic,assign) NSInteger      virtualIndex;

@end

@interface MoElasticMenu : UIView

@property (nonatomic,assign)NSTimeInterval  lastTouchTimestamp;
@property (nonatomic,assign)CGPoint         lastTouchPoint;
@property (nonatomic,assign)CGPoint         secondLayerThreshold;
@property (nonatomic,assign)int             menuItemCount;
@property (nonatomic,assign)NSInteger       menuItemWithMarginWidth;
@property (nonatomic,retain)NSMutableArray  *menuItemLayersArray;
@property (nonatomic,retain)NSMutableArray  *menuItemHighlightedLayersArray;
@property (nonatomic,retain)NSMutableArray  *menuItemNamesArray;
@property (nonatomic,assign)CALayer         *moreLayer;
@property (nonatomic,assign)CALayer         *moreHighlightLayer;
@property (nonatomic,retain)NSString        *moreHintName;
@property (nonatomic,retain)CALayer         *lessLayer;
@property (nonatomic,retain)CALayer         *lessHighlightLayer;
@property (nonatomic,retain)NSString        *lessHintName;


@property (nonatomic,assign)NSInteger       menuItemWidth;
@property (nonatomic,assign)NSInteger       menuItemHeight;
@property (nonatomic,assign)CGFloat         menuStartXOrY;
@property (nonatomic,assign)CGFloat         menu2StartXOrY;
@property (nonatomic,assign)CGFloat         menuTotalWidthOrHeight;
@property (nonatomic,assign)CGFloat         menu2TotalWidthOrHeight;
@property (nonatomic,assign)int             maxMenuCount;
@property (nonatomic,retain)CALayer         *secondLayerHintLayer;
@property (nonatomic,retain)CALayer         *secondLayerHintHighlightLayer;


@property (nonatomic,assign)NSInteger       currentIndex;
@property (nonatomic,assign) BOOL           isActive;
@property (nonatomic,assign) BOOL           secondLayerActive;
@property (nonatomic,assign) BOOL           hasMoreItems;
@property (nonatomic,assign) BOOL           inAnimation;
@property (nonatomic,assign) BOOL           quickSingleTap;
@property (nonatomic, retain) NSTimer       *singleTapTimer;

@property (nonatomic,retain) CAShapeLayer   *firstLayer;
@property (nonatomic,retain) CAShapeLayer   *secondLayer;
@property (nonatomic,retain) CAShapeLayer   *shimLayer;
@property (nonatomic,retain) CALayer        *bubbleLayer;
@property (nonatomic,retain) CATextLayer    *bubbleTextLayer;
@property (nonatomic,retain) UIFont         *font;
@property (nonatomic,retain) CALayer        *fullLayer;
@property (nonatomic,retain) CALayer        *instructionsImageLayer;
@property (nonatomic,retain) CALayer        *baseLayer;
@property (nonatomic,retain) CAShapeLayer   *hintLayer;
@property (nonatomic,retain) CATextLayer    *hint2Layer;
@property (nonatomic,assign) CGRect         baseFrame;
@property (nonatomic,assign) CGRect         fullFrame;
@property (nonatomic,assign) EMOrientationType      touchOrientation;
@property (nonatomic,assign) EMDirectionType        stripDirection;
@property (nonatomic, retain) NSTimer       *moreChoicesTimer;
@property (nonatomic, retain) NSTimer       *demoTimer;
@property (nonatomic, retain) NSString      *demoHelpMessage;
@property (nonatomic, assign) CGFloat       demoDelay;
@property (nonatomic, assign) BOOL          demoAnimation;
@property (nonatomic, retain) UIButton      *popMessageButton;


@property(assign) NSObject <MoElasticMenuDelegate> *delegate;
@property (nonatomic,retain) NSArray        *menuItems;

@property (nonatomic, retain) UIImageView   *elasticMenuPopImage;    // sandeep

- (id)initWithFrame:(CGRect)frame stripDirection: (EMDirectionType) direction  withMenuItems:(NSArray *)menuItemsArray;
- (id)initWithFullFrame:(CGRect)fullFrame touchDirection: (EMOrientationType) orient stripDirection: (EMDirectionType) direction  withMenuItems:(NSArray *)menuItemsArray;
- (id)initWithFullFrame:(CGRect)frame touchDirection: (EMOrientationType) orient stripDirection: (EMDirectionType) direction withDelegate:(id <MoElasticMenuDelegate>)del;
- (id)initWithFrame:(CGRect)frame touchDirection: (EMOrientationType) orient stripDirection: (EMDirectionType) direction withDelegate:(id <MoElasticMenuDelegate>)del;
- (void) performDemo: (CGFloat) initialDelayTime;
@end
