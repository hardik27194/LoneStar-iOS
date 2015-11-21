//
//  MobiusoActionView
//  MobiusoActionView
//
//  Created by sandeep on 12/20/14.
//  Updated 08/23/2015
//  Copyright (c) 2014 Sandeep. All rights reserved.
//  Updated 9/9/2015
//


#import <Foundation/Foundation.h>
#import "Animator.h"
#import "MoSpringAnimation.h"

#define MOACTION_TITLE_HEIGHT            32
#define BUTTON_HEIGHT           40
#define TEXT_MARGIN             60
#define BUTTON_TAG_BASE         9900
#define BUTTON_TITLE_TAG_BASE   9950


@class MobiusoActionView;

typedef NS_ENUM(NSInteger, PaneState) {
    PaneStateOpen,
    PaneStateClosed,
};

@protocol MobiusoActionViewDelegate


@optional
- (void) dismissActionView;
// if input is not expected then the inputStr will be nil
- (void) dismissWithClickedButtonIndex: (NSInteger) buttonIndex withText: (NSString *) inputStr;
// The delegate must know which is the current ActionView in 'action'
- (void) setCurrentActionViewId: (NSInteger) referenceTag;


// check if needed
#ifdef NOTNOW
- (void)actionView:(MobiusoActionView *)view draggingEndedWithVelocity:(CGPoint)velocity;
- (void)actionViewBeganDragging:(MobiusoActionView *)view;
#endif

@end

typedef void (^ActionCompletionBlock)(MobiusoActionView *actionView, NSInteger buttonIndex, NSString *inputTxt);


@interface MobiusoActionView : UIView <MoSpringAnimationDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    
    
}

@property (nonatomic, assign) id currentResponder;

@property (nonatomic, weak) id <MobiusoActionViewDelegate> delegate;
@property (nonatomic, retain)  UIView      *pane;
@property (nonatomic, retain)  UIView      *shadedView;


@property (nonatomic, retain) NSMutableArray *buttonArray;
@property (nonatomic, retain) NSString *messageStr;
@property (nonatomic, retain) NSString *actionTitle;
@property (nonatomic, retain) NSString *placeholderText;
@property (nonatomic, retain) NSArray  *popupArray;
@property (nonatomic, assign) BOOL     secureTextEntry;

@property (nonatomic, retain) UIColor *paneColor;
@property (nonatomic, retain) UIColor *buttonTextColor;

@property (nonatomic) MoSpringAnimation *springAnimation;

- (id) initWithTitle: (NSString *) title
            delegate: (id<MobiusoActionViewDelegate>) delegate
          andMessage: (NSString *) message
     placeholderText: (NSString *) suggestion
   cancelButtonTitle: (NSString *) cancelButtonTitle
   otherButtonTitles: (NSArray *) buttonTitleArray
               color: (UIColor *) color;

- (id) initWithTitle: (NSString *) title
            delegate: (id<MobiusoActionViewDelegate>) delegate
          andMessage: (NSString *) message
     placeholderText: (NSString *) suggestion
   cancelButtonTitle: (NSString *) cancelButtonTitle
   otherButtonTitles: (NSArray *) buttonTitleArray
               color: (UIColor *) color
               frame: (CGRect) frame;


- (void) show;  // Shows the view with animation
- (void) showWithCompletionBlock: (void (^)(MobiusoActionView *actionView, NSInteger buttonIndex, NSString *inputTxt)) block;
- (void) didTap:(UITapGestureRecognizer *)tapRecognizer;
- (void) refresh;

//- (void) setTextColor:(UIColor *)color;

@end