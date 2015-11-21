//
//  MoElasticArcMenu.h
//

#import <UIKit/UIKit.h>

@protocol MoElasticArcMenuDelegate;

/**
 *  An enumeration for the different locations of buttons on the 
 *  MoElasticArcMenuDelegate view.
 *
 *  
 */
typedef NS_ENUM(NSUInteger, MoElasticArcMenuLocation) {
    MoElasticArcMenuLocationTop,    /// The location above the center button.
    MoElasticArcMenuLocationBottom, /// The location below the center button.
    MoElasticArcMenuLocationLeft,   /// The location left of the center button.
    MoElasticArcMenuLocationRight   /// The location right of the center button.
};

/**
 *  An enumeration for the different states of the MoElasticArcMenuView
 *
 *  
 */
typedef NS_ENUM(NSUInteger, MoElasticArcMenuState) {
    MoElasticArcMenuStateOpen,    /// The state for when all of the buttons on the view are showing.
    MoElasticArcMenuStateClosed,  /// The state for when only the center button is showing.
    MoElasticArcMenuStateExpanded /// The state for when one of the outer buttons is highlighted
};

/**
 *  The class for creating a many options button. This is a type of button that
 *  when clicked, shows other possible selections the user can make. These selections
 *  can be made through swiping or multiselections.
 *
 *  
 */
@interface MoElasticArcMenu : UIControl

/// Image that will be displayed at the respective location on the MoElasticArcMenu
@property (strong, nonatomic) UIImage *leftButtonImage,
                                      *rightButtonImage,
                                      *topButtonImage,
                                      *bottomButtonImage;

/// Images that will be displayed when one of the buttons is highlighted
@property (strong, nonatomic) UIImage *highlightedLeftButtonImage,
                                      *highlightedRightButtonImage,
                                      *highlightedTopButtonImage,
                                      *highlightedBottomButtonImage;

/// Image that will be displayed as the center button on the MoElasticArcMenu.
@property (strong, nonatomic) UIImage *centerButtonImage;

/// Image that will be used when the center button is highlighted
@property (strong, nonatomic) UIImage *highlightedCenterButtonImage;

/// Holds the current state of the view. 
@property (nonatomic) MoElasticArcMenuState currentManyOptionsButtonState;

/// Holds the current locations where there are buttons. 
@property (readonly, strong, nonatomic) NSArray *locationsArray;

/// The size to use for the frame when the button is in the MoElasticArcMenuStateClosed.
@property (readonly, nonatomic) CGSize closedSize;
/// The size to use for the frame when the button is in the MoElasticArcMenuStateOpen.
@property (readonly, nonatomic) CGSize openedSize;

/// The delegate object for this view
@property (weak, nonatomic) id<MoElasticArcMenuDelegate> delegate;

/// A transformation that will be performed to the center button when the MoElasticArcMenu is in the closed state.
@property (nonatomic) CGAffineTransform transformForCenterButtonWhenClosed;

/// A transformation that will be performed to the center button when the MoElasticArcMenu is in the closed state.
@property (nonatomic) CGAffineTransform transformForCenterButtonWhenOpened;


/**
 *  Custom initializer for when the frame, and all of the images for all of the buttons
 *  around the view are known.
 *
 *  @param frame             The frame for the view.
 *  @param centerButtonImage The UIImage for the button that will always be displayed in
 *                           the center of the view.
 *  @param leftButtonImage   The UIImage for the button that will be displayed to the left
 *                           of the center button when the MoElasticArcMenu is in open
 *                           mode.
 *  @param rightButtonImage  The UIImage for the button that will be displayed to the right
 *                           of the center button when the MoElasticArcMenu is in open
 *                           mode.
 *  @param topButtonImage    The UIImage for the button that will be displayed to the top
 *                           of the center button when the MoElasticArcMenu is in open
 *                           mode.
 *  @param bottomButtonImage The UIImage for the button that will be displayed to the left
 *                           of the center button when the MoElasticArcMenu is in open
 *                           mode.
 *
 *  @return An instance of the MoElasticArcMenu with all of the provided arguements as
 *          the images for each of its views.
 *
 *  
 */
- (instancetype)initWithFrame:(CGRect)frame
            centerButtonImage:(UIImage *)centerButtonImage
              leftButtonImage:(UIImage *)leftButtonImage
             rightButtonImage:(UIImage *)rightButtonImage
               topButtonImage:(UIImage *)topButtonImage
         andBottomButtonImage:(UIImage *)bottomButtonimage;

/**
 *  Custom initializer for when the frame, and all of the images for all of the buttons
 *  around the view are known.
 *
 *  If any of the buttons images are set to nil, that means that there will be no button at
 *  that location and the delegate method will not be called for any interation at that location
 *  on the view. If you would like to have user interaction on one of the sides of the view, but
 *  also have no image there, you can specify that image to be <code>[UIImage new]</code>
 *
 *  @param centerButtonImage The UIImage for the button that will always be displayed in
 *                           the center of the view.
 *  @param leftButtonImage   The UIImage for the button that will be displayed to the left
 *                           of the center button when the MoElasticArcMenu is in open
 *                           mode.
 *  @param rightButtonImage  The UIImage for the button that will be displayed to the right
 *                           of the center button when the MoElasticArcMenu is in open
 *                           mode.
 *  @param topButtonImage    The UIImage for the button that will be displayed to the top
 *                           of the center button when the MoElasticArcMenu is in open
 *                           mode.
 *  @param bottomButtonImage The UIImage for the button that will be displayed to the left
 *                           of the center button when the MoElasticArcMenu is in open
 *                           mode.
 *
 *  @return An instance of the MoElasticArcMenu with all of the provided arguements as
 *          the images for each of its views.
 *
 *  
 */
- (instancetype)initWithCenterButtonImage:(UIImage *)centerButtonImage
                          leftButtonImage:(UIImage *)leftButtonImage
                         rightButtonImage:(UIImage *)rightButtonImage
                           topButtonImage:(UIImage *)topButtonImage
                     andBottomButtonImage:(UIImage *)bottomButtonimage;

@property (nonatomic, assign) CGRect  menuCanvasFrame;
@property (nonatomic, assign) CGFloat menuRadius;
@property (nonatomic, assign) CGFloat menuDuration;
@property (nonatomic, assign) CGFloat menuButtonDiameter;   // actually its a dimension (square)
@property (nonatomic, assign) CGFloat menuCenterButtonDiameter;   // actually its a dimension (square)
@property (nonatomic, assign) CGFloat menuButtonCornerRadius; // this will define the shape
@property (nonatomic, assign) CGFloat menuButtonExpandedCornerRadius; // this will define the shape


@end


/**
 *  The protocol for the many options button. This protocol informs the delegate object
 *  of the MoElasticArcMenu that one of the buttons was selected at a specific index.
 *
 *  
 *
 */
@protocol MoElasticArcMenuDelegate <NSObject>

/**
 *  Informs the delegate object that a button was selected at a specific location on the
 *  MoElasticArcMenu.
 *
 *  @param button The MoElasticArcMenu that a button was selected on.
 *  @param location The location on the MoElasticArcMenu where a button was selected.
 *
 *  
 */
- (void)manyOptionsButton:(MoElasticArcMenu *)button didSelectButtonAtLocation:(MoElasticArcMenuLocation)location;


@end
