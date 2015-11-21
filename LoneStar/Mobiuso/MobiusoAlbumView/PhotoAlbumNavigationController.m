
//
//  AlbumViewController.m
//
//
//

#import "PhotoAlbumNavigationController.h"

#import "AppDelegate.h"
#import "Theme.h"
#import "Utilities.h"
//#import "Utils.h"
#import "PhotoObject.h"
//#import "FolderDetailViewController.h"
#import "PhotoDetailViewController.h"
//#import "MobiusoMapActionView.h"
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLRegion.h>
#import <CoreLocation/CLVisit.h>
#import "PhotoPreviewVC.h"
#import "HomeVC.h"

@import CoreLocation;


#import "PhotoCell.h"

#import "ADVAnimationController.h"
#import "DropAnimationController.h"
#import "ZoomAnimationController.h"
#import "SliceAnimationController.h"
#import "TransitionOperator.h"

#import "NSString+StringSizeWithFont.h"
#import "MoProgressView.h"

//#import "PhotoViewController.h"
//#import "PhotoScrollerCommon.h"

//#import "MarkupIO.h"

//#import "SettingsMainViewController.h"

#import "MoRippleTap.h"

#import "Strings.h"

#import <Photos/Photos.h>

#import "MoImageViewController.h"
#import "MoImageInfo.h"
#import "MoShelfPlusStickyHeader.h"
#import "MobiusoBubblePopup.h"
#import "CacheManager.h"

typedef enum {
    LayoutVersion1 = 0,
    LayoutVersion2,
    LayoutVersion3,
    LayoutVersionCount
} LayoutVersion;

static CGSize AssetGridThumbnailSize;

#define HELP_BUBBLE_TAG 20140811
#define MARK_BUTTON_TAG_BASE 10000
#define INFO_BUTTON_TAG_BASE 20000
#define SELECT_BUTTON_TAG_BASE 30000
#define SHOW_HIDE_BUTTON_TAG_BASE 40000


#define ALBUMLIST_PICKER    100
#define AREASOFINTEREST_PICKER  101

#define NavigationAtRootLevel (_root == nil)


@interface PhotoAlbumNavigationController () <PHPhotoLibraryChangeObserver>
{
    BOOL                        loading;
    BOOL                        waitingToReload;
    BOOL                        selectionMode;
    BOOL                        selectionModeAll;

    NSArray                     *menuIcons;
    NSArray                     *menuHighlightIcons;
    NSArray                     *menuTitles;
    NSArray                     *menuActions;
    
    UILabel                     *noPhotos;

    MoElasticMenu               *elasticMenu;

    UIImageView                 *filterPanel;

    UIImageView                 *actionPanel;

    NSArray                     *folderImages;

    NSArray                     *headerImages;

    // Tag
    NSString                    *tagString;

    //
    // Filter and search
    //
    
    // DATE
    NSString                    *dateFilterString;
    
    NSDate                      *dateFilterExact;
    
    NSArray                     *dateFilterMatchArray;  // array of strings that must be matched eg "Jan", "14" - will match all assets in Jan 2014

    // LOCATION - OR MAP - given a location and radius or given a map region in a rectangle, find the photos
    
    NSString    *locationFilterString;

    CLLocation  *locationFilter;    // Location to search
    
    CGSize      locationAccuracy;   // distance in Meters if > 1, if < 1 then the 'degrees', x and y dimensions
    
    // FILTER BY TAG or STRING
    NSString    *textFilterString;

// Context
    NavSearchType                       currentSearchType;
    
    BOOL                                currentSearchCombineWithAnd;
    
    NavActionView                       currentActionView;
    
    NavSortField                        currentSortField;
    
    NavSortType                         currentSortDirection;
    
    int                                 currentServer;
    
    
    BOOL                                keyboardShowing;
    
    NSTimer                             *searchToFireTimer;
    
    NSTimer                             *photosLibraryChangeTimer;

    BOOL                                autoSearch;
    
    UICollectionView                    *savedHackReferenceToCollectionView;   //
    
    NSArray                             *albumList;
    
    NSArray                             *poiList;
    
    NSString                            *albumTitle;
}

// Phone Photo Roll
@property (nonatomic, retain) NSArray   *collectionsFetchResults;
@property (nonatomic, retain) NSArray   *collectionsLocalizedTitles;
@property (nonatomic, retain) NSMutableArray *collectionsBeingShown;

@property (nonatomic, retain) NSMutableArray *filteredItemsIndexArray;

@property (strong) PHCachingImageManager *imageManager;

// Regular
@property (nonatomic, strong) id<ADVAnimationController>    animationController;

@property (nonatomic, strong) PhotoObject                   *currentItem;
@property (nonatomic, assign) NSInteger                     layoutType;

@property (nonatomic, retain) NSMutableArray                *markedFiles;
@property (nonatomic, strong) NSString                      *localMarkedFileName;

@property (nonatomic, retain) NSMutableArray                *selectedItems;

@property (nonatomic, retain) NSArray                       *photosEtc;
@property (nonatomic, retain) NSArray                       *filteredPhotosEtc;
@property (nonatomic, retain) NSArray                       *folders;

@property (nonatomic, assign) BOOL                          hasFolders; // are there any folders (yet)?
@property (nonatomic, assign) BOOL                          hasPhotos; // are there any photos (yet)?

@property  (nonatomic, retain) IBOutlet UIButton            *closeButton;

@property (nonatomic, assign) BOOL                          showingMarkedFilesOnly;

@property (nonatomic, retain) UIButton                      *filterButton;

@property (nonatomic, retain) MoArcMenu                     *floatingMenu;

// For panning for select
@property (strong, nonatomic) NSIndexPath                   *lastAccessed;

@property (nonatomic, strong) UINib                         *headerNib;

@property (nonatomic, retain) UIImage                       *checkMarkImage;

@property (nonatomic, retain) UIImage                       *plusImage;

@end



@implementation PhotoAlbumNavigationController

@synthesize root = _root;

#if 0
- (void) layoutTopButtons
{
    UIButton *layoutButton = [[UIButton alloc] initWithFrame:(CGRect){0,0,36,36}];
    [layoutButton setImage:[UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed:@"icon-layout-72.png"]] forState:UIControlStateNormal];
    [layoutButton setImage:[UIImage RemapColor:[Theme signatureColor] maskImage:[UIImage imageNamed:@"icon-layout-72.png"]] forState:UIControlStateHighlighted];
    [layoutButton addTarget:self action:@selector(didPressSwitchLayout:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *layoutButtonItem = [[UIBarButtonItem alloc] initWithCustomView:layoutButton];
    
    
    _filterButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [_filterButton setImage: [UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed: (_showingMarkedFilesOnly? @"icons-star-solid.png" : @"icons-star.png")] ] forState:UIControlStateNormal];
    [_filterButton setFrame:CGRectMake(-6,0,30,30)];
    [_filterButton addTarget:self action:@selector(didPressFilterMarked) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *filterBarButton = [[UIBarButtonItem alloc]  initWithCustomView:_filterButton];
    
    
    // UIBarButtonItem *arcButton = [[UIBarButtonItem alloc]  initWithCustomView:[self menuOptions]];
    
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -12;// it was -6 in iOS 6
    
#if 0
    UIButton *leftButton;
    if (!self.root) {
        leftButton = [[UIButton alloc] initWithFrame:(CGRect){0,0,30,30}];
        [leftButton setImage:[UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed:@"menu.png"]] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(didPressSettings:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        leftButton = [[UIButton alloc] initWithFrame:(CGRect){0,0,22,22}];
        [leftButton setImage:[UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed:@"back.png"]] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(menuBackAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    // self.navigationItem.leftBarButtonItem = settingsButtonItem;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, leftButtonItem];
#endif
    
    self.navigationItem.rightBarButtonItems = @[/*geoButton, arcButton,*/ negativeSpacer,  layoutButtonItem, filterBarButton];

}
#endif

#pragma mark - title
- (void) setTitle:(NSString *)title
{
    // Navigation Bar tap action
    UITapGestureRecognizer* tapRecon = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(navigationBarTap:)];
    tapRecon.numberOfTapsRequired = 1;
    CGSize size = [self.view bounds].size;
    
    UIView *titleView;
    if (title) {
        UILabel *shim = [[UILabel alloc] init];
        UIFont *titleFont = [UIFont fontWithName:[Theme fontName] size:16];
        CGRect rect = [title boundingRectWithSize:size Font:titleFont];
        shim.frame = CGRectMake(0, 0, rect.size.width, 44);
        shim.text = title;
        shim.textColor = [Theme mainColor];
        titleView = shim;
    } else {
        // Add the Header Image
        UIImageView *shim = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Snaptica-Header-2.png"]];
        shim.frame = CGRectMake(0, 0, 192, 36);
        titleView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 192, 36)];
        titleView.userInteractionEnabled = YES;
//        shim.contentMode = UIViewContentModeCenter;
        [titleView addSubview:shim];
    }
    
    // shim.backgroundColor = [UIColor blackColor];
    self.navigationItem.titleView = titleView;
    [titleView addGestureRecognizer:tapRecon];
    [titleView setUserInteractionEnabled:YES];

}

#if 0
- (void) setProgressView
{
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:(id) COLORFROMHEX(0xff96e9ff).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0x80a9c9f9).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0x547fe4fe).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0xff96e9ff).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0xc0a9c9f9).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0x447fe4fe).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0xff96e9ff).CGColor ];
    CGRect frame = [Utilities applicationFrame];
    progressView = [[MoGradientProgressView alloc] initWithFrame:CGRectMake(0,244, frame.size.width, 5)];
    
    [progressView setGradientColors:colors];
    
    [self.view addSubview: progressView];
    progressView.progress = 1.0f;
}

- (void) startProgressView
{
    if (!progressView) {
        [self setProgressView];
    }
    progressView.hidden = NO;
    [self.view bringSubviewToFront:progressView];
    [progressView startAnimating];
}

- (void) stopProgressView
{
    [progressView stopAnimating];
    progressView.hidden = YES;
}
#else
- (void) setProgressView
{
    progressView = [[MoProgressView alloc] initWithView:self.view];
#if 0
    UIImageView *hudBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 256, 256)];
    hudBGView.image = [UIImage imageNamed:@"logo"];
    progressView.customView = hudBGView;
    progressView.mode = MoProgressViewCustomView; // MoProgressHUDModeCustomView;
#endif
    [self.view addSubview:progressView];

}

- (void) startProgressView
{
    if (!progressView) {
        [self setProgressView];
    }
//    progressView.hidden = NO;
    [self.view bringSubviewToFront:progressView];
    [progressView show: YES];
}

- (void) stopProgressView
{
    [progressView hide:NO];
//    progressView.hidden = YES;
}

#endif

CGFloat statusBarHeight()
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

#pragma mark - refresh a server
- (void) refresh
{
    [self setupLayout];
    
    NSString *title;
    if (self.root) {
        NSArray *arr = [self.root componentsSeparatedByString:@":"];
        title = arr[[arr count]-1];
    }
    
    BOOL remove = NO;
    if (currentSearchType != NavSearchTypeNone) {
        title = [NSString stringWithFormat:@"[%ld Photos]", (unsigned long)[_filteredItemsIndexArray count]];
        [self showFilterPanel];
        [elasticMenu removeFromSuperview];
        remove = YES;
    } else {
        if (_showingMarkedFilesOnly) {
            title = [NSString stringWithFormat:@"[%ld Favorite]", (unsigned long)[_assetsFetchResults count]];   // show this count
        } else {
            [self hideFilterPanel];
        }
    }
    
    if (selectionMode) {
        [self showActionPanel];
        remove = YES;
    } else {
        [self hideActionPanel];
    }
    
    if (remove) {
        [elasticMenu removeFromSuperview];
    } else {
        [self addElasticMenu:EMOrientationRight stripDirection:EMDirectionHorizontalFront];
    }
    
    [self setTitle:title];

    [self reload];
    
//    20150718 [self stopProgressView];
    

}

- (void) reset
{
    _hasFolders = NO;
    _hasPhotos = NO;
    [self loadAlbums];
    [self refresh];
}

#pragma mark - User Close Response
- (void) closeAction: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.collectionView = nil;
        self.background = nil;
    }];
}

#pragma mark - Setup
- (void) setBackgroundEffect
{
    CALayer *layer = self.collectionView.layer;
    
    if (_background) {
//        UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:0.25];    // COLORFROMHEX(0x10d71341); //
                                                                         //    UIImage *blurred =  [screenshot applyBlurWithRadius:12 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
        UIImage *blurred = _background; //  [_background applyTintEffectWithColor:tintColor];
        MLog(@"Background Image size: %@", [HomeVC displayMemory: CGImageGetHeight(blurred.CGImage) * CGImageGetBytesPerRow(blurred.CGImage)]);
        layer.contents = (__bridge id)(blurred.CGImage);
        layer.contentsGravity = kCAGravityResizeAspectFill;
    } else {
        self.collectionView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"wild_oliva.png"]]; //  // Wood-Planks
    }
    
}

- (void) addButtons
{

    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(self.view.frame.size.width - 40, 8, 32, 32);
        [_closeButton addTarget:self action:@selector(menuBackAction) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed: @"dismissButtWHITE"/* @"closeThin.png"*/]] forState:UIControlStateNormal];
        [self.view addSubview:_closeButton];
    } else {
        _closeButton.frame = CGRectMake(self.view.frame.size.width - 40, 8, 32, 32);
        
    }

}

#pragma mark - View lifecycle
- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addButtons];
    
    currentServer = 0 ; // [[SettingsManager instance] currentServer];
//    if ((currentServer<0) && (_root))
    {
        _imageManager = [[PHCachingImageManager alloc] init];
        [self.imageManager stopCachingImagesForAllAssets];
//        self.previousPreheatRect = CGRectZero;

    }
    
    currentSortDirection = NavSortTypeDescending;
    currentSortField = NavSortFieldModificationDate;
    
    currentSearchType = NavSearchTypeNone;
    currentSearchCombineWithAnd = YES;  // By default all conditions have to be true
    
    _filteredItemsIndexArray = nil;
    
    _checkMarkImage = [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-checkmark-solid-72.png"]];
    
    _plusImage = [UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed:@"menu-plus-solid-72.png"]];
    
#ifdef FILE_DEBUG
    if ([self respondsToSelector:@selector(topLayoutGuide)])
    {
        DLog(@"Top: %f", self.topLayoutGuide.length);
    }
#endif
    progressView = nil;

    waitingToReload = NO;

#ifdef DO_PAN_SELECTION
    // init gesture for multiple selection with panning
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanForSelection:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
#endif
    // init gesture for Selection of multiple items
    longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongTapForSelection:)];
    longTapGestureRecognizer.minimumPressDuration = 0.75;
    [self.view addGestureRecognizer:longTapGestureRecognizer];
    
    _selectedItems = [[NSMutableArray alloc] init];     // initially none selected...
    
#ifdef HANDLE_FOREGROUND
    // add observer for refresh
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnterForeground:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
#endif
    
    // Here we add the keyboard notification
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
     
                                               object:nil];
    
    keyboardShowing = NO;
    
    _layoutType = [[SettingsManager instance] intVal:kSettingNavigationLayoutKey];   // Do it from preferences
    
    if (_layoutType < 0) {
        [self didPressSwitchLayout:nil];
    }

    
    CGRect frame = [Utilities applicationFrame];
    frame.origin.y = frame.size.height / 3;
    frame.origin.x = 50;
    frame.size.height = 40;
    frame.size.width -= 100;
    
    noPhotos = [[UILabel alloc] initWithFrame: frame];
    noPhotos.backgroundColor = [UIColor clearColor];
    noPhotos.layer.cornerRadius = 4.;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    layer.backgroundColor = [UIColor blackColor].CGColor;
    layer.cornerRadius = 6.0f;
    layer.opacity = 0.5f;
    [noPhotos.layer addSublayer:layer];

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
  
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = @"NO PHOTOS";
    
    [noPhotos addSubview:textLabel];
 
    noPhotos.hidden = YES;
    
    [_collectionView addSubview:noPhotos];
    
    albumTitle = @"All Photos";
    
    // Load the Album
#if 0
    [self layoutTopButtons];
#endif
    
    [self setupLayout];

    [self setBackgroundEffect];
    
    // For settings screen
    // self.animationController = [[ZoomAnimationController alloc] init];
    // self.animationController = [[DropAnimationController alloc] init];
    // self.animationController = [[SliceAnimationController alloc] init];
    self.animationController = [[TransitionOperator alloc] init];

//   20150718 [self startProgressView];

    [self reset];
    
    
    

}

#if 0
- (void) presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    DLog(@"Presenting Next ...");
//    [UIView animateWithDuration:0.4 delay:0.0 options:0 animations:^{
//    } completion:nil];
    
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}
#endif

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat scale = [UIScreen mainScreen].scale;
    //        RFQuiltLayout* layout = (id)self.collectionView.collectionViewLayout;
    CGSize cellSize = [Theme blockPixels];
    //    CGSize cellSize = ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

#if 0
- (void) viewWillDisappear:(BOOL)animated
{
    DLog(@"\n\n>>>>>> viewWillDisappear.\n\n");
    if ([self isMovingToParentViewController]) {
        DLog(@"isMovingToParentViewController");
    }
    if ([self isMovingFromParentViewController]) {
        DLog(@"isMovingFromParentViewController");
    }
    [super viewWillDisappear:animated];
    self.collectionView = nil;
    self.background = nil;
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    DLog(@"\n\n>>>>>> viewDidDisappear.\n\n");
    if ([self isMovingToParentViewController]) {
        DLog(@"isMovingToParentViewController");
    }
    if ([self isMovingFromParentViewController]) {
        DLog(@"isMovingFromParentViewController");
    }
    [super viewDidDisappear:animated];
    
}
#endif

- (void) setupLayout
{
#if STICKY_HEADER// Sticky Header
    
    self.headerNib = [UINib nibWithNibName:@"MoShelfPlusStickyHeader" bundle:nil];
    // Also insets the scroll indicator so it appears below the search bar
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self.collectionView registerNib:self.headerNib
          forSupplementaryViewOfKind:GridLayoutHeaderStickyHeader
                 withReuseIdentifier:@"header"];
    // End of Sticky Header
#endif
    [self reloadLayout];
}

// Parallax stuff
#if STICKY_HEADER   // Sticky Header
- (void)reloadLayout {
    
    MobiusoQuiltLayout* layout = (id)_collectionView.collectionViewLayout;
    layout.direction = UICollectionViewScrollDirectionVertical;
    
    // Make it proportional to screen
    layout.blockPixels = [Theme blockPixels];
#if STICKY_HEADER// Sticky Header
    
    layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, [MoShelfPlusStickyHeader maxHeight]);
    layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(self.view.frame.size.width, [MoShelfPlusStickyHeader minHeight]);
    //        layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height);
    layout.parallaxHeaderAlwaysOnTop = YES;
    
    // If we want to disable the sticky header effect
    layout.disableStickyHeaders = YES;
#endif
    
}
#endif

#pragma mark - Rotations and Status Bar Viewing
// The following causes a problem with hiding and showing the statusbar button.  If the property changes then the back button
// does not work properly.
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         __unused UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         DLog(@"Orientation: %ld", (long)orientation);
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         DLog(@"Size: %f, %f", size.width, size.height);
         [self refresh];
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}

#pragma mark - User actions
#define UNKNOWN_SEARCH      -1
#define GENERAL_SEARCH      0
#define RESOLUTION_SEARCH   1
#define DATE_SEARCH         2

#pragma mark MoShelfStickyHeaderDelegate Methods

- (void) infoButtonPressed: (id) sender
{
    MobiusoBubblePopup *bubblePop = [[MobiusoBubblePopup alloc] initWithFrame:[self.view bounds] withOrientation:MBOrientationNorthWest andDuration:15.0f];
    bubblePop.delegate = self;
    bubblePop.tag = HELP_BUBBLE_TAG;
    [self.view addSubview:bubblePop];
    
    
    [bubblePop showMessage: _helpInformation withTitle:_stickyTitle andSubtitle: @"Usage Information"];
}

- (void) searchButtonPressed:(id)sender
{
    [self.collectionView setContentOffset:CGPointMake(0, 0)];
    [_stickyHeaderCell.searchBar performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1.0f];
    

}

#pragma mark - Generalized Search Action
- (void) initiateSearch: (NSString *) searchString withType: (NSInteger) typeIndex
{
    DLog(@"Text: %@", searchString);
    if ((searchString == nil) || ([searchString length] == 0)) {
        // Error Message.. or Sound
        return;
    }
    
    textFilterString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger resolvedTypeIndex = typeIndex;
    // Try to resolve if we don't know what we are looking for...
    if (typeIndex == UNKNOWN_SEARCH) {
        
        NSCharacterSet *resolutionCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789x$+><="];
        if ([textFilterString rangeOfCharacterFromSet:[resolutionCharacters invertedSet]].location == NSNotFound) {
            // This is a resolution string
            DLog(@"Resolution string");
            resolvedTypeIndex = RESOLUTION_SEARCH;
        }
        if ([textFilterString hasPrefix:@"$"]) {
            // iPhone screen resolutions
            if ([textFilterString rangeOfString:@"$iphone4" options:NSCaseInsensitiveSearch].location == 0) { // works for 4S as well
                textFilterString = @"=640x960";
            } else if ([textFilterString rangeOfString:@"$iphone5" options:NSCaseInsensitiveSearch].location == 0) { // works for 5S as well
                textFilterString = @"=640x1136";
            } else if ([textFilterString rangeOfString:@"$iphone6+" options:NSCaseInsensitiveSearch].location == 0) {
                textFilterString = @"=1080x1920";
            } else if ([textFilterString rangeOfString:@"$iphone6" options:NSCaseInsensitiveSearch].location == 0) {
                textFilterString = @"=750x1334";
            } else if ([textFilterString rangeOfString:@"$ipad" options:NSCaseInsensitiveSearch].location == 0) {
                textFilterString = @"=1536x2048";
            }
            resolvedTypeIndex = RESOLUTION_SEARCH;
        }
        if ([textFilterString hasPrefix:@"/"]) {
            // iPhone camera resolutions
            if ([textFilterString rangeOfString:@"/iphone4" options:NSCaseInsensitiveSearch].location == 0) { // works for 4S as well
                textFilterString = @"=2448x3264";
            } else if ([textFilterString rangeOfString:@"/iphone5" options:NSCaseInsensitiveSearch].location == 0) { // works for 5S as well
                textFilterString = @"=2448x3264";
            } else if ([textFilterString rangeOfString:@"/iphone6" options:NSCaseInsensitiveSearch].location == 0) { // works for 6+ as well
                textFilterString = @"=2448x3264";   // 6+ front is 1280x960
            }
            // TODO iPad
            resolvedTypeIndex = RESOLUTION_SEARCH;
        }
        
        // Try date now
        {
            dateFilterString = [textFilterString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            
            // NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
            
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:usLocale];
            NSDate *date = [dateFormatter dateFromString:textFilterString];
            if (date == nil) {
                dateFormatter.dateStyle = NSDateFormatterMediumStyle;
                date = [dateFormatter dateFromString:textFilterString];
            }
            if (date == nil) {
                dateFormatter.dateStyle = NSDateFormatterLongStyle;
                date = [dateFormatter dateFromString:textFilterString];
            }
            
            //
            NSString *formattedDateString;
            if (date) {
                DLog(@"Exact Date is: %@", [dateFormatter stringFromDate:date]);
                dateFilterExact = date; // find the exact date
                dateFilterMatchArray = nil;
                [dateFormatter setDateFormat:@"yyyyMMdd"];
                formattedDateString =  [dateFormatter stringFromDate:date];
                resolvedTypeIndex = DATE_SEARCH;
            } else {
                // parse for reasonable string ...
                dateFilterMatchArray = [textFilterString componentsSeparatedByString:@" "];
                dateFilterExact = nil;
                [dateFormatter setDateFormat:@"dd:MMM:yyyy"];
                // Do further analysis and see if it is indeed date or not
                NSMutableArray *months = [NSMutableArray arrayWithObjects:@"January",@"February", @"March", @"April", @"May",@"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
                
                
                BOOL matches = YES;
                for (NSString *word in dateFilterMatchArray) {
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", word]; // if you need case sensitive search avoid '[c]' in the predicate
                    
                    NSArray *results = [months filteredArrayUsingPredicate:predicate];
                    if ([results count] == 0) {
                        // Try if it is a number
                        NSCharacterSet *numberCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
                        if ([word rangeOfCharacterFromSet:[numberCharacters invertedSet]].location != NSNotFound) {
                            // something other than numbers included,
                            matches = NO;
                            break; // no need to carry on
                        }
                    } else {
                        // continue, this is good...
                    }
                }
                
                if (matches) {
                    resolvedTypeIndex = DATE_SEARCH;
                } // Else general search
            }

            
            
#ifdef REFERENCE
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            
            // NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
            
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:usLocale];
            if (dateFilterExact) {
                DLog(@"Exact Date is: %@", [dateFormatter stringFromDate:dateFilterExact]);
                [dateFormatter setDateFormat:@"yyyyMMdd"];
                formattedDateString =  [dateFormatter stringFromDate:dateFilterExact];
            } else {
                // parse for reasonable string ...
                //[dateFormatter setDateFormat:@"dd:MMM:yyyy"];
                [dateFormatter setDateStyle:NSDateFormatterFullStyle];
            }
#endif
            
        }
    }
    switch (resolvedTypeIndex) {
        case GENERAL_SEARCH: // Any string
        case UNKNOWN_SEARCH:
        {
//            20150718[self startProgressView];
            [self filterAssets:NavSearchTypeByString];
//            20150718[self stopProgressView];
//            20150718[self refresh];
        }
            
            break;
        case RESOLUTION_SEARCH: // Pixel Resolution
        {
//            20150718[self startProgressView];
            [self filterAssets:NavSearchTypeByString];
//            20150718[self stopProgressView];
//            20150718[self refresh];
        }
            break;
            
        case DATE_SEARCH: // Date
        {
//            20150718[self startProgressView];
            [self filterAssets:NavSearchTypeByDate];
//            20150718[self stopProgressView];
//            20150718[self refresh];
        }
            break;
        default:
            break;
    }
    
}


#pragma mark - SearchBar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    if (searchToFireTimer) {
        [searchToFireTimer invalidate];
        searchToFireTimer = nil;
    }
    currentSearchType = NavSearchTypeByString;
    textFilterString = [searchBar text];
    if (!autoSearch) {
        [_stickyHeaderCell.searchBar resignFirstResponder];
    }
    [self initiateSearch: textFilterString withType:UNKNOWN_SEARCH];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar                    // called when cancel button pressed
{
    // Save the previous search string and remove the keyboard
    currentSearchType = NavSearchTypeNone;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
#ifdef SEARCH_DEBUG
    DLog(@"Search text: %@", searchText);
#endif
    if (searchToFireTimer) {
        [searchToFireTimer invalidate];
    }
    // Put a delay of few seconds
    // Fire IAP timer
    searchToFireTimer = [NSTimer scheduledTimerWithTimeInterval:5  target:self selector:@selector(searchToFire:)  userInfo:nil repeats:NO];
    
}

- (void) searchToFire: (NSTimer *) timer
{
    autoSearch = YES;
    [self searchBarSearchButtonClicked: _stickyHeaderCell.searchBar];
    searchToFireTimer = nil;
}
- (void) tappedOnStickyHeader: (id) sender
{
    if (searchToFireTimer) {
        [searchToFireTimer invalidate];
    }
    [_stickyHeaderCell.searchBar resignFirstResponder];
    autoSearch = NO;
}

- (void) tappedOnClearSearchLabel: (id) sender
{
    [_stickyHeaderCell.searchBar resignFirstResponder];
    _filteredItemsIndexArray = nil;
    currentSearchType = NavSearchTypeNone;
    _stickyHeaderCell.searchBar.text = @"";
    [self refresh];
    
}

#ifdef DO_PAN_SELECTION

// for multiple selection with panning
- (void)onPanForSelection:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    double fX = [gestureRecognizer locationInView:_collectionView].x;
    double fY = [gestureRecognizer locationInView:_collectionView].y;
    
    for (UICollectionViewCell *cell in _collectionView.visibleCells)
    {
        float fSX = cell.frame.origin.x;
        float fEX = cell.frame.origin.x + cell.frame.size.width;
        float fSY = cell.frame.origin.y;
        float fEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (fX >= fSX && fX <= fEX && fY >= fSY && fY <= fEY)
        {
            NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
            
            if (_lastAccessed != indexPath)
            {
                [self collectionView:_collectionView didSelectItemAtIndexPath:indexPath];
            }
            
            _lastAccessed = indexPath;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        _lastAccessed = nil;
        _collectionView.scrollEnabled = YES;
    }
}
#endif

// for preview

- (void)onLongTapForSelection:(UILongPressGestureRecognizer *)gestureRecognizer
{
#if  defined(PHOTO_NAV_DEBUG)
    DLog(@"Long tap");
#endif
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        selectionMode = !selectionMode;
        if (!selectionMode) {
            // clear everything and scram
            for (PhotoObject *selitem in _selectedItems) {
                selitem.imageSelected = NO;
            }
            _selectedItems = [[NSMutableArray alloc] init];
            selectionModeAll = NO;
        } else {
            if (_root) {
                double fX = [gestureRecognizer locationInView:_collectionView].x;
                double fY = [gestureRecognizer locationInView:_collectionView].y;
                
                
                //                    NSIndexPath *indexPath = nil;
                for (UICollectionViewCell *cell in _collectionView.visibleCells)
                {
                    float fSX = cell.frame.origin.x;
                    float fEX = cell.frame.origin.x + cell.frame.size.width;
                    float fSY = cell.frame.origin.y;
                    float fEY = cell.frame.origin.y + cell.frame.size.height;
                    
                    if (fX >= fSX && fX <= fEX && fY >= fSY && fY <= fEY)
                    {
                        // NOT NEEDED indexPath = [_collectionView indexPathForCell:cell];
                        PhotoObject *item = ((PhotoCell *) cell).item;
                        item.imageSelected = YES;   // initially it will be
                        [_selectedItems addObject:item];
                        break;
                    }
                }
            }
            
        }
        [self refresh]; // was reload
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL shouldRecognize = NO;
    
    return shouldRecognize;
}
#pragma mark - Download (or acquire from Cache) Actual Photos
#ifdef TEMP
- (void)downloadImageWithURL:(NSURL *)url withFileName: (NSString *) fileName completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    //
    // If the cache has the file, then return it
    //
    CacheManager *cm = [AppDelegate sharedDelegate].cacheManager;
    
    NSString *pathKey = [NSString stringWithFormat:@"%@:%@", self.root, fileName];
    
    if ([cm fileExistsInCache: pathKey]) {
        // Load up the image and return the reference
        NSData *data = [cm fileData: pathKey];
        if (data) {
            completionBlock(YES,[UIImage imageWithData: data]);
            return;
        }
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   // reacuire the cachemanager so we are not carrying the reference around
                                   CacheManager *cm = [AppDelegate sharedDelegate].cacheManager;
                                   // Tuck the data to the Cache...
                                   [cm cacheData: data forFile: pathKey];
                                   
                                   UIImage *image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}
#endif

#pragma mark - Manage Content/Files

- (void) loadAlbums
{
    // Request the directory
//    NSString *serverAddress = [AppDelegate currentHostAddress];
//    if (BuiltInPhotoGallery)
    {
        // Load the default Photo Albums
        // Root level
        
        if (NavigationAtRootLevel) {
            
            PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
            userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];

            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES]];
            
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:options];
            PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:options];
            self.collectionsFetchResults = @[topLevelUserCollections, smartAlbums];
            self.collectionsLocalizedTitles = @[NSLocalizedString(@"Albums", @""), NSLocalizedString(@"Smart Albums", @"")];
            self.collectionsBeingShown = [NSMutableArray arrayWithArray: @[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES]]];
            
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

        } else {
        
            // we need to update the assetFetchResults...
            _assetsFetchResults = [self photosList:_assetCollection];
            // we should have the results loaded in the  _assetCollection & _assetsFetchResults
            DLog(@"count = %ld", (unsigned long)[_assetsFetchResults count]);
            if (currentSearchType != NavSearchTypeNone) {
                DLog(@"Filtered count = %ld", (unsigned long)_filteredItemsIndexArray.count);
            }
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
        }
        
        [self reload];
//        20150718[self stopProgressView];

    }
}
- (void) reload
{
    // safely reload Data - if populating then wait
    if (loading) {
        // delay it
        waitingToReload = YES;
    } else {
        [_collectionView reloadData];
    }
}
//
// After the Directory has been read, parse the list
//
- (void) populateData: (NSData *) data
{
    NSError *error;
    
    loading = YES;
    
    NSArray* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          
                          options:kNilOptions
                          error:&error];
#if  defined(PHOTO_NAV_DEBUG) || defined(WEB_DEBUG)
    DLog(@"count=%lu", (unsigned long)[json count]);
#endif
    if (error) {
#ifdef DEBUG
        NSString * line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        DLog(@"Ret: %@", line);
#endif
    }
    
    NSMutableArray *folders = [[NSMutableArray alloc] init];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[json count]];
    // NSMutableArray *markedItems = [NSMutableArray arrayWithCapacity:[json count]];
    
    int i=0;
    
    for (NSDictionary *item in json) {
        // DLog(@"%@", item);
        // IssueItem *singleitem = [IssueItem issueItemWithDict:item];
        
        PhotoObject *singleitem = [[PhotoObject alloc] init];
        
        
        singleitem.date = item[@"lastmod"];
        singleitem.title = [item[@"name"] lastPathComponent];
        singleitem.descriptionX = item[@"type"];
        singleitem.size = item[@"size"];
        
        if (IS_EQUAL(item[@"type"], @"dir")) {

            singleitem.imageName = folderImages[i%[folderImages count]]; // @"DefaultAlbumFolder1.png";
            i++;
            
            // Need to get proper imageURL from the returned name (which is in the file system representation)
            if (item[@"poster"]) {
                /* http://54.225.255.140/Snaptica/image/img.php?src=/home/bitnami/htdocs/Snaptica/Users/sandeep131/albums/2014/Israel-2014/02-DeadSea-Masada-20130526/NEX7-Small/DSC06637.JPG&w=1024&h=200
                NSString *filename = [NSString stringWithFormat: @"%@%@/file/file=%@:%@", kServer, kProduct, [item[@"name"] stringByReplacingOccurrencesOfString:@"/" withString:@":"], item[@"poster"]]; */
                
                NSString *serverAddress = [AppDelegate currentHostAddress];
 
                NSString *filename = [NSString stringWithFormat: @"%@/%@/%@/image?src=%@/%@", serverAddress, kCompany, kProduct, item[@"name"], item[@"poster"]];
#ifdef NOTNOW

                DLog(@"File: %@", filename);
                NSURL *imageURL = [NSURL URLWithString:filename];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                if (imageData) {
                    singleitem.image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
                }
#else
#ifdef IMAGE_DEBUG
                DLog(@"image being shown: %@", singleitem.imageName);
#endif
                singleitem.image = [UIImage imageNamed:singleitem.imageName];
                singleitem.imageName = UrlSafeString(filename);
#endif
            }
            singleitem.itemType = FolderItem;
            
            
            [folders addObject:singleitem];
        } else {

            // Check if we are dealing with images (JPG) - ignore others
            NSString *name = item[@"name"];
            if ([name hasPrefix:@"/"]) {
                DLog(@"absolute name: %@", name);
                name = [name lastPathComponent];
            }
            FileType type = [Utilities fileType: name];
            NSString *serverAddress = [AppDelegate currentHostAddress];
            
            switch (type) {
                case FileTypeJPEG:
                {
                    /*
                     singleitem.imageName = [NSString stringWithFormat: @"%@%@/file/file=%@", kServer, kProduct, [item[@"name"] stringByReplacingOccurrencesOfString:@"/" withString:@":"]];
                     */
                    NSString *pathKey = [NSString stringWithFormat: @"%@:%@", self.root?self.root:kAlbums, name];
                    singleitem.imageName = [[NSString stringWithFormat: @"%@/%@/%@/file/user=%@/path=%@", serverAddress, kCompany, kProduct, kAnonymousUser, pathKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

//                    singleitem.imageName = [NSString stringWithFormat: @"%@/%@/image?src=%@", serverAddress, kProduct, item[@"name"]];
                    singleitem.imageDownloaded = NO;
                    
                    singleitem.image = [UIImage imageNamed:@"DefaultPhoto2.png"];
                    singleitem.itemType = PhotoItem;
                    
                    // Add only if an image (check JPG, PNG, etc)...
                    [items addObject:singleitem];
                        
                    singleitem.imageMarked = (NSNotFound != [_markedFiles indexOfObject:[name lastPathComponent]]);
                }
                    
                    break;
                    
                case FileTypeText:

                {
                    NSString *filename = [name lastPathComponent];
                    if (IS_EQUAL(filename, MARKED_FILENAME)) {
#if  defined(PHOTO_NAV_DEBUG) || defined(WEB_DEBUG)

                        DLog(@"Found MarkedFile.txt! %@", name);
                        
#endif
                        // Don't do anything at all [self downloadMarkedFile:name];
                        
                    }
                }
                    
                default:
                    break;
            }
        }
    }
    
    self.folders = folders;
    if ([folders count] > 0) _hasFolders = YES; else _hasFolders = NO;
    self.photosEtc = items;
    if ([items count] > 0) _hasPhotos = YES; else _hasPhotos = NO;
    
    loading = NO;
    if (waitingToReload) {
        [_collectionView reloadData];
    }
}

// Given the relativePath (or fullpath), generate the directory upto the leaf level - return the full path
- (NSString *) createDirectory: (NSString *) relativePath inRootPath: (NSString *) rootPath
{
    NSString *delimiter = nil;
    NSString *dir = @"";
    NSRange index = [relativePath rangeOfString:@"/"];
    if (index.location != 0)  {
        delimiter = @"/";
    }
    if (index.location != NSNotFound) {
        // find out the leading components and create directories if necessary
        index = [relativePath rangeOfString:@"/" options:NSBackwardsSearch];
        dir = [relativePath substringToIndex:index.location];
        NSLog(@"path=%@", dir);
    }
    
    NSString *appDir = delimiter? [NSString stringWithFormat:@"%@%@%@", rootPath, delimiter, dir] : dir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:appDir])
    {
        NSError *err = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:appDir
                                       withIntermediateDirectories:YES attributes:nil error:&err])
        {
            NSLog(@"DDFileLogManagerDefault: Error creating directory: %@", err);
            return nil;
        }
    }
    
    return delimiter? [NSString stringWithFormat:@"%@%@%@", rootPath, delimiter, relativePath] : relativePath;
}
//
- (NSString *) mirrorPath: (NSString *) file
{
    NSString *regularPath = [file stringByReplacingOccurrencesOfString:@":" withString:@"/"];
    NSString *delimiter = [regularPath hasPrefix:@"/"] ?@"": @"/";
    NSString *mirrorPath = [NSString stringWithFormat:@"%@%@%@",[AppDelegate pictFolder],
                           delimiter,
                           regularPath];
    return mirrorPath;
    
}

#ifdef NOTNOW

// Clones Data to File System Path specified
- (NSString *)clone: (NSString *) file withData: (NSData *) data
{
    
    // Stash this file for usage & update in the
    CacheManager *cm = [AppDelegate cacheManager];
    NSString *fullpath = [cm stashData:data forFile:file];
    
    // copy blindly, later check the existence of the file and whether we have new data
//    BOOL success = [data writeToFile: fullpath atomically:YES];
#if  defined(PHOTO_NAV_DEBUG) || defined(WEB_DEBUG)
    DLog(@"result=%@", fullpath);
#endif
    
    return (fullpath);
}

- (NSString *)clone: (NSString *) file withArray: (NSArray *) lines
{

    CacheManager *cm = [AppDelegate cacheManager];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    for (NSString *line in lines) {
        [data appendData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData: [@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSString *fullpath = [cm stashData:data forFile:file];
    NSLog(@"result=%@", fullpath);
    return (fullpath);
}

// Write JSON file - in the Backup area
- (BOOL) clone: (NSString *) file withDictionary: (NSDictionary *) dict
{
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    CacheManager *cm = [AppDelegate cacheManager];
    NSString *fullpath = [cm stashData:jsonData forFile:file];
    NSLog(@"result=%@", fullpath);
    return (fullpath);
    
}
#endif

struct psuedoIndexPath {
    int row;
    int section;
};
typedef struct psuedoIndexPath pseduoIndexPath;

- (pseduoIndexPath) indexForRow: (NSUInteger) itemIndex
{
    NSUInteger count1 = [_collectionsBeingShown[0] boolValue]?[(PHFetchResult *)_collectionsFetchResults[0] count]:0;
    NSUInteger count2 = [_collectionsBeingShown[1] boolValue]?[(PHFetchResult *)_collectionsFetchResults[1] count]:0;

    pseduoIndexPath result;
    result.row = -1;
    result.section = -1;
    
    if (itemIndex > (count1+count2+4) ) {
        result.row = -1;
        result.section = -1;
    } else if (itemIndex >= count1+3) {
        result.row = (int) (itemIndex - (count1+3));
        result.section = 2;
    } else if (itemIndex >= 2) {
        result.row = (int) (itemIndex - 2);
        result.section = 1;
    } else {
        result.row = (int) itemIndex;
        result.section = 0;
    }
    return result;
}

- (ItemType) itemType: (NSUInteger) itemIndex
{
    NSUInteger row = itemIndex;
//    if (BuiltInPhotoGallery)
    {
        if (NavigationAtRootLevel) {
            // First item is All Photos
            BOOL showing = [_collectionsBeingShown[0] boolValue];
            NSUInteger count1 = showing? [(PHFetchResult *)_collectionsFetchResults[0] count] : 0;
//            NSUInteger count2 = [(PHFetchResult *)_collectionsFetchResults[0] count];
            
            if ((row==0) || (row == 2) ||
                (row == (count1+3))) {
                return FolderHeaderItem;
            } else {
                return FolderItem;
            }
        } else {
            return PhotoItem;
        }
    }
}


#ifdef NOTNOW
#pragma mark - Marked Files Management
- (NSMutableArray *) markedFileInCurrentDirectory
{
    NSString *file = [NSString stringWithFormat: @"%@:%@", self.root?self.root:@"", MARKED_FILENAME];
    NSString *serverAddress = [AppDelegate currentHostAddress];
    NSString *nameUrlString = [NSString stringWithFormat: @"%@/%@/%@/file/user=%@/file=%@", serverAddress,
                               kCompany,
                               kProduct,
                               kAnonymousUser,
                               [file stringByReplacingOccurrencesOfString:@"/" withString:@":"]];
    
    NSURL *url = [NSURL URLWithString:UrlSafeString(nameUrlString)];
    CacheManager *cm = [AppDelegate sharedDelegate].cacheManager;
    __weak PhotoAlbumNavigationController *weakSelf = self;
    [cm downloadFileWithURL:url
                   withPath:file
            completionBlock:^(BOOL succeeded, NSData *fileData, NSString *errorMessage) {
                if (succeeded) {
                    _localMarkedFileName = [self clone:file withData:fileData];
                    // TODO - if the lines could be read from the NSData - do so (to avoid reading the file again)
                    _markedFiles = [MarkupIO loadMarkupsFromFile: _localMarkedFileName];
#if  defined(PHOTO_NAV_DEBUG) || defined(WEB_DEBUG)
                    DLog(@"%@", _localMarkedFileName);
                    DLog(@"Found %ld items in the markup [%@]", (unsigned long)[_markedFiles count], _localMarkedFileName);
#endif
                    [weakSelf reload];
                } else {
                    _markedFiles = [[NSMutableArray alloc] init];
                    [self handleErrorString:errorMessage];
                }
    }];
    return nil; // this is not yet populated

}

- (void) setMarkedFileInCurrentDirectory: (NSArray *) markedFiles
{
    NSString *file = [NSString stringWithFormat: @"%@:%@", self.root?self.root:@"", MARKED_FILENAME];
    [self clone:file withArray:markedFiles];
}

// The following is not used
- (void) loadMarkedFile: (NSString *) content
{
        //
    
}

- (NSArray *) reconcileMarkedFiles
{
    // Iterate each item for the folder and build an array by checking against Marked Files
    NSMutableArray *relevant = [[NSMutableArray alloc] init];
    // More efficient to scan it once
    for (PhotoObject *photo in _photosEtc) {
        if ([_markedFiles containsObject:photo.title]) {
            [relevant addObject:photo];
        }
    }
    return relevant;
}
#endif

#pragma mark - Builtin Files Sidecar files ".exif"
// Exif + other info
- (NSDictionary *) loadPhotoExifFile: (NSString *) file
{
    //
    return nil;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
        return 1; // [self.collectionsFetchResults count] + 1;
}

// Does not do Multiple Sections, so we fool the Layout ...
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSUInteger count;
    // For Local Server
//    if (BuiltInPhotoGallery)
    {
        if (NavigationAtRootLevel) {
            count = 2; // For all photos + the main header
            int i = 0;
            for (PHFetchResult *fetchResult in self.collectionsFetchResults) {
                BOOL showing = [_collectionsBeingShown[i] boolValue];
                count += (showing? fetchResult.count : 0) + 1;
                i++;
            }
        } else {
            // Photo level
            count = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray count] : [_assetsFetchResults count];
            noPhotos.hidden = (count>0);

        }

    }
    return count;
}

#ifdef STICKY_HEADER
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger section = indexPath.section;
    
    
    // Check the kind if it's GridLayoutHeaderParallaxHeader
    if ([kind isEqualToString:GridLayoutHeaderStickyHeader]) {
        
        MoShelfPlusStickyHeader *cell = (MoShelfPlusStickyHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                      withReuseIdentifier:@"header"
                                                                                                             forIndexPath:indexPath]; // Was UICollectionReusableView
        
        cell.titleLabel.text = _stickyTitle;
        NSUInteger sectioncount = 1;
        NSUInteger count = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray count] : [_assetsFetchResults count];
        cell.supplementaryInfoLabel.text = cell.supplementaryInfoLabel2.text = (sectioncount>1)?[NSString stringWithFormat:@"%ld items [%ld sections]", (unsigned long)count, (unsigned long)sectioncount] :
        [NSString stringWithFormat:@"%ld item(s)%@", (unsigned long)count, (currentSearchType != NavSearchTypeNone) ? @" (Clear)" : @""];
        
        UITapGestureRecognizer* clearTap = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(tappedOnClearSearchLabel:)];
        UITapGestureRecognizer* clearTap2 = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(tappedOnClearSearchLabel:)];
        clearTap.numberOfTapsRequired = 1;
        if (self.filteredItemsIndexArray) {
            cell.supplementaryInfoLabel.layer.borderWidth = cell.supplementaryInfoLabel2.layer.borderWidth = 1.0f;
            [cell.supplementaryInfoLabel2 addGestureRecognizer:clearTap2];
            [cell.supplementaryInfoLabel addGestureRecognizer:clearTap];
        } else {
            cell.supplementaryInfoLabel.layer.borderWidth = cell.supplementaryInfoLabel2.layer.borderWidth = 0.0;
            [cell.supplementaryInfoLabel2 removeGestureRecognizer:clearTap2];
            [cell.supplementaryInfoLabel removeGestureRecognizer:clearTap];
        }
        cell.searchBar.delegate = self;

#if 0
        cell.selectorControl.items = @[ @"Albums"];
        cell.selectorControl.font = [UIFont fontWithName:[Theme fontName] size:14];
        cell.selectorControl.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        cell.selectorControl.selectedIndex = 0;
        

        [cell.selectorControl addTarget:self action:@selector(selectorControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.selectorControl addTarget:self action:@selector(selectorControlTapped:) forControlEvents:UIControlEventTouchUpInside];
#endif

        [cell.selectorButton setTitle:albumTitle forState:UIControlStateNormal];
        
        cell.delegate = self;
        

        UIButton *layoutButton = [[UIButton alloc] initWithFrame:(CGRect){cell.frame.size.width - 80, 6, 36, 36}];
        [layoutButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"icon-layout-72.png"]] forState:UIControlStateNormal];
        [layoutButton setImage:[UIImage RemapColor:[Theme signatureColor] maskImage:[UIImage imageNamed:@"icon-layout-72.png"]] forState:UIControlStateHighlighted];
        [layoutButton addTarget:self action:@selector(didPressSwitchLayout:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:layoutButton];

        UIButton *cameraButton = [[UIButton alloc] initWithFrame:(CGRect){cell.frame.size.width - 120, 6, 36, 36}];
        [cameraButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"camera.png"]] forState:UIControlStateNormal];
        [cameraButton setImage:[UIImage RemapColor:[Theme signatureColor] maskImage:[UIImage imageNamed:@"camera.png"]] forState:UIControlStateHighlighted];
        [cameraButton addTarget:self action:@selector(didPressCamera:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:cameraButton];

        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(tappedOnStickyHeader:)];
        singleTap.numberOfTapsRequired = 1;
        [cell addGestureRecognizer:singleTap];

        autoSearch = NO;

        //        NSInteger randomBkg = arc4random()%3;
        //        NSString *imageName = [NSString stringWithFormat:@"bkg%ld-blur.jpg", (long)randomBkg];
        //        cell.bkg.image = [UIImage imageNamed:imageName];
        
//        if (self.viewController) {
//            if ([(MoShelfPlusViewController *)self.viewController respondsToSelector: @selector(dataSources)])
//            {
//                NSArray *sources = [(MoShelfPlusViewController *)self.viewController  dataSources];
//                {
//                    NSMutableArray *segmentArray = [[NSMutableArray alloc] init];
//                    for (MoShelfPlusDataSource *datasource in sources) {
//                        [segmentArray addObject:datasource.shortTitle];
//                    }
//                    cell.selectorControl.items = segmentArray;
//                    cell.selectorControl.font = [UIFont fontWithName:[Theme fontName] size:14];
//                    cell.selectorControl.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3];
//                    cell.selectorControl.selectedIndex = 0;
//                    [cell.selectorControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
//                }
//            }
//        }
//
        
        // Tuck this in for future reference
//        stickyHeaderCell = cell;
        
        return cell;
        
    }
    
    return nil;
}

#endif


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier;
    PhotoObject *item;
    PhotoCell *cell;

    //
    //
    // BuiltIn Photos
    //
    //
//    if (BuiltInPhotoGallery)
    {
        
        BOOL infoButtonShown = YES;

        NSUInteger row = indexPath.row;

        NSString *showHide;
        
        if (NavigationAtRootLevel) {
            
            switch (row) {
                case 0:
                    CellIdentifier = @"HeaderCell";
                    item = [[PhotoObject alloc] init];
                    item.title = [[NSString stringWithFormat: @"[%@]", [AppDelegate currentHostDisplayName] ] uppercaseString];
                    item.image = [UIImage imageNamed: @"bkg1"];
                    break;
                    
                case 1:
                    
                    CellIdentifier = @"FolderCell";
                    item = [[PhotoObject alloc] init];
                    item.title = @"All Photos";
                    break;
                    
                default:
                    CellIdentifier = @"FolderCell";
                    int row = (int) indexPath.row - 2;  // reduce 1 for the All Photos & 1 for Header Cell
                    for (int i=0; i < [self.collectionsFetchResults count]; i++) {
                        PHFetchResult *fetchResult = self.collectionsFetchResults[i];
                        BOOL showing = [_collectionsBeingShown[i] boolValue];
                        int count = showing? (int)[fetchResult count]: 0;
                        if (row <= count) {
                            if (row==0) {
                                CellIdentifier = @"HeaderCell";
                                item = [[PhotoObject alloc] init];
                                item.title = [_collectionsLocalizedTitles[i] uppercaseString];
                                item.image = [UIImage imageNamed: @"niagara"];
                                infoButtonShown = NO;
                                showHide = showing ? @"HIDE" : @"SHOW";
                            } else {
                                PHCollection *collection = fetchResult[row-1];
                                item = [[PhotoObject alloc] init];
                                item.title = collection.localizedTitle;
                            }
                            break;
                        }
                        row -= count + 1;
                    }
                    item.imageName = folderImages[indexPath.row%[folderImages count]]; // @"DefaultAlbumFolder1.png";
                    break;
            }
        } else {
            CellIdentifier = @"PhotoCell";
            item = [[PhotoObject alloc] init];
            item.title = @"Photos";
            item.imageDownloaded = NO;
            item.indexReference = [NSNumber numberWithInteger:row];
            
            item.image = [UIImage imageNamed:@"logo"];
            item.itemType = PhotoItem;
            
        }


        cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        
        
        cell.item = item;
        cell.backgroundColor = item.background; // [UIColor whiteColor];
        if (infoButtonShown) {
            cell.infoButton.tag = INFO_BUTTON_TAG_BASE + indexPath.row;    // keep this so we know which button was pressed;
            [cell.infoButton addTarget:self action:@selector(tapOnInfoButton:) forControlEvents:UIControlEventTouchUpInside];
            cell.infoButton.hidden = NO;
            if (row == 0) {
                showHide = @"SWITCH";
            } else {
                showHide = @"INFO";
            }
        } else {
            cell.infoButton.hidden = NO;    // TEMP
            cell.infoButton.tag = INFO_BUTTON_TAG_BASE + indexPath.row;    // keep this so we know which button was pressed;
            [cell.infoButton addTarget:self action:@selector(tapOnInfoButton:) forControlEvents:UIControlEventTouchUpInside];
        }
//        [cell.infoButton setTitle: showHide forState: UIControlStateNormal];
        if (!NavigationAtRootLevel) {
            NSUInteger itemIndex = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray[indexPath.row] integerValue] : indexPath.row;
            PHAsset *asset = _assetsFetchResults[itemIndex];
            item.date = asset.creationDate;
            item.imageMarked = asset.isFavorite;
            item.imageName = [asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"#SLASH#"];
            
            // Test by writing some data out
            [self.imageManager requestImageForAsset:asset
                                         targetSize:AssetGridThumbnailSize
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                          
                                          // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                          cell.imageView.image = result;
                                          cell.item.image = result;
                                          cell.item.imageDownloaded = YES;
                                          
                                          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                          dateFormatter.timeStyle = NSDateFormatterNoStyle;
                                          dateFormatter.dateStyle = NSDateFormatterMediumStyle;
                                          
//                                          NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
                                          
                                          NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                                          [dateFormatter setLocale:usLocale];
//                                          DLog(@"%@", [dateFormatter stringFromDate:asset.creationDate]);
                                          cell.item.title = [dateFormatter stringFromDate:asset.creationDate];
                                          cell.fileNameLabel.text = [dateFormatter stringFromDate:asset.creationDate];
                                          cell.fileSizeLabel.text = [NSString stringWithFormat:@"[%ld x %ld]", (unsigned long)asset.pixelWidth, (unsigned long)asset.pixelHeight];
#if 0
                                          DLog(@"Dictionary: %@", info);
                                          // For now write a file out...
                                          [self clone:[NSString stringWithFormat:@"%@:%@", _root, item.imageName] withDictionary:info];
#endif
                                      }];

#if 0
            if (cell.markButton == nil) {
                cell.markButton = [[MoRippleTap alloc]
                                   initWithFrame:CGRectMake(2, 2, 32, 32)
                                   andImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:item.imageMarked?@"icons-star-solid.png":@"icons-star.png"]] // @"MenuThumbsupSolid.png":@"MenuThumbsupLine.png"
                                   andTarget:@selector(tapOnMarkButton:)
                                   andBorder:NO
                                   delegate:self
                                   ];
                cell.markButton.rippleOn = YES;
                cell.markButton.alpha = 0.8;
                cell.markButton.rippleColor = [Theme mainColor];
                [cell addSubview:cell.markButton];
            } else {
                // load the correct image based on the status
                [cell.markButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:item.imageMarked?@"icons-star-solid.png":@"icons-star.png"]]];
            }
            cell.markButton.tag = MARK_BUTTON_TAG_BASE + indexPath.row;
#endif
            // Selection Mode On
            if (selectionMode) {
                //
                // First check if the item is in the selected Item
                //
                int founditem = -1;
                for (int i=0; i < (int) [_selectedItems count] ; i++) {
                    PhotoObject *itm = _selectedItems[i];
                    if (itm.imageName && item.imageName && IS_EQUAL(itm.imageName, item.imageName)) {
                        founditem = i;
                        item.imageSelected = YES;
                        break;
                    }
                }
                if (founditem >= 0) {
                    [_selectedItems replaceObjectAtIndex:founditem withObject:item];
                } else if (selectionModeAll) {
                    // We are considering all items to be selected
                    // add the item
                    item.imageSelected = YES;
                    [_selectedItems addObject:item];
                }
                
                if (cell.selectButton == nil) {
                    CGSize size = cell.frame.size;
                    cell.selectButton = [[MoRippleTap alloc]
                                         initWithFrame:CGRectMake(size.width/2-24, size.height/2-24, 48, 48)
                                         andImage: (item.imageSelected?_checkMarkImage : _plusImage)
                                         andTarget:@selector(tapOnSelectButton:)
                                         andBorder:YES
                                         delegate:self
                                         ];
                    cell.selectButton.rippleOn = YES;
                    cell.selectButton.alpha = 0.9;
                    cell.selectButton.rippleColor = [UIColor whiteColor];
                    [cell addSubview:cell.selectButton];
                } else {
                    // load the correct image based on the status
                    [cell.selectButton setImage: (item.imageSelected?_checkMarkImage : _plusImage)];
                }
                cell.selectButton.tag = SELECT_BUTTON_TAG_BASE + indexPath.row;
                
                
            } else {
                if (cell.selectButton) {
                    [cell.selectButton removeFromSuperview];
                    cell.selectButton = nil;
                }
            }

        }
        //
        // End of Builtin PHotos
        //
       
    }
    return cell;
}


#pragma mark - UICollectionView Delegate
#ifdef NOTPOSSIBLEWITHQUILTLAYOUT
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        RecipeCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        NSString *title = [[NSString alloc]initWithFormat:@"Recipe Group #%li", indexPath.section + 1];
        headerView.title.text = title;
        UIImage *headerImage = [UIImage imageNamed:@"header_banner.png"];
        headerView.backgroundImage.image = headerImage;
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}
#endif


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (keyboardShowing) {
        [_stickyHeaderCell.searchBar resignFirstResponder];
    } else {
        [self tappedOnItemAtRow:indexPath];
    }

}
#pragma mark - Top Level Menu Actions


- (void)didPressSwitchLayout:(id)sender {
    _layoutType++;
    if (_layoutType == LayoutVersionCount) {
        _layoutType = LayoutVersion1;
    }
    
    [[SettingsManager instance] setIntVal: (int)_layoutType forKey:kSettingNavigationLayoutKey];
    [[SettingsManager instance] sync];
    
     [self.collectionView.collectionViewLayout invalidateLayout];
    [self reload];
}

- (void)didPressCamera:(id)sender {
    [self dismissViewControllerAnimated:NO completion:
     ^{
         self.collectionView = nil;
         self.background = nil;
         
         HomeVC *homeVC = [HomeVC sharedHomeVC];
         if (homeVC && [homeVC respondsToSelector:@selector(cameraButtonPressed:)]) {
             [homeVC cameraButtonPressed: nil];
         }
     }];
}



- (void) didPressFilterMarked
{
    _showingMarkedFilesOnly = !_showingMarkedFilesOnly;
    
    [_filterButton setImage: [UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed: (_showingMarkedFilesOnly? @"icons-star-solid.png" : @"icons-star.png")] ] forState:UIControlStateNormal];

//    if (BuiltInPhotoGallery)
    {
        _assetsFetchResults = [self photosList:_assetCollection];
    }
    
    [self refresh];
    
}

- (BOOL) toggleImageMark: (PhotoObject *) item
{
    item.imageMarked = !item.imageMarked;
    
//    if (BuiltInPhotoGallery)
    {
        // Get the asset first...
//        + (PHFetchResult *)fetchAssetCollectionsWithLocalIdentifiers:(NSArray *)identifiers options:(PHFetchOptions *)options
        
        [_assetsFetchResults enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
//            NSLog(@"asset %@", asset);
            if (IS_EQUAL(asset.localIdentifier, item.imageName)) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:asset];
                    [request setFavorite:![asset isFavorite]];
                } completionHandler:^(BOOL success, NSError *error) {
                    if (!success) {
                        NSLog(@"Error: %@", error);
                    }
                }];
            }
        }];
        
        
//        PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[item.imageName] options:nil];
//        if ((result == nil) || ([result count] == 0) || ([result count] > 1)) return NO;
//        PHAsset *asset = (PHAsset *) result[0];
        
    }
    
    return item.imageMarked;

}

- (BOOL) toggleImageSelection: (PhotoObject *) item
{
    item.imageSelected = !item.imageSelected;
    
//    NSString *name = [item.imageName lastPathComponent];
    if (item.imageSelected) {
        [_selectedItems addObject:item];
// no need to keep it sorted...
//        _selectedItems = [NSMutableArray arrayWithArray:[_selectedItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        
    } else {
        // You will be removing this
        [_selectedItems removeObject:item];
        // also turn off the selected mode all
        selectionModeAll = NO;  // Turn off
    }
    
    // Now update the marked file properly
    // [self setMarkedFileInCurrentDirectory:_markedFiles];
    
    return item.imageSelected;
    
}

#pragma mark - Elastic Menu
// Sandeep
- (void) addElasticMenu: (EMOrientationType) orientation stripDirection: (EMDirectionType) direction
{
    if (elasticMenu) [elasticMenu removeFromSuperview];
    
    menuIcons =  @[
                   @"menu-back-72.png",
//                   @"menu-thumbsup-72.png",
                   @"menu-filter-72.png",
                   @"menu-date-72.png",
                   @"menu-location-line-72.png",
#ifdef DOMAP
                   @"menu-map-72.png",
#endif
                   @"menu-map-72.png",
                   @"menu-refresh-72.png",
                   @"menu-cancel-72.png"
                   ];
    
    menuHighlightIcons =  @[
                            @"menu-back-solid-72.png",
//                            @"menu-thumbsup-solid-72.png",
                            @"menu-filter-solid-72.png",
                            @"menu-date-solid-72.png",
                            @"menu-location-solid-72.png",
#ifdef DOMAP

                            @"menu-map-solid-72.png",
#endif
                            @"menu-map-solid-72.png",
                            @"menu-refresh-solid-72.png",
                            @"menu-cancel-solid-72.png"
                         ];
    menuTitles = @[@"Back", /* @"Marked",*/ @"Filter", @"Date", @"Address search",
#ifdef DOMAP
                   @"Map search",
#endif
                   @"Area of Interest",
                   @"Refresh", @"Clear Filters"];
    
    menuActions = @[@"menuBackAction", /* @"didPressFilterMarked",*/ @"menuFilterAction", @"menuDateAction", @"menuAddressSearchAction",
#ifdef DOMAP
                    @"menuMapSearchAction",
#endif
                    @"menuPOIAction",
                    @"menuRefreshAction", @"menuClearFilterAction"];
    
    int rangebegin = 0;
    int rangecount = (int)[menuIcons count];
    if (NavigationAtRootLevel) { //
        rangebegin = 1;
        rangecount--;
        // range = {1, ([menuIcons count]-1)};
    }
    if (currentSearchType == NavSearchTypeNone) {
        rangecount--;
    }
    NSRange range = {rangebegin, rangecount};
    menuIcons = [menuIcons subarrayWithRange: range];
    menuHighlightIcons = [menuHighlightIcons subarrayWithRange: range];
    menuTitles = [menuTitles subarrayWithRange: range];
    menuActions = [menuActions subarrayWithRange: range];
    
    CGRect frame = [Utilities applicationFrame];
    
    // USING THE ELASTIC MENU
    
    elasticMenu = [[MoElasticMenu alloc] initWithFullFrame:frame touchDirection:orientation stripDirection: direction withDelegate:self];
    
    elasticMenu.backgroundColor = [UIColor clearColor]; // COLORFROMHEX(0xffeeeeee);
    elasticMenu.userInteractionEnabled = YES;
    [self.view addSubview: elasticMenu];
    // END OF USING THE ELASTIC MENU
}

#define FILTER_SWITCH_TAG_BASE  2015020710
#define ACTION_BUTTON_TAG_BASE  2015020723
#define ACTION_PANEL_CLOSE_BUTTON_TAG 2015020714
#define FILTER_PANEL_CLOSE_BUTTON_TAG 2015020708

- (void) setFilterPanelState: (UISwitch *) sender
{
    NSUInteger tag = sender.tag - FILTER_SWITCH_TAG_BASE;
    
    switch (tag) {
        case 0:
            if (!(currentSearchType & NavSearchTypeByString)) {
                // If it was OFF then we need to throw the dialog up
                [self menuFilterAction];
            }
            currentSearchType = (currentSearchType ^ NavSearchTypeByString); // Toggle it
            break;

        case 1:
            
            if (!(currentSearchType & NavSearchTypeByDate)) {
                // If it was OFF then we need to throw the dialog up
                [self menuDateAction];
            }
            currentSearchType = (currentSearchType ^ NavSearchTypeByDate); // Toggle it
            break;

        case 2:
            
            if (!(currentSearchType & NavSearchTypeByAddress)) {
                // If it was OFF then we need to throw the dialog up
                [self menuAddressSearchAction];
            }
            currentSearchType = (currentSearchType ^ NavSearchTypeByAddress); // Toggle it
            break;

        case 3:
            
            if (!(currentSearchType & NavSearchTypeByMap)) {
                // If it was OFF then we need to throw the dialog up
                [self menuMapSearchAction];
            }
            currentSearchType = (currentSearchType ^ NavSearchTypeByMap); // Toggle it
            break;

        default:
            break;
    }
    [self filterAssets:currentSearchType];
//   20150718 [self refresh];
    
}

- (void) showActionPanel
{
    if (actionPanel == nil) {
        CGRect frame = [Utilities applicationFrame];
        CGRect basepanelFrame = CGRectMake(0, frame.size.height - 60, frame.size.width, 60);
        
        if (IS_IOS8) {
            // Blur Effect
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            [bluredEffectView setFrame:basepanelFrame];
            
            
            // Vibrancy Effect
            UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
            UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
            // vibrancyEffectView.backgroundColor = COLORFROMHEX(0xff990000);
            [vibrancyEffectView setFrame:bluredEffectView.bounds];
            // Add Vibrancy View to Blur View
            [bluredEffectView addSubview:vibrancyEffectView];
            // Add Label to Vibrancy View
            //            [self.view addSubview: bluredEffectView];
            actionPanel = (id) bluredEffectView;

        } else {

            UIImageView *actionPanelView = [[UIImageView alloc] initWithFrame:basepanelFrame];
            actionPanelView.backgroundColor = COLORFROMHEX(0xa0000000);
            actionPanel = (id) actionPanelView;
        }
        
        
        
        [self.view addSubview:actionPanel];
        actionPanel.userInteractionEnabled = YES;

#if 0
        UIButton* showButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 50, 8, 36, 36)];
        [showButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-forward-72.png"]] forState:UIControlStateNormal];
        [actionPanel addSubview:showButton];
        [showButton addTarget:self action:@selector(openLocalSelected:) forControlEvents:UIControlEventTouchUpInside];
        showButton.tag = ACTION_BUTTON_TAG_BASE + 0;
        
        UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 50, 44, 36, 14)];
        showLabel.textColor = [UIColor whiteColor];
        showLabel.textAlignment = NSTextAlignmentCenter;
        showLabel.text = @"SHOW";
        showLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        showLabel.alpha = 1.0;
        [actionPanel addSubview:showLabel];
#endif
        
        UIButton* tagButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 50, 8, 36, 36)];
        [tagButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-write-72.png"]] forState:UIControlStateNormal];
        [actionPanel addSubview:tagButton];
        [tagButton addTarget:self action:@selector(menuTagAction) forControlEvents:UIControlEventTouchUpInside];
        tagButton.tag = ACTION_BUTTON_TAG_BASE + 1;
        
        UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 50, 44, 36, 14)];
        tagLabel.textColor = [UIColor whiteColor];
        tagLabel.textAlignment = NSTextAlignmentCenter;
        tagLabel.text = @"TAG";
        tagLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        tagLabel.alpha = 1.0;
        [actionPanel addSubview:tagLabel];
        

        UIButton* deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 100, 8, 36, 36)];
        [deleteButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-trash-line-72.png"]] forState:UIControlStateNormal];
        [actionPanel addSubview:deleteButton];
        [deleteButton addTarget:self action:@selector(menuDeleteAction) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.tag = ACTION_BUTTON_TAG_BASE + 0;
        
        UILabel *deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 100, 44, 36, 14)];
        deleteLabel.textColor = [UIColor whiteColor];
        deleteLabel.textAlignment = NSTextAlignmentCenter;
        deleteLabel.text = @"DELETE";
        deleteLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        deleteLabel.alpha = 1.0;
        [actionPanel addSubview:deleteLabel];

        UIButton* lightboxButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 150, 8, 36, 36)];
        [lightboxButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"addtolightbox.png"]] forState:UIControlStateNormal];
        [actionPanel addSubview:lightboxButton];
        [lightboxButton addTarget:self action:@selector(menuLightboxAction) forControlEvents:UIControlEventTouchUpInside];
        lightboxButton.tag = ACTION_BUTTON_TAG_BASE + 0;
        
        UILabel *lightboxLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 150, 44, 36, 14)];
        lightboxLabel.textColor = [UIColor whiteColor];
        lightboxLabel.textAlignment = NSTextAlignmentCenter;
        lightboxLabel.text = @"LIGHTBOX";
        lightboxLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        lightboxLabel.alpha = 1.0;
        [actionPanel addSubview:lightboxLabel];

        UIButton* allButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 8, 36, 36)];
        [allButton setImage: _checkMarkImage forState:UIControlStateNormal];
        [actionPanel addSubview:allButton];
        [allButton addTarget:self action:@selector(menuSelectAllAction) forControlEvents:UIControlEventTouchUpInside];
        allButton.tag = ACTION_BUTTON_TAG_BASE + 4;
        
        UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 44, 36, 14)];
        allLabel.textColor = [UIColor whiteColor];
        allLabel.textAlignment = NSTextAlignmentCenter;
        allLabel.text = @"ALL";
        allLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        allLabel.alpha = 1.0;
        [actionPanel addSubview:allLabel];

        UIButton* noneButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 8, 36, 36)];
        [noneButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-nocheckmark-72.png"]] forState:UIControlStateNormal];
        [actionPanel addSubview:noneButton];
        [noneButton addTarget:self action:@selector(menuSelectNoneAction) forControlEvents:UIControlEventTouchUpInside];
        noneButton.tag = ACTION_BUTTON_TAG_BASE + 3;
        
        UILabel *noneLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 44, 36, 14)];
        noneLabel.textColor = [UIColor whiteColor];
        noneLabel.textAlignment = NSTextAlignmentCenter;
        noneLabel.text = @"NONE";
        noneLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        noneLabel.alpha = 1.0;
        [actionPanel addSubview:noneLabel];

        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.tag = ACTION_PANEL_CLOSE_BUTTON_TAG;
        closeButton.frame = CGRectMake(frame.size.width/2 - 16, frame.size.height - 90, 32, 32);
        [closeButton addTarget:self action:@selector(clearPanelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"SimpleCloseLine.png"]] forState:UIControlStateNormal];
        closeButton.layer.cornerRadius = 16;
        closeButton.layer.backgroundColor = COLORFROMHEX(0x80000000).CGColor;
        CALayer *sublayer = [CALayer layer];
        sublayer.frame = [closeButton bounds];
        sublayer.contents = (__bridge id)([UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"SimpleCloseLine.png"]].CGImage);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview: closeButton];

    } else {
        actionPanel.hidden = NO;
        [self.view viewWithTag:ACTION_PANEL_CLOSE_BUTTON_TAG].hidden = NO;
        
    }
    
}

- (void) hideActionPanel
{
    if (actionPanel) {
        actionPanel.hidden = YES;
        UIButton *button = (UIButton *)[self.view viewWithTag:ACTION_PANEL_CLOSE_BUTTON_TAG];
        button.hidden = YES;
    }
//    [self addElasticMenu:EMOrientationRight stripDirection:EMDirectionHorizontalFront];
}

- (void) showFilterPanel
{
    if (filterPanel == nil) {
        CGRect frame = [Utilities applicationFrame];
        
        CGRect basepanelFrame = CGRectMake(0, frame.size.height - 60, frame.size.width, 60);
        
        if (IS_IOS8) {
            // Blur Effect
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            [bluredEffectView setFrame:basepanelFrame];
            
            
            // Vibrancy Effect
            UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
            UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
            // vibrancyEffectView.backgroundColor = COLORFROMHEX(0xff990000);
            [vibrancyEffectView setFrame:bluredEffectView.bounds];
            // Add Vibrancy View to Blur View
            [bluredEffectView addSubview:vibrancyEffectView];
            // Add Label to Vibrancy View
            //             [self.view addSubview: bluredEffectView];
            filterPanel = (id) bluredEffectView;
        } else {
            
            UIImageView *filterPanelView = [[UIImageView alloc] initWithFrame:basepanelFrame];
            filterPanelView = [[UIImageView alloc] initWithFrame:basepanelFrame];
            filterPanelView.backgroundColor = COLORFROMHEX(0x80000000);
        }
        
        [self.view addSubview:filterPanel];
        filterPanel.userInteractionEnabled = YES;
        
        [[UISwitch appearance] setOnTintColor:[Theme mainColor]];
//        [[UISwitch appearance] setTintColor:[UIColor colorWithRed:213.0/255 green:183.0/255 blue:165.0/255 alpha:1.000]];
//        [[UISwitch appearance] setThumbTintColor:[UIColor colorWithRed:125.0/255 green:30.0/255 blue:21.0/255 alpha:1.000]];
#ifdef DOMAP
        const int switchcount = 4;// was 4
#else
        const int switchcount = 3;// was 4
#endif
        const int switchwidth = 64;
        int switchframewidth = frame.size.width / switchcount;

        UISwitch* filterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake((switchframewidth-64)/2, 10, switchwidth, 24)];
        [filterPanel addSubview:filterSwitch];
        [filterSwitch setOn: (currentSearchType & NavSearchTypeByString)];
        [filterSwitch addTarget:self action:@selector(setFilterPanelState:) forControlEvents:UIControlEventValueChanged];
        filterSwitch.tag = FILTER_SWITCH_TAG_BASE + 0;
        
        UIButton *filterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 42, switchframewidth, 16)];
        
        [filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [filterButton setTitleColor:[Theme mainColor] forState:UIControlStateHighlighted];
        [filterButton setTitle: @"Filter" forState:UIControlStateNormal];
        [filterButton addTarget:self action:@selector(menuFilterAction) forControlEvents:UIControlEventTouchUpInside];
        
        filterButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        filterButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        [filterPanel addSubview:filterButton];

        UISwitch* dateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(switchframewidth + (switchframewidth-64)/2, 10, switchwidth, 24)];
        [filterPanel addSubview:dateSwitch];
        [dateSwitch addTarget:self action:@selector(setFilterPanelState:) forControlEvents:UIControlEventValueChanged];
        dateSwitch.tag = FILTER_SWITCH_TAG_BASE + 1;

        [dateSwitch setOn: (currentSearchType & NavSearchTypeByDate)];
        
        UIButton *dateButton = [[UIButton alloc] initWithFrame:CGRectMake(switchframewidth, 42, switchframewidth, 16)];
        [dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dateButton setTitleColor:[Theme mainColor] forState:UIControlStateHighlighted];
        [dateButton setTitle: @"Date" forState:UIControlStateNormal];
        [dateButton addTarget:self action:@selector(menuDateAction) forControlEvents:UIControlEventTouchUpInside];
        
        dateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        dateButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        [filterPanel addSubview:dateButton];

        UISwitch* addressSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(switchframewidth * 2 + (switchframewidth-64)/2, 10, switchwidth, 24)];
        [filterPanel addSubview:addressSwitch];
        addressSwitch.tag = FILTER_SWITCH_TAG_BASE + 2;
        [addressSwitch setOn: (currentSearchType & NavSearchTypeByAddress)];
        [addressSwitch addTarget:self action:@selector(setFilterPanelState:) forControlEvents:UIControlEventValueChanged];
        
        UIButton *addressButton = [[UIButton alloc] initWithFrame:CGRectMake(switchframewidth * 2, 42, switchframewidth, 16)];
        [addressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addressButton setTitleColor:[Theme mainColor] forState:UIControlStateHighlighted];
        [addressButton setTitle: @"Address" forState:UIControlStateNormal];
        [addressButton addTarget:self action:@selector(menuAddressSearchAction) forControlEvents:UIControlEventTouchUpInside];
        
        addressButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        addressButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        [filterPanel addSubview:addressButton];

#ifdef DOMAP
        UISwitch* mapSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(switchframewidth * 3 + (switchframewidth-64)/2, 10, switchwidth, 24)];
        [filterPanel addSubview:mapSwitch];
        mapSwitch.tag = FILTER_SWITCH_TAG_BASE + 3;
        [mapSwitch setOn: (currentSearchType & NavSearchTypeByMap)];
        [mapSwitch addTarget:self action:@selector(setFilterPanelState:) forControlEvents:UIControlEventValueChanged];
        
        UIButton *mapButton = [[UIButton alloc] initWithFrame:CGRectMake(switchframewidth * 3, 42, switchframewidth, 16)];
        [mapButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [mapButton setTitleColor:[Theme mainColor] forState:UIControlStateHighlighted];
        [mapButton setTitle: @"Map" forState:UIControlStateNormal];
        [mapButton addTarget:self action:@selector(menuMapSearchAction) forControlEvents:UIControlEventTouchUpInside];
        
        mapButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        mapButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        [filterPanel addSubview:mapButton];
#endif

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.tag = FILTER_PANEL_CLOSE_BUTTON_TAG;
        closeButton.frame = CGRectMake(frame.size.width/2 - 16, frame.size.height - 90, 32, 32);
        [closeButton addTarget:self action:@selector(clearPanelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"SimpleCloseLine.png"]] forState:UIControlStateNormal];
        closeButton.layer.cornerRadius = 16;
        closeButton.layer.backgroundColor = COLORFROMHEX(0x80000000).CGColor;
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview: closeButton];

    } else {
        filterPanel.hidden = NO;
        [self.view viewWithTag:FILTER_PANEL_CLOSE_BUTTON_TAG].hidden = NO;
        UISwitch *sw = (UISwitch *)[self.view viewWithTag: FILTER_SWITCH_TAG_BASE];
        [sw setOn: (currentSearchType & NavSearchTypeByString)];
        sw = (UISwitch *)[self.view viewWithTag: FILTER_SWITCH_TAG_BASE+1];
        [sw setOn: (currentSearchType & NavSearchTypeByDate)];
        sw = (UISwitch *)[self.view viewWithTag: FILTER_SWITCH_TAG_BASE+2];
        [sw setOn: (currentSearchType & NavSearchTypeByAddress)];
        sw = (UISwitch *)[self.view viewWithTag: FILTER_SWITCH_TAG_BASE+3];
        [sw setOn: (currentSearchType & NavSearchTypeByMap)];
        
    }
    
}

- (void) hideFilterPanel
{
    if (filterPanel) {
        filterPanel.hidden = YES;
        [self.view viewWithTag:FILTER_PANEL_CLOSE_BUTTON_TAG].hidden = YES;
    }
//    [self addElasticMenu:EMOrientationRight stripDirection:EMDirectionHorizontalFront];
}

#pragma mark - MoElasticMenuDelegate

-(NSInteger) menuItemCount
{
    return [menuIcons count] ;
}

-(id)menuItemImageForIndex:(NSInteger)index
{
    
#ifdef IMAGE_DEBUG
    DLog(@"image being shown: %@", [menuIcons objectAtIndex: index]);
#endif
    
    return [UIImage imageNamed:[menuIcons objectAtIndex: index]];
}

-(id)menuItemHighlightImageForIndex:(NSInteger)index
{
    
#ifdef IMAGE_DEBUG
    DLog(@"image being shown: %@", [menuHighlightIcons objectAtIndex: index]);
#endif
    return [UIImage imageNamed:[menuHighlightIcons objectAtIndex: index]];
}

-(NSString *)menuItemTitleForIndex:(NSInteger)index
{
    return [menuTitles objectAtIndex: index];
}


-(void)didSelectMenuItem:(NSInteger)idx
{
    if (idx < [menuActions count]) {
        SEL actionSelector = NSSelectorFromString(menuActions[idx]);
        IMP imp = [self methodForSelector: actionSelector];
        void (*func)(id, SEL) = (void *)imp;
        
        if ([(NSObject *)self respondsToSelector: actionSelector]) {
            func(self, actionSelector);
            // [self performSelector:aSelector];
        }
    }
    
}

- (void) menuBackAction
{
    if (self.root)
        [self dismissViewControllerAnimated:YES completion:^{
            self.collectionView = nil;
            self.background = nil;
        }];
}

#ifdef NOTNOW
- (void) menuMarkedAction
{
    DLog(@"Marked");
}
#endif

// Search string to be supplied
- (void) menuFilterAction
{
    if (textFilterString == nil) {
        textFilterString = @"";
    }
    
    MobiusoActionView *stringSearchActionView =     [Utilities setupActionView:StringActionView withMessage:STRING_FILTER_MESSAGE withTitle:STRING_FILTER_TITLE placeholderText: textFilterString andButtons:@[@"SEARCH", @"RESOLUTION"] cancelButtonTitle:nil color:[Theme redColor] inView:self.view andDelegate:self];
    stringSearchActionView.paneColor = RGBColor(237, 20, 91);
    
    [self.view bringSubviewToFront: stringSearchActionView];
    [stringSearchActionView show];
    currentActionView = StringActionView;
    
    
    DLog(@"Filter string");
}


- (void) menuAddressSearchAction
{
    if (locationFilterString == nil) {
        locationFilterString = @"";
    }
    
    MobiusoActionView *mapActionView = [Utilities setupActionView:AddressActionView withMessage:LOCATION_FILTER_MESSAGE withTitle:LOCATION_FILTER_TITLE placeholderText:locationFilterString andButtons:@[@"WITHIN 1 MILE", @"WITHIN 10 MILES", @"WITHIN 100 MILES"] cancelButtonTitle:nil color:RGBColor(0, 170, 172) inView:self.view andDelegate:self];
    

    [self.view bringSubviewToFront: mapActionView];
    [mapActionView show];
//    currentActionView = AddressActionView;

    
    DLog(@"Address search");
}

- (void) menuMapSearchAction
{
#ifdef NOTNOW
    MobiusoMapActionView *mapActionView = [self setupMapActionView:DateActionView withMessage:LOCATION_FILTER_MESSAGE withTitle:LOCATION_FILTER_TITLE mapLocation:nil andButtons:@[@"SEARCH ADDRESS", @"SET REGION"] cancelButtonTitle:nil ];
    mapActionView.paneColor = RGBColor(26, 129, 182);
    
    [self.view bringSubviewToFront: mapActionView];
    [mapActionView show];
    currentActionView = AddressActionView;
    mapActionView.paneColor = RGBColor(0, 170, 172);
    
    DLog(@"Map search");
#endif
    
}

- (void) menuPOIAction
{
    poiList = [CacheManager areasOfInterest];
    if (poiList.count > 0) {
        MoPopupListToo *picker = [[MoPopupListToo alloc] initWithHeaderTitle:@"Areas of Interest" cancelButtonTitle:@"Never Mind" confirmButtonTitle:@"Search"];
        picker.delegate = self;
        picker.dataSource = self;
        picker.needFooterView = NO;
        picker.tag = AREASOFINTEREST_PICKER;
        picker.headerBackgroundColor =[Theme altColor];
        [picker show];
    } else {
        [MobiusoToast toast:@"No labels in the Photos" inView:self.view];
    }

}

- (void) menuRefreshAction
{
    DLog(@"Refresh");
    // Delete the cache file and populate the data again...
//    NSString *file = [NSString stringWithFormat: @"%@:%@", self.root?self.root:kAlbums, DIRECTORY_LISTNAME];
//    CacheManager *cm = [AppDelegate cacheManager];
//    BOOL removed = [cm purgeFileInCache: file];

//    DLog(@"Removed cache entry: %@", removed? @"Yes" : @"No" );
    
    [self reset];
}
- (void) menuSearchAction
{
    DLog(@"Search");
    
}

- (void) menuClearFilterAction
{
    DLog(@"Clear Search Action");
    currentSearchType = NavSearchTypeNone;
//    [self reload];
    [self refresh];
}

- (void) clearPanelButtonPressed: (UIButton *) sender
{
    switch (sender.tag) {
        case FILTER_PANEL_CLOSE_BUTTON_TAG:
            currentSearchType = NavSearchTypeNone;
            poiList = nil;
            [self refresh];
            break;

        case ACTION_PANEL_CLOSE_BUTTON_TAG:
            selectionMode = NO;
            // clear everything and scram
            for (PhotoObject *selitem in _selectedItems) {
                selitem.imageSelected = NO;
            }

            _selectedItems = [[NSMutableArray alloc] init];
            
            [self hideActionPanel];
            [self refresh];
            break;
            
            
        default:
            break;
    }
}
- (void) didFireDemoHelp
{
    // For now we keep track of it internally - should have a persistent info to manage user experience
    // demoPerformed = YES;
}

// For BUiltin Only
- (PHFetchResult *) photosList: (PHCollection *) collection
{
    // Fetch all assets, sorted by date created.
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    NSString *key;
    switch (currentSortField) {
        case NavSortFieldCreationDate:
            key = @"creationDate";
            break;
            
        case NavSortFieldModificationDate:
            key = @"modificationDate";
            break;
            
        default:
            key = @"creationDate";
            break;
    }
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:key ascending:(currentSortDirection == NavSortTypeAscending) ? YES : NO]];
    if (_showingMarkedFilesOnly) {
        options.predicate = [NSPredicate predicateWithFormat:@"favorite = YES"];
    }

    PHFetchResult *assetsFetchResult;
    if (collection) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        }
    } else {
        assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];
    }
    return assetsFetchResult;
}

#pragma mark - User Action Methods - Per Item
- (void) openFolder: (NSUInteger) row
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:(IS_IPAD?@"MainStoryboard_iPhone":@"MainStoryboard_iPhone") bundle:nil];
//    if (BuiltInPhotoGallery)
    {
        if (self.root==nil) {
            PhotoAlbumNavigationController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoAlbumNavigationController"];
            PHCollection *collection = nil;
            if (row == 1) { // All Photos

            } else if (row > 1) {
                
                pseduoIndexPath indexPath = [self indexForRow:row];
                PHFetchResult *fetchResult = self.collectionsFetchResults[indexPath.section-1];
                collection = fetchResult[indexPath.row-1];
                
            }
            viewController.assetsFetchResults = [self photosList:collection];
            viewController.assetCollection = (PHAssetCollection *)collection;
            NSString *title = collection?collection.localizedTitle : @"All Photos";
            
            
            viewController.root = [NSString stringWithFormat:@"%@:%@", (self.root? self.root: @":" kAlbums), title];
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            // Deeper - need to figure out what to do..
        }
        
    }

}

- (void) openLocalPhoto: (NSIndexPath *) indexPath
{
#ifdef NOTNOW
    PhotoCell * cell = (PhotoCell *) [_collectionView cellForItemAtIndexPath:indexPath];
    
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    NSUInteger itemIndex = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray[indexPath.row] integerValue] : indexPath.row;
    imageInfo.imageAsset = _assetsFetchResults[itemIndex];
    imageInfo.imageAssetCollection = _assetCollection;
    imageInfo.placeholderImage = [UIImage imageNamed:@"DefaultPhoto2.png"];
    CGRect cellframe = cell.frame;
    // Find the scrollview on top of this...
    CGPoint offset = _collectionView.contentOffset;
    
    imageInfo.referenceRect = CGRectMake(cellframe.origin.x - offset.x, cellframe.origin.y - offset.y, cellframe.size.width, cellframe.size.height);
    imageInfo.referenceView = self.view;
    //        imageInfo.referenceContentMode = self.bigImageButton.contentMode;
    imageInfo.referenceCornerRadius = 0;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:MoImageViewControllerMode_Image
                                           backgroundStyle:MoImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:MoImageViewControllerTransition_FromOriginalPosition];
#endif
    
}

#ifdef NOTNOW
- (void) openPhoto: (NSUInteger) row webStyle: (BOOL) webStyle
{
    if (BuiltInPhotoGallery) {
        // Should not happen - but just in case
    } else {
        PhotoObject *item;
        NSUInteger foldercount = [_folders count];
        
        // Index into the Item based on the row on which clicked
        item = _currentItem = _photosEtc[row-(foldercount+1+(_hasFolders?1:0))];
        NSString *name = item.imageName;
        
        FileType ft = [Utilities fileType:name];
        
        if (webStyle || (ft != FileTypeJPEG)) {
            // NOTNOW [self performSegueWithIdentifier:@"showDetail" sender:self];
            // open in ResourceView
            
            _resourceViewController = [[MobiusoResourceViewController alloc]
                                       initWithHtmlFile:item.imageName withFolder: self.root andTitle: name];
            _resourceViewController.resourceDataDelegate = self;
            
            NSRange index = [name rangeOfString: self.root];
            NSString *displayName;
            if (index.location != NSNotFound) {
                displayName = [name substringFromIndex:(index.location+[self.root length]+1)];
            }
            ((MobiusoResourceViewController *)_resourceViewController).htmlFileTitle = [self.root stringByAppendingString: [NSString stringWithFormat:@":%@", displayName]];
            ((MobiusoResourceViewController *)_resourceViewController).toolbarTitle = displayName;
            [self.navigationController pushViewController: _resourceViewController animated:YES];
        } else {
            
            PhotoViewController *pvc = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
            _resourceViewController = pvc;
            
            //        pvc.isWebTest = YES;
#ifdef LIBJPEG
            // Check the following - if it is strictly needed using libjpegTurboDecoder seems to be faster for the web and
            // creates a file that can be used for caching...
            //        pvc.decoder = pvc.isWebTest ? libjpegIncremental : libjpegTurboDecoder;
            pvc.decoder = libjpegTurboDecoder;
#else
            pvc.decoder = cgimageDecoder;
#endif
            NSMutableArray *images = [[NSMutableArray alloc] init];
            if ((selectionMode) && ([_selectedItems count]>1)) {
                pvc.justDoOneImage = NO;
                for (PhotoObject *item in _selectedItems) {
                    [images addObject:item];
                }
            } else {
                pvc.justDoOneImage = NO;
                //            pvc.imageName = name;
                [images addObject:item];
            }
            pvc.imageData = images;
            pvc.orientation = 0;
            pvc.root = self.root;
            pvc.resourceDataDelegate = self;
            NSString *basefile = [item.imageName lastPathComponent];
            NSString *extension = [item.imageName pathExtension];
            NSRange findDot = [basefile rangeOfString: extension options:NSBackwardsSearch|NSCaseInsensitiveSearch];
            if ((findDot.location != NSNotFound) &&
                (findDot.location + [extension length]) == [basefile length]) {
                basefile = [basefile substringToIndex: (findDot.location - 1)];
            }
            
            //        pvc.title = basefile;
            
            // pvc.modalPresentationCapturesStatusBarAppearance = YES;
            
            [self.navigationController pushViewController:pvc animated:YES];
            
        }
    }
}
#endif

- (void)tapOnMarkButton:(id)sender {
    
    NSUInteger row = ((MoRippleTap *)sender).tag - MARK_BUTTON_TAG_BASE;
    switch ([self itemType: row]) {
        case FolderHeaderItem:
        case PhotoHeaderItem:
            return;
            break;
        case FolderItem:
        {
            _currentItem = _folders[row - 1];
            // Toggle the caching (when visible on the Folder)
            
        }
            break;
        case PhotoItem:
            
        {
            PhotoObject *item;

//            if (BuiltInPhotoGallery)
            {
                PhotoCell *cell = [self findCell:sender];
                item = cell.item;
            }
            
            [self toggleImageMark: item];
            [(MoRippleTap *) sender setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:item.imageMarked?@"icons-star-solid.png":@"icons-star.png"]]];

        }
            break;
    }

}

- (void)tapOnSelectButton:(id)sender {
    
    NSUInteger row = ((MoRippleTap *)sender).tag - SELECT_BUTTON_TAG_BASE;
    switch ([self itemType: row]) {
        case FolderHeaderItem:
        case PhotoHeaderItem:
        case FolderItem:
            return;

        case PhotoItem:
            
        {
            PhotoObject *item;
//            if (BuiltInPhotoGallery)
            {
                PhotoCell *cell = [self findCell:sender];
                item = cell.item;
            }
            
            [self toggleImageSelection: item];
            [(MoRippleTap *) sender setImage: item.imageSelected?_checkMarkImage: _plusImage];
        }
            break;
    }
    
}

- (PhotoCell *) findCell: (UIView *) sender
{
    UIView *view = (UIView *)sender;
//    PhotoCell * cell;
    while ((view = [view superview])) {
        if ([view isKindOfClass:[PhotoCell class]]) {
            break;
        }
    }
    return (PhotoCell *) view;
}

#if 0
- (void)tapOnShowHideButton : (id) sender
{
    if (BuiltInPhotoGallery) {
        NSUInteger row = ((UIButton *)sender).tag - SHOW_HIDE_BUTTON_TAG_BASE;
        if ([self itemType: row] == FolderHeaderItem) {

            row -= 2;   // 1 for main header and 1 for All Photos
            for (int i=0; i < [self.collectionsFetchResults count]; i++) {
                PHFetchResult *fetchResult = self.collectionsFetchResults[i];
                BOOL showing = [_collectionsBeingShown[i] boolValue];
                int count = showing? (int)[fetchResult count]: 0;
                if (row <= count) {
                    if (row==0) {
                        [_collectionsBeingShown setObject:[NSNumber numberWithBool:!showing] atIndexedSubscript:i];
                        break;
                    } else {
                    }
                    break;
                }
                row -= count + 1;
            }

            [self refresh];
        }
    }
}
#endif

- (void)tapOnInfoButton:(id)sender
{
    // [self tappedOnItemAtRow: ((UIButton *)sender).tag];
//    if (BuiltInPhotoGallery)
    {
        NSUInteger row = ((UIButton *)sender).tag - INFO_BUTTON_TAG_BASE;
        if ([self itemType: row] == FolderHeaderItem) {
            if (row==0) {
                [self menuServerAction];
            } else {
                row -= 2;   // 1 for main header and 1 for All Photos
                for (int i=0; i < [self.collectionsFetchResults count]; i++) {
                    PHFetchResult *fetchResult = self.collectionsFetchResults[i];
                    BOOL showing = [_collectionsBeingShown[i] boolValue];
                    int count = showing? (int)[fetchResult count]: 0;
                    if (row <= count) {
                        if (row==0) {
                            [_collectionsBeingShown setObject:[NSNumber numberWithBool:!showing] atIndexedSubscript:i];
                            break;
                        } else {
                        }
                        break;
                    }
                    row -= count + 1;
                }
                
                [self refresh];
                
            }
            return;
        }
        
        // Not a header
        PhotoCell *cell = [self findCell: (id) sender];
        _currentItem = cell.item;
        DLog(@"cell %@", cell.item.title);
        if (!NavigationAtRootLevel) {
            // Photos
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:(IS_IPAD?@"MainStoryboard_iPhone":@"MainStoryboard_iPhone") bundle:nil];
            
            PhotoDetailViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoDetailViewController"];
            
            // Get the cell
//            PhotoCell *cell = (PhotoCell *) [(UIButton *)sender superview];
            
            viewController.item = _currentItem;
            viewController.root = cell.item.title;
            
            NSUInteger itemIndex = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray[row] integerValue] : row;
            viewController.asset = (PHAsset *) _assetsFetchResults[itemIndex];
            viewController.assetCollection = self.assetCollection;

            // Use the asset to create the EXIF file...
//            item.imageName = [asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"#SLASH#"];
            // Test by writing some data out
            viewController.delegate = self;
            
            [self presentViewController:viewController animated:YES completion:nil];
            
            // For some reason the collectionView Reference in the outlet is getting lost when you return
            
        } else {
            {
#ifdef  NOTNOW
                // Folders - we are at the Root Level
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:(IS_IPAD?@"MainStoryboard_iPhone":@"MainStoryboard_iPhone") bundle:nil];
                
                FolderDetailViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"FolderDetailViewController"];
                viewController.item = _currentItem;
                viewController.root = [NSString stringWithFormat:@"%@:%@", [AppDelegate currentHostDisplayName], _currentItem.title];
                // viewController.markedFiles = _markedFiles;
                pseduoIndexPath indexPath = [self indexForRow:row];
                PHCollection *collection = nil;
                if (indexPath.section != 0) {   // All Photos Row
                    PHFetchResult *fetchResult = self.collectionsFetchResults[indexPath.section-1];
                    collection = fetchResult[indexPath.row-1];
                    DLog(@"Collection %@", collection.localizedTitle);
                    viewController.assetsFetchResults = fetchResult;
                }
                viewController.assetCollection = (PHAssetCollection *)collection;
                
#if 0
                // Get some other information
                pseduoIndexPath indexPath = [self indexForRow:row];
                PHFetchResult *fetchResult = self.collectionsFetchResults[indexPath.section-1];
                PHCollection *collection = fetchResult[indexPath.row-1];
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                    viewController.assetsFetchResults = assetsFetchResult;
                    viewController.assetCollection = assetCollection;
                    title = collection.localizedTitle;
                }
#endif
                
                [self.navigationController pushViewController:viewController animated:YES];
#endif
                
            }
            
        }
        return;
    }
    

}

#ifdef DEBUG
- (void) setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
}

#endif
- (void) tappedOnItemAtRow: (NSIndexPath *) indexPath
{
    NSUInteger row = indexPath.row;
    switch ([self itemType: row]) {
        case FolderHeaderItem:
        case PhotoHeaderItem:
            return;
            break;
        case FolderItem:
        {
            [self openFolder: row];
        }
            break;
            
        case PhotoItem:
        {
//            if (BuiltInPhotoGallery)
            {
                NSUInteger itemIndex = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray[indexPath.row] integerValue] : indexPath.row;
                
                // Create image info
                PHAsset            *imageAsset = _assetsFetchResults[itemIndex];
                PHAssetCollection *imageAssetCollection = _assetCollection;
                if (_delegate) {
                    [_delegate photoAlbumViewController:self didFinishPickingMedia:imageAsset inAssetCollection:imageAssetCollection withContextArray:_assetsFetchResults andMarker:itemIndex];
                } else {
                    // Handle Locally
                    {
                        
                        // Create image info
                        MoImageInfo *imageInfo = [[MoImageInfo alloc] init];
                        imageInfo.placeholderImage = [UIImage imageNamed:@"logo"];
                        imageInfo.imageAsset = imageAsset;
                        imageInfo.imageAssetCollection = _assetCollection;
                        imageInfo.imageURL = nil; // imageReferenceURL;
                        
                        imageInfo.referenceRect = [Utilities applicationFrame];// _captureImage.frame;
                        imageInfo.referenceView = self.view;
                        //        imageInfo.referenceContentMode = self.bigImageButton.contentMode;
                        imageInfo.referenceCornerRadius = 0;
                        
                        imageInfo.imageMarkerIndex =  indexPath.row; // itemIndex;
                        
                        if (imageAsset.mediaType == PHAssetMediaTypeImage ) {
                            
                            // Setup view controller
                            PhotoPreviewVC *imageViewer = [[PhotoPreviewVC alloc]
                                                           initWithImageInfo:imageInfo
                                                           mode:MoImageViewControllerMode_Image
                                                           backgroundStyle:MoImageViewControllerBackgroundOption_Scaled];  // Scaled
                            imageViewer.dismissalDelegate = self;
                            imageViewer.duration = 0.0f;    // In this case it does not go away by default
                            imageViewer.lightboxMode = NO; // lightboxMode;  // set explicitly
                            imageViewer.imageType = SnapLibrary;
                            
                            // Present the view controller.
                            //    imageViewer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                            
                            [imageViewer showFromViewController:self transition:MoImageViewControllerTransition_FromOffscreen]; // _FromOriginalPosition
                        } else {
                            [MobiusoToast toast:[NSString stringWithFormat:@"%@ not supported (yet)", (imageAsset.mediaType == PHAssetMediaTypeVideo) ? @"Video" : @"Audio"] inView:self.view];
                        }

                    }

                }
                
            }
        }
            return;
            break;
    }
    

}
#pragma mark - PhotoDetailViewControllerDelegate Methods
- (void) dismissedPresentedController:(PhotoDetailViewController *)viewController
{
    [self refresh];
    DLog(@"Returning from the Photo Detail");
}


#pragma mark - MoImageViewerControllerDelegate Methods
- (void) imageViewerDidDismiss:(MoImageViewController *)imageViewer
{
    DLog(@"Did Dismiss");
    
    [self reload];
}

- (BOOL) imageViewController: (MoImageViewController *)imageViewer nextImage: (NSInteger) markerIndex
{
    markerIndex++;
    if (markerIndex >= ((currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray count] : [_assetsFetchResults count])) {
        return NO;
    }
    NSUInteger itemIndex = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray[markerIndex] integerValue] : markerIndex;
    
    // Create image info
    PHAsset            *imageAsset = _assetsFetchResults[itemIndex];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;

    [[PHImageManager defaultManager] requestImageDataForAsset: imageAsset options:options resultHandler: ^(NSData *imageData,
                                                                                                           NSString *dataUTI, UIImageOrientation orientation,  NSDictionary *info) {
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            [imageViewer updateInterfaceWithImage:image];
            imageViewer.imageInfo.image = image;
            imageViewer.imageInfo.imageAsset = imageAsset;
            imageViewer.imageInfo.imageAssetCollection = _assetCollection;

            imageViewer.imageInfo.imageMarkerIndex = markerIndex; // new Index
        }
    }];
    return YES;    // placeholder
}

- (BOOL) imageViewController: (MoImageViewController *)imageViewer previousImage: (NSInteger) markerIndex
{
    markerIndex--;
    if (markerIndex < 0) {
        return NO;
    }
    NSUInteger itemIndex = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray[markerIndex] integerValue] : markerIndex;
    
    // Create image info
    PHAsset            *imageAsset = _assetsFetchResults[itemIndex];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset: imageAsset options:options resultHandler: ^(NSData *imageData,
                                                                                                           NSString *dataUTI, UIImageOrientation orientation,  NSDictionary *info) {
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            [imageViewer updateInterfaceWithImage:image];
            imageViewer.imageInfo.image = image;
            imageViewer.imageInfo.imageAsset = imageAsset;
            imageViewer.imageInfo.imageAssetCollection = _assetCollection;
            imageViewer.imageInfo.imageMarkerIndex = markerIndex; // new Index
        }
    }];
    
    return YES;    // placeholder
}

#ifdef IMAGEEDITOR_HANDOFF_TO_HOMEVIEW
- (BOOL) imageViewerWillDismissForEdit:(MoImageViewController *)imageViewer withImage:(UIImage *)image
{
#if 0
    // Start the image Editor
    ImageEditor *editor = [[ImageEditor alloc] initWithImage: image delegate:self];
    [self presentViewController:editor animated:true completion:nil];
    return YES;
#endif
    [self dismissViewControllerAnimated:NO completion:
     ^{
         self.collectionView = nil;
         self.background = nil;

         HomeVC *homeVC = [HomeVC sharedHomeVC];
         // Do we need to call dismissalDelegate or not?
         if (homeVC && [homeVC respondsToSelector:@selector(launchImageEditor:)]) {
             [homeVC launchImageEditor: image];
         }
     }];
    return YES;

}

#pragma mark - ImageEditorDelegate
- (void)imageEditor:(ImageEditor*)editor didFinishEdittingWithImage:(UIImage*)image
{
    DLog(@"ImageEditor finished");
    // save the image in the correct spot and refresh
    {
        MoImageInfo *imageInfo = [[MoImageInfo alloc] init];
        imageInfo.image = image;
        imageInfo.imageAsset = nil;
        imageInfo.imageAssetCollection = nil;
        imageInfo.imageURL = nil; // imageReferenceURL;
        
        imageInfo.referenceRect = [self.view frame];// _captureImage.frame;
        imageInfo.referenceView = self.view;
        //        imageInfo.referenceContentMode = self.bigImageButton.contentMode;
        imageInfo.referenceCornerRadius = 0;
        
        imageInfo.imageMarkerIndex =  -1; // itemIndex;
        PhotoPreviewVC *imageViewer = [[PhotoPreviewVC alloc]
                                       initWithImageInfo:imageInfo
                                       mode:MoImageViewControllerMode_Image
                                       backgroundStyle:MoImageViewControllerBackgroundOption_Scaled];  // Scaled
        imageViewer.dismissalDelegate = self;
        imageViewer.duration = 0.0f;    // In this case it does not go away by default
        imageViewer.lightboxMode = NO; // lightboxMode;  // set explicitly
        imageViewer.imageType = SnapLibrary;
        
        // Present the view controller.
        //    imageViewer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [imageViewer showFromViewController:self transition:MoImageViewControllerTransition_FromOffscreen]; // _FromOriginalPosition
        
    }
    //    self.imageInfo.image = image;
    //    [self updateInterfaceWithImage:image];
    //    self.imageLocked = YES;
    //
    //    needToSave = YES;
    //    [self setTitle];
    
    [editor dismissViewControllerAnimated:YES completion:nil];
    //    [self addTapGestures];
    
}

- (void)imageEditorDidCancel:(ImageEditor*)editor
{
    DLog(@"ImageEditor cancelled");
    [editor dismissViewControllerAnimated:YES completion:nil];
    //    [self addTapGestures];
}

#endif
#pragma mark – RFQuiltLayoutDelegate


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath // defaults to 1x1
{

    NSUInteger row = indexPath.row;
    NSUInteger height, width;
    CGSize size = [Theme blockPixels];
//    if (BuiltInPhotoGallery)
    {
        switch ([self itemType: row]) {
            case FolderHeaderItem:
            case PhotoHeaderItem:
                height = 2;
                width = 2;
                 break;
            case FolderItem:
                height = 2;
                if (size.width > 320) {
                    width = 1;
                } else {
                    width = 2;
                }
                break;
                
            default:
                switch (_layoutType) {
                    case LayoutVersion1:
                        height = 4;
                        width = 1;
                        break;
                    case LayoutVersion2:
                        height = 6;
                        width = 2;
                        break;
                    case LayoutVersion3:
                    default:
                        height = 8;
                        width = 2;
                        break;
                }
        }
    }
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetsForItemAtIndexPath:(NSIndexPath *)indexPath // defaults to uiedgeinsetszero
{
//    if (BuiltInPhotoGallery)
    {
        return UIEdgeInsetsMake(0, 0, 0, 0);
        
    }
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
#ifdef NOTNOW
#if  defined(PHOTO_NAV_DEBUG)
    DLog(@"In Segue");
#endif
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        FolderDetailViewController *controller = segue.destinationViewController;
        
        controller.item = _currentItem;
    }
#endif
}



#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.animationController.isPresenting = YES;
    
    return self.animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animationController.isPresenting = NO;
    
    return self.animationController;
}

#pragma mark - Convenience Methods
- (void) setupIndex: (NSUInteger) idx
{
    PhotoObject *item = _currentItem = _photosEtc[idx];
    
    NSString *name = item.imageName;
    
    NSRange index = [name rangeOfString: self.root];
    NSString *displayName;
    if (index.location != NSNotFound) {
        displayName = [name substringFromIndex:(index.location+[self.root length]+1)];
    }
#ifdef NOTNOW
    if ([_resourceViewController class] == [MobiusoResourceViewController class]) {
        MobiusoResourceViewController *rvc = (MobiusoResourceViewController *)_resourceViewController;
        
        [rvc setupWithHtmlFile:item.imageName withFolder: self.root andTitle: name];
        rvc.htmlFileTitle = [self.root stringByAppendingString: [NSString stringWithFormat:@":%@", displayName]];
        rvc.toolbarTitle = displayName;
    } else if ([_resourceViewController class] == [PhotoViewController class]) {
#ifdef DOLATER
        PhotoViewController *pvc = (PhotoViewController *)_resourceViewController;
#ifdef LIBJPEG
        // Check the following - if it is strictly needed using libjpegTurboDecoder seems to be faster for the web and
        // creates a file that can be used for caching...
        //        pvc.decoder = pvc.isWebTest ? libjpegIncremental : libjpegTurboDecoder;
        pvc.decoder = libjpegTurboDecoder;
#else
        pvc.decoder = cgimageDecoder;
#endif
        pvc.imageName = name;
        pvc.root = self.root;
        NSString *basefile = [item.imageName lastPathComponent];
        NSString *extension = [item.imageName pathExtension];
        NSRange findDot = [basefile rangeOfString: extension options:NSBackwardsSearch|NSCaseInsensitiveSearch];
        if ((findDot.location != NSNotFound) &&
            (findDot.location + [extension length]) == [basefile length]) {
            basefile = [basefile substringToIndex: (findDot.location - 1)];
        }
        
        pvc.title = basefile;
        
        [pvc imageSetup];
#endif
        
    }
    
#endif
    
}

#pragma mark - MobiusoResourceDataDelegate

- (BOOL) prevItem
{
    NSUInteger idx = [_photosEtc indexOfObject:_currentItem];
    
    if ((idx != NSNotFound) && (idx > 0)) {
        // Set up a new Document on the controller
        [self setupIndex:(idx-1)];
        return TRUE;
    } else {
        return FALSE;
    }
}

- (BOOL) nextItem
{
    NSUInteger idx = [_photosEtc indexOfObject:_currentItem];
    
    if ((idx != NSNotFound) && (idx < ([_photosEtc count] - 1))) {
        // Set up a new Document on the controller
        [self setupIndex:(idx+1)];
        return TRUE;
    } else {
        return FALSE;
    }
}

- (BOOL) toggleMark
{
    return [self toggleImageMark:_currentItem];
}

- (BOOL) toggleMark: (PhotoObject *) item
{
    return [self toggleImageMark:item];
}

#pragma mark - URL Connection Delegate Methods

// -------------------------------------------------------------------------------
//	handleError:error
// -------------------------------------------------------------------------------
- (void)handleError:(NSError *)error
{
    [self handleErrorString:[error localizedDescription]];
}

// -------------------------------------------------------------------------------
//	handleError:error
// -------------------------------------------------------------------------------
- (void)handleErrorString:(NSString *)errorMessage
{
    NSString *serverAddress = [AppDelegate currentHostAddress];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat: @"Error (%@)", serverAddress]
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark - Navigation Bar Tap
- (void) navigationBarTap: (id) sender
{
    MobiusoBubblePopup *bubblePop = [[MobiusoBubblePopup alloc] initWithFrame:[self.view bounds] withOrientation:MBOrientationTop andDuration:15.0f];
    bubblePop.delegate = self;
    bubblePop.tag = HELP_BUBBLE_TAG;
    [self.view addSubview:bubblePop];
    
    
    // Full bundle ID NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNumber =   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *displayName =   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    [bubblePop showMessage: self.root withTitle:displayName andSubtitle: [NSString stringWithFormat: @"v%@ [%@]", versionNumber, buildNumber]];
    
}

#pragma mark - ActionViews
- (void)menuServerAction
{
#ifdef NOTNOW
    NSMutableArray *buttonArray = [NSMutableArray arrayWithArray:@[ @"Photo Roll"]];
    
    NSMutableArray *serverList = [[SettingsManager instance] currentServerList];
    
    for (NSDictionary *dict in serverList) {
        NSString *name = [dict objectForKey:@"serverName"];
        [buttonArray addObject:name];
    }
    
    MobiusoActionView *shareActionView = [self setupActionView:ShareActionView withMessage:SERVER_MESSAGE withTitle:SERVER_TITLE placeholderText: nil andButtons:buttonArray cancelButtonTitle:nil ];
    
    
    [self.view bringSubviewToFront: shareActionView];
    [shareActionView show];
    currentActionView = ServerActionView;
#endif
    
}

- (void) menuDateAction
{
    if (dateFilterString == nil) {
        dateFilterString = @"";
    }

//    MobiusoActionView *dateActionView = [self setupActionView:DateActionView withMessage:DATE_FILTER_MESSAGE withTitle:DATE_FILTER_TITLE placeholderText: dateFilterString andButtons:@[@"SEARCH"] cancelButtonTitle:nil ];
    MobiusoActionView *dateActionView = [Utilities setupActionView:DateActionView withMessage:DATE_FILTER_MESSAGE withTitle:DATE_FILTER_TITLE placeholderText:dateFilterString andButtons:@[@"SEARCH"] cancelButtonTitle:nil color:[Theme redColor] inView:self.view andDelegate:self];
    
    
    [self.view bringSubviewToFront: dateActionView];
    [dateActionView show];
    currentActionView = DateActionView;

}


- (void) menuTagAction
{
    if (tagString == nil) {
        tagString = @"";
    }
    

    MobiusoActionView *tagActionView = [Utilities setupActionView:TagActionView withMessage:TAG_MESSAGE withTitle:TAG_TITLE placeholderText: tagString andButtons:@[@"OK"] cancelButtonTitle:nil color:[Theme redColor] inView:self.view andDelegate:self];
    tagActionView.popupArray = [CacheManager tagsForAllPhotos];
    
    [self.view bringSubviewToFront: tagActionView];
    [tagActionView show];
    currentActionView = TagActionView;
    
}

- (void) menuLightboxAction
{
    
    for (PhotoObject *item in _selectedItems) {
        DLog(@"Item: %@", item.imageName);
        item.imageSelected = NO; // we deselect it even if it means that they were not deleted (because we will be clearing the panel
        NSUInteger row = [item.indexReference integerValue];
        NSUInteger itemIndex = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray[row] integerValue] : row;
        PHAsset *asset = _assetsFetchResults[itemIndex];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        
        // Download from cloud if necessary
        options.networkAccessAllowed = YES;
        options.synchronous = YES;  // we have to carefully fetch and add all the images...
        options.progressHandler = nil;  /*^(BOOL degraded, double progress, NSError *error, BOOL *stop) */
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(2048,2048) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);
                
                //create a string from unique identifier
                NSString *lightboxAssetId = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, newUniqueID));
                [LightBoxManager addToLightbox:result withAssetId:lightboxAssetId andImageType:SnapLibrary andLinkID:nil];
            }
            
        }];
    }
}

- (void) menuDeleteAction
{
    
    
    MobiusoActionView *deleteActionView = [Utilities setupActionView:DeleteActionView withMessage:DELETE_PHOTOS_MESSAGE withTitle:DELETE_PHOTOS_TITLE placeholderText: tagString andButtons:@[@"I AM SURE"] cancelButtonTitle:@"NEVER MIND" color:[Theme redColor] inView:self.view andDelegate:self];
    
    [self.view bringSubviewToFront: deleteActionView];
    [deleteActionView showWithCompletionBlock:^(MobiusoActionView *actionView, NSInteger buttonIndex, NSString *inputText) {
        if (buttonIndex == 0) {
            [MobiusoToast toast:@"Deleting" inView:self.view];
            __block NSMutableArray *deleteAssets = [[NSMutableArray alloc] init];
            for (PhotoObject *item in _selectedItems) {
                DLog(@"Item: %@", item.imageName);
                item.imageSelected = NO; // we deselect it even if it means that they were not deleted (because we will be clearing the panel
                NSUInteger row = [item.indexReference integerValue];
                NSUInteger itemIndex = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray[row] integerValue] : row;
                PHAsset *asset = _assetsFetchResults[itemIndex];
                if ([asset canPerformEditOperation:PHAssetEditOperationDelete]) {
                    [deleteAssets addObject:asset];
                }
            }
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest deleteAssets:deleteAssets];
            } completionHandler:^(BOOL success, NSError *error) {
                DLog(@"Finished deleting asset. %@", (success ? @"Success." : error));
                
            }];
            _selectedItems = [[NSMutableArray alloc] init];
            selectionMode = NO;
            // The library change will force the refresh...

        }
    }];
//    currentActionView = TagActionView;
    
}

- (void) menuSelectAllAction
{
//    if (BuiltInPhotoGallery)
    {

        _selectedItems = [[NSMutableArray alloc] init];
        selectionModeAll = YES;
        // Show all visible items to have been selected and set a bit
        for (UICollectionViewCell *cell in _collectionView.visibleCells)
        {
                PhotoObject *item = ((PhotoCell *) cell).item;
                item.imageSelected = YES;   // initially it will be
                [_selectedItems addObject:item];
        }
        
        [self refresh];

    }
}

- (void) menuSelectNoneAction
{
//    if (BuiltInPhotoGallery)
    {
    
        selectionModeAll = NO;
        for (PhotoObject *item in _selectedItems) {
            item.imageSelected = NO;
        }
        _selectedItems = [[NSMutableArray alloc] init];
        
        [self refresh];
        
    }
}


#pragma mark - Photos Assets Filter
- (void) filterAssets: (NavSearchType) searchFilter
{
    __block MoProgressView *hud = [[MoProgressView alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    [hud show:TRUE];

    
#if 1
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:(id) COLORFROMHEX(0xff96e9ff).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0x80a9c9f9).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0x547fe4fe).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0xff96e9ff).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0xc0a9c9f9).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0x447fe4fe).CGColor ];
    [colors addObject:(id) COLORFROMHEX(0xff96e9ff).CGColor ];
    CGRect frame = [Utilities applicationFrame];
    __block MoGradientProgressView *gProgressView = [[MoGradientProgressView alloc] initWithFrame:CGRectMake(0,244, frame.size.width, 5)];
    
    [gProgressView setGradientColors:colors];
    
    [self.view addSubview: gProgressView];
    [self.view bringSubviewToFront:gProgressView];
    progressView.progress = 1.0f;
    [gProgressView startAnimating];

#endif
    
    _filteredItemsIndexArray = [[NSMutableArray alloc] init];
    currentSearchType = currentSearchType | searchFilter;
    
#ifdef SIMULATE_DELAY
    [NSThread sleepForTimeInterval:5.0f];
#endif
    
    // Prime any info before the enumeration
    NSDateFormatter *dateFormatter;
    NSString *formattedDateString;
    if (searchFilter & NavSearchTypeByDate) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        
        // NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
        
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:usLocale];
        if (dateFilterExact) {
            DLog(@"Exact Date is: %@", [dateFormatter stringFromDate:dateFilterExact]);
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            formattedDateString =  [dateFormatter stringFromDate:dateFilterExact];
        } else {
            // parse for reasonable string ...
            //[dateFormatter setDateFormat:@"dd:MMM:yyyy"];
            [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        }
        
    }
    BOOL pixelMatch = NO;
    BOOL generalMatch = NO;
    NSUInteger pixelWidth = 0;
    NSUInteger pixelHeight = 0;
    NavSearchOperator operator = NavSearchOperatorEquals;
    
    if (currentSearchType & NavSearchTypeByString) {
        
        NSRange r;
        NSString *s = [textFilterString copy];
        // operators are for quality, greater than or lower than of the specified values
        if ((r = [s rangeOfString:@"[=><]" options:NSRegularExpressionSearch]).location != NSNotFound) {
            if (r.location == 0) {
                NSString *op = [s substringWithRange: (NSRange) {0,1}];
                if (IS_EQUAL(@"=", op)) {
                    operator = NavSearchOperatorEquals;
                } else if (IS_EQUAL(@">", op)) {
                    operator = NavSearchOperatorGreaterThan;
                } else {
                    operator = NavSearchOperatorLessThan;
                }
                s = [s stringByReplacingCharactersInRange:r withString:@""];
                // We are expecting numbers
                if ((r = [s rangeOfString:@"[0-9x]" options:NSRegularExpressionSearch]).location != NSNotFound) {
                    pixelMatch = YES;
                    NSArray *numbers = [s componentsSeparatedByString:@"x"];
                    if ([numbers count] > 2) {
                        DLog(@"Input problem");
                    } else {
                        pixelWidth = [(NSString *) numbers[0] integerValue];
                        if ([numbers count] == 1) {
                            pixelHeight = pixelWidth;
                        } else {
                            pixelHeight = [(NSString *) numbers[1] integerValue];
                        }
                    }
                } // else // treat as general string
            }
        } else {
            generalMatch = YES;
        }
        
        if (!pixelMatch) generalMatch = YES;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // The main loop to filter items out
        [_assetsFetchResults enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            NSString *assetDate = [dateFormatter stringFromDate:asset.creationDate];
            
            BOOL datefound = YES;
            if (currentSearchType & NavSearchTypeByDate) {
                if (dateFilterExact) {
                    // compare
                    if (!IS_EQUAL(assetDate, formattedDateString)) {
                        datefound = NO;
                    } else {
                        DLog(@"Found asset: %@", formattedDateString);
                        
                    }
                } else if (dateFilterMatchArray){
                    // compare all components with the found string
                    datefound = YES;
                    for (NSString *component in dateFilterMatchArray) {
                        if (![assetDate localizedCaseInsensitiveContainsString:component]) {
                            datefound = NO;
                            break;
                        }
                    }
                    
                }
            } else if (!currentSearchCombineWithAnd) {
                datefound = NO;  // otherwise it will be included erroneously
                
            }
            // datefound will be set here
            
            // Map search
            BOOL mapfound = YES;
            if (currentSearchType & NavSearchTypeByAddress) {
                CLLocationCoordinate2D assetCoord = asset.location.coordinate;
                
                if (IS_MAP_LOCATION_ZERO(assetCoord)) {
                    mapfound = NO;
                } else {
                    
                    CGFloat lat = fabs(assetCoord.latitude - locationFilter.coordinate.latitude);
                    CGFloat lng = fabs(assetCoord.longitude - locationFilter.coordinate.longitude);
                    //                DLog(@"Diff = %f, %f", lat, lng);
                    if (locationAccuracy.height > 1) {  // Use the distance
                        if ([asset.location distanceFromLocation:locationFilter] > locationAccuracy.height) {
                            mapfound = NO;
                        }
                    } else {
                        if ((lat > locationAccuracy.height) || (lng > locationAccuracy.width)) {
                            mapfound = NO;
                        }
                    }
                }
            } else if (!currentSearchCombineWithAnd) {
                mapfound = NO;  // otherwise it will be included erroneously
            }
            
            // Text search
            BOOL stringfound = YES;
            if (currentSearchType & NavSearchTypeByString) {
                if (pixelWidth > 0) {   // pixel comparison
                    switch (operator) {
                        case NavSearchOperatorEquals:
                            if ((asset.pixelWidth != pixelWidth) || (asset.pixelHeight != pixelHeight)) {
                                stringfound = NO;
                            }
                            break;
                            
                        case NavSearchOperatorGreaterThan:
                            if ((asset.pixelWidth < pixelWidth) || (asset.pixelHeight < pixelHeight)) {
                                stringfound = NO;
                            }
                            break;
                            
                        case NavSearchOperatorLessThan:
                            if ((asset.pixelWidth > pixelWidth) || (asset.pixelHeight > pixelHeight)) {
                                stringfound = NO;
                            }
                            break;
                            
                        default:
                            stringfound = NO;   // this should not happen...
                            break;
                    }
                } else  if (generalMatch)    {
                    // Go through the Tags file and get the array of tags for this ...
                    NSArray *tagsArray = [CacheManager tagsForPhoto:asset];
                    BOOL found = NO;
                    if (tagsArray && ([tagsArray count] > 0)) {
                        // See if it matches...
                        for (NSString *tag in tagsArray) {
                            if ([tag localizedCaseInsensitiveContainsString:textFilterString]) {
                                found = YES;
                                break;
                            }
                        }
                    }
                    stringfound = found;
#if 1
                    // If not found above, then search through the locations
                    if (!found) {
                        // Search the assets
                        CLLocation *location = asset.location;
                        CacheManager *cm = [AppDelegate cacheManager];
                        NSDictionary *placemarkDict = [cm locationPlacemarks:location.coordinate];
                        // Read Tags
                        NSArray *photoTagArray = [cm tagsForPhoto:asset];
                        //                    found = NO;
                        if (photoTagArray) {
                            for (NSString *tag in photoTagArray) {
                                if ([tag localizedCaseInsensitiveContainsString:textFilterString]) {
                                    found = YES;
                                    break;
                                }
                            }
                        }
                        if (!found && placemarkDict) {
                            for (NSString *key in placemarkDict) {
                                if (IS_EQUAL(key, @"addressdictionary") || IS_EQUAL(key, @"areaofinterest")) {
                                    NSArray *array = [placemarkDict objectForKey:key];
                                    for (NSString *area in array) {
                                        if ([area localizedCaseInsensitiveContainsString:textFilterString]) {
                                            found = YES;
                                            break;
                                        }
                                    }
                                    
                                } else {
                                    NSString *str = [placemarkDict objectForKey:key];
                                    if ([str localizedCaseInsensitiveContainsString:textFilterString]) {
                                        found = YES;
                                        break;
                                    }
                                    
                                }
                            }
                            
                        }
                        stringfound = found;
                    }
#endif
                }
                
            } else if (!currentSearchCombineWithAnd) {
                stringfound = NO;  // otherwise it will be included erroneously
            }
            
            BOOL matchfound = (currentSearchCombineWithAnd ? (datefound && mapfound && stringfound) : (datefound || mapfound || stringfound));
            
            if (matchfound)
                [_filteredItemsIndexArray addObject: [NSNumber numberWithInteger:idx]];
            
        }];
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide: NO];
            [hud removeFromSuperview];
            [self refresh];

        });
    });
    
    return; //  [_filteredItemsIndexArray count];
}

#pragma mark - MobiusoActionView Delegate Methods
- (void) setCurrentActionViewId:(NSInteger)referenceTag
{
    currentActionView = referenceTag;
}

- (void) dismissActionView
{
    // Reattach Gesture recognizers
    [self.view addGestureRecognizer:longTapGestureRecognizer];
#ifdef DO_PAN_SELECTION
    [self.view addGestureRecognizer:panGestureRecognizer];
#endif
    
    switch (currentActionView) {
        case ServerActionView:
        default:
            // don't do anything, just break
            break;
            
    }
}

- (void) dismissWithClickedButtonIndex: (NSInteger) buttonIndex withText: (NSString *) text

{
    // Reattach Gesture recognizers
    [self.view addGestureRecognizer:longTapGestureRecognizer];
#ifdef DO_PAN_SELECTION
    [self.view addGestureRecognizer:panGestureRecognizer];
#endif

    switch (currentActionView) {
            
#pragma mark Sharing View
            // Share View
        case ServerActionView:
        {
            int idx = (int)buttonIndex - 1;
            currentServer = idx;
            switch (idx) {
                case -1:
                {
                    // Photo Roll on the system
                    [[SettingsManager instance] setCurrentServer: idx];
                }
                    break;
                    
                default:
                {
                    NSMutableArray *serverList = [[SettingsManager instance] currentServerList];

                    if (idx < [serverList count]) {
                        // This will trigger a refresh
                        [[SettingsManager instance] setCurrentServer: idx];
                    }
                    break;
                }
                    
            }
        }
            
            break;

        case DateActionView:
        {
            switch (buttonIndex) {
                case 0:
                {
                    DLog(@"Text: %@", text);
                    if ((text == nil) || ([text length] == 0)) {
                        // Error Message.. or Sound
                        return;
                    }
                    dateFilterString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.timeStyle = NSDateFormatterNoStyle;
                    dateFormatter.dateStyle = NSDateFormatterShortStyle;
                    
                    // NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
                    
                    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                    [dateFormatter setLocale:usLocale];
                    NSDate *date = [dateFormatter dateFromString:text];
                    if (date == nil) {
                        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
                        date = [dateFormatter dateFromString:text];
                    }
                    if (date == nil) {
                        dateFormatter.dateStyle = NSDateFormatterLongStyle;
                        date = [dateFormatter dateFromString:text];
                    }
                    
                    //
                    NSString *formattedDateString;
                    if (date) {
                        DLog(@"Exact Date is: %@", [dateFormatter stringFromDate:date]);
                        dateFilterExact = date; // find the exact date
                        dateFilterMatchArray = nil;
                        [dateFormatter setDateFormat:@"yyyyMMdd"];
                        formattedDateString =  [dateFormatter stringFromDate:date];
                    } else {
                        // parse for reasonable string ...
                        dateFilterMatchArray = [text componentsSeparatedByString:@" "];
                        dateFilterExact = nil;
                        [dateFormatter setDateFormat:@"dd:MMM:yyyy"];
                    }
                    
                    // Reload assets
                    [self filterAssets:NavSearchTypeByDate];
//                    20150718 [self refresh]; // reload everything
                }
                    
                    break;
                default:
                    break;
            }
        }
            break;
            
        case AddressActionView:
        {
            switch (buttonIndex) {
                case 0: // Precise
                case 1: // Town level
                case 2: // Larger
                {
                    DLog(@"Text: %@", text);
#if 1
                    if ((text == nil) || ([text length] == 0)) {
                        // Error Message.. or Sound
                        return;
                    }
                    locationFilterString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                    20150718[self startProgressView];
#ifdef CACHE_AVAILABLE
                    // Check if we have cached this address
                    CacheManager *cm = [AppDelegate sharedDelegate].cacheManager;
                    CLLocation *location = [cm locationForAddress:text];
                    if (location != nil) {
                        locationFilter = location;
                        CGFloat mult = powf(10, buttonIndex)*1.6;    // It will be 1, 10 or 100 (We are showing in miles, so mult by 1.6)
                        locationAccuracy = CGSizeMake(1000*mult, 1000*mult);   // 1000 meters (1km) for precise, 10KM or 100KM.
                        [self filterAssets:NavSearchTypeByAddress];
//                       20150718 [self refresh]; // reload everything
                    } else
#endif
                    {
                        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                        [geocoder geocodeAddressString:text completionHandler:
                         ^(NSArray* placemarks, NSError* error) {
                             
                             if (error == nil) {
                                 //            placemarklist = placemarks;
                                 //            [cm setLocationPlacemarks:placemarklist forLocation:location.coordinate];
                                 //            [self setButtonTitles];
                                 // What happens if there are multiple results??
                                 
                                 for (CLPlacemark *placemark in placemarks) {
                                     locationFilter = placemark.location;
                                     
#ifdef CACHE_AVAILABLE
                                     // cache this as well
                                     [cm setLocation:placemark.location forAddress:locationFilterString];
#endif
                                     
                                     CGFloat mult = powf(10, buttonIndex);    // It will be 1, 10 or 100
                                     locationAccuracy = CGSizeMake(1000*mult, 1000*mult);   // 1000 meters (1km) for precise, 10KM or 100KM.
                                     
                                     DLog(@"Location: %f:%f", placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
#ifdef REFERENCE
                                     NSArray *areas = placemark.areasOfInterest;
                                     NSString *areasofinterest = @"";
                                     for (NSString *area in areas) {
                                         DLog(@"Area of Interest: %@", area);
                                         areasofinterest = [NSString stringWithFormat:@"%@\n%@", areasofinterest, area];
                                     }
                                     DLog(@"City: %@", placemark.locality);
                                     DLog(@"State: %@", placemark.administrativeArea);
                                     DLog(@"Country: %@", placemark.country);
                                     DLog(@"Thoroughfare: %@", placemark.thoroughfare);
                                     DLog(@"Sub-Thoroughfare: %@", placemark.subThoroughfare);
                                     DLog(@"ISO Country: %@", placemark.ISOcountryCode);
                                     DLog(@"Address Dictionary: %@", placemark.addressDictionary);
                                     NSString *geoLocationShort = [NSString stringWithFormat:@"%@, %@ [%@]", placemark.locality?placemark.locality:@"", placemark.administrativeArea?placemark.administrativeArea:@"", placemark.ISOcountryCode?placemark.ISOcountryCode:@""];
                                     NSDictionary *dict = placemark.addressDictionary;
                                     NSString *addr = @"";
                                     for (NSString *line in [dict objectForKey: @"FormattedAddressLines"]) {
                                         addr = [NSString stringWithFormat:@"%@\n%@", addr, line];
                                     }
                                     NSString *geoLocationFull;
                                     if ([addr length] > 0) {
                                         geoLocationFull = [NSString stringWithFormat:@"%@\nLocation Address:\n%@", areasofinterest, addr];
                                         
                                     } else {
                                         geoLocationFull = [NSString stringWithFormat:@"%@\nLocation Address:\n%@\n%@, %@ %@ [%@]\n",
                                                            areasofinterest,
                                                            [dict objectForKey:@"Street"], [dict objectForKey:@"City"], [dict objectForKey:@"State"], [dict objectForKey:@"ZIP"], [dict objectForKey:@"CountryCode"] ];
                                         
                                     }
                                     DLog(@"short: %@\nlong: %@\n", geoLocationShort, geoLocationFull);
#endif
                                     [self filterAssets:NavSearchTypeByAddress];
                                 }
//                                 20150718[self refresh]; // reload everything
                             } else {
                                 [self handleError:error];
                             }
//                            20150718 [self stopProgressView];
                             
                         } ];
                    }
#endif
                }
                    
                default:
                    break;
            }
        }
            break;

        case StringActionView:
        {
            DLog(@"Text: %@", text);
            if ((text == nil) || ([text length] == 0)) {
                // Error Message.. or Sound
                return;
            }
            textFilterString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            switch (buttonIndex) {
                case 0: // Any string
                {
//                    20150718[self startProgressView];
                    [self filterAssets:NavSearchTypeByString];
//                    20150718[self stopProgressView];
//                    20150718[self refresh];
                }

                    break;
                case 1: // Pixel Resolution
                {
//                    20150718[self startProgressView];
                    [self filterAssets:NavSearchTypeByString];
//                    20150718[self stopProgressView];
//                   20150718 [self refresh];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;

        case TagActionView:
        {
            switch (buttonIndex) {
                case 0:
                {
                    DLog(@"Text: %@", text);
                    if ((text == nil) || ([text length] == 0)) {
                        // Error Message.. or Sound
                        return;
                    }
                    tagString = text;
                    NSMutableArray *tagArray = [[NSMutableArray alloc] init];;
                    for (NSString *tag in [text componentsSeparatedByString:@","]) {
                        [tagArray addObject:[tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    }
                    
//                    if (BuiltInPhotoGallery)
                    {
                        for (PhotoObject *item in _selectedItems) {
                            DLog(@"Item: %@", item.imageName);
                            NSUInteger row = [item.indexReference integerValue];
                            NSUInteger itemIndex = (currentSearchType != NavSearchTypeNone) ? [_filteredItemsIndexArray[row] integerValue] : row;
                            PHAsset *asset = _assetsFetchResults[itemIndex];
//                            CacheManager *cm = [AppDelegate sharedDelegate].cacheManager;
                            [CacheManager updateTagsForPhoto:asset withTags:tagArray];
                        }
                    }
#ifdef CLEAR_SELECTION
                    selectionMode = NO;
                    // clear everything and scram
                    for (PhotoObject *selitem in _selectedItems) {
                        selitem.imageSelected = NO;
                    }
                    _selectedItems = [[NSMutableArray alloc] init];
#endif
                    
                    [self refresh];
                }
                    break;
                    
                default:
                    break;
            }
        }
            
        default:
            break;
    }
}

#pragma mark - PHPhotoLibraryChangeObserver
// Changes In Fast Succession - keep a timer so that we can catch it once
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    if (photosLibraryChangeTimer) {
        [photosLibraryChangeTimer invalidate];
    }
    // Put a delay of few seconds
    // Fire the timer - but this is needed in the main loop
    dispatch_async(dispatch_get_main_queue(), ^{
        photosLibraryChangeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f  target:self selector:@selector(photosChangeAction:)  userInfo:changeInstance repeats:NO];
    });
}

- (void) photosChangeAction: (NSTimer *) timer
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (NavigationAtRootLevel) {
            
            NSMutableArray *updatedCollectionsFetchResults = nil;
            
            PHChange *changeInstance = [timer userInfo];
            
            for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
                PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
                if (changeDetails) {
                    if (!updatedCollectionsFetchResults) {
                        updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                    }
                    [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
                }
            }
            
            if (updatedCollectionsFetchResults) {
                self.collectionsFetchResults = updatedCollectionsFetchResults;
                //            [_collectionView reloadData];
                DLog(@"Updated fetch results");
                [self refresh];
            }
        } else {
            [self reset];
        }
        
    });

}

#pragma mark - Segment View Delegate
#if 0
- (void) selectorControlValueChanged: (id) sender
{
    DLog(@"Segment Value: %ld", (long) [(ADVSegmentedControl *)sender selectedIndex]);
}
#endif

- (void) selectorControlTapped: (id) sender
{
    DLog(@"Selector Control Tapped");
    PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
    userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES]];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:options];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:options];
    self.collectionsFetchResults = @[topLevelUserCollections, smartAlbums];
    self.collectionsLocalizedTitles = @[NSLocalizedString(@"Albums", @""), NSLocalizedString(@"Smart Albums", @"")];
    self.collectionsBeingShown = [NSMutableArray arrayWithArray: @[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES]]];

    NSMutableArray *albums = [[NSMutableArray alloc] init];
    
    [self.collectionsFetchResults[0] enumerateObjectsUsingBlock:^(PHCollectionList *asset, NSUInteger idx, BOOL *stop) {
        DLog(@"%ld: %@", (unsigned long)idx, asset.localizedTitle);
        [albums addObject: asset.localizedTitle];
    }];

    [self.collectionsFetchResults[1] enumerateObjectsUsingBlock:^(PHAssetCollection *asset, NSUInteger idx, BOOL *stop) {
        DLog(@"%ld: %@", (unsigned long)idx, asset.localizedTitle);
        [albums addObject: asset.localizedTitle];
    }];

    albumList = @[@"All Photos"];
    albumList = [albumList arrayByAddingObjectsFromArray: [albums sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    MoPopupListToo *picker = [[MoPopupListToo alloc] initWithHeaderTitle:@"Albums" cancelButtonTitle:@"All Photos" confirmButtonTitle:@"Selected"];
    picker.delegate = self;
    picker.dataSource = self;
    picker.needFooterView = NO;
    picker.tag = ALBUMLIST_PICKER;
    picker.headerBackgroundColor =[Theme mainColor];
    [picker show];

}

/* comment out this method to allow
  PickerView:titleForRow: to work.
 */
- (NSAttributedString *)popupList:(MoPopupListToo *)pickerView
               attributedTitleForRow:(NSInteger)row
{
    
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString: (pickerView.tag == AREASOFINTEREST_PICKER) ? poiList[row] : albumList[row]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
                                            }];
    return att;
}

- (NSString *)popupList:(MoPopupListToo *)pickerView
               titleForRow:(NSInteger)row
{
    return (pickerView.tag == AREASOFINTEREST_PICKER) ? poiList[row] : albumList[row];
}

- (NSInteger)numberOfRowsInPickerView:(MoPopupListToo *)pickerView
{
    return (pickerView.tag == AREASOFINTEREST_PICKER) ? poiList.count : albumList.count;
}

- (void)popupList:(MoPopupListToo *)pickerView didConfirmWithItemAtRow:(NSInteger)row
{
    if (pickerView.tag == AREASOFINTEREST_PICKER) {
        DLog(@"%@ is chosen!", poiList[row]);
        textFilterString = poiList[row];
        [self filterAssets:NavSearchTypeByString];
//        poiList = nil;
    } else {
        DLog(@"%@ is chosen!", albumList[row]);
        
        __block NSString *albumId = nil;
        
        if (row > 0) {
            PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
            userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
            
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES]];
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:options];
            
            [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *asset, NSUInteger idx, BOOL *stop) {
                DLog(@"%ld: %@", (unsigned long)idx, asset.localizedTitle);
                if (IS_EQUAL(asset.localizedTitle, albumList[row])) {
                    albumId = asset.localIdentifier;
                    *stop = YES;
                }
            }];
            
            if (!albumId) {
                PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:options];
                [topLevelUserCollections enumerateObjectsUsingBlock:^(PHCollectionList *asset, NSUInteger idx, BOOL *stop) {
                    DLog(@"%ld: %@", (unsigned long)idx, asset.localizedTitle);
                    if (IS_EQUAL(asset.localizedTitle, albumList[row])) {
                        albumId = asset.localIdentifier;
                        *stop = YES;
                    }
                }];
            }
        }
        PHFetchResult *assetCollections = nil;
        if (albumId) {
            assetCollections = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumId] options:nil];
        }
        
        if ((assetCollections && ([assetCollections count] > 0)) || (row == 0)) {
            _assetCollection = (row == 0) ? nil : assetCollections[0];
            _assetsFetchResults = [self photosList:_assetCollection];
            albumTitle = (row==0) ? [albumList[row] copy] : [NSString stringWithFormat:@"Showing: %@", albumList[row]];
            [_stickyHeaderCell.selectorButton setTitle:albumList[row] forState:UIControlStateNormal];
            [self refresh];
        }
        albumList = nil;
    }

}

-(void)popupList:(MoPopupListToo *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows
{
#ifdef DEBUG
    for(NSNumber *n in rows){
        NSInteger row = [n integerValue];
        DLog(@"%@ is chosen!", albumList[row]);
    }
#endif
}

- (void)popupListDidClickCancelButton:(MoPopupListToo *)pickerView
{
    NSLog(@"Canceled.");
    if (pickerView.tag == AREASOFINTEREST_PICKER) {
        
    } else {
        _assetCollection = nil;
        _assetsFetchResults = [self photosList:_assetCollection];
        [self refresh];
        albumList = nil;
    }

}


#pragma mark - Keyboard
#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillShow {
    // Animate the current view out of the way
    keyboardShowing = YES;
}

-(void)keyboardWillHide {
    keyboardShowing = NO;
}

#if 0
// Class Methods
#pragma mark - Tags Management
// Updates the tags (appends if there are existing tags already defined for this photo
+ (NSDictionary *) updateTagsForPhoto: (PHAsset *) photoAsset withTags: (NSArray *) tags
{
    NSError *error = nil;
    NSString *pathKey = [self tagsPathKey:photoAsset];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [self infoForPhoto:photoAsset]];
    // First we have to read the file
    if (dict) {
        // Looks like the file exists, combine the old entries
        // Make it unique
        NSArray *tagsArray = dict[@"tags"];
        if (tagsArray && ([tagsArray count] > 0)) {
            tagsArray = [tagsArray arrayByAddingObjectsFromArray:tags];
        } else {
            tagsArray = tags;
        }
        [dict setObject:tagsArray forKey:@"tags"];
    } else {
        dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"tags": tags}];
    }
    
    error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    __unused NSString *fullpath =  [self stashCommonData:jsonData forFile:pathKey];
    
    
    return dict;
}

// Sets the tags (overwrites the previous ones) if there are existing tags already defined for this photo
+ (BOOL) setTagsForPhoto: (PHAsset *) photoAsset withTags: (NSArray *) tags
{
    NSError *error = nil;
    NSString *pathKey = [self tagsPathKey:photoAsset];
    NSMutableDictionary *dict;
    
        dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"tags": tags}];
    
    error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    __unused NSString *fullpath =  [self stashCommonData:jsonData forFile:pathKey];
    
    return (error==nil);
}

+ (NSArray *) tagsForPhoto: (PHAsset *) photoAsset
{
    NSError *error = nil;
    NSString *pathKey = [self tagsPathKey:photoAsset];
    NSString *basePath = [self mapFilePath:pathKey inFileSystemZone:FileSystemZoneGroupCommon];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:basePath error:&error];
    
    NSMutableDictionary *dict;
    
    NSArray *tagsArray = nil;
    // First we have to read the file
    if ((!error) && (fileAttributes != nil)) {
        // Looks like the file exists, load it
        NSData *allData = [[NSData alloc]initWithContentsOfFile:basePath options:NSDataReadingMappedIfSafe error:&error];
        dict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error]];
        tagsArray = [dict objectForKey: @"tags"];
    }
    return tagsArray;
}

+ (NSDictionary *) infoForPhoto: (PHAsset *) photoAsset
{
    NSError *error = nil;
    NSString *pathKey = [self tagsPathKey:photoAsset];
    NSString *basePath = [self mapFilePath:pathKey inFileSystemZone:FileSystemZoneGroupCommon];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:basePath error:&error];
    
    NSMutableDictionary *dict = nil;
    
    // First we have to read the file
    if ((!error) && (fileAttributes != nil)) {
        // Looks like the file exists, load it
        NSData *allData = [[NSData alloc]initWithContentsOfFile:basePath options:NSDataReadingMappedIfSafe error:&error];
        dict = [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error];
    }
    return dict;
    
}

+ (NSString *) tagsPathKey: (PHAsset *) photoAsset
{
    return [NSString stringWithFormat:@":Photos:%@", [[photoAsset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"#SLASH#"] stringByAppendingString:TAGS_FILE_UTI]];
}

//
+ (NSString *) mapFilePath: (NSString *) pathKey inFileSystemZone: (FileSystemZone) fileZone
{
    NSString *root;
    NSString *pathKeyToUse;
    switch (fileZone) {
        case FileSystemZoneCache:
            root = [AppDelegate cacheRoot];
            pathKeyToUse = [self flattenFilePath: pathKey];
            break;
        case FileSystemZoneStash:
            root = [AppDelegate pictRoot];
            pathKeyToUse = [self unFlattenFilePath:pathKey];
            break;
        case FileSystemZoneGroupCommon:
            root = [AppDelegate commonRoot];
            pathKeyToUse = [self unFlattenFilePath:pathKey];
            break;
    }
    return [root stringByAppendingPathComponent:pathKeyToUse];
    
}

// If the file path component has special chars, replace them to '#'
+ (NSString *) flattenFilePath: (NSString *) component {
    NSRange r;
    NSString *s = [component copy];
    while ((r = [s rangeOfString:@"[/:]" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@"#"];
    return s;
}

// The file components are separated by :, replace them to '/'
+ (NSString *) unFlattenFilePath: (NSString *) component {
    NSRange r;
    NSString *s = [component copy];
    while ((r = [s rangeOfString:@"[:]" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@"/"];
    return s;
}

+ (NSString *) cacheData: (NSData *) data forFile: (NSString *) pathKey
{
    return [self cacheStashData:data forFile:pathKey inZone: FileSystemZoneCache];
}

+ (NSString *) stashData : (NSData *) data forFile: (NSString *) pathKey
{
    return [self cacheStashData:data forFile:pathKey inZone: FileSystemZoneStash];
}

+ (NSString *) stashCommonData : (NSData *) data forFile: (NSString *) pathKey
{
    return [self cacheStashData:data  forFile:pathKey inZone: FileSystemZoneGroupCommon];
}


+ (NSString *) cacheStashData: (NSData *) data forFile: (NSString *) pathKey inZone: (FileSystemZone) fileZone
{
    // Write the file in the local file system...
    
#if 0
    NSString *basePath;
    if (cacheZone) {
        basePath = [root stringByAppendingPathComponent: [self flattenFilePath: pathKey]];
    } else {
        NSString *path = [self unFlattenFilePath:pathKey];
        basePath = [root stringByAppendingString:path];
    }
#ifdef CACHE_DEBUG
    DLog(@"%@ing the file [%@]: %@", cacheZone? @"Cach" : @"Stash", basePath, pathKey);
#endif
#endif
    NSString *basePath = [self mapFilePath:pathKey inFileSystemZone:fileZone];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL created;
    
    // Overwrite the file...
    NSError *err = nil;
    if ([fileManager fileExistsAtPath:basePath]) {
        [fileManager removeItemAtPath:basePath error:&err];
        if (err) {
            DLog(@"CacheStashData (%@): Error removing existing file: %@", pathKey, err);
        }
    }
    /*if (![fileManager fileExistsAtPath:basePath]) */ {
        // Check if the directory exists
        NSString *dir = [basePath stringByDeletingLastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:dir
                                           withIntermediateDirectories:YES attributes:nil error:&err]) {
                DLog(@"cacheStashData (%@): Error creating directory: %@", pathKey, err);
                return nil;
            }
        }
        
    }
    created = [fileManager createFileAtPath:basePath contents:data attributes:nil];
    
    if (!created) return nil;   // Error
    
    // IMPORTANT
    // Modify the basePath to remove the application Path (on Simulator it keeps changing)
    NSString *appSavePath = [Utilities applicationSavePath];
    NSRange index = [basePath rangeOfString:appSavePath];
    NSString *relativePath = basePath;
    if (index.location == 0) {
        relativePath = [basePath substringFromIndex:(index.location+index.length)];
    }
    
    
//    //    [self sync];    // optimize this with the cron manager for Cache
//    @synchronized(_filesByUrlList) {
//        [_filesByUrlList setObject:relativePath forKey:pathKey];
//        _syncNeeded = YES;
//    }
    
    return basePath;
}
#endif
@end
