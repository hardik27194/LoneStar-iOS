//
//  MobiusoHome.m
//  
//
//  Created by sandeep on 1/21/13.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//

#import "MobiusoTimedCurtain.h"
#import "Utilities.h"
#import "QuartzCore/QuartzCore.h"
#import "QuartzCore/CAAnimation.h"
#import "MobiusoToast.h"
#import "Theme.h"


@implementation MoSettingsButton
- (id)  initWithImage:(UIImage *)img
                                     highlightedImage:(UIImage *)himg
                                          anchorColor: (UIColor *) color
{
    if (self = [super init])
    {
        self.userInteractionEnabled = YES;
        self.anchorColor = color;
        self.backgroundColor = [UIColor clearColor] ; // ]colorWithPatternImage:[OTRSettingsManager bundledImage: @"whitey.png"]];
        [self setImage: img forState:UIControlStateNormal];
        [self setImage: himg forState:UIControlStateHighlighted];
    }
    return self;
}

@end

@implementation MobiusoTimedCurtain

@synthesize wallPaper;
@synthesize delegate;
@synthesize progressItems;
@synthesize activity = _activity;
@synthesize gestureState;
@synthesize timer;
@synthesize tapGesture;
@synthesize glyph;
@synthesize bgImageName;
@synthesize countdown;

#define PROGRESS_VIEW_TAG   20130211
#define COUNTDOWN_VIEW_TAG  20141103

- (void) addInfo: (UIView *) background
{
    CGRect frame = [background bounds];
    CGFloat top = 8;
    CGFloat bottom = 160;
    _header = [[UILabel alloc] initWithFrame:CGRectMake(0, /*frame.size.height - bottom - 2*/ top, frame.size.width, top + 48)];
    [_header setBackgroundColor:[UIColor clearColor]];
    [_header setTextColor: COLORFROMHEX(0xffffffff) ];
    UIFont *font1 = [UIFont fontWithName:@"Roboto-Thin" size: IS_IPAD? 48: 36];
    [_header setFont:font1];
    [_header setText: @"Closing..."];
    [_header setTextAlignment:NSTextAlignmentCenter];
    [background addSubview:_header];
    
    
    _footer = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - bottom - 2, frame.size.width, bottom)];
    [_footer setBackgroundColor:[UIColor clearColor]];
    [_footer setTextColor: COLORFROMHEX(0xffffffff) ];
    UIFont *font2 = [UIFont fontWithName:@"Avenir-Book" size: IS_IPAD? 16: 14];
    [_footer setFont:font2];
    [_footer setText: @"Tap anywhere to disable"];
    [_footer setTextAlignment:NSTextAlignmentCenter];
    [background addSubview:_footer];
    

}
- (id)initWithFrame:(CGRect)frame delegate: (id <MobiusoTimedCurtainDelegate> ) del
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = del;
        self.backgroundColor = [UIColor clearColor];
        self.wallPaper = [self backgroundView: frame];
        [self doSlideIn:self.wallPaper completionBlock:^(BOOL  finished) {
            [self addInfo: self.wallPaper];
           }];
    }
    return self;
}

// For iOS 7
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIView *) backgroundView: (CGRect) frame
{
    UIView *returnview;
    
    if (IS_IOS8) {
        // Blur Effect
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [bluredEffectView setFrame:frame];
        
        
        // Vibrancy Effect
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        // vibrancyEffectView.backgroundColor = COLORFROMHEX(0xff990000);
        [vibrancyEffectView setFrame:self.bounds];
        // Add Vibrancy View to Blur View
        [bluredEffectView addSubview:vibrancyEffectView];
        // Add Label to Vibrancy View
        returnview = bluredEffectView;
    } else {
        
        // Interesting one's "white_bed_sheet.png", "worn_dots.png", "textured_stripes.png"
        // tiny_grid.png subtle_dots.png are good
        // tiny_grid.png
        NSArray* myImages = [[NSBundle mainBundle] pathsForResourcesOfType:@"png"
                                                               inDirectory: @"MobiusoTextures"];
        NSString *themeImage = @"tiny_grid.png"; // [MPSettingsManager stringForOTRSettingKey: kOTRSettingKeyTheme];
        
        UIImage *bgImage = nil;
        UIImageView *background = [[UIImageView alloc] initWithFrame: frame];
        if (themeImage != nil) {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:themeImage ofType:nil inDirectory:@"MobiusoTextures"];
            if (imagePath != nil) {
                bgImage = [UIImage imageWithContentsOfFile: imagePath];
            }
        } else {
            // Randomize the image
            
            NSUInteger timeMask = (NSUInteger)[NSDate timeIntervalSinceReferenceDate] & 0x3f;   // can't be more than 64
            if ([myImages count] && (timeMask < [myImages count])) {
                bgImageName = [myImages objectAtIndex: timeMask % [myImages count]];
                // make sure we get the root name of the found string (so it will work well on retina
                bgImageName = [bgImageName stringByReplacingOccurrencesOfString:@"@2x.png" withString:@".png"];
                
                bgImage = [UIImage imageWithContentsOfFile: bgImageName];
                DLog(@"Using Background Image: %@", bgImageName);
            }
        }
        
        if (bgImage == nil) {
            // Make this an array as well... Nice bokeh images and backgrounds...
            //UIImage *pattern =  [UIImage imageNamed:@"NGC.jpg"];
            [Utilities setOptimalImageViewProperties:background image: [UIImage imageNamed:@"Wallpaper.png"]];//
        }
        background.backgroundColor = [UIColor colorWithPatternImage:bgImage];
        background.userInteractionEnabled = YES;
        background.alpha = 0.8f;
        background.autoresizesSubviews = YES;
        
        // Overlay a shadow image that adds a subtle darker drop shadow around the edges
        UIImage*        shadow = [[UIImage imageNamed:@"inner-shadow.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        UIImageView*    shadowImageView = [[UIImageView alloc] initWithFrame: frame];
        shadowImageView.alpha = 0.7;
        shadowImageView.image = shadow;
        shadowImageView.userInteractionEnabled = NO;
        
        shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [background addSubview:shadowImageView];
        
        
        
        //[shadowImageView release];
        UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc]
                                               initWithTarget: self action: nil /*selector*/]; //
        [tapGesture2 setDelegate: self];
        tapGesture2.numberOfTapsRequired = 1;
        [background addGestureRecognizer:tapGesture2];
        
        // Overlay A white Spotlight as well (Need a blendmodepath)
        
        
        // Title
        //  UIImage *headerImage = [Utilities imageWithContentsOfFile: @"HomeHeader.png"];
        
        // Ideal width of an image
#ifdef NOTNOW
        CGFloat width, height, top, bottom;
        if (frame.size.height < 320) {
            width = 192; height = 48; top = 3;
            bottom = 100;
        } else {
            width = 256; height = 64; top = 5;
            bottom = (IS_IPAD? 160: 160);
        }
        
        
        top += (IS_IOS7?20:0);
        UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - width)/2, top, width, height)];
        tempImageView.image = headerImage;
        [background addSubview:tempImageView];
#endif
        returnview = background;
    }
    
    return returnview;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) reload: (CGRect) frame
{
    //self.frame = frame; // Set up our frame to be correct
#ifdef NOTNOW
    if (self.wallPaper != nil) {
        [self.wallPaper removeFromSuperview];
    }
    self.wallPaper = [self backgroundView: frame];
    [self addSubview:self.wallPaper];
    // [self insertSubview:self.wallPaper atIndex:0];
#endif
    self.wallPaper.frame = frame;
    UIView *progress = [self viewWithTag:PROGRESS_VIEW_TAG];
    progress.frame = frame;
    countdown.center = progress.center;
    CGFloat top = 8;
    CGFloat bottom = 160;
    _header.frame = CGRectMake(0, /*frame.size.height - bottom - 2*/ top, frame.size.width, top + 48);
    _footer.frame = CGRectMake(0, frame.size.height - bottom - 2, frame.size.width, bottom);
    

}


#pragma mark Activity/Loading
- (UIView *) createProgressView {
    
    
    UIView *progress = [[UIView alloc] init];
    progress.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    progress.frame =[self bounds];
    progress.tag = PROGRESS_VIEW_TAG;

    countdown = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    countdown.tag = COUNTDOWN_VIEW_TAG;
    countdown.center = progress.center;
    [countdown setBackgroundColor:[UIColor clearColor]];
    [countdown setTextColor: COLORFROMHEX(0xff990000) ];
    UIFont *font1 = [UIFont fontWithName:@"Roboto-Light" size: IS_IPAD? 48: 36];
    [countdown setFont:font1];
    [countdown setText: @"10"];
    [countdown setTextAlignment:NSTextAlignmentCenter];
    [progress addSubview:countdown];

    
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    // [activity startAnimating];
    [_activity sizeToFit];
    _activity.center = progress.center;
    [progress addSubview:_activity];
    //[activity release];
    
    
   [self addSubview:progress]; //  [self insertSubview:progress belowSubview:self.menu];//
    // [self.view bringSubviewToFront:loading];
    tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget: self action: nil /*selector*/]; //
    [tapGesture setDelegate: self];
    tapGesture.numberOfTapsRequired = 1;
    [progress addGestureRecognizer:tapGesture];


    self.progressItems = [[NSMutableArray alloc] init];
    return progress;
}

- (void) activity: (BOOL) visible
{
    UIView *progressView = [self viewWithTag: PROGRESS_VIEW_TAG];
    if (progressView==nil){
        progressView = [self createProgressView];
    }
    if (visible) {
        progressView.hidden = NO;
        [self bringSubviewToFront:progressView];
    }
    
    progressView.alpha = visible ? 0.0 : 1;
    [UIView animateWithDuration:0.3
                     animations:^{
                         progressView.alpha = visible ? 1 : 0.0;
                     }
                     completion: ^(BOOL  finished) {
                         if (!visible) {
                             progressView.hidden = YES;
                         }
                     }];
    
}

// we need to be in the main UI thread
- (void) showActivity
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread: @selector(showActivity)
                               withObject: nil
                            waitUntilDone: FALSE];
        return;
    }
    [self activity: TRUE];
}

// We need to be in the main thread
- (void) hideActivity
{
    // [activity stopAnimating];
    if (_activity == nil) return;
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread: @selector(hideActivity)
                               withObject: nil
                            waitUntilDone: FALSE];
        return;
    }
    [_activity stopAnimating];
    [self activity: FALSE];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(performAction)]) {
        [self.delegate performSelector:@selector(performAction)];
    }
}

# pragma mark - Demo Timer

// Slide In the View - properties will be set to where the view is supposed to be visible
// completion block will provide the next action when the slide is finished
// targetimage view's current frame is set up.  It moves to the point where it is required (in the center)
- (void) doSlideIn: (UIView *) targetView completionBlock: (void (^) (BOOL)) block
{
    //[targetImageView setCenter:CGPointMake(160, 100)/*sender.center*/];
    CGSize size = [self frame].size;
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    CGPoint frombottom = CGPointMake(size.width/2, size.height*3/2);
    [UIView animateWithDuration:1.0f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [targetView setCenter: frombottom];
                         [targetView setAlpha:1.0f];
                         [targetView setCenter: center];
                     }
                     completion: block
#ifdef NOTNOW
                        ^(BOOL finished){
                         //[targetImageView removeFromSuperview];
                         //points++;
                         //NSLog(@"points: %i", points);
                         [menu animateDemo]; // it will take care of open and close automatically
                    }
#endif
     ];
    
    [self addSubview:targetView];
    
}

- (void) doFade: (UIView *) view
{
    view.alpha = 0;
    [UIView animateWithDuration:0.6f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // [starView setCenter:CGPointMake(0, 0)];
                         [view setAlpha:0.6f];
                         // [view setCenter: center];
                     }
                     completion:^(BOOL finished){
                         //[targetImageView removeFromSuperview];
                         //points++;
                         //NSLog(@"points: %i", points);
                         // [menu animateDemo]; // it will take care of open and close automatically
                     }];
    
    
}



#pragma mark - Activity
- (void) showSpinnerOnMain: (NSNumber *) enableObject
{
    BOOL enable = [enableObject boolValue];
    [self showSpinner:enable];
}

// When you enable spinner, you block all user actions (except the popups)
- (void) showSpinner: (BOOL) enable
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread: @selector(showSpinnerOnMain:)
                               withObject: [NSNumber numberWithBool:enable]
                            waitUntilDone: FALSE];
        return;
    }
    UIView *progressView = [self viewWithTag: PROGRESS_VIEW_TAG];
    if (progressView==nil){
        progressView = [self createProgressView];
    }
    if (!enable) {
        //[self sendSubviewToBack:progressView];

        [_activity performSelectorOnMainThread: @selector(stopAnimating)
                                            withObject: nil
                                         waitUntilDone: FALSE];
        // [activity stopAnimating];
    } else {
        [self bringSubviewToFront:progressView];
        [_activity startAnimating];
    }
}

- (void) dismiss
{
    [MobiusoToast toast:@"Cancelling ..."];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissAction)]) {
        [delegate performSelector: @selector(dismissAction)];
    }
    
}

// SingleTap Action

//
// Load the view with the start angle and span in clockWise direction
//
// itemID should start with 0 and continue as 1, 2, 3 after that for different 
// progress circle
//
- (void) showProgress: (CGFloat) percent item: (NSInteger) itemId
{
    UIView *progressView = [self viewWithTag: PROGRESS_VIEW_TAG];
#ifdef DEBUG_TIMEDCURTAIN
    DLog(@"[p: %f, %ld", percent, (long)itemId);
#endif
    if (progressView==nil){
        progressView = [self createProgressView];
    } else  if (progressView.layer != nil) {
        // Remove the layers associated with our id
        if ([self.progressItems count] > itemId) {
            NSArray *layerArr = [self.progressItems objectAtIndex: itemId];
            if ((NSNull *)layerArr != [NSNull null]) {
                for (CALayer *l in layerArr) {
                    [l removeFromSuperlayer];
                }
                [self.progressItems removeObjectAtIndex:itemId];
                [self.progressItems insertObject:[NSNull null] atIndex:itemId];
            }
        }
    }

    NSUInteger n = floor((percent<1)?((1.0f-percent)*10):((100.0f-percent)/10));
    countdown.text = [NSString stringWithFormat:@"%lu", (unsigned long)n ];

    // if (percent > 25) return;

    CGPoint startPoint = self.center;
    CGFloat endRadius = TRACK_BASE + itemId * TRACK_WIDTH * 5;
    // CGFloat repeatCount = 10.0f;
    CGFloat start = 0.0f;
    CGFloat span = DEGREES_TO_RADIANS(360*((percent>1)?0.01:1)*percent);
    // DLog(@"span: %f", span);
    
    
    
    // For inside track - colored
    // Due to a bug in calculating points in ArcMenu, we are off by 90.  Calculate that here
    // Bug hack
    // start += DEGREES_TO_RADIANS(90);
    UIBezierPath* aPath = [UIBezierPath bezierPathWithArcCenter: startPoint // CGPointMake(15, 2)
                                                         radius: endRadius
                                                     startAngle: (start+span)    // was DEGREES_TO_RADIANS
                                                       endAngle: (start-0.0001)
                                                      clockwise: YES];
    
    // For outside track - colored
    UIBezierPath* bPath = [UIBezierPath bezierPathWithArcCenter: startPoint // CGPointMake(15, 2)
                                                         radius: endRadius
                                                     startAngle: (start)
                                                       endAngle: (start+(span))
                                                      clockwise: YES];
	CAShapeLayer *insideTrack = [CAShapeLayer layer];
    // insideTrack.delegate = self;
	insideTrack.path = aPath.CGPath;
	insideTrack.strokeColor = COLORFROMHEX(0xffededed).CGColor; // [UIColor grayColor].CGColor;
	insideTrack.fillColor = [UIColor clearColor].CGColor;
	insideTrack.lineWidth = TRACK_WIDTH;
#if TRACK_DOTTED_INSIDE
    insideTrack.lineDashPattern = [NSArray arrayWithObjects: [NSNumber numberWithInt:10], [NSNumber numberWithInt:5], nil];
#endif
    insideTrack.opacity = (percent==100)? 0.0f : 0.4f;
#if TRACK_SHADOW
    insideTrack.shadowColor = [UIColor blackColor].CGColor;
    insideTrack.shadowOffset = CGSizeMake(0, 1);
    insideTrack.shadowOpacity = 0.7f;
    insideTrack.shadowRadius = 1.0f;
#endif
	// [progressView.layer addSublayer:insideTrack];
    [progressView.layer insertSublayer:insideTrack above: [[progressView.layer sublayers] objectAtIndex:0]];
    // [insideTrack setNeedsDisplay];
    CAShapeLayer *outsideTrack = [CAShapeLayer layer];
	outsideTrack.path = bPath.CGPath;
	outsideTrack.strokeColor = [Theme mainColor].CGColor;
	outsideTrack.fillColor = [UIColor clearColor].CGColor;
	outsideTrack.lineWidth = TRACK_WIDTH;
#if TRACK_DOTTED_OUTSIDE
    outsideTrack.lineDashPattern = [NSArray arrayWithObjects: [NSNumber numberWithInt:10], [NSNumber numberWithInt:5], nil];
#endif
    outsideTrack.opacity = 0.4f;
#if TRACK_SHADOW
    outsideTrack.shadowColor = [UIColor blackColor].CGColor;
    outsideTrack.shadowOffset = CGSizeMake(0, 1);
    outsideTrack.shadowOpacity = 0.7f;
    outsideTrack.shadowRadius = 1.0f;
#endif
	// [progressView.layer addSublayer:outsideTrack];
    [progressView.layer insertSublayer:outsideTrack above: [[progressView.layer sublayers] objectAtIndex:0]];
    
    
#ifdef TRANSITION
    CABasicAnimation* transition =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    transition.removedOnCompletion = FALSE;
    transition.fillMode = kCAFillModeForwards;
    transition.duration = 2.0;
    transition.beginTime = 0;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [transition setToValue: [NSNumber numberWithFloat: 0.6]];
    
    [insideTrack addAnimation:transition forKey:@"opacity"];
    [outsideTrack addAnimation:transition forKey:@"opacity"];
#endif
 
    // If we don't have intermediate entries in the array, fill them with "null" entries
    if ([self.progressItems count] <= itemId) {
        for(NSUInteger i = [self.progressItems count]; i < itemId; i++)
            [self.progressItems addObject: [NSNull null]];
        [self.progressItems addObject: [NSArray arrayWithObjects:insideTrack, outsideTrack, nil]];
    } else {
        [self.progressItems removeObjectAtIndex:itemId];
        [self.progressItems insertObject: [NSArray arrayWithObjects:insideTrack, outsideTrack, nil] atIndex: itemId];
    }
    
}

- (BOOL) hideProgress: (NSInteger) itemId
{
    // make sure we have valid itemId
    if ([self.progressItems count] > itemId) {
        NSArray *layerArr = [self.progressItems objectAtIndex: itemId];
        if ((NSNull *)layerArr != [NSNull null]) {
            for (CALayer *l in layerArr) {
                [l removeFromSuperlayer];
            }
            [self.progressItems removeObjectAtIndex:itemId];
            [self.progressItems insertObject:[NSNull null] atIndex:itemId];
        }
    }
    // Now check if we have any progressItem remaining
    for (NSArray *layerArr in self.progressItems) {
        if ((NSNull *)layerArr != [NSNull null]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark Gesture Delegate methods
// (1) the first method to receive the touch event
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // DLog(@"gestureRecognizer shouldReceiveTouch: tapCount = %d",(int)touch.tapCount);
    if (touch.tapCount ==1) {
        // UIView *progressView = [self viewWithTag: PROGRESS_VIEW_TAG];
        SEL useSelector =  @selector(dismiss);
        // Allow time for the 2nd tap. if it does not appear, then count it as a single tap
        self.timer = [NSTimer timerWithTimeInterval:0.3 target:self selector: useSelector userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        self.gestureState = UIGestureRecognizerStateBegan;
        return YES;
    }
    else if (touch.tapCount ==2 && self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        // Perform fast action - this can be changed through settings
        // [self launchSettings];
        return YES;
    }
    return NO;
}

// (2) the second method to recognize the touch event
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // DLog(@"shouldRecognizeSimultaneouslyWithGestureRecognizer, state is %@", [self getGestureState: gestureRecognizer.state]);
    self.gestureState = gestureRecognizer.state;
    return YES;
}


- (void) invalidateTapTimers
{
    // if the summary view recognized another event (such as a click on the link, etc), then we don't need to treat
    // the tap as a single tap
    if (self.singleTouchTimer) {
        [self.singleTouchTimer invalidate];
        self.singleTouchTimer = nil;
    }
}

@end
