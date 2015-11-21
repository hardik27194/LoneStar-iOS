//
//  GalaxyViewController.m
//  SnapticaToo
//
//  Created by sandeep on 12/31/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import "GalaxyViewController.h"
#import "SSGalaxyManager.h"
//#import "CacheManager.h"
#import "MoToolTipView.h"

#import "Utilities.h"
#import "Strings.h"
#import "SettingsManager.h"
#import "MobiusoActionView.h"
#import "MoArcMenu.h"
#import "Theme.h"
#import "MoRippleTap.h"
#import "Constants.h"
#import "AppDelegate.h"


#import "UIImage+RemapColor.h"

#define kUserAssociationAction 100
#define SkyscapeNotInstalledActionView 101
#define AppNotInstalledActionView 102
#define WatsonView                103


@interface GalaxyViewController ()
{
    int                 currentServer;
    MoRippleTap         *_infoButton;
    MoRippleTap         *_watsonButton;
    NSTimer             *timer;
}

@property (nonatomic, retain)   NSMutableArray  *menuItems;
@property (nonatomic, retain)   NSArray         *menuDataStructure;
@property (nonatomic, retain)   MoArcMenu       *settingsMenu;
@property (nonatomic, retain)   NSMutableArray  *settingsMenuItems;
@property (nonatomic, retain)   MoArcMenu       *menu;

// Tool tip Management
#define THIS_SCREEN_ID          kApplicationRoot ".Galaxy"

@property (nonatomic, strong) NSArray           *toolTips;
@property (nonatomic, assign) NSInteger         currentTooltip;
@property (nonatomic, retain) MoToolTipView     *currentTooltipView;
@property (nonatomic, retain) NSTimer           *tooltipTimer;

@end

@implementation GalaxyViewController

#pragma mark - View Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
#ifdef SETTINGS_DEBUG
    CGRect frame = _bgImageView.frame;
    DLog(@"Frame: %.1f, %.1f, %.1f, %.1f\n", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
#endif
    CGRect frame = [Utilities applicationFrame];
    _dimmerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    
    [self initMenuItems];
    [self setCurrentIndexType: frame.size];
    
#ifdef IBM_WATSON
    _watsonButton = [[MoRippleTap alloc]
                   initWithFrame:CGRectMake(frame.size.width - 70, frame.size.height - 70, 64, 64)
                   andImage: [UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed:@"IBM-Watson.png"]]
                   andTarget:@selector(goWatson)
                   andBorder:NO
                   delegate:self
                   ];
    _watsonButton.rippleOn = YES;
    _watsonButton.rippleColor = [UIColor lightGrayColor];
    
    [self.view addSubview: _watsonButton];

#endif
    
    _items = [SettingsManager populateItems];
    
#ifdef SETTINGS_DEBUG
    DLog(@"JSON: %@", [Utilities jsonString: [NSDictionary dictionaryWithObject:_items forKey:@"item"]]);
#endif
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
     
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingNeedsRefresh)
                                                 name: LOCAL_NOTIFICATION_SERVER_ADDED
                                               object:nil];
    [SettingsManager instance].delegate = self;
    
#if 0
    [self setupToolTips];
    
    _tooltipTimer = [NSTimer timerWithTimeInterval: 3.0 target: self selector: @selector(tooltipDisplay) userInfo:nil repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer: _tooltipTimer forMode: NSRunLoopCommonModes];
#endif
    
    [self performSelector:@selector(addRipple) withObject:nil afterDelay:2.0];
    
//    [self setupToolTips];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(frame.size.width - 40, 8, 32, 32);
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    //    [closeButton setImage:[UIImage imageNamed:@"dismissButt"] forState:UIControlStateNormal];   // SimpleCloseLine.png
    
    [closeButton setImage:[UIImage imageNamed:@"dismissButtWHITE"] forState:UIControlStateNormal];
    closeButton.layer.cornerRadius = 16;
    closeButton.layer.backgroundColor = COLORFROMHEX(0x80000000).CGColor;
    CALayer *sublayer = [CALayer layer];
    sublayer.frame = [closeButton bounds];
    sublayer.contents = (__bridge id)([UIImage imageNamed:@"dismissButtWHITE"].CGImage);
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview: closeButton];

    
}

//
- (void) viewDidDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName: LOCAL_NOTIFICATION_SETTINGS object:nil];
    [SettingsManager instance].delegate = nil;
    if (_currentTooltipView) {
        [_currentTooltipView dismissAnimated:NO];
        _currentTooltipView = nil;
    }
    [_tooltipTimer invalidate];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - convenience methods for view
- (void) settingNeedsRefresh
{
    _items = [SettingsManager populateItems];
    [_tableView reloadData];
}

#ifdef NOTNOW
- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#endif

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

// Respond to the dismiss gesture - this closes the view - so let's post a notification for change
-(void)handleTap:(id)sender {
    
    if (((UITapGestureRecognizer *)sender).state != UIGestureRecognizerStateEnded) return;
    
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) close {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Menu Items
# pragma mark - Menu Prep methods
- (void) initMenuItems
{
    // Build Menu
    // Note: This array is ordered to handle the IndexBucket Types to match the index
    //
    // These are "well known" items so prepopulated - it will be enhanced to add other items that are
    // are not in the list here...
    _menuDataStructure = [NSMutableArray arrayWithObjects:
                          // FlashDrive
                          [NSDictionary dictionaryWithObjectsAndKeys:@"Secure Storage", @"title",@"FlashDrive",@"name",@"com.medpresso.FlashDrive",@"AppBundleID", @"Galaxy-FlashDrive-64.png",@"IconName", @"Galaxy-FlashDrive-64.png",@"2xIconName", COLORFROMHEX(0xffd32a44), @"AnchorColor", kFlashDriveAppStoreLink, @"AppStoreLink", nil],
                          // TestZapp
                          [NSDictionary dictionaryWithObjectsAndKeys:@"Quiz & Improve", @"title",@"TestZapp",@"name",@"com.medpresso.TestZapp",@"AppBundleID", @"Galaxy-TestZapp-64.png",@"IconName", @"Galaxy-TestZapp-64.png",@"2xIconName", COLORFROMHEX(0xffd32a44), @"AnchorColor",
                           kTestZappAppStoreLink, @"AppStoreLink", nil],
                          // nTrack
                          [NSDictionary dictionaryWithObjectsAndKeys:@"Learn with fun", @"title",@"nTrack 2",@"name",@"com.medpresso.nTrack2",@"AppBundleID", @"Galaxy-Track-64.png",@"IconName", @"Galaxy-Track-64.png",@"2xIconName", COLORFROMHEX(0xffd32a44), @"AnchorColor",
                           kNtrack2AppStoreLink, @"AppStoreLink", nil],
                          // SnapWord
                          [NSDictionary dictionaryWithObjectsAndKeys:@"SnapWord", @"title",@"SnapWord",@"name",@"com.medpresso.SnapWord",@"AppBundleID", @"Galaxy-SnapWord-64.png",@"IconName", @"Galaxy-SnapWord-64.png",@"2xIconName", COLORFROMHEX(0xffffa000), @"AnchorColor",
                           kSnapWordAppStoreLink, @"AppStoreLink", nil],
                          // Skills
                          [NSDictionary dictionaryWithObjectsAndKeys:@"Unlimited Skills", @"title",@"Skills Hub",@"name",@"com.medpresso.skillsapp",@"AppBundleID", @"Galaxy-Skills-64.png",@"IconName", @"Galaxy-Skills-64.png",@"2xIconName", COLORFROMHEX(0xff1f90cd), @"AnchorColor",
                           kSkillsHubAppStoreLink, @"AppStoreLink", nil],
                          // Reference
                          [NSDictionary dictionaryWithObjectsAndKeys:@"Trusted References", @"title",@"Library",@"name",@"com.medpresso.MySkyscape",@"AppBundleID", @"Galaxy-Library-64.png",@"IconName", @"Galaxy-Library-64.png",@"2xIconName", COLORFROMHEX(0xffffa000), @"AnchorColor",
                           kSMLAppStoreLink, @"AppStoreLink", nil],
                          // Buzz
                          /*    ";"
                           [NSDictionary dictionaryWithObjectsAndKeys:@"Medpresso Buzz", @"title",@"Library",@"name",@"com.medpresso.Medpresso,@"AppBundleID", @"Galaxy-Buzz-64.png",@"IconName", @"Galaxy-Library-64.png",@"2xIconName", COLORFROMHEX(0xffffa000), @"AnchorColor",
                           kBuzzAppStoreLink, @"AppStoreLink", nil],
                           */
                          
                          nil];
    
    
    // Main Menu
    _menuItems = [[NSMutableArray alloc] init];
    UIImage *storyMenuItemImage = [UIImage imageNamed: (IS_IPAD? @"bg-menuitem-96.png" : @"bg-menuitem.png")];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed: (IS_IPAD? @"bg-menuitem-highlighted-96.png" : @"bg-menuitem-highlighted.png")];
    for (int i=0; i<[self.menuDataStructure count]; i++) {
        NSDictionary *item = (NSDictionary *) [self.menuDataStructure objectAtIndex:i];
        UIImage *img = [UIImage imageNamed: [item objectForKey: (IS_IPAD ?  @"2xIconName": @"IconName")]];
        UIColor *clr = [item objectForKey: @"HexColor"];
        MoArcMenuItem *menuItem = [[MoArcMenuItem alloc] initWithImage:storyMenuItemImage
                                                      highlightedImage:storyMenuItemImagePressed
                                                          ContentImage: img
                                               highlightedContentImage: nil
                                                           anchorColor:clr];
        menuItem.hint = [item objectForKey: @"name"];
        [_menuItems addObject: menuItem];
    }
    
    // Settings/Profile/Help Menu (top right)
    _settingsMenuItems = [[NSMutableArray alloc] init];
    
    MoArcMenuItem *menuItem1 = [[MoArcMenuItem alloc] initWithImage:nil
                                                   highlightedImage:nil
                                                       ContentImage: [UIImage imageNamed:@"Home-Settings-Info-Solid.png"]
                                            highlightedContentImage: nil
                                                        anchorColor: [UIColor blackColor]];
    menuItem1.hint = @"About";
    [_settingsMenuItems addObject:menuItem1];
    
    MoArcMenuItem *menuItem2 = [[MoArcMenuItem alloc] initWithImage:nil
                                                   highlightedImage:nil
                                                       ContentImage: [UIImage imageNamed:@"Home-Settings-Tools-Solid.png"]
                                            highlightedContentImage: nil
                                                        anchorColor: [UIColor blackColor]];
    menuItem2.hint = @"Settings";
    [_settingsMenuItems addObject:menuItem2];
    
    MoArcMenuItem *menuItem3 = [[MoArcMenuItem alloc] initWithImage:nil
                                                   highlightedImage:nil
                                                       ContentImage: [UIImage imageNamed:@"Home-Settings-Profile-Solid.png"]
                                            highlightedContentImage: nil
                                                        anchorColor: [UIColor blackColor]];
    menuItem3.hint = @"Profile";
    [_settingsMenuItems addObject:menuItem3];
    
#ifdef NOTNOW
    MoArcMenuItem *menuItem4 = [[MoArcMenuItem alloc] initWithImage:nil
                                                   highlightedImage:nil
                                                       ContentImage: [UIImage imageNamed:@"Home-Settings-Login-Solid.png"]
                                            highlightedContentImage: nil
                                                        anchorColor: [UIColor blackColor]];
    menuItem4.hint = @"Login";
    [_settingsMenuItems addObject:menuItem4];
#endif
    
    
}


# pragma mark - MoArcMenuDelegate methods
- (void) handleSkyscapeInstall
{
    //    [[AppDelegate sharedDelegate] showSkyscapeInstall];
    NSString *currentUserID = [AppDelegate currentUserId];
    
    BOOL isAnonymous = ((currentUserID == nil) || IS_EQUAL(currentUserID, kAnonymousUser)) ;
    MobiusoActionView *actionView = [Utilities setupActionView:kUserAssociationAction
                                                   withMessage:ACCOUNT_FILTER_MESSAGE
                                                     withTitle:ACCOUNT_FILTER_TITLE
                                               placeholderText:nil
                                                    andButtons:@[isAnonymous? @"SKYSCAPE ACCOUNT" : @"UNLINK SKYSCAPE", @"LINK WITH DROPBOX" /* @"SIGN UP",  */]
                                             cancelButtonTitle:nil
                                                         color: [Theme redColor]
                                                        inView:self.view
                                                   andDelegate:self];
    //    actionView.paneColor = [Theme redColor];
    [actionView show];
    
    
}

- (void) needSkyscapeInstall
{
    // Show the message
    MobiusoActionView *skyscapeActionView = [Utilities setupActionView: SkyscapeNotInstalledActionView
                                                           withMessage:ACCOUNT_NO_SKYSCAPE_MESSAGE
                                                             withTitle:ACCOUNT_NO_SKYSCAPE_TITLE
                                                       placeholderText: nil andButtons:@[@"INSTALL NOW",  @"INSTALL LATER", @"REMOTE LOGIN"] cancelButtonTitle:nil
                                                                 color: RGBColor(237, 20, 91)
                                                                inView:self.view
                                                           andDelegate:self];
    //    skyscapeActionView.paneColor = RGBColor(237, 20, 91);
    
    [self.view bringSubviewToFront: skyscapeActionView];
    [skyscapeActionView show];
    
}

- (void)downloadSkyscape
{
    
    NSString *iTunesLink = kSMLAppStoreLink;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    
}

- (void) dismissActionView
{
    
    switch (_currentActionViewId) {
        case kUserAssociationAction:
            // Do something, if you have to, else the view will just vanish
            break;
            
        case SkyscapeNotInstalledActionView:
        default:
            // don't do anything, just break
            break;
            
    }
}
- (void) dismissWithClickedButtonIndex: (NSInteger) buttonIndex withText: (NSString *) text

{
    switch (_currentActionViewId) {
            
#pragma mark Watson Action
        case WatsonView:
        {
            switch (buttonIndex) {
                case 0:
                    [MobiusoToast toast:@"Watson link activated"];
                    break;
                    
                default:
                    break;
            }
        }
            break;
#pragma mark Account View
            // Account View
        case kUserAssociationAction:
            switch (buttonIndex) {
                case 0:
                {
                    // Check login
                    // Call Medpresso instead of testpresso
                    NSDictionary *userDictionary = [SSGalaxyManager getSkyscapeUser];
                    if (userDictionary == nil) {
                        // Show the message
                        [self performSelector:@selector(needSkyscapeInstall) withObject:nil afterDelay:0.1f];
                    } else {
                        [[SettingsManager instance] setCurrentUser:userDictionary];
                    }
                    
                }
                    break;
                    
                case 1:
                {
                    // Throw a login screen
                    
                }
                    break;
                    
                default:
                    break;
            }
            
            
            break;
            
//        case SkyscapeNotInstalledActionView:
//        {
//            switch (buttonIndex) {
//                case 0:
//                {
//                    // Go To AppStore Install
//                    [self downloadSkyscape];
//                    break;
//                }
//                    
//                default:
//                    // cancelled - nothing to be done
//                    break;
//            }
//            
//        }
//            break;
            
        case AppNotInstalledActionView:
            switch (buttonIndex)
        {
            case 0:
                [self downloadSelectedApp];
                break;
            case 1:
                break;
            default:
                break;
        }
            
            break;

            
        default:
            break;
    }
}

#pragma mark - ArcMenu Delegate
- (void) MoArcMenu:(MoArcMenu *)activeMenu didSelectIndex:(NSInteger)idx
{
    
    if (activeMenu == self.settingsMenu) {
        if (_settingsDelegate && [_settingsDelegate respondsToSelector: @selector(handleSettings:)]) {
            if ([_settingsDelegate handleSettings: idx]) {
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }
        }
        switch (idx) {
            case 0: // Help
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
                
            case 1: // Settings
                    //
            {
            }
                
                break;
                
            case 2: // Login
                    // For now login controller - call profile view controller and include whether logged in or not...
            {
                //                [self dismissViewControllerAnimated:YES completion:nil];
                [self handleSkyscapeInstall];
                //                [self performSelector:@selector(handleSkyscapeInstall) withObject:nil afterDelay:0.5f];
            }
                
                break;
                
            case 3:
            {
                
            }
                break;
                
            default:    // Profile
                break;
                
        }
    } else {
        // Main Menu
        // If we are the app to launch just close the view, we will
        // be right there!
        if (idx < SSAppCount) {
            NSDictionary *selectedApp = _menuDataStructure[idx];
            NSString *appBundleId = [selectedApp objectForKey:@"AppBundleID"];
            NSString *appName = [selectedApp objectForKey:@"name"];
            self.selectedAppItunesLink = [selectedApp objectForKey:@"AppStoreLink"];

            DLog(@"Selected: %@", appBundleId);
            NSDictionary *app = [SSGalaxyManager getApp:appBundleId];
#ifdef GALAXY_DEBUG
            /*
             appVersion
             appBundleNo
             appName
             appIcon
             appId
             appBundleId
             appURLScheme
             exportId
             */
            for (id obj in app) {
                DLog(@"%@", obj);
            }
#endif
            // Call the App
            // NSString *appName = [app objectForKey:@"appName"];
            // This is a simpler form of SmartLink - Just Open from the menu item provided (if a specific action, like find a
            // Smartlink term is specified, then you will have some unique Session ID and the parameters passed as a # separated list
            NSURL * url;
            if ((app)  && ([[UIApplication sharedApplication] canOpenURL:(url = [NSURL URLWithString:[NSString stringWithFormat: @"%@://skyscape?action=open&return=%@&session=&parm=", [app objectForKey:@"appURLScheme"], kMyURLScheme]])])) {
                
                [self dismissViewControllerAnimated:YES completion:nil];
                [[UIApplication sharedApplication] openURL:url];
                
            } else {
                
                if([appName isEqualToString:@"Library"]){
                    appName = @"Skyscape Medical Library";
                }
               
                NSString *message = [NSString stringWithFormat:APP_NOT_INSTALLED_MESSAGE, appName];
                
              /*  if([appName isEqualToString:@"FlashDrive"]){
                    
                    MobiusoActionView *actionView = [Utilities setupActionView:AppNotInstalledActionView
                                                                   withMessage:@""
                                                                     withTitle:@"COMING SOON"
                                                               placeholderText:nil
                                                                    andButtons:nil
                                                             cancelButtonTitle:nil
                                                                         color: [Theme redColor]
                                                                        inView:self.view
                                                                   andDelegate:self];
                      [actionView show];
                    
                }else if([appName isEqualToString:@"Library"]){
                    [self downloadSelectedApp];
                }else if([appName isEqualToString:@"TestZapp"]){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.skyscape.com/nclexqow/default.aspx"]];
                }
                else*/{
                    MobiusoActionView *actionView = [Utilities setupActionView:AppNotInstalledActionView
                                                                   withMessage:message
                                                                     withTitle:APP_NOT_INSTALLED_TITLE
                                                               placeholderText:nil
                                                                    andButtons:@[@"INSTALL NOW"]
                                                             cancelButtonTitle:@"NOT NOW"
                                                                         color: [Theme redColor]
                                                                        inView:self.view
                                                                   andDelegate:self];
                    [actionView show];
                }
                
                
                
              
            }
            
        }
    }
    
}

-(void)downloadSelectedApp
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.selectedAppItunesLink]];
}


- (void) setCurrentIndexType: (CGSize) rectSize
{
    
    NSMutableArray *menuOptions = [[NSMutableArray alloc] init];
    
    UIImage *anchorImage = [UIImage imageNamed: ((rectSize.width < 640) || (rectSize.height <640)? @"Skyscape-galaxy-128.png":@"Skyscape-galaxy-128.png")];
    UIImage *anchorHighlightedImage = [UIImage imageNamed: ((rectSize.width < 640) || (rectSize.height <640)? @"Skyscape-galaxy-128.png":@"Skyscape-galaxy-128.png")];
    UIColor *anchorColor = COLORFROMHEX(0xffffb000); // dec32f, ff6701
    for (int i=0; i<[_menuDataStructure count]; i++) {
        [menuOptions addObject: [_menuItems objectAtIndex: i]];
    }
    
    if (self.menu != nil) {
        [self.menu removeFromSuperview];
    }
    self.menu = [[MoArcMenu alloc]
                 initWithFrame: self.view.frame
                 menus: menuOptions
                 position: ArcMenuSpanLeftSemiCircle
                 anchor: anchorImage
                 anchorHighlighted: anchorHighlightedImage
                 animationRepeatCount: 3 // HUGE_VALF
                 anchorAnimation: YES
                 selectedMenuItemAsAnchor:NO
                 centerButtonDiameter:120   // check the size
                 withBlurView:self.view
                 ];
    
    self.menu.startPoint = CGPointMake(rectSize.width/2, rectSize.height/2);
    self.menu.anchorColor = anchorColor;
    self.menu.delegate = self;
    
    [self.menu animateAnchor];
    [self.view addSubview:self.menu];
    
    [self.menu performSelector:@selector(animateMenuOpen) withObject:nil afterDelay:1.0f];
    
    //
    //
    // Now add the Settings/Profile/Help Menu
    //
    //
#ifdef SUPPORT_GALAXY_SETTINGS
    if (self.settingsMenu) {
        [self.settingsMenu removeFromSuperview];
    }
    self.settingsMenu = [[MoArcMenu alloc]
                         initWithFrame: self.view.bounds
                         menus: _settingsMenuItems
                         position: ArcMenuSpanUpperRight
                         anchor: [UIImage imageNamed:@"Home-Settings-Gear.png"]
                         anchorHighlighted: [UIImage imageNamed:@"Home-Settings-Gear-Solid.png"]
                         animationRepeatCount: 3
                         anchorAnimation: YES
                         selectedMenuItemAsAnchor: NO
                         withBlurView:self.view];
    //    CGSize size = [self frame].size;
    self.settingsMenu.startPoint = CGPointMake(32.f /*rectSize.width - 25.f*/, rectSize.height - 32.f);
    DLog(@"x: %f, y: %f", rectSize.width - 25.0f, rectSize.height - 25.f);
    self.settingsMenu.anchorColor = anchorColor;
    self.settingsMenu.delegate = self;
    // [self.settingsMenu animateAnchor];
    
    
    [self.view addSubview:self.settingsMenu];
#endif
    
    
    
}

#pragma mark - Rotation
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         __unused UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         //         DLog(@"Orientation: %ld", orientation);
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //         DLog(@"Size: %f, %f", size.width, size.height);
         [self dismissViewControllerAnimated:YES completion:nil];
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}

#define OLDSTYLE

#pragma mark - Keyboard

#ifdef OLDSTYLE
#define kOFFSET_FOR_KEYBOARD 80.0

- (void)getKeyBoardHeight:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    _keyboardHeight = keyboardFrameBeginRect.size.height;
}

-(void)keyboardWillShow:(NSNotification*) notification
{
    [self getKeyBoardHeight:notification];
    
    _keyboardVisible = YES;
    
    CGRect frame = [[_currentResponder superview] superview].frame;
#ifdef SETTINGS_DEBUG
    
    DLog(@"current y=%f, height=%f", frame.origin.y, frame.size.height);
    DLog(@"Tableview y=%f, offset=%f", [_tableView frame].origin.y, _tableView.contentOffset.y);
#endif
    
    CGFloat fieldbottom = frame.origin.y + frame.size.height + ([_tableView frame].origin.y  - _tableView.contentOffset.y);
    
    // if the bottom part of the field cell is below the top of the keyboard, we need to move it by that much
    CGFloat topofthekeyboard = (self.view.frame.size.height - _keyboardHeight);
    _keyboardMoveOffset = (fieldbottom > topofthekeyboard) ?  (fieldbottom - topofthekeyboard) : 0;
    // Animate the current view out of the way
    
    [self setViewMovedUp:YES];
}

-(void)keyboardWillHide:(NSNotification*) notification
{
    _keyboardVisible = NO;
    
    [self setViewMovedUp:NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    _currentResponder = sender;
    
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
#if 0
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= _keyboardMoveOffset;
        rect.size.height += _keyboardMoveOffset;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += _keyboardMoveOffset;
        rect.size.height -= _keyboardMoveOffset;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
#endif
    // move the tableview offset by the amount of offset
    CGPoint offset = _tableView.contentOffset;
    offset.y +=  (movedUp? 1 : -1) * _keyboardMoveOffset;
    
#if 0
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
    _tableView.contentOffset = offset;
    
    [UIView commitAnimations];
#endif
    
    [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:4.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        _tableView.contentOffset = offset;
        
        
    } completion:^(BOOL finished) {
        
        //        [transitionContext completeTransition:YES];
    }];
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textFld;
{
    return YES;
}

#endif


#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldEndEditing: (UITextField *)textFld
{
#ifdef SETTINGS_DEBUG
    DLog(@"Text: %@", textFld.text);
#endif
    
    return YES;
}



-(void) textFieldDidEndEditing: (UITextField *)textFld
{
    
}


/*
 #pragma mark - Navigation
 
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - Twinkles
- (void) addRipple
{
    CGRect frame = [self.view frame];
    _infoButton = [[MoRippleTap alloc]
                   initWithFrame:CGRectMake(CGRectGetMidX(frame), frame.origin.y, 16, 16)
                   andImage: nil // [UIImage imageNamed:@"info_Button.png"]
                   andTarget:nil
                   andBorder:NO
                   delegate:self
                   ];
    _infoButton.rippleOn = YES;
    _infoButton.rippleColor = [UIColor whiteColor];
    _infoButton.rippleWidth = 1.0f;
    _infoButton.rippleRadius = 12.0f;
    _infoButton.rippleDuration = 2.5f;
    
    [self.view addSubview: _infoButton];
    
    timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(randomize) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer: timer forMode:NSRunLoopCommonModes];
    
}

- (void) randomize
{
    CGFloat random1 = (CGFloat)arc4random()/0xFFFFFFFF;  // between 0 & 1
    CGFloat random2 = (CGFloat)arc4random()/0xFFFFFFFF;  // between 0 & 1
    CGRect frame = [self.view bounds];
    _infoButton.center = CGPointMake(random1 * frame.size.width, random2 * frame.size.height);
    [_infoButton handle: nil];
    CGFloat delay = 1.5f + (arc4random() % 5);
    timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(randomize) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer: timer forMode:NSRunLoopCommonModes];
}

#pragma mark - Tooltips

- (void) setupToolTips
{
    _toolTips = [NSMutableArray arrayWithObjects:
                 // Main Menu
                /* [NSDictionary dictionaryWithObjectsAndKeys:
                  @"SkillsHub", @"name",
                  @"Learn – Track – Quiz – anytime, anywhere...", @"message",
                  _appIconView, @"target",
                  self, @"delegate",
                  [Theme redColor], @"color",
                  [UIColor whiteColor], @"textColor",
                  [UIFont fontWithName:@"Avenir Next" size:16], @"textFont",
                  [NSNumber numberWithInt:arc4random() % 2 ], @"animation",
                  nil],*/
                 // Main Menu
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  @"Smartlink Apps", @"name",
                  @"Tap to open other Skyscape Apps", @"message",
                  _menu.tapButton, @"target",
                  self, @"delegate",
                  [Theme redColor], @"color",
                  [UIColor whiteColor], @"textColor",
                  [UIFont fontWithName:@"Avenir Next" size:16], @"textFont",
                  [NSNumber numberWithInt:arc4random() % 2 ], @"animation",
                  nil],
                 // Settings Menu
//                 [NSDictionary dictionaryWithObjectsAndKeys:
//                  @"Settings", @"name",
//                  @"Tap on this button to select settings and customization options.", @"message",
//                  _settingsMenu.tapButton, @"target",
//                  self, @"delegate",
//                  [Theme signatureColor], @"color",
//                  [UIColor whiteColor], @"textColor",
//                  [UIFont fontWithName:@"Avenir Next" size:16], @"textFont",
//                  [NSNumber numberWithInt:arc4random() % 2 ], @"animation",
//                  nil],
                 nil];
    
    _currentTooltip = [MoToolTipView shouldRunTooltip:THIS_SCREEN_ID];
    
    
    
}

- (void) toolTipViewDismissed:(MoToolTipView *)toolTipView
{
    // Now we go to the next one...
    _currentTooltip++;
    [MoToolTipView setShouldRunTooltip:THIS_SCREEN_ID toolTipIndex: _currentTooltip];    // next time this tooltip will be shown
                                                                                         // Set up some amount of delay to run the next one...
    if (_currentTooltipView) {
        _currentTooltipView = nil;
    }
    [self performSelector:@selector(tooltipDisplay) withObject: nil afterDelay: 0.5f /*(_currentTooltip * 2) + 4.0f*/];
}

#pragma mark - Display the next tooltip
- (void) tooltipDisplay
{
    
    if (self.currentTooltip >= [self.toolTips count]) {
#ifdef DEBUG_TOOLTIPS
        // Uncomment the following (and remove return), so that it will rotate through
        self.currentTooltip = 0;
#else
        return;
#endif
    }
    
    _currentTooltipView = [MoToolTipView showInView:self.view withItem: _toolTips[_currentTooltip]];
    
}

#pragma mark - Watson
#define IBM_WATSON_TITLE NSLocalizedString(@"SKYSCAPE SCHOLAR", @"SKYSCAPE")
#define IBM_WATSON_MESSAGE NSLocalizedString(@"You can ask a question to get appropriate guidance from the resources in the Skyscape Medical Library.", @"You can ask a question to get appropriate guidance")

#ifdef IBM_WATSON
- (void) goWatson
{
    [self dismissViewControllerAnimated:YES completion: ^{
        NSString *placeholder = @"Ask your question";
        // Show the message
        MobiusoVideoActionView *skyscapeActionView = [Utilities setupVideoActionView: WatsonView
                                                                         withMessage: IBM_WATSON_MESSAGE
                                                                           withTitle: IBM_WATSON_TITLE
                                                                     placeholderText: placeholder
                                                                          andButtons: @[@"SMART SEARCH"]
                                                                   cancelButtonTitle: nil
                                                                               color: [Theme redColor]
                                                                          background: @"Skyscape_Galaxy_IBM_Watson.png"
                                                                              inView: [[AppDelegate sharedDelegate] rootView] andDelegate:self
                                                      ];
        
        [self.view bringSubviewToFront: skyscapeActionView];
        [skyscapeActionView show];
    }];
    
}
#endif

@end
