//
//  MobiusoToast.m
//

//

// Constants for our look and feel 
#define HorizontalPadding               30.0
#define VerticalPadding                 8.0
#define CornerRadius                    5.0
#define ShadowRadius                    3.50
#define ShadowOpacity                   0.30
#define ShadowOffset                    CGSizeZero
#define ShadowColor                     [[UIColor blackColor] CGColor]
#define BorderWidth                     1.50
#define BorderColor                     [[UIColor colorWithWhite: 0.80 alpha: 0.80] CGColor]
#define BackgroundColor                 [UIColor colorWithWhite: 0.00 alpha: 0.80]
#define VerticalPositionRatio           0.50
#define HorizontalPositionRatio         0.83
#define AutoResizingMask                UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin

// The label itself
#define LabelFont                       [UIFont fontWithName:@"Droid Sans" size: 16] // [UIFont systemFontOfSize: 12] 
#define LabelFontColor                  [UIColor orangeColor]
#define LabelShadowRadius               1.00
#define LabelShadowOpacity              0.75
#define LabelShadowOffset               CGSizeZero
#define LabelShadowColor                [[UIColor blackColor] CGColor]
#define LabelVerticalPositionRatio      0.50
#define LabelHorizontalPositionRatio    0.50

//Animation
#define MessageFadeInDuration           0.50
#define MessageFadeOutDuration          0.50

#import "MobiusoToast.h"

@implementation MobiusoToast

@synthesize duration;
@synthesize text;

+ (void)toast:      (NSString *)aString
{return [MobiusoToast toast: aString
                                  forDuration: MoToastMessageDefaultDuration];}

+ (void)toast:      (NSString *)aString inView:  (UIView *)view
{return [MobiusoToast toast: aString
                                  inView: view
                                   forDuration: MoToastMessageDefaultDuration];}

+ (void)toast: (NSString *)aString  forDuration:  (CGFloat) aDuration 
{return [MobiusoToast toast: aString
                                  inView: [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view]
                                   forDuration: aDuration];}

+ (void)toast:  (NSString *)aString   inView: (UIView *)view forDuration: (CGFloat)aDuration
{
    MobiusoToast *singleton = [[MobiusoToast alloc] initWithDuration: aDuration
                                                                 andText: aString];
    [singleton displayInView: view];
    // [singleton release];
}

- (id)initWithMessage:         (NSString *)aString
{return [self initWithDuration: MoToastMessageDefaultDuration
                       andText: aString];}

- (id)initWithDuration:     (CGFloat)aDuration  andText:(NSString *)aString
{
    self = [super init];
    if(self)
    {
        duration    = aDuration;
        text        = [aString copy];
        _label      = [[UILabel alloc] init];
        
        [_label setAdjustsFontSizeToFitWidth: YES];
        [_label setText: text];
        [_label setFont: LabelFont];
        
        CGRect frame = CGRectZero;
        frame.size = [text sizeWithFontSafe: _label.font];
        [_label setFrame: frame];
        
        frame.size = CGSizeMake(frame.size.width + HorizontalPadding, frame.size.height + VerticalPadding);
        [self setFrame: frame];
        
        [_label setCenter: CGPointMake(frame.size.width * LabelHorizontalPositionRatio, frame.size.height * LabelVerticalPositionRatio)];
        
        [_label.layer setShadowRadius: LabelShadowRadius];
        [_label.layer setShadowOpacity: LabelShadowOpacity];
        [_label.layer setShadowColor: LabelShadowColor];
        [_label.layer setShadowOffset: LabelShadowOffset];
        
        [self addSubview: _label];
        
        [_label setTextColor: LabelFontColor];
        [_label setBackgroundColor: [UIColor clearColor]];
        
        [self.layer setBorderColor: BorderColor];
        [self.layer setBorderWidth: BorderWidth];
         
        [self setBackgroundColor: BackgroundColor];
         
        [self.layer setCornerRadius: CornerRadius];
        
        [self.layer setShadowRadius: ShadowRadius];
        [self.layer setShadowOpacity: ShadowOpacity];
        [self.layer setShadowColor: ShadowColor];
        [self.layer setShadowOffset: ShadowOffset];
        
        [self setAutoresizingMask: AutoResizingMask];
    }
    return self;
}

- (void)dealloc
{
    //[_label release];
    //[text release];
    //[super dealloc];
}

- (void)display
{    
    [self displayInView: [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view]];
}

- (void)displayInView:      (UIView *)view
{    
    [self displayInView: view atCenter: ((UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) ?
                                         CGPointMake(view.frame.size.width * VerticalPositionRatio, view.frame.size.height * HorizontalPositionRatio) :
                                         CGPointMake(view.frame.size.height * VerticalPositionRatio, view.frame.size.width * HorizontalPositionRatio))] ;
    
}

- (void)displayInView:(UIView *)view atCenter: (CGPoint) point
{
    [self setCenter: point];
    self.alpha = 0;
    [view addSubview: self];
    
    [UIView beginAnimations: nil context: nil];
    //{
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration: MessageFadeInDuration];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(finishDisplay)];
    self.alpha = 1;
    //}
    [UIView commitAnimations];
    
}

- (void) setLabel:(NSString *)newtext
{
    [_label setText:[newtext copy]];
    CGRect newFrame = _label.frame;
    newFrame.size = [newtext sizeWithFontSafe: _label.font];
    _label.frame = newFrame;
    
    newFrame.size = CGSizeMake(newFrame.size.width + HorizontalPadding, newFrame.size.height + VerticalPadding);
    [self setFrame: newFrame];
    
    [_label setCenter: CGPointMake(newFrame.size.width * LabelHorizontalPositionRatio, newFrame.size.height * LabelVerticalPositionRatio)];
    
    [_label.layer setShadowRadius: LabelShadowRadius];
    [_label.layer setShadowOpacity: LabelShadowOpacity];
    [_label.layer setShadowColor: LabelShadowColor];
    [_label.layer setShadowOffset: LabelShadowOffset];
}

- (void)finishDisplay
{
    [UIView beginAnimations: nil context: nil];
    //{
        [UIView setAnimationDelay: duration];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration: MessageFadeOutDuration];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(removeFromSuperview)];
        self.alpha = 0;
    //}
    [UIView commitAnimations];
}

@end