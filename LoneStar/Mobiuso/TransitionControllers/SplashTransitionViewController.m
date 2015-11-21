//
//  SplashTransition
//  Snaptica Pro
//
//  Created by Sandeep on 6/16/2015.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "SplashTransitionViewController.h"
#import "HUTransitionAnimator.h"
#import "ZBFallenBricksAnimator.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "Theme.h"
#import "StylizedTextView.h"
#import "UIImage+RemapColor.h"

typedef enum {
    TransitionTypeNormal,
    TransitionTypeVerticalLines,
    TransitionTypeHorizontalLines,
    TransitionTypeGravity,
} TransitionType;


@interface SplashTransitionViewController ()
<UINavigationControllerDelegate, UIWebViewDelegate>
{
    TransitionType type;
    BOOL pushed;
    BOOL fastexit;
}

@property (weak, nonatomic) IBOutlet UIView *pyramidView;

@property (weak, nonatomic) IBOutlet UIView *pyramidStep1View;

@property (weak, nonatomic) IBOutlet UIView *pyramidStep2View;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UILabel *inAppStatusLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet StylizedTextView *circleTextView;


@end


@implementation SplashTransitionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _splashDuration = 1.5;
        fastexit = NO;
        
    }
    return self;
}

- (void) setMoreInformation:(NSString *)moreInformation
{
    if (!moreInformation) return;

    
    NSLog(@"String Length: %ld", (unsigned long)[moreInformation length]);
    
    // The line break mode wraps character-by-character
    uint8_t breakMode = kCTLineBreakByCharWrapping;
    CTParagraphStyleSetting wordBreakSetting = {
        kCTParagraphStyleSpecifierLineBreakMode,
        sizeof(uint8_t),
        &breakMode
    };
    CTParagraphStyleSetting alignSettings[1] = {wordBreakSetting};
    CTParagraphStyleRef paraStyle = CTParagraphStyleCreate(alignSettings, 1);
    
    // Set the text
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"Avenir", IS_IPAD ? 18.0f : 14.0f, NULL);
    
    // Create the attributed string
    NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)fontRef, (NSString *)kCTFontAttributeName,
                                    (__bridge id)paraStyle, (NSString *)kCTParagraphStyleAttributeName,
                                    (__bridge id)[UIColor lightGrayColor].CGColor, kCTForegroundColorAttributeName,
                                    nil];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:moreInformation attributes:attrDictionary];
    CFRelease(fontRef);
    CFRelease(paraStyle);
    
    // Add the attributed string to the CTView
    _circleTextView.string = attString;
//    [self.view addSubview:_circleTextView];
    CGRect frame = _pyramidView.frame;
    frame.origin.x -= 80;
    frame.origin.y -= 80;
    frame.size.width += 160;
    frame.size.height += 160;
    [_circleTextView setNeedsDisplay];

//    cView.frame = frame;
    
    _moreInformation = moreInformation;
}

- (void) setupCameraBellowsEffect
{
    
    
    
    CGFloat tilt = 10.0;    // Views on the top will seem to react more to the motion
    CGFloat transparency = 0.5;
    UIView *view = self.pyramidView;
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = view.backgroundColor.CGColor;
    sublayer.frame = view.bounds;
    sublayer.opacity = transparency;
    view.layer.opacity = 1.0f;
    sublayer.cornerRadius = view.bounds.size.width / 2; // 10;
    
    
    view.backgroundColor = [UIColor clearColor];
    [view.layer insertSublayer:sublayer atIndex:0];
    
    UIView *lastView;
    while (view)
    {
        ////        view.alpha = transparency;
        //        CALayer *sublayer = [CALayer layer];
        //        sublayer.backgroundColor = view.backgroundColor.CGColor;
        //        sublayer.frame = view.bounds;
        ////        view.backgroundColor = [UIColor clearColor];
        ////        [view.layer addSublayer:sublayer];
        ////        sublayer.opacity = transparency;
        //        transparency -= 0.05;
        view.layer.cornerRadius = view.bounds.size.width / 2; //  10;
        view.clipsToBounds = NO;
//        view.alpha = 1.0;
        [[self class] addHorizontalTilt:tilt verticalTilt:tilt ToView:view];
        tilt += 5;
        lastView = view;
        view = [view.subviews firstObject];
    }
    lastView.clipsToBounds = YES;

}

- (void) setupViewType: (BOOL) isAbout
{
    BOOL purchased = YES; // IAP status
    if (isAbout) {
        // AboutView
        _versionLabel.hidden = NO;
        
        // Full bundle ID NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *buildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *displayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        _versionLabel.text = [NSString stringWithFormat:@"%@ %@ - Build %@", displayName, versionNumber, buildNumber];
        
        // Check the status of the Purchase - trial or not..
        _inAppStatusLabel.text = purchased? @"Premium Purchased - Thanks!" : @"Trial Version - Get Premium";
        CGRect sigBounds = _signatureImageView.bounds;
        _signatureImageView.layer.cornerRadius = sigBounds.size.width/2;
        _signatureImageView.clipsToBounds = YES;
    } else {
        // Splash View
        _closeButton.hidden = YES;
        _versionLabel.hidden = YES;
        _inAppStatusLabel.hidden = YES;
        _aboutTitle.hidden = YES;
    }
    
}


- (void) splash
{
    // Check if we have tucked in the name of the image, if so, use it
    UIImage *image = [UIImage imageNamed:@"amazonas.png"];
    //add the image to the forefront...
    if (image) {
        //        UIImageView *splashImageView = [[UIImageView alloc] initWithImage:image];
        //splashImageView.contentMode = UIViewContentModeScaleAspectFill;
        //[self.view addSubview:splashImageView];
        //[self.view bringSubviewToFront:splashImageView];
        self.view.layer.contents = (__bridge id)(image.CGImage);
        self.view.contentMode = UIViewContentModeScaleAspectFill;

#ifdef EXTENDED_DEBUG
        MLog(@"Splash BG Image size: %@", [HomeVC displayMemory: CGImageGetHeight(image.CGImage) * CGImageGetBytesPerRow(image.CGImage)]);
#endif

        UIImage *img2 = [UIImage imageNamed:@"oldcamera.png"];
        
#ifdef EXTENDED_DEBUG
        MLog(@"Old Camera size: %a", [HomeVC displayMemory: CGImageGetHeight(img2.CGImage) * CGImageGetBytesPerRow(img2.CGImage)]);
#endif
        
        CALayer *sublayer = [CALayer layer];
        sublayer.contentsGravity = kCAGravityResizeAspectFill;
        sublayer.contents = (__bridge id)(img2.CGImage);
        sublayer.frame = self.view.bounds;
        [self.view.layer addSublayer:sublayer];
        
        [self setupCameraBellowsEffect];

//        [self setupStylizedText];
    }
}


+ (void)addHorizontalTilt:(CGFloat)x verticalTilt:(CGFloat)y ToView:(UIView *)view
{
    UIInterpolatingMotionEffect *xAxis = nil;
    UIInterpolatingMotionEffect *yAxis = nil;
    
    if (x != 0.0)
    {
        xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-x];
        xAxis.maximumRelativeValue = [NSNumber numberWithFloat:x];
    }
    
    if (y != 0.0)
    {
        yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-y];
        yAxis.maximumRelativeValue = [NSNumber numberWithFloat:y];
    }
    
    if (xAxis || yAxis)
    {
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        NSMutableArray *effects = [[NSMutableArray alloc] init];
        if (xAxis)
        {
            [effects addObject:xAxis];
        }
        
        if (yAxis)
        {
            [effects addObject:yAxis];
        }
        group.motionEffects = effects;
        [view addMotionEffect:group];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    [self splash];
    
    type = TransitionTypeNormal;
    
    self.navigationController.delegate = self;

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraRequested:)];
    [_pyramidView addGestureRecognizer:gesture];
    pushed = NO;
    [self setupViewType:(!_nextController || (_splashDuration == 0))];
    
    [self setTapDelegate:self withAction:@selector(fastpop:)];
    
//    UITapGestureRecognizer *licenseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(licenseTapped:)];
//    [_licenseLabel addGestureRecognizer:licenseGesture];


}

- (void) viewDidAppear:(BOOL)animated
{
    if (_nextController) {
        [self performSelector:@selector(pop:) withObject:nil afterDelay:_splashDuration];//    [self pop:arc4random()%3];  // randomize the handoff
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    DLog(@"Disappearing");
    self.view = nil;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Hide Status Bar
- (BOOL)prefersStatusBarHidden {
    return true;
}


// =============================================================================
#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    NSObject <UIViewControllerAnimatedTransitioning> *animator;
    
    switch (type) {
        case TransitionTypeVerticalLines:
            animator = [[HUTransitionVerticalLinesAnimator alloc] init];
            [(HUTransitionAnimator *)animator setPresenting:NO];
            if (animator && fastexit) ((HUTransitionAnimator *)animator).animationDuration = 0.25;
            break;
        case TransitionTypeHorizontalLines:
            animator = [[HUTransitionHorizontalLinesAnimator alloc] init];
            [(HUTransitionAnimator *)animator setPresenting:NO];
            if (animator && fastexit) ((HUTransitionHorizontalLinesAnimator *)animator).animationDuration = 0.25;
            break;
        case TransitionTypeGravity:
            animator = [[ZBFallenBricksAnimator alloc] init];
            if (animator && fastexit) ((ZBFallenBricksAnimator *)animator).animationDuration = 0.25;
            break;
        default:
            animator = nil;
    }
    
    return animator;
}


// =============================================================================
#pragma mark - IBAction

- (IBAction)pop:(id) sender

{
    NSUInteger ttype = arc4random()%3;
    switch (ttype) {
        case 0:
            type = TransitionTypeVerticalLines;
            break;
            
        case 1:
            type = TransitionTypeHorizontalLines;
            break;
            
        case 2:
            type = TransitionTypeGravity;
            break;
    }
    
    if (_nextController) {
        if (!pushed) {
#if 0
            [self.navigationController pushViewController:[[AppDelegate sharedDelegate] homeController] animated:YES];
            pushed = YES;
#endif
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) fastpop:(id) sender
{
    fastexit = YES;
    [self pop: sender];
}

- (void) cameraRequested: (id) sender
{
#if 0
    HomeVC *homeController = (HomeVC *) [[AppDelegate sharedDelegate] homeController] ;
    homeController.openCamera = YES;
    fastexit = YES;
    [self.navigationController pushViewController:homeController animated:YES];
    pushed = YES;
#endif
}

- (void) setTapDelegate: (id <UIGestureRecognizerDelegate>) delegate withAction: (SEL) selector
{
    UITapGestureRecognizer *_tapLinkRecognizer = [[UITapGestureRecognizer alloc]
                          initWithTarget: delegate action: selector]; //
    [_tapLinkRecognizer setDelegate: delegate];
    _tapLinkRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:_tapLinkRecognizer];
    
    
}

- (IBAction)licenseTapped:(id) sender
{
    DLog(@"Tapped license");
    [self createLicense];
}

#pragma mark - Views for creating About Thumbnails
- (UIWebView *) createLicense
{
    // Get the File for the notice somewhere - for now from the
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"license" ofType:@"html" inDirectory:nil];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //    UIView *rootView = [[AppDelegate sharedDelegate] rootView];
    CGRect frame = [Utilities applicationFrame];
//    frame.origin.x += frame.size.width;
    UIWebView *webView = [[UIWebView alloc] initWithFrame: frame];
    
    [webView  setScalesPageToFit:YES];
    webView.delegate = self;
    webView.tag = 9988;
    [webView  loadRequest: request];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(frame.size.width - 40, 8, 32, 32);
    [closeButton addTarget:self action:@selector(closeLicense) forControlEvents:UIControlEventTouchUpInside];
    //    [closeButton setImage:[UIImage imageNamed:@"dismissButt"] forState:UIControlStateNormal];   // SimpleCloseLine.png
    
    [closeButton setImage:[UIImage imageNamed:@"dismissButtWHITE"] forState:UIControlStateNormal];
    closeButton.layer.cornerRadius = 16;
    closeButton.layer.backgroundColor = COLORFROMHEX(0x80000000).CGColor;
    CALayer *sublayer = [CALayer layer];
    sublayer.frame = [closeButton bounds];
    sublayer.contents = (__bridge id)([UIImage imageNamed:@"dismissButtWHITE"].CGImage);
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [webView addSubview: closeButton];

    [self.view addSubview: webView];
    
    return webView;
}

#pragma mark - WebView
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    NSData *data = UIImageJPEGRepresentation(screenshot, 1.0);
}


- (void) closeLicense
{
    [[self.view viewWithTag:9988] removeFromSuperview];
}


@end

