//
//  MoWelcomeViewController.h
//  Mobiuso
//
//

#import "MoWelcomeViewController.h"
#import "Strings.h"
#import "Constants.h"
#import "Theme.h"
#import "Utilities.h"
#import "POP.h"
//#import "SettingsManager.h"
//#import "SettingsVC.h"
#import "MoToolTipView.h"

#define FAKEVIEW_TAG    201507120
#define IMAGEVIEW_TAG   201507121

@interface MoWelcomeViewController ()

@end

CGFloat const scrollViewHeight = 578.f;
CGFloat const scrollViewMargin = 0.f;

@interface WelcomeConfig: NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSArray *tooltips;
@property (nonatomic, assign) CGFloat fill;

+ (int) intValue: (NSString *) numberString;
- (instancetype) initWithDictionary: (NSDictionary *) welcomeConfigItemDict;

@end

@interface MoWelcomeViewController ()

@property (nonatomic, retain) NSMutableArray    *pageViews;
@property (nonatomic, retain) NSMutableArray    *pageToolTips;
@property (nonatomic, assign) NSInteger         currentTooltip;
@property (nonatomic, assign) NSInteger         currentPage;
@property (nonatomic, retain) MoToolTipView     *currentTooltipView;

@property (nonatomic, retain) NSMutableArray    *pageFillScale;

@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;

@end

@implementation MoWelcomeViewController

@synthesize pageScrollView;

+ (BOOL) shouldRunWelcomeFlow {
    //You should run if not yet run
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kWelcomeDefaultHasRunFlowKeyName];
}

+ (void) setShouldRunWelcomeFlow:(BOOL)should {
    //ShouldRun is opposite of hasRun
    [[NSUserDefaults standardUserDefaults] setBool:!should forKey:kWelcomeDefaultHasRunFlowKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) resizeViews
{
    
    CGRect newFrame = [self.view bounds];
    self.view.frame = newFrame;
//#ifdef NOTNOW
    self.pageScrollView.frame = newFrame;
    for (UIImageView *view in [_welcomeScreen subviews]) {
        view.frame = newFrame;
    }
    _welcomeScreen.frame = newFrame;
    _doneButton.center = CGPointMake(newFrame.size.width - 32, 20);
//#endif
}

- (void)loadView
{
    [super loadView];
    CGRect frame = CGRectMake(0, 0, 0, 0);
    self.pageScrollView = [[PagedScrollView alloc] initWithFrame:frame];
    self.pageScrollView.delegate = self;
    // self.settingsTableView.delegate = self;
    self.pageScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:pageScrollView];

#ifdef NOTNOW
#define PLUS_SIGN_IMAGE_NAME          @"31-circle-plus.png"
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    skipButton.frame = CGRectMake(0, 0, 32, 32);
    UIImage *buttonImage = [UIImage imageNamed: PLUS_SIGN_IMAGE_NAME];
    [skipButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [skipButton addTarget:self action:@selector(skipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
#endif

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = APPLICATION_NAME;
    self.view.backgroundColor = [UIColor blackColor];
    CGRect viewBounds = self.view.bounds;
    CGFloat scrollViewWidth = viewBounds.size.width;
    CGRect pageFrame = CGRectMake((self.view.bounds.size.width - scrollViewWidth), 0, scrollViewWidth, viewBounds.size.height);
    

    
    pageScrollView = [pageScrollView initWithFrame:pageFrame];
    pageScrollView.backgroundColor = [UIColor blackColor];
    CALayer *effectsLayer = [CALayer layer];
#ifdef STANDARD
    NSString *wallpaper = @"NatGeo01.jpg";
    effectsLayer.contents = (__bridge id)([Utilities bundledImage:(wallpaper? wallpaper:@"niagara.png")
                                              inRelativeDirectory:@"SnapticaGallery/2-Nature"].CGImage);
#else
    effectsLayer.contents = (__bridge id)[UIImage imageNamed:@"Flower.jpg"].CGImage; // [SettingsVC myLaunchImage].CGImage;
#endif
    effectsLayer.opacity = 0.5f;
    effectsLayer.frame = self.view.bounds;
    effectsLayer.contentsGravity = kCAGravityResizeAspectFill;
    [pageScrollView.layer insertSublayer:effectsLayer atIndex:0];

    
    pageScrollView.scrollView.backgroundColor = [UIColor clearColor];
    
    //self.navigationController.navigationBar.tintColor = [Theme mainColor];
    
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:5];
    
    NSArray *imagesArray;
    
    imagesArray = [self loadWelcomeConfig];
    if (!imagesArray) {
        imagesArray = [Utilities bundledRawImages: WELCOME_RESOURCES];  // alpha ordered images instead..
    }
    self.imagesCount = [imagesArray count];
    
    
    CGSize screensize = [self.view bounds].size;
    _pageToolTips = [[NSMutableArray alloc] init];
    _pageFillScale = [[NSMutableArray alloc] init];
    
    for (id imageConfig in imagesArray) {
        _welcomeScreen = [[UIView alloc] init];
        _welcomeScreen.backgroundColor = [UIColor clearColor]; // COLORFROMHEX(0xffe1cdc8); // COLORFROMHEX(0xff08394e);
        _welcomeScreen.contentMode = UIViewContentModeScaleAspectFill;
        _welcomeScreen.clipsToBounds = YES;

//        NSString *imgName;
        UIImage *image;
        WelcomeConfig *config = nil;
        
        if ([imageConfig isKindOfClass:[NSString class]]) {
            // It is the image name,
//            imgName = imageConfig;
            image = [UIImage imageNamed:imageConfig];
        } else {
            config = [[WelcomeConfig alloc] initWithDictionary: imageConfig];
            // Find out the image name for this page..
            NSString *name = config.image;
            
            NSString *imgName = [[NSBundle mainBundle] pathForResource:name ofType:nil inDirectory:WELCOME_RESOURCES];
            image = [UIImage imageWithContentsOfFile: imgName];

            
        }
//        UIImage *image = [UIImage imageNamed:imgName];
//        if (image == nil) {
//            image = [UIImage imageWithContentsOfFile: imgName];
//        }

        
        
        // MAIN IMAGE in the middle part
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGFloat width = screensize.width * config.fill;
        CGFloat height = (screensize.height - 48 - 20) *config.fill;
        CGFloat deltaX = (screensize.width - width) / 2;
        CGFloat deltaY = 48 + ((screensize.height - 48 - 20) - height) / 2;
        imageView.frame = CGRectMake(deltaX, deltaY, width, height);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.tag = IMAGEVIEW_TAG;
        
        // Compute the actual scale based on how the image fits withing the imageView frame
//        CGFloat scale = [[UIScreen mainScreen] scale];
        CGFloat w = image.size.width; // / scale;
        CGFloat h = image.size.height; //  / scale;
        CGFloat w_ratio = width / w;
        CGFloat h_ratio = height / h;
        CGFloat image_ratio;
        if (w_ratio < h_ratio) {
            image_ratio = w_ratio;
        } else {
            image_ratio = h_ratio;
        }
        [_pageFillScale addObject:[NSNumber numberWithFloat:image_ratio]];
        
        [_welcomeScreen addSubview:imageView];
        
        // TITLE (IF ANY)
        if (config) {
            UILabel *title = [[UILabel alloc] initWithFrame: CGRectMake(0, 12, viewBounds.size.width, 24)];
            title.text = config.title;
            title.font = [UIFont fontWithName:[Theme fontName] size:20];
            title.textColor = [Theme mainColor];
            title.textAlignment = NSTextAlignmentCenter;
            
            [_welcomeScreen addSubview:title];
        }

        // Check if there are tooltips
//        if (config.tooltips)
        {
            //
            //
            [_pageToolTips addObject:config.tooltips];
        }
        
        _welcomeScreen.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [views addObject:_welcomeScreen];
    }
    
    [pageScrollView setScrollViewContents:views];
    _pageViews = views;

#ifdef ONLYIFNONAVIGATIONBAR
    // Done or Skip Button
    CGRect frame = [self.view bounds];
    _doneButton = [UIButton buttonWithType: UIButtonTypeCustom/*UIButtonTypeRoundedRect*/];
    _doneButton.center = CGPointMake(frame.size.width - 32, 44);
    _doneButton.bounds = CGRectMake(0, 0, 50, 24);
    _doneButton.showsTouchWhenHighlighted = YES;
    _doneButton.backgroundColor = [Theme mainColor];
    _doneButton.alpha = 0.7;
    NSString *doneTitle =  @"Skip";
    [_doneButton setTitle: doneTitle forState: UIControlStateNormal];
    _doneButton.titleLabel.font = [UIFont fontWithName:[Theme fontName] size:14];
    _doneButton.titleLabel.textColor = [UIColor whiteColor];
    [_doneButton addTarget:self action:@selector(skipButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _doneButton];
#endif
        
    self.skipButton = [[UIButton alloc ]initWithFrame:CGRectMake((self.view.bounds.size.width - 80) / 2, self.view.bounds.size.height - 64, 80, 32)];
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    self.skipButton.backgroundColor = [Theme mainColor];
    [self.view addSubview:self.skipButton];
    self.skipButton.userInteractionEnabled = YES;
    [self.skipButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandlerView:)];
    _tapGesture.numberOfTapsRequired = 1;
    _tapGesture.delegate = self;

    
    
}

- (void) viewDidAppear:(BOOL)animated
{
    // Initial call to the pageChanged
    [self pageChanged:0];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[[pageScrollView.layer sublayers] objectAtIndex:0] removeFromSuperlayer];
}

- (void) viewWillLayoutSubviews {
    CGFloat scrollViewWidth = self.view.bounds.size.width;
    CGRect pageFrame = CGRectMake((self.view.bounds.size.width - scrollViewWidth), 0, scrollViewWidth, self.view.bounds.size.height);
    [self.pageScrollView setFrame:pageFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *) loadWelcomeConfig
{
    NSError *error;
    
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"Welcome" ofType:@"json" inDirectory:WELCOME_RESOURCES];
    if ([[NSFileManager defaultManager] fileExistsAtPath:configFilePath]) {
        @try {
            
            NSData *data = [NSData dataWithContentsOfFile:configFilePath];
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            
#ifdef DEBUG
            DLog(@"count=%lu", (unsigned long)[json count]);
#endif
            if (error) {
#ifdef DEBUG
                NSString * line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                DLog(@"Ret: %@", line);
#endif
                return  nil;
                
            } else {
                return json[@"pages"];
            }
        }
        @catch (NSException *exception) {
            DLog(@"Error Occured %@ (reason: %@)", [exception name], [exception reason]);
            return nil;
        }
    } else {
        return nil;
    }
    


}

- (void)doneButtonPressed:(id)sender {
    
    if([self.skipButton.titleLabel.text compare:@"Done"] == 0)
    {        
        [MoWelcomeViewController setShouldRunWelcomeFlow:NO];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Rotations
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    return;
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    return;
    
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate {
    return NO;
}


- (void) pageChanged: (int) newPage
{
    _currentPage = newPage;
    if(newPage == self.imagesCount - 1)
    {
        [self.skipButton setTitle:@"Done" forState:UIControlStateNormal];
    } else if(newPage == self.imagesCount - 2) {
        // If the user goes backwards by 1, we may want to change the label to Skip...
        [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    }
    if ([_pageToolTips[newPage] count] > 0) {
        //
        DLog(@"Has tooltips on page: %d", newPage);
        // Initiate the Tooltips now...
        self.skipButton.hidden = YES;
        _currentTooltip = 0;
        [self.pageScrollView removeGestureRecognizer:_tapGesture];
        [self showTooltip];
    } else {
        _currentTooltip = -1;
        self.skipButton.hidden = NO;
        // Add a gesture Recognizer to allow to tap to the next page...
        [self.pageScrollView addGestureRecognizer:_tapGesture];
    }
}

- (void)tapHandlerView:(UITapGestureRecognizer*)sender
{
    _currentPage += 1;
    if (_currentPage >= self.imagesCount) {
        _currentPage = 0;
    }
    [self.pageScrollView jumpToPage:_currentPage];
    [self pageChanged: (int) _currentPage];
}

-(void)scrollStarted
{
    DLog(@"Scroll Started");
    POPBasicAnimation *buttonAnimation = [POPBasicAnimation animation];
    buttonAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    buttonAnimation.fromValue = @(1.0);
    buttonAnimation.toValue = @(0.3);
    [self.skipButton pop_addAnimation:buttonAnimation forKey:@"skipAlpha"];

}

-(void)scrollEnded
{
    DLog(@"Scroll Ended");
    POPBasicAnimation *buttonAnimation = [POPBasicAnimation animation];
    buttonAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    buttonAnimation.fromValue = @(0.3);
    buttonAnimation.toValue = @(1.0);
    [self.skipButton pop_addAnimation:buttonAnimation forKey:@"skipAlpha"];

}

// Show the Tooltip

- (void) showTooltip
{
    NSMutableDictionary *tooltipDict = _pageToolTips[_currentPage][_currentTooltip];
    CGFloat fillScale = [_pageFillScale[_currentPage] floatValue];

    // Get the image Size
    
    UIImage *image = ((UIImageView *)[((UIView *)_pageViews[_currentPage]) viewWithTag:IMAGEVIEW_TAG]).image;
    
    CGSize screensize = [self.view bounds].size;
#ifdef NOTNOW
    CGFloat width = screensize.width * fillScale;
    CGFloat height = (screensize.height - 48 - 20) * fillScale;
    CGFloat deltaX = (screensize.width - width) / 2;
    CGFloat deltaY = 48 + ((screensize.height - 48 - 20) - height) / 2;
#endif
    
//    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width * fillScale; //  / scale;
    CGFloat height = imageSize.height * fillScale; //  / scale;

    CGFloat deltaX = (screensize.width - width) / 2;
    CGFloat deltaY = 48 + ((screensize.height - 48 - 20) - height) / 2;

    
    MoToolTip *tooltip = [[MoToolTip alloc] initWithDict:tooltipDict];
    // Set up the location, etc
    tooltip.delegate = self;
    UIView *oldView = [self.view viewWithTag:FAKEVIEW_TAG];
    if (oldView) [oldView removeFromSuperview];
    NSString *location;
    CGRect frame;
    if ((location = tooltipDict[@"location"])) {
        [self.view addSubview:tooltip.target];
        // RGBA
        NSArray *components = [location componentsSeparatedByString:@","];
        frame = self.view.bounds;
        if ([components count] != 4) {
            frame = CGRectMake(frame.size.width/2 - 32, frame.size.height/2 - 32, 64, 64);
        } else {
            frame = CGRectMake([WelcomeConfig intValue:components[0]], [WelcomeConfig intValue:components[1]], [WelcomeConfig intValue:components[2]], [WelcomeConfig intValue:components[3]]);
        }
    } else {
        frame = CGRectMake(frame.size.width/2 - 32, frame.size.height/2 - 32, 64, 64);
    }
    // Map the frame according to the fillScale
    CGRect newframe = CGRectMake(deltaX + frame.origin.x * fillScale, deltaY + frame.origin.y * fillScale, frame.size.width * fillScale, frame.size.height * fillScale);
    
    UIView *fakeView = [[UIView alloc] initWithFrame: newframe];
    fakeView.tag = FAKEVIEW_TAG;
    [self.view addSubview: fakeView];
    tooltip.target = fakeView;

    _currentTooltipView = [MoToolTipView showInView:self.view withTooltip:tooltip ];

}

// Tooltip Dismissed...
- (void) toolTipViewDismissed:(MoToolTipView *)toolTipView
{
    NSUInteger count = [_pageToolTips[_currentPage] count];
    _currentTooltip++;
    if (_currentTooltip >= count) {
        self.skipButton.hidden = NO;
        [self.pageScrollView addGestureRecognizer:_tapGesture];
        return;
    } else {
        [self showTooltip];
    }
    
}

@end



@implementation WelcomeConfig

+ (int) intValue: (NSString *) numberString
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [[numberFormatter numberFromString:numberString] intValue];

}

- (instancetype) initWithDictionary: (NSDictionary *) welcomeConfigItemDict
{
    if ((self = [super init])) {
        _image = welcomeConfigItemDict[@"image"];
        _title = welcomeConfigItemDict[@"title"];
        NSString *fillstring = welcomeConfigItemDict[@"fill"];
        if (fillstring) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            _fill = [[numberFormatter numberFromString:fillstring] floatValue];
        } else {
            _fill = 1.0f;
        }

        NSArray *tips = welcomeConfigItemDict[@"tooltips"];
        NSMutableArray *tooltips = [[NSMutableArray alloc] init];
        for (NSDictionary *tip in tips) {
            /*
             "name"  : "Item 1",
             "message": "This is some helpful message for item 1",
             "location": "100,100,64,64",
             "geometry": "circle",
             "animation": "0",
             "color":  "990000",
             "font": "Avenir Next",
             "fontsize": "16"
             
             _target = [dict valueForKey:@"target"];
             _name = [dict valueForKey:@"name"];
             _color = [dict valueForKey:@"color"];
             _textColor = [dict valueForKey:@"textColor"];
             _textFont = [dict valueForKey:@"textFont"];
             _message = [dict valueForKey:@"message"];
             _delegate = [dict valueForKey:@"delegate"];
             _animation = [[dict valueForKey:@"animation"] intValue];
             _geometry = [dict valueForKey:@"goemetry"];

             */
            NSMutableDictionary *newtipDict = [NSMutableDictionary dictionaryWithDictionary:tip];
            NSString *animation = tip[@"animation"];
            if (animation) {
                newtipDict[@"animation"] = [NSNumber numberWithInt: [WelcomeConfig intValue:animation]];
            }
            NSString *colorval = tip[@"color"];
            UIColor *color;
            if (colorval) {
                // RGBA
                NSArray *components = [colorval componentsSeparatedByString:@","];
                if ([components count] != 4) {
                    color = [Theme mainColor];
                } else {
                    color = [UIColor colorWithRed:[WelcomeConfig intValue:components[0]]/255.0f green:[WelcomeConfig intValue:components[1]]/255.0f blue:[WelcomeConfig intValue:components[2]]/255.0f alpha:[WelcomeConfig intValue:components[3]]/255.0f];
                }
            } else {
                color = [Theme mainColor];
            }
            newtipDict[@"color"] = color;
            
            // font/fontSize
            NSString *fontname = tip[@"font"];
            NSString *fontSize = tip[@"fontsize"];
            int fontsize = 16;
            if (!fontname) fontname = [Theme fontName];
            if (fontSize) fontsize = [WelcomeConfig intValue:fontSize];
            UIFont *font = [UIFont fontWithName:fontname size:fontsize];
            newtipDict[@"textFont"] = font;
            
            colorval = tip[@"textcolor"];
            if (colorval) {
                // RGBA
                NSArray *components = [colorval componentsSeparatedByString:@","];
                if ([components count] != 4) {
                    color = [Theme mainColor];
                } else {
                    color = [UIColor colorWithRed:[WelcomeConfig intValue:components[0]]/255.0f green:[WelcomeConfig intValue:components[1]]/255.0f blue:[WelcomeConfig intValue:components[2]]/255.0f alpha:[WelcomeConfig intValue:components[3]]/255.0f];
                }
            } else {
                color = [Theme mainColor];
            }
            newtipDict[@"textColor"] = color;
            
            NSString *location = tip[@"location"];
            if (location) {
                newtipDict[@"location"] = location;
            }


//            MoToolTip *tooltip = [[MoToolTip alloc] initWithDict:newtipDict];
            // fake target for test
            [tooltips addObject:newtipDict];
        }
        _tooltips = tooltips;
    }
    return self;
}


@end