//
//  MoArcMenu.h
//  MoArcMenu
//
//  Created by sandeep on 01/10/13.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//
//  Updated 20150921
//

#import <UIKit/UIKit.h>
#import "MoArcMenuItem.h"
#import "MoArcBackground.h"
#import "UIImage+BlurredFrame.h"
#import "UIImage+ImageEffects.h"
#import "UIView+ScreenShot.h"

@protocol MoArcMenuDelegate;


typedef enum  {
    ArcMenuSpanLowerRight,
    ArcMenuSpanUpperLeft,
    ArcMenuSpanUpperRight,
    ArcMenuSpanLowerLeft,
    ArcMenuSpanRightSemiCircle,
    ArcMenuSpanLeftSemiCircle,
    ArcMenuSpanTopSemiCircle,
    ArcMenuSpanBottomSemiCircle,
    ArcMenuSpanTopThreeFourthCircle,
    ArcMenuSpanBottomThreeFourthCircle

} ArcMenuPosition;


#define GLOWVIEW_TAG 9988

@interface MoArcMenu : UIView <MoArcMenuItemDelegate>

@property (nonatomic, copy) NSArray *menusArray;
@property (nonatomic, getter = isExpanding) BOOL expanding;
@property (nonatomic, assign) id<MoArcMenuDelegate> delegate;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *highlightedImage;
@property (nonatomic, retain) UIImage *contentImage;
@property (nonatomic, retain) UIImage *highlightedContentImage;
@property (nonatomic, retain) MoArcBackground *shim;
@property (nonatomic, retain) UIView *blur;
@property (nonatomic, retain) UIView *underlyingView;


@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat timeOffset;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;
@property (nonatomic, assign) CGFloat expandRotation;
@property (nonatomic, assign) CGFloat closeRotation;
@property (nonatomic, retain) UIColor *anchorColor;
@property (nonatomic, assign) int selectedIndex;
@property (nonatomic, assign) CGFloat repeatCount;
@property (nonatomic, assign) BOOL useSelectedMenuItemAsAnchor;
@property (nonatomic, assign) CGPoint gravity;
@property (nonatomic, retain) MobiusoToast *menuHint;

- (id) initWithFrame:(CGRect)frame menus: (NSArray *) aMenusArray position: (ArcMenuPosition) position anchor: (UIImage *) anchorImage anchorHighlighted: (UIImage *) anchorHighlightedImage animationRepeatCount: (CGFloat) count anchorAnimation: (BOOL) shouldAnimate selectedMenuItemAsAnchor: (BOOL) anchorType centerButtonDiameter: (CGFloat) diameter;

- (id) initWithFrame:(CGRect)frame menus: (NSArray *) aMenusArray position: (ArcMenuPosition) position anchor: (UIImage *) anchorImage anchorHighlighted: (UIImage *) anchorHighlightedImage animationRepeatCount: (CGFloat) count anchorAnimation: (BOOL) shouldAnimate selectedMenuItemAsAnchor: (BOOL) anchorType centerButtonDiameter: (CGFloat) diameter withBlurView: (UIView *) view;

- (void) MoArcMenuItemTouchesBegan:(MoArcMenuItem *)item;
- (void) MoArcMenuItemTouchesEnd:(MoArcMenuItem *)item;
- (void) animateAnchor;

- (void) animateMenuOpen;
- (void) animateMenuClose;

// Set up the Demo to expand or contract
- (void) animateDemo;

- (void) setBlurWithView: (UIView *) view;
- (void) setBlurView: (UIView *) view;

- (MoArcMenuItem *) tapButton;

@end

@protocol MoArcMenuDelegate <NSObject>

@optional
- (void) MoArcMenu:(MoArcMenu *)menu didSelectIndex:(NSInteger)idx;
- (void) MoArcMenuFired:(MoArcMenu *)menu;
- (void) MoArcMenuDismissed:(MoArcMenu *)menu;

@end