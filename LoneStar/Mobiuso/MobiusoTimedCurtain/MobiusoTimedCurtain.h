//
//  MobiusoHome.h
//  
//
//  Created by sandeep on 1/21/13.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//

#import <UIKit/UIKit.h>


//#import "MobiusoProgressDelegate.h"

#define TRACK_WIDTH 10.0f
#define TRACK_BASE  48.0f
#define TRACK_DOTTED_INSIDE 0
#define TRACK_DOTTED_OUTSIDE 0
#define TRACK_SHADOW 0

@protocol MobiusoTimedCurtainDelegate <NSObject>

@optional
- (void)dismissAction;  // Cancels the Time out process
- (void)performAction;  // Timeout progress complete, do what you need to (like, save or close)

@end

@interface MoSettingsButton : UIButton
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint nearPoint;
@property (nonatomic) CGPoint farPoint;
@property (nonatomic, retain) UIColor *anchorColor;
@property (nonatomic, retain) NSString *hint;
- (id)  initWithImage:(UIImage *)img
     highlightedImage:(UIImage *)himg
          anchorColor: (UIColor *) color;
@end

@interface MobiusoTimedCurtain : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, retain)   UIView *wallPaper;
@property (nonatomic, retain)   NSMutableArray *menuItems;
@property (nonatomic,retain)    NSArray *menuDataStructure;
@property (nonatomic,retain)    NSMutableArray *referenceDataStructure;
@property (nonatomic, retain)   id <MobiusoTimedCurtainDelegate> delegate;
@property (nonatomic, retain)   UIViewController *myController;
@property (nonatomic, retain)   NSMutableArray *progressItems;
@property (nonatomic, retain)   UIActivityIndicatorView *activity;
@property (nonatomic,assign)    UIGestureRecognizerState gestureState;
@property (nonatomic,strong)    NSTimer *timer;
@property (nonatomic,strong)    NSTimer *demoTimer;
@property (nonatomic, retain)   UITapGestureRecognizer *tapGesture;

@property (nonatomic,assign)    BOOL demoToExpand;
@property (nonatomic,assign)    CGFloat demoDelay;
@property (nonatomic, retain)   UIImageView *glyph;
@property (nonatomic, retain)   NSString *bgImageName;
@property (nonatomic, retain)   UILabel *countdown;
@property (nonatomic, retain)   UILabel *header;
@property (nonatomic, retain)   UILabel *footer;

//@property (nonatomic, retain) UILabel *             toolbarTitleView;

@property (nonatomic,strong) NSTimer *              singleTouchTimer;

- (id)initWithFrame:(CGRect)frame delegate: (id <MobiusoTimedCurtainDelegate> ) del;
- (void) showProgress: (CGFloat) percent item: (NSInteger) itemId;
- (BOOL) hideProgress: (NSInteger) itemId;
- (void) showActivity;
- (void) hideActivity;
- (void) showSpinner: (BOOL) show;
- (void) reload: (CGRect) frame;

@end
