//
//  MoImageViewController.h
//
//
//

@import UIKit;

#import "MoImageInfo.h"
#import "Configs.h"

///--------------------------------------------------------------------------------------------------------------------
/// Definitions
///--------------------------------------------------------------------------------------------------------------------

@protocol MoImageViewControllerDismissalDelegate;
@protocol MoImageViewControllerOptionsDelegate;
@protocol MoImageViewControllerInteractionsDelegate;
@protocol MoImageViewControllerAccessibilityDelegate;
@protocol MoImageViewControllerAnimationDelegate;

typedef NS_ENUM(NSInteger, MoImageViewControllerMode) {
    MoImageViewControllerMode_Image,
    MoImageViewControllerMode_AltText,
};

typedef NS_ENUM(NSInteger, MoImageViewControllerTransition) {
    MoImageViewControllerTransition_FromOriginalPosition,
    MoImageViewControllerTransition_FromOffscreen,
};

typedef NS_OPTIONS(NSInteger, MoImageViewControllerBackgroundOptions) {
    MoImageViewControllerBackgroundOption_None = 0,
    MoImageViewControllerBackgroundOption_Scaled = 1 << 0,
    MoImageViewControllerBackgroundOption_Blurred = 1 << 1,
};

extern CGFloat const MoImageViewController_DefaultAlphaForBackgroundDimmingOverlay;
extern CGFloat const MoImageViewController_DefaultBackgroundBlurRadius;

///--------------------------------------------------------------------------------------------------------------------
/// JTSImageViewController
///--------------------------------------------------------------------------------------------------------------------

@interface MoImageViewController : UIViewController

@property (strong, nonatomic, readonly) MoImageInfo *imageInfo;

@property (strong, nonatomic, readonly) UIImage *image;

@property (assign, nonatomic, readonly) MoImageViewControllerMode mode;

@property (assign, nonatomic, readonly) MoImageViewControllerBackgroundOptions backgroundOptions;

@property (weak, nonatomic, readwrite) id <MoImageViewControllerDismissalDelegate> dismissalDelegate;

@property (weak, nonatomic, readwrite) id <MoImageViewControllerOptionsDelegate> optionsDelegate;

@property (weak, nonatomic, readwrite) id <MoImageViewControllerInteractionsDelegate> interactionsDelegate;

@property (weak, nonatomic, readwrite) id <MoImageViewControllerAccessibilityDelegate> accessibilityDelegate;

@property (weak, nonatomic, readwrite) id <MoImageViewControllerAnimationDelegate> animationDelegate;

// Gesture Recognizers
@property (strong, nonatomic) UITapGestureRecognizer *singleTapperPhoto;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapperPhoto;
@property (strong, nonatomic) UITapGestureRecognizer *singleTapperText;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPresserPhoto;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;

// Image to be locked
@property (nonatomic, assign) BOOL  imageLocked;

/**
 Designated initializer.
 
 @param imageInfo The source info for image and transition metadata. Required.
 
 @param mode The mode to be used. (JTSImageViewController has an alternate alt text mode). Required.
 
 @param backgroundStyle Currently, either scaled-and-dimmed, or scaled-dimmed-and-blurred. 
 The latter is like Tweetbot 3.0's background style.
 */
- (instancetype)initWithImageInfo:(MoImageInfo *)imageInfo
                             mode:(MoImageViewControllerMode)mode
                  backgroundStyle:(MoImageViewControllerBackgroundOptions)backgroundOptions;

/**
 JTSImageViewController is presented from viewController as a UIKit modal view controller.
 
 It's first presented as a full-screen modal *without* animation. At this stage the view controller
 is merely displaying a snapshot of viewController's topmost parentViewController's view.
 
 Next, there is an animated transition to a full-screen image viewer.
 */
- (void)showFromViewController:(UIViewController *)viewController
                    transition:(MoImageViewControllerTransition)transition;

/**
 Dismisses the image viewer. Must not be called while previous presentation or dismissal is still in flight.
 */
- (void)dismiss:(BOOL)animated;

// Updates the image viewer with the new image

- (void)updateInterfaceWithImage:(UIImage *)image;

@end

///--------------------------------------------------------------------------------------------------------------------
/// Dismissal Delegate
///--------------------------------------------------------------------------------------------------------------------

@protocol MoImageViewControllerDismissalDelegate <NSObject>

/**
 Called after the image viewer has finished dismissing.
 */
- (void)imageViewerDidDismiss:(MoImageViewController *)imageViewer;
#ifdef IMAGEEDITOR_HANDOFF_TO_HOMEVIEW
- (BOOL) imageViewerWillDismissForEdit: (MoImageViewController *)imageViewer withImage: (UIImage *) image;
#endif

@optional
/**
 serve up next image if available
 */
- (BOOL) imageViewController: (MoImageViewController *)imageViewer nextImage: (NSInteger) markerIndex;
/**
 serve up previous image if available
 */

- (BOOL) imageViewController: (MoImageViewController *)imageViewer previousImage: (NSInteger) markerIndex;

@end

///--------------------------------------------------------------------------------------------------------------------
/// Options Delegate
///--------------------------------------------------------------------------------------------------------------------

@protocol MoImageViewControllerOptionsDelegate <NSObject>
@optional

/**
 Return YES if you want the image thumbnail to fade to/from zero during presentation
 and dismissal animations.
 
 This may be helpful if the reference image in your presenting view controller has been
 dimmed, such as for a dark mode. JTSImageViewController otherwise presents the animated 
 image view at full opacity, which can look jarring.
 */
- (BOOL)imageViewerShouldFadeThumbnailsDuringPresentationAndDismissal:(MoImageViewController *)imageViewer;

/**
 The font used in the alt text mode's text view.
 
 This method is only used with `MoImageViewControllerMode_AltText`.
 */
- (UIFont *)fontForAltTextInImageViewer:(MoImageViewController *)imageViewer;

/**
 The tint color applied to tappable text and selection controls.
 
 This method is only used with `MoImageViewControllerMode_AltText`.
 */
- (UIColor *)accentColorForAltTextInImageViewer:(MoImageViewController *)imageView;

/**
 The background color of the image view itself, not to be confused with the background
 color for the view controller's view. 
 
 You may wish to override this method if displaying an image with dark content on an 
 otherwise clear background color (such as images from the XKCD What If? site).
 
 The default color is `[UIColor clearColor]`.
 */
- (UIColor *)backgroundColorImageViewInImageViewer:(MoImageViewController *)imageViewer;

/**
 Defaults to `JTSImageViewController_DefaultAlphaForBackgroundDimmingOverlay`.
 */
- (CGFloat)alphaForBackgroundDimmingOverlayInImageViewer:(MoImageViewController *)imageViewer;

/**
 Used with a JTSImageViewControllerBackgroundStyle_ScaledDimmedBlurred background style.
 
 Defaults to `JTSImageViewController_DefaultBackgroundBlurRadius`. The larger the radius,
 the more profound the blur effect. Larger radii may lead to decreased performance on
 older devices. To offset this, JTSImageViewController applies the blur effect to a
 scaled-down snapshot of the background view.
 */
- (CGFloat)backgroundBlurRadiusForImageViewer:(MoImageViewController *)imageViewer;

@end

///--------------------------------------------------------------------------------------------------------------------
/// Interactions Delegate
///--------------------------------------------------------------------------------------------------------------------

@protocol MoImageViewControllerInteractionsDelegate <NSObject>
@optional

/**
 Called when the image viewer detects a long press.
 */
- (void)imageViewerDidLongPress:(MoImageViewController *)imageViewer atRect:(CGRect)rect;

/**
 Called when the image viewer is deciding whether to respond to user interactions.
 
 You may need to return NO if you are presenting custom, temporary UI on top of the image viewer. 
 This method is called more than once. Returning NO does not "lock" the image viewer.
 */
- (BOOL)imageViewerShouldTemporarilyIgnoreTouches:(MoImageViewController *)imageViewer;

/**
 Called when the image viewer is deciding whether to display the Menu Controller, to allow the user to copy the image to the general pasteboard.
 */
- (BOOL)imageViewerAllowCopyToPasteboard:(MoImageViewController *)imageViewer;

@end

///--------------------------------------------------------------------------------------------------------------------
/// Accessibility Delegate
///--------------------------------------------------------------------------------------------------------------------


@protocol MoImageViewControllerAccessibilityDelegate <NSObject>
@optional

- (NSString *)accessibilityLabelForImageViewer:(MoImageViewController *)imageViewer;

- (NSString *)accessibilityHintZoomedInForImageViewer:(MoImageViewController *)imageViewer;

- (NSString *)accessibilityHintZoomedOutForImageViewer:(MoImageViewController *)imageViewer;

@end

///---------------------------------------------------------------------------------------------------
/// Animation Delegate
///---------------------------------------------------------------------------------------------------

@protocol MoImageViewControllerAnimationDelegate <NSObject>
@optional

- (void)imageViewerWillBeginPresentation:(MoImageViewController *)imageViewer withContainerView:(UIView *)containerView;

- (void)imageViewerWillAnimatePresentation:(MoImageViewController *)imageViewer withContainerView:(UIView *)containerView duration:(CGFloat)duration;

- (void)imageViewer:(MoImageViewController *)imageViewer willAdjustInterfaceForZoomScale:(CGFloat)zoomScale withContainerView:(UIView *)containerView duration:(CGFloat)duration;

- (void)imageViewerWillBeginDismissal:(MoImageViewController *)imageViewer withContainerView:(UIView *)containerView;

- (void)imageViewerWillAnimateDismissal:(MoImageViewController *)imageViewer withContainerView:(UIView *)containerView duration:(CGFloat)duration;

@end








