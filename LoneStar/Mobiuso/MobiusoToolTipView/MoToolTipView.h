//
//  MoTooltipView.h
//
//  Created by Sandeep Shah 03/12/2015
//  - inspired by Chris Miles' CMPopup bubbles implementation
//

/** Display a Tooltip on the screen, pointing at the
			designated view or button.
 
	A UIView subclass drawn using core graphics. Pops up (optionally animated)
	a speech bubble-like view on screen, a rounded rectangle with a gradiant
	fill containing a specified text message, drawn with a pointer dynamically
	positioned to point at the center of the designated button or view.
 
 Usage 1:::
    point at a UIBarButtonItem in a nav bar:
 
	- (void)showToolTip {
		NSString *message = @"Start by adding a waterway to your favourites.";
		MoToolTipView *toolTipView = [[CMPopTipView alloc] initWithMessage:message];
		toolTipView = self;
		[toolTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
		
		self.myPopTipView = popTipView;
	}

	- (void)dismissToolTip {
		[self.myToolTipView dismissAnimated:NO];
		self.myToolTipView = nil;
	}

 
	#pragma mark MoToolTipViewDelegate methods
	- (void)toolTipViewWasDismissed:(MoToolTipView *)popTipView {
		// User can tap MoToolTipView to dismiss it
		self.myToolTipView = nil;
	}

 Usage 2::: - pointing at a UIButton:

	- (IBAction)buttonAction:(id)sender {
		// Toggle popTipView when a standard UIButton is pressed
		if (nil == self.roundRectButtonPopTipView) {
			self.roundRectButtonPopTipView = [[[CMPopTipView alloc] initWithMessage:@"My message"] autorelease];
			self.roundRectButtonPopTipView.delegate = self;

			UIButton *button = (UIButton *)sender;
			[self.roundRectButtonPopTipView presentPointingAtView:button inView:self.view animated:YES];
		}
		else {
			// Dismiss
			[self.roundRectButtonPopTipView dismissAnimated:YES];
			self.roundRectButtonPopTipView = nil;
		}	
	}

	#pragma mark CMPopTipViewDelegate methods
	- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
		// User can tap CMPopTipView to dismiss it
		self.roundRectButtonPopTipView = nil;
	}
 
 */

#import <UIKit/UIKit.h>
#import "MoToolTip.h"

typedef enum {
	PointDirectionUp = 0,
	PointDirectionDown
} PointDirection;

typedef enum {
    CMPopTipAnimationSlide = 0,
    CMPopTipAnimationPop
} CMPopTipAnimation;


@protocol MoToolTipViewDelegate;


@interface MoToolTipView : UIView {
	UIColor					*backgroundColor;
	NSString				*message;
	id						targetObject;
	UIColor					*textColor;
	UIFont					*textFont;
    CMPopTipAnimation       animation;

	@private
	CGSize					bubbleSize;
	CGFloat					cornerRadius;
	BOOL					highlight;
	CGFloat					sidePadding;
	CGFloat					topMargin;
	PointDirection			pointDirection;
	CGFloat					pointerSize;
	CGPoint					targetPoint;
    CGFloat                 lineSlant;

    UIView                  *holeView;

}

@property (nonatomic, retain)			UIColor					*backgroundColor;
@property (nonatomic, assign)           id<MoToolTipViewDelegate>	delegate;
@property (nonatomic, assign)			BOOL					disableTapToDismiss;
@property (nonatomic, retain)			NSString				*message;
@property (nonatomic, retain)           UIView	                *customView;
@property (nonatomic, retain, readonly)	id						targetObject;
@property (nonatomic, retain)			UIColor					*textColor;
@property (nonatomic, retain)			UIFont					*textFont;
@property (nonatomic, assign)			NSTextAlignment			textAlignment;
@property (nonatomic, assign)           CMPopTipAnimation       animation;
@property (nonatomic, assign)           CGFloat                 maxWidth;
@property (nonatomic, retain)           NSString                *geometry;

@property (nonatomic, assign)           CGFloat                 origBorderWidth, origCornerRadius;
@property (nonatomic)                   CGColorRef              origBorderColor;

/* Contents can be either a message or a UIView */
- (id)initWithMessage:(NSString *)messageToShow;
- (id)initWithCustomView:(UIView *)aView;
- (instancetype) initWithTooltip: (MoToolTip *) tooltip;

- (void)presentPointingAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated;
- (void)presentPointingAtBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

- (PointDirection) getPointDirection;

+ (NSInteger) shouldRunTooltip: (NSString *) screenID;
+ (void) setShouldRunTooltip: (NSString *) screenID toolTipIndex: (NSInteger) index;
+ (MoToolTipView *) showInView: (UIView *) container withItem: (NSDictionary *) dict;;
+ (MoToolTipView *) showInView: (UIView *) container withTooltip: (MoToolTip *) tooltip;


@end


@protocol MoToolTipViewDelegate <NSObject>
- (void)  toolTipViewDismissed:(MoToolTipView *)toolTipView;
@end
