//
//  ViewController.m
//  LoneStar
//
//  Created by sandeep on 10/30/15.
//  Copyright © 2015 Medpresso. All rights reserved.
//

#import "ViewController.h"
#import "Utilities.h"
#import "MoRippleTap.h"
#import "UIImage+RemapColor.h"
#import "NSString+StringSizeWithFont.h"
#import "SplashTransitionViewController.h"
#import "Theme.h"
#import "SettingsMainViewController.h"

static ViewController *myself;

@interface ViewController () <BookPortalViewDelegate, UIWebViewDelegate, UIViewControllerTransitioningDelegate
#if 0
                                    , BookViewControllerDelegate
#endif
>


@property (strong, nonatomic) IBOutlet UIImageView *blurBgImage;
@property (strong, nonatomic) IBOutlet UIView      *containerView;
@property (strong, nonatomic) IBOutlet UILabel     *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel     *userLabel;
@property (strong, nonatomic) IBOutlet UILabel     *artistLabel;

@property (strong, nonatomic) IBOutlet UILabel     *elapsedTimeLabel;


@property (strong, nonatomic) IBOutlet UIView      *playPauseButtonView;

@property (strong, nonatomic) IBOutlet UIButton      *playButton;
@property (strong, nonatomic) IBOutlet UIButton      *pauseButton;

@property (nonatomic, strong) IBOutlet UIButton  *boxButton;
@property (nonatomic, strong) IBOutlet UIButton  *bookMarkButton;

// Autolayout views
@property (nonatomic, strong) IBOutlet UIView  *boxButtonView;
@property (nonatomic, strong) IBOutlet UIView  *bookMarkButtonView;
@property (nonatomic, strong) IBOutlet UIView  *tagTrackButtonView;

@property (nonatomic, strong) IBOutlet UIView  *waveFormContainerView;
@property (nonatomic, strong) IBOutlet UIView  *controlsContainerView;

#pragma mark - Interface Items
@property (nonatomic, retain) MoRippleTap       *infoTap;

@property (nonatomic, retain) UIButton          *galaxyButton;
@property (nonatomic, retain) UIButton          *backButton;

#pragma mark - Book items
@property (nonatomic, retain) UIImage           *noticePageImage;
@property (nonatomic, retain) UIWebView         *noticePageWebView;

#pragma mark - other Private Variables
@property (nonatomic, strong) NSArray *bookItems;
@property (nonatomic, strong) NSString *currentUser;

@property (nonatomic, assign) NSUInteger lastIndex;

// Some test items
@property (nonatomic, strong) NSArray *fontsArray;
@property (nonatomic, strong) NSArray *wallpaperImages;

@end

@implementation ViewController

- (NSArray *) bookItems
{
    if (!_bookItems) {
        _bookItems = @[
#ifdef SPECIFIC_PRODUCT
                       @{
                           @"name" : ShortName,
                           @"editor" : Editor,
                           @"image" : IconName
                           }
#else
                       // SHow multiple products for testing and examples
                       @{
                           @"name" : @"5MCC",
                           @"editor" : @"Frank Domino, MD",
                           @"image" : @"5mcc-2016.jpg"
                           },
                       @{
                           @"name" : @"RNDrugs",
                           @"editor" : @"Skidmore",
                           @"image" : @"RnDrug16.tif"
                           },
                       @{
                           @"name" : @"FerriDrugs",
                           @"editor" : @"Fred Ferri, MD",
                           @"image" : @"FerriCA16.tif"
                           },
                       @{
                           @"name" : @"Grays Anatomy",
                           @"editor" : @"Gray",
                           @"image" : @"GraysAnat3.tif"
                           },
                       @{
                           @"name" : @"Harriet Lane",
                           @"editor" : @"McMillan, Lee, et al",
                           @"image" : @"harrietlnped2_big.png"
                           },
                       @{
                           @"name" : @"FitzPatrick Atlas",
                           @"editor" : @"Wolff/Johnson",
                           @"image" : @"fitzatlas6_big.png"
                           },
                       @{
                           @"name" : @"5MPeds 7",
                           @"editor" : @"Michael D Cabana, MD",
                           @"image" : @"5MPC7.jpg"
                           },
#endif

                       ];
    }
    return _bookItems;
}
#define TOP_OFFSET  8

- (void) refreshGalaxyButton: (UIView *) container
{
    
    CGRect buttonFrame;
    NSString *imageName;
    SEL action;
    BOOL    backVisible = NO;
    
    if (_backButton) {
        [_backButton removeFromSuperview];
        _backButton = nil;
    }
    
#ifdef NOTYET
    if ([[AppDelegate sharedDelegate] returnAppUrlScheme] != nil) {
        buttonFrame = (CGRect){4, TOP_OFFSET+4, 22, 22};
        action = @selector(didPressBackToCallingApp:);
        imageName = @"back.png";
        backVisible = YES;
        _backButton = [[UIButton alloc] initWithFrame: buttonFrame];
        [_backButton setImage:[UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed: imageName]] forState:UIControlStateNormal];
        [_backButton addTarget:self action: action forControlEvents: UIControlEventTouchUpInside];
        [container addSubview:_backButton];
    }
#endif
    
    if (_galaxyButton) {
        [_galaxyButton removeFromSuperview];
    }
    
    buttonFrame = (CGRect) {(backVisible? 40 : 4), TOP_OFFSET, 44, 44};
    imageName  =  @"menu.png"; // @"galaxy.png";
    action = @selector(didPressSettings:);
    _galaxyButton = [[UIButton alloc] initWithFrame: buttonFrame];
    [_galaxyButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed: imageName]] forState:UIControlStateNormal];
    [_galaxyButton addTarget:self action: action forControlEvents: UIControlEventTouchUpInside];
    [container addSubview:_galaxyButton];
}


#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
  
    [self setup];
    
    _lastIndex = arc4random()%[self.bookItems count];

    _currentUser = @"sandeep@skyscape.com";
    [self refresh: self.bookItems[_lastIndex]];
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnItem:)];
    [_ipv addGestureRecognizer:tapGestureRecognizer];

}

// Hide Status Bar
- (BOOL)prefersStatusBarHidden {
    return true;
}

// Rotation possible only for the video
- (UIInterfaceOrientationMask )supportedInterfaceOrientations
{
    return  (UIInterfaceOrientationMaskLandscape|UIInterfaceOrientationMaskPortrait);
}

#pragma mark - Rotation support
- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    _infoTap.frame = CGRectMake(size.width - 32, 8, 28, 28);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup, etc
- (void) setup
{
    CGRect frame = [self.view bounds];
    _ipv.delegate = self;
    
    _infoTap = [[MoRippleTap alloc]
                initWithFrame:CGRectMake(frame.size.width - 32, 8, 28, 28)
                andImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"info.png"]]
                andTarget:@selector(didPressInfo)
                andBorder:NO
                delegate:self
                ];
    _infoTap.rippleOn = YES;
    _infoTap.rippleColor = [UIColor lightGrayColor];
    
    [self.view addSubview: _infoTap];
    

    [_userLabel setBackgroundColor:[UIColor clearColor]];
    [_userLabel setTextColor: [UIColor whiteColor] ];
    [_userLabel setTextAlignment:NSTextAlignmentCenter];
    _userLabel.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    _userLabel.layer.cornerRadius= 16;

    // insert blurring Effect
    [_blurBgImage addSubview: [Utilities addBlurVibrancyView:self.blurBgImage.bounds options:NO]];
    
    // Some variables to hold
    {
        if (myself == nil) {
            myself = self;
            self.fontsArray = @[
                                           @"Qarmic_sans_Abridged",
                                           @"Lightyears",
                                           @"Roboto-Thin",
                                           @"BebasNeue",
                                           @"Museo300-Regular",
                                           @"Pacifico"
                                           ];
            self.wallpaperImages = @[
                                                @"amazonas.png",
                                                @"billow",
                                                @"candela",
                                                @"canyon",
                                                @"Flower",
                                                @"sky",
                                                @"sunrise"
                                                ];
        }
    }
    
    [self refreshGalaxyButton:self.view];

}

#pragma mark - Tapped
- (void) tappedOnItem:(UIGestureRecognizer *) gestureRecognizer
{
    _lastIndex = (_lastIndex + 1) % [self.bookItems count];

    [self refresh: self.bookItems[_lastIndex]];


}

- (void)didPressInfo {
    // Open the Book Controller

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    BookViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"BookViewController"];
   
    UIImage *aboutPage = [ViewController screenshot: self.titleLabel.text size:self.view.bounds.size posterImage:nil category:self.artistLabel.text];
    
    UIImage *leftInsideCover = [UIImage imageNamed:@"Skyscape_Galaxy_Page.jpg"];
    
    Book *book = [[Book alloc] initWithDict: @{
                        @"pages" : @[leftInsideCover, self.ipv.coverImage, aboutPage, _noticePageImage, [Utilities setupScreenshot:self.view], @"page.png"],
//                        @"actions" : @[],
                        @"name" :  self.bookItems[_lastIndex][@"name"],
                        @"editor" : self.bookItems[_lastIndex][@"editor"],

                        @"cover" : self.ipv.coverImage
                        }];
    controller.book = book;
    controller.currentUser = _currentUser;
    controller.recognizer = nil;
#if 0
    controller.delegate = self;
#endif
    
    [self presentViewController:controller animated:YES completion:nil];
    
}

#pragma mark - Set items on the screen
- (void) refresh: (NSDictionary *) currentItem
{
    UIImage *bookImage = [UIImage imageNamed: currentItem[@"image"]];
    _ipv.coverImage = bookImage;
    
    
    _blurBgImage.image = bookImage;
    
    self.titleLabel.text = currentItem[@"name"];
    self.artistLabel.text = currentItem[@"editor"];
    _userLabel.text = _currentUser;
    
    
    UIFont *font = _userLabel.font;
    CGSize labelSize = [_currentUser sizeWithFontSafe:font];

    CGRect frame = _userLabel.frame;
    CGPoint center = _userLabel.center;
    frame.size.width = labelSize.width+20;
    _userLabel.frame = frame;
    _userLabel.center = center;
    
    self.noticePageWebView = [self createNoticeWebView];

}

// Create a Album ...
+ (UIImage *) screenshot: (NSString *) name
                    size: (CGSize) screenshotSize
             posterImage: (UIImage *) poster
                category: (NSString *) category
{
    CGRect frame = CGRectZero;
    frame.size = screenshotSize;
    
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0.0);
    
    __unused int randomIndex = arc4random() % [myself.fontsArray count];
    int randomImageIndex = arc4random() % [myself.wallpaperImages count];
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor darkGrayColor]; //[UIColor colorWithPatternImage:[UIImage imageNamed:audioUtilities->wallpaperImages[randomImageIndex]]];
    view.layer.contents =  (__bridge id)[UIImage imageNamed:myself.wallpaperImages[randomImageIndex]].CGImage;
    
    CALayer *baseLayer = [[CALayer alloc] init];
    
    baseLayer.frame = frame;
    
    CALayer *insetLayer = [[CALayer alloc] init];
    CGRect insetFrame = frame;
    
    int borderSize = 30 + (arc4random() % (int)screenshotSize.width/6);
    insetFrame.origin.x +=borderSize;
    insetFrame.origin.y +=borderSize;
    insetFrame.size.height -= (2*borderSize);
    insetFrame.size.width  -= (2*borderSize);
    
    insetLayer.frame = insetFrame;
    randomImageIndex = arc4random() % [myself.wallpaperImages count];
    
    //    insetLayer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:audioUtilities->wallpaperImages[randomImageIndex]]].CGColor;
    if (poster) {
        insetLayer.contents = (__bridge id) poster.CGImage;
        insetLayer.cornerRadius = insetFrame.size.height / 2;
        insetLayer.masksToBounds = YES;
        insetLayer.contentsGravity = kCAGravityResizeAspectFill;
    } else {
//        Don't put an inset insetLayer.contents = (__bridge id)([UIImage imageNamed:myself.wallpaperImages[randomImageIndex]].CGImage);
    }
    
    
    
    UIFont *headlineFont = [UIFont fontWithName:@"Helvetica Neue" size:64];
    if (headlineFont == nil) headlineFont = [UIFont systemFontOfSize:64];
    // add a small layer on the top
    CGSize maximumSize = CGSizeMake(insetFrame.size.width - 30, 72);
    NSString *myString = category;
    
    CGRect temprect = [myString boundingRectWithSize:maximumSize Font:headlineFont];
    CGSize myStringSize = temprect.size;
    
    CATextLayer *headerText = [self createTextLayer:[UIColor redColor] font: headlineFont size: 64];
    headerText.frame = CGRectMake((insetFrame.size.width-myStringSize.width)/2, borderSize + 20, myStringSize.width, myStringSize.height+20);
    headerText.string = myString;
    
    
    
    CALayer *imageLayer = [[CALayer alloc] init];
    imageLayer.frame = CGRectMake(10, (frame.size.height - 72), 256, 64);
    imageLayer.contents = (__bridge id)([UIImage imageNamed:@"Mobiuso-Logo-256x64.png"].CGImage);
    
    
    UIFont *bodyFont = [UIFont fontWithName:@"Helvetica Neue" size:64];
    if (bodyFont == nil) bodyFont = [UIFont systemFontOfSize:64];
    // add a small layer on the top
    maximumSize = CGSizeMake(screenshotSize.width - 30, 300);
    NSString *body = [NSString stringWithFormat: @"%@", (name?name:@"")];
    
    temprect = [body boundingRectWithSize:maximumSize Font:bodyFont];
    CGSize bodySize = temprect.size;
    
    
    CATextLayer *bodyText = [self createTextLayer:[UIColor whiteColor] font: bodyFont size: 64];
    bodyText.frame = CGRectMake(insetFrame.origin.x+(insetFrame.size.width-bodySize.width)/2, insetFrame.origin.y + 300, bodySize.width, bodySize.height + 20);
    bodyText.string = body;
    bodyText.wrapped = YES;
    bodyText.alignmentMode = kCAAlignmentCenter;
    
    
    
    [view.layer addSublayer: baseLayer];
    [baseLayer addSublayer: insetLayer];
    [insetLayer addSublayer:headerText];
    [baseLayer addSublayer: imageLayer];
    [baseLayer addSublayer:bodyText];
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return returnImage;
    
    
}

#pragma mark - Utilities
+ (CATextLayer *) createTextLayer: (UIColor *) foregroundColor font: (UIFont *) font size: (CGFloat) fontSize
{
    CATextLayer *layer = [CATextLayer layer];
    layer.opacity = 1.0f;
    layer.shadowOpacity = 1.0f;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.foregroundColor = [foregroundColor CGColor];
    layer.font = (__bridge CFTypeRef)(font.fontName);
    layer.fontSize = fontSize;
    layer.zPosition = 0;
    layer.alignmentMode = kCAAlignmentCenter;
    
    layer.shadowOffset = CGSizeMake(0, 8);
    layer.shadowRadius = 16;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.15;
    return layer;
}


#pragma mark - InteractivePlayer Delegate
/* BookPortalViewDelegate METHODS */

- (void) actionOneButtonTapped: (UIButton *) sender isSelected: (BOOL) selected
{
    DLog(@"One: %@", selected? @"Selected" : @"Not selected");
    SplashTransitionViewController *splash = [[SplashTransitionViewController alloc] initWithNibName:@"SplashTransitionViewController" bundle:nil];
    [self presentViewController:splash animated:YES completion:^{
        splash.signatureImageView.image = _ipv.coverImage;
        splash.splashDuration = 0;
        splash.aboutTitle.text = _titleLabel.text;
        splash.moreInformation = [NSString stringWithFormat:@"%@ - licensed to %@", [_titleLabel.text uppercaseString], [_currentUser uppercaseString]];
    }];
    
}

- (void) actionTwoButtonTapped: (UIButton *) sender isSelected: (BOOL) selected
{
    DLog(@"Two: %@", selected? @"Selected" : @"Not selected");
    _lastIndex = (_lastIndex + 1) % [self.bookItems count];
    
    [self refresh: self.bookItems[_lastIndex]];
    

    
}

- (void) actionThreeButtonTapped: (UIButton *) sender isSelected: (BOOL) selected
{
    DLog(@"Three: %@", selected? @"Selected" : @"Not selected");
    
}

#ifdef NOTNOW
#pragma mark - BookViewControllerDelegate
- (void) bookPageTapped: (NSInteger)page
{
    DLog(@"Tapped : %ld", page);

    SplashTransitionViewController *splash = [[SplashTransitionViewController alloc] initWithNibName:@"SplashTransitionViewController" bundle:nil];
    [self presentViewController:splash animated:YES completion:^{
        splash.signatureImageView.image = _ipv.coverImage;
        splash.splashDuration = 0;
        splash.aboutTitle.text = _titleLabel.text;
    }];

    
}
#endif

#pragma mark - Views for creating About Thumbnails
- (UIWebView *) createNoticeWebView
{
    // Get the File for the notice somewhere - for now from the
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"license" ofType:@"html" inDirectory:nil];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
//    UIView *rootView = [[AppDelegate sharedDelegate] rootView];
    CGRect frame = [Utilities applicationFrame];
    frame.origin.x += frame.size.width;
    UIWebView *webView = [[UIWebView alloc] initWithFrame: frame];
    
    [webView  setScalesPageToFit:YES];
    webView.delegate = self;
    [webView  loadRequest: request];
    
    [self.view addSubview: webView];

    return webView;
}

#pragma mark - WebView
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    __unused CGSize z =  webView.scrollView.contentSize;
    self.noticePageImage = [Utilities setupScreenshot:webView];
    DLog(@"Size: (%f, %f)", self.noticePageImage.size.width, self.noticePageImage.size.height);
    [webView removeFromSuperview];
//    NSData *data = UIImageJPEGRepresentation(screenshot, 1.0);
}

#pragma mark - Settings
- (void) didPressSettings: (id) sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Settings" bundle:nil];
    
    
    SettingsMainViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    
    controller.transitioningDelegate = self;
    controller.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:controller animated:YES completion:nil];
    
    
}

@end
