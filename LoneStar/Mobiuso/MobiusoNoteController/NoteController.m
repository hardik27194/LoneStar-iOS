//
//  NoteController.m
//  ShshDox
//
//  Created by sandeep on 7/10/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//
#import "NoteController.h"
#import "Utilities.h"
#import "Theme.h"
#import "Constants.h"
#import "ICTextView.h"
#import "RNDecryptor.h"
#import "RNEncryptor.h"
#import "UIImage+RemapColor.h"
#import "Strings.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>
#import "AppDelegate.h"
#import "MobiusoToast.h"
#import "TimeoutUIApplication.h"
#import "EncryptionUtilities.h"
#import "MobiusoActionView.h"
#import "MoArcMenu.h"
#import "SocialUtilities.h"

// For older SDKs
#ifndef NSFoundationVersionNumber_iOS_6_1
#define NSFoundationVersionNumber_iOS_6_1 993.0
#endif

#define MAX_DISPLAY_COUNT 5
#define MAX_SMS_SIZE    918

@interface NoteController () <UITextViewDelegate, UISearchBarDelegate>

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSString              *filePath;
@property (nonatomic, assign) BOOL                  isEncrypted;
@property (nonatomic, retain) NSString              *password;
@property (nonatomic, assign) BOOL                  textViewLoaded;
@property (nonatomic, retain) NSTimer               *writeTimer;
@property (nonatomic, retain) UIButton              *refreshButton;

@property (nonatomic, retain) ICTextView            *textView;
@property (nonatomic, retain) UISearchBar           *searchBar;
@property (nonatomic, retain) MoProgressView        *activityView;
@property (nonatomic, assign) NSUInteger            saveCounter;

@property (nonatomic, retain) MobiusoTimedCurtain   *curtain;
@property (nonatomic, retain) NSTimer               *progressTimer;
@property (nonatomic, assign) CGFloat               curtainProgressValue1;
@property (nonatomic, assign) CGFloat               curtainProgressValue2;
@property (nonatomic, assign) BOOL                  curtainActive;

@property (nonatomic, assign) BOOL                  withDropbox;

@property (nonatomic, retain) MoArcMenu             *shareMenu;
@property (nonatomic, retain) NSMutableArray        *shareMenuItems;

@end


@implementation NoteController

//
//
// From Local File System (_withDropbox is set to NO)
//
- (id) initWithFilePath: (NSString *) filePath andPassword: (NSString *) passwd
{
    if ((self = [self initCommon: [filePath lastPathComponent]])) {
        _withDropbox = NO;
        _filePath = filePath;
        _password = passwd;
    }
    return self;
}

- (id)initCommon: (NSString *) fname  {
    if (!(self = [super init])) return nil;
    
    FileType type = [Utilities fileType:fname];
    _isEncrypted = (type == FileTypeSHSH);
    // If this is an encrypted file, then we must set notification
    if (_isEncrypted) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout:) name:kApplicationDidTimeoutNotification object:nil];
        
    }
    
    self.navigationItem.title = _isEncrypted?
                                    [NSString stringWithFormat:@"%@*",[Utilities basenameIfEncryptedfile:fname]]
                                    : fname ;
    
    [self layoutButtons];
    
    return self;
}

#define MAIL_INDEX  0
#define SMS_INDEX   1
#define WHATSAPP_INDEX  2

- (void) addShareMenu
{
    _shareMenuItems = [[NSMutableArray alloc] init];
    
    
    // MAIL
    MoArcMenuItem *menuItem3 = [[MoArcMenuItem alloc] initWithImage:nil
                                                   highlightedImage:nil
                                                       ContentImage: [UIImage imageNamed:@"Mail"]
                                            highlightedContentImage: nil
                                                        anchorColor: [UIColor blackColor]];
    menuItem3.hint = @"Mail";
    [_shareMenuItems addObject:menuItem3];
    
    // SMS
    MoArcMenuItem *menuItem4 = [[MoArcMenuItem alloc] initWithImage:nil
                                                   highlightedImage:nil
                                                       ContentImage: [UIImage imageNamed:@"SMS"]
                                            highlightedContentImage: nil
                                                        anchorColor: [UIColor blackColor]];
    menuItem4.hint = @"Message";
    [_shareMenuItems addObject:menuItem4];
    
    
    MoArcMenuItem *menuItem7 = [[MoArcMenuItem alloc] initWithImage:nil
                                                   highlightedImage:nil
                                                       ContentImage: [UIImage imageNamed:@"WhatsApp"]
                                            highlightedContentImage: nil
                                                        anchorColor: [UIColor blackColor]];
    menuItem7.hint = @"WhatsApp";
    [_shareMenuItems addObject:menuItem7];
    
}
- (UIView *) addShimLayer: (CGRect) shimframe withRoundedCorner: (BOOL) rounded
{
    UIView *_shimView;
#if 1
#ifdef DO_BLUR_EFFECT
    if (IS_IOS8) {
        // Blur Effect
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [bluredEffectView setFrame:shimframe];
        
        
        // Vibrancy Effect
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        // vibrancyEffectView.backgroundColor = COLORFROMHEX(0xff990000);
        [vibrancyEffectView setFrame:bluredEffectView.bounds];
        // Add Vibrancy View to Blur View
        [bluredEffectView addSubview:vibrancyEffectView];
        // Add Label to Vibrancy View
        //            [self.view addSubview: bluredEffectView];
        _shimView = (id) bluredEffectView;
        _shimView.alpha = 1.0;   //
        
    } else
#endif
    {
        _shimView = [[UIView alloc] initWithFrame:shimframe];
        _shimView.backgroundColor = [UIColor blackColor];
        _shimView.alpha = 0.5;
        _shimView.frame = shimframe;
        _shimView.tag = 1010;
        _shimView.alpha = 0.3;
    }
    if (rounded) {
        _shimView.layer.cornerRadius = shimframe.size.height/2;
    }
    _shimView.clipsToBounds = YES;
    [self.view addSubview:_shimView];
#endif
    return _shimView;
}

- (void) addShadow: (CALayer *) layer
{
#if 0
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowRadius = 2.0f;
    layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    layer.shadowOpacity = 1.0f;
#endif
}

- (void) layoutButtons
{
    [self addShareMenu];

    CGRect frame = [Utilities applicationFrame];
// Put a decent background behind it...
    __unused UIView *shareShimView = [self addShimLayer:CGRectMake(frame.size.width - 48, 44, 48, 48) withRoundedCorner:YES];
    
    // Top Right Arc Menu for Sharing
    self.shareMenu = [[MoArcMenu alloc]
                      initWithFrame: self.view.bounds
                      menus: _shareMenuItems
                      position: ArcMenuSpanLowerLeft
                      anchor: [UIImage imageNamed:@"share"]
                      anchorHighlighted: [UIImage imageNamed:@"share"]
                      animationRepeatCount: 3
                      anchorAnimation: YES
                      selectedMenuItemAsAnchor: NO
                      withBlurView:self.view];
    //    CGSize size = [self frame].size;
    self.shareMenu.startPoint = CGPointMake(frame.size.width - 24.0f, 64);
    self.shareMenu.anchorColor = [UIColor whiteColor];
    self.shareMenu.delegate = self;
    [self addShadow:self.shareMenu.layer];
    
    [self.view addSubview: _shareMenu];
    
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 48, 77, 48, 14)];
    shareLabel.text = @"Share";
    shareLabel.textColor = [UIColor whiteColor];
    shareLabel.textAlignment = NSTextAlignmentCenter;
    shareLabel.font = [UIFont fontWithName:@"BebasNeue" size:12];
    [self addShadow:shareLabel.layer];
    [self.view addSubview:shareLabel];

#if 0
    _refreshButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [_refreshButton setImage: [UIImage RemapColor:[UIColor grayColor] maskImage: [UIImage imageNamed: @"Icon-Refresh-48.png"]] forState:UIControlStateNormal];
    [_refreshButton setFrame:CGRectMake(-6,0,24,24)];
    [_refreshButton addTarget:self action:@selector(didPressUpdate) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc]  initWithCustomView:_refreshButton];
    
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressShare)];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -6;// it was -6 in iOS 6
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, updateButton, shareButton];
    
    
    // Set the left button to Done
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = doneButton;
#endif

}

- (void)loadView
{
    // BOOL iOS7 = NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1; // sigh
    
    CGRect tempFrame = [Utilities applicationFrame]; // [UIScreen mainScreen].applicationFrame;
    
#if 0
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 8.0f, tempFrame.size.width - 88.0f, 24.0f)];
    titleView.text = [_filePath lastPathComponent];
    titleView.font = [UIFont fontWithName:@"Bebas Neue" size:20];
    titleView.textColor = [Theme mainColor];
#endif
    
    CGFloat statusBarOffset = 4.0f;// iOS7 ? 0.0 : 0.0; //
    _saveCounter = 0;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, statusBarOffset, tempFrame.size.width - 44, 36.0)];
    _searchBar.delegate = self;

    _searchBar.tintColor = COLORFROMHEX(0xffec008c);
    // _searchBar.barStyle = UIBarStyleBlackTranslucent;  // sandeep was Default
    _searchBar.translucent = YES;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchBar.keyboardType = UIKeyboardTypeASCIICapable;
    _searchBar.alpha = 1.0;
    _searchBar.placeholder = @"Search Text";
    
    
    CGSize size = CGSizeMake(30, 32);
    // create context with transparent background
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,30,32)
                                cornerRadius:6.0] addClip];
    [COLORFROMHEX(0x80f0f0f0) setFill];
    // [[UIColor colorWithPatternImage:[UIImage imageNamed:@"shl.png"]] setFill];
    
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[UISearchBar appearance] setSearchFieldBackgroundImage:image forState:UIControlStateNormal];

    // create context with transparent background
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,30,40)
                                cornerRadius:0.0] addClip];
    [COLORFROMHEX(0xffffffff) setFill];
    // [[UIColor colorWithPatternImage:[UIImage imageNamed:@"shl.png"]] setFill];
    
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    _searchBar.backgroundImage = image2;

    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    UIView *mainView = [[UIView alloc] initWithFrame:tempFrame];
    
    // CGFloat keyboardHeight = 216.0; // Again, lazy
    CGFloat searchBarHeight = _searchBar.frame.size.height;
    // if (!iOS7)
        tempFrame.origin.y = 0.0;
    _textView = [[ICTextView alloc] initWithFrame:tempFrame];
    UIEdgeInsets tempInsets = UIEdgeInsetsMake(searchBarHeight+statusBarOffset, 0.0, 40, 0.0);
    _textView.contentInset = tempInsets;
    _textView.font = [UIFont fontWithName:[Theme lightFontName] size:18.0f]; // [UIFont systemFontOfSize:14.0];
    _textView.scrollIndicatorInsets = tempInsets;
    _textView.delegate = self;
    _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive; // Causes a problem when UIScrollViewKeyboardDismissModeOnDrag
    
    [mainView addSubview:_textView];
    [mainView addSubview:_searchBar];
#if 0
    [mainView addSubview:titleView];
#endif

    self.view = mainView;
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame: CGRectMake(tempFrame.size.width - 48, 0, 44, 44)];
    [closeButton setImage:[UIImage RemapColor:COLORFROMHEX(0xa0000000) maskImage:[UIImage imageNamed: @"dismissButtWHITE"]] forState:UIControlStateNormal];
    [closeButton addTarget:self action: @selector(done:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];

}

- (void)unloadViews {
    _activityView = nil;
    self.textView = nil;
}

- (void) resizeViews {
    
    CGRect tempFrame = [UIScreen mainScreen].applicationFrame; // [Utilities applicationFrame];
    _textView.frame = tempFrame;
    
    if (self.curtainActive) {
        self.curtain.frame = tempFrame;
        [self.curtain reload:tempFrame];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    _activityView = [[MoProgressView alloc] initWithView:self.view];
    [self.view addSubview:_activityView];
    _activityView.delegate = self;
    _activityView.labelText = @"Loading Note";
    [_activityView show:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    __weak NoteController *weakSelf = self;
    [self.navigationController setToolbarHidden:YES];
    [self reload];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
     
                                               object:nil];

}

- (void) viewDidAppear:(BOOL)animated
{
    [_textView resignFirstResponder];
    MobiusoActionView *actionView = [Utilities setupActionView: 1001
                                                             withMessage: ROSTER_NOTE_HELP_MESSAGE
                                                               withTitle: ROSTER_NOTE_HELP_TITLE
                                                         placeholderText: nil
                                                              andButtons: @[USER_EMPTY_BUTTON_OK]
                                                       cancelButtonTitle: nil
                                                                   color: [Theme mainColor]
//                                                              background: @"bkg2"
                                                                  inView: self.view
                                                             andDelegate: self];
    [actionView showWithCompletionBlock:  ^(MobiusoActionView *actionView, NSInteger buttonIndex, NSString *inputText) {
        [_textView becomeFirstResponder];
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    
}

- (void) viewDidDisappear:(BOOL)animated
{
    if(_activityView)
        [_activityView hide:YES];
    
}


#pragma mark - Rotation support

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self resizeViews];
    
}

// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification

{
    
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    BOOL isLandscape = ([[UIApplication sharedApplication] statusBarOrientation] != UIDeviceOrientationPortrait);
    
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(_searchBar.frame.size.height, 0.0, (isLandscape? kbSize.width+40:kbSize.height+40), 0.0);
    
    _textView.contentInset = contentInsets;
    
    _textView.scrollIndicatorInsets = contentInsets;
    
    
    
}



// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification

{
    // DLog(@"Offset: %f", _textView.contentOffset.y);

    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    _textView.contentInset = contentInsets;
    
    _textView.scrollIndicatorInsets = contentInsets;

    
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView {
    [_writeTimer invalidate];
    self.writeTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(saveChanges)
                            userInfo:nil repeats:NO];
    self.navigationItem.title = [NSString stringWithFormat:@"*%@", [_filePath lastPathComponent]];

}


#pragma mark - private methods



#pragma mark - Reload the File
- (void)reload {
#if 0

    BOOL updateEnabled = NO;
#endif
    {
        // FilePath
        NSError *error;
        NSString *fileContents = [[NSString alloc] initWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error: &error];
        self.textView.text = fileContents;
        if (_activityView) [_activityView hide:YES];
    }
    
#if 0
    _refreshButton.enabled = updateEnabled;
    [_refreshButton setImage: [UIImage RemapColor:(updateEnabled?[Theme mainColor]:[UIColor grayColor]) maskImage: [UIImage imageNamed: @"Icon-Refresh-48.png"]] forState:UIControlStateNormal];
#endif
    
}

- (void)saveChanges {
    if (!_writeTimer) return;
    [_writeTimer invalidate];
    _writeTimer = nil;
    

    NSString *fileContents = self.textView.text;
    if (_isEncrypted) {
        // NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
        // NSError *nsError;
        BOOL result;
        
{
            result = [EncryptionUtilities encryptFile:_filePath withPassword:_password andContent:fileContents];
        }
        // [_file writeData:encryptedData error:&error];
        if (!result) {
            DLog(@"Error writing file.");
            [MobiusoToast toast: SAVE_ERROR_STRING inView:self.view forDuration:3.0f];
            _saveCounter = MAX_DISPLAY_COUNT;  // Next save should show the message
            return;
        }
    } else {
{
            [Utilities writeFile:_filePath withContents:fileContents];
        }
    }
    if (_saveCounter++ >= MAX_DISPLAY_COUNT) {
        [MobiusoToast toast: SAVED_STRING inView:self.view forDuration:1.0f];
        _saveCounter = 0;
    }
    self.navigationItem.title = [_filePath lastPathComponent];
}

#pragma mark - Navigation Bar Button actions
- (void)didPressUpdate {
    _textViewLoaded = NO;
    [self reload];
}

/*
 #pragma mark - SMS File as attachment
 if (buttonIndex == 0) // SMS
 #pragma mark - Email file as attachment
 
 else if (buttonIndex == 1) // Email
 
*/
#pragma mark - ArcMenu Delegate Methods
- (void) MoArcMenu:(MoArcMenu *)menu didSelectIndex:(NSInteger)idx
{
    switch (idx) {
        case MAIL_INDEX: // EMail
        {
            [SocialUtilities mail:self withFile:_filePath];

        }
            break;
 
        case SMS_INDEX: // SMS
        {
            [SocialUtilities textMessage:self withFile:_filePath];
        }
 
            break;
        case WHATSAPP_INDEX: // WhatsApp
        {
            [SocialUtilities whatsApp:self withFile:_filePath];
        }
 
            break;
 
        default:
            break;
    }
 
}

- (void) MoArcMenuDismissed:(MoArcMenu *)menu
{
    
}

- (void) MoArcMenuFired:(MoArcMenu *)menu
{
    
}

#if 0
- (void)didPressShare {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:SHARE_STRING delegate:self cancelButtonTitle: nil destructiveButtonTitle:nil otherButtonTitles:nil];
    NSArray *buttonTitles = [self buttonTitlesForShareButton];
    for (NSString *title in buttonTitles) {
        [sheet addButtonWithTitle:title];
    }
    sheet.cancelButtonIndex = [buttonTitles count] - 1;
    
    [sheet showInView:self.view];
    
}

- (NSArray*) buttonTitlesForShareButton {
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:4];
    [titleArray addObject:@"SMS"];      // button 0
    [titleArray addObject:@"E-mail"];   // button 1
    if (_isEncrypted) {
        [titleArray addObject:@"Send Password"];  // @"Send Password by SMS" button 2
    }
    if (IS_IOS7) {
        [titleArray addObject:@"Save as PDF"];  // @"Generate PDF" (and 'send'?) button 2, 3 or 4
    }
    
    [titleArray addObject:ACTION_CANCEL_STRING];
    return titleArray;
}
#endif


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!searchText || [searchText isEqualToString:@""])
    {
        [_textView resetSearch];
        return;
    }
    [_textView scrollToString:searchText searchOptions:(NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines|NSRegularExpressionDotMatchesLineSeparators) animated:YES atScrollPosition:ICTextViewScrollPositionMiddle];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [_textView becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_textView scrollToString:searchBar.text searchOptions:NSRegularExpressionCaseInsensitive animated:YES atScrollPosition:ICTextViewScrollPositionMiddle];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    [_textView resetSearch];
}

#pragma mark - Alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - MFMessageComposeViewControllerDelegate methods
#if 0
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#endif

#pragma mark - Mail Delegate
// Email delegates ================
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)results error:(NSError *)error  {
    NSString *message = nil;
    switch (results) {
        case MFMailComposeResultCancelled: {
            message = NSLocalizedString(@"Email Cancelled", @"");
        }
            break;
            
        case MFMailComposeResultSaved:{
            message = NSLocalizedString(@"Email Saved", @"");
        }
            break;
            
        case MFMailComposeResultSent:{
            message = NSLocalizedString(@"Email Sent", @"");
        }
            break;
            
        case MFMailComposeResultFailed:{
            message = NSLocalizedString(@"Email error, try again", @"");
        }
            break;
            
            
        default: break;
    }
    // Dismiss the Email View Controller
    [controller dismissViewControllerAnimated:true completion: nil];
    if (message) {
        [MobiusoToast toast:message inView:self.view];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate Methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString *message = nil;
    switch (result) {
        case MessageComposeResultSent: {
            message = NSLocalizedString(@"Message Sent", @"");
        }
            break;
            
        case MessageComposeResultCancelled: {
            message = NSLocalizedString(@"Message Cancelled.", @"");
        }
            break;
        case MessageComposeResultFailed:
        default:
        {
            message = NSLocalizedString(@"Message failed", @"");
        }
            break;
            
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    [MobiusoToast toast:message inView:self.view];
}


- (NSString*) shareString {
    return [NSString stringWithFormat:@"%@ " kWebsiteReference, SHARE_MESSAGE_STRING];
}

- (NSString*) shareHTMLString: (BOOL) encrypted
{
    return [NSString stringWithFormat:SHARE_HTML_BODY_STRING, @"NAME", encrypted? @" encrypted" : @"", SHARE_MESSAGE_STRING];
}

- (NSString*) fileToHTML: (NSString *) content
{
    return [NSString stringWithFormat:FILE_CONVERSION_STRING,  content, SHARE_MESSAGE_STRING];
    
}

#pragma mark - ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // This is a hack - it has to be a better method to handle the button index matching...
    NSUInteger smsPasswordButtonIndex =  (_isEncrypted)? 2 : -1;
    NSUInteger pdfButtonIndex =  (IS_IOS7)? ((_isEncrypted)? 3 : 2) : -1;
    
#pragma mark - SMS File as attachment
    if (buttonIndex == 0) // SMS
        {
            if (![MFMessageComposeViewController canSendText]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_STRING message:[NSString stringWithFormat:@"SMS %@", NOT_AVAILABLE_STRING] delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                [alert show];
            } else {
                MFMessageComposeViewController *sms = [[MFMessageComposeViewController alloc] init];
                sms.messageComposeDelegate = self;

                sms.modalPresentationStyle = UIModalPresentationFormSheet;
                [self presentViewController:sms animated:YES completion:nil];
            }
        }
#pragma mark - Email file as attachment
    
        else if (buttonIndex == 1) // Email
        {
            if (![MFMailComposeViewController canSendMail])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_STRING message:[NSString stringWithFormat:@"E-mail %@", NOT_AVAILABLE_STRING] delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                @try {
                    MFMailComposeViewController *email = [[MFMailComposeViewController alloc] init];
                    email.mailComposeDelegate = self;
#if 0
                    NSString *filename = [_file.info.path name];
                    NSRange fileextension = [filename rangeOfString: @"." options:NSBackwardsSearch];
                    
                    BOOL isEncrypted = NO;
                    NSString *extension = @"";
                    if ((fileextension.location != NSNotFound) && ((filename.length - fileextension.location) > 1)) {
                        extension = [filename substringFromIndex:fileextension.location+1];
                    }
                    NSString *mimeType;
                    
                    if ([extension isEqualToString:@"jpg"]) {
                        mimeType = @"image/jpeg";
                    } else if ([extension isEqualToString:@"png"]) {
                        mimeType = @"image/png";
                    } else if ([extension isEqualToString:@"doc"]) {
                        mimeType = @"application/msword";
                    } else if ([extension isEqualToString:@"ppt"]) {
                        mimeType = @"application/vnd.ms-powerpoint";
                    } else if ([extension isEqualToString:@"html"]) {
                        mimeType = @"text/html";
                    } else if ([extension isEqualToString:@"pdf"]) {
                        mimeType = @"application/pdf";
                    } else if ([extension isEqualToString:@"text"] || [extension isEqualToString:@"txt"]) {
                        mimeType = @"application/text";
                    } else if ([extension isEqualToString:@"shsh"]) {
                        isEncrypted = YES;
                        mimeType = @"application/shsh";
                    }
                    
                    [email setSubject: [NSString stringWithFormat: @"%@ from %@" , filename, APPLICATION_NAME]];
                    [email setMessageBody:[self shareHTMLString: isEncrypted] isHTML:YES];
                    email.modalPresentationStyle = UIModalPresentationFormSheet;
                    // Add attachment
                    DBError *error;
                    NSData *fileData =  [_file readData:&error];
                    
                    
                    [email addAttachmentData:fileData mimeType:mimeType fileName:[_file.info.path name]];
                    
                    [self presentViewController:email animated:YES completion:nil];
#endif
                }
                @catch (NSException *exception) {
                    DLog(@"Error Occured %@ (reason: %@)", [exception name], [exception reason]);
                }
           }
        }
#pragma mark - SMS password
        else if (buttonIndex == smsPasswordButtonIndex) // Send Password by SMS
        {
            if (![MFMessageComposeViewController canSendText]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_STRING message:[NSString stringWithFormat:@"SMS %@", NOT_AVAILABLE_STRING] delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                [alert show];
            } else {
                // For now it is by SMS and user has to type the password in
                // Send a token later
                MFMessageComposeViewController *sms = [[MFMessageComposeViewController alloc] init];
                sms.messageComposeDelegate = self;
                sms.modalPresentationStyle = UIModalPresentationFormSheet;
                [self presentViewController:sms animated:YES completion:nil];
            }
            
        }
#pragma mark - Save as PDF
        else if (buttonIndex == pdfButtonIndex) //  PDF (Originally QR code)
        {
            
#if 0
            NSString *filename = [_filePath lastPathComponent];

            
            NSString *text = [_textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];

            NSString *html = [self fileToHTML: text] ;
            NSString *header = [NSString stringWithFormat: HEADER_STRING, filename];
            NSString *footer = [NSString stringWithFormat: FOOTER_STRING, SHARE_MESSAGE_STRING];
            //
            //
            //
            //
            @try {
                NSString *pdfPath = [MoPDFGenerator generatePDFFromHTMLString:html withHeader:header andFooter:footer];
                {
                    NSString *filename = [Utilities basename: [_filePath lastPathComponent]];
                    NSString *newFilePath = [NSString stringWithFormat:@"%@/%@" PDF_FILE_UTI, [_filePath stringByDeletingLastPathComponent], filename];
                    NSFileManager *filemanager = [NSFileManager defaultManager];
                    if (filemanager) {
                        [filemanager createFileAtPath:newFilePath contents:[NSData dataWithContentsOfFile:pdfPath] attributes:nil];
                    }
                    [MobiusoToast toast: [NSString stringWithFormat: @"Created PDF: %@", [newFilePath lastPathComponent]] inView:self.view forDuration:2.0f];

                }
                
            }
            @catch (NSException *exception) {
                DLog(@"Error Occured %@ (reason: %@)", [exception name], [exception reason]);
            }
            
#endif
        }

}

#pragma mark - Status Bar
- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark MoProgressViewDelegate methods

- (void) progressViewWasHidden:(MoProgressView *)progressView {
    // Remove HUD from screen when the HUD was hidded
    [_activityView removeFromSuperview];
}

#pragma mark - time out for encrypted file

-(void)applicationDidTimeout:(NSNotification *) notif
{
    // close out
    NSLog(@"Timed out!");
    // [self.navigationController popViewControllerAnimated:YES];
    if (![NSThread isMainThread])
    {
        // 20141226 [self performSelectorInBackground:@selector(applicationDidTimeout:) withObject:notif];
        [self performSelectorOnMainThread:@selector(applicationDidTimeout:) withObject:notif waitUntilDone:NO];
        NSLog(@"Not in main thread when timing out..!");
        return;
    }
    //
    [_searchBar removeFromSuperview];
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }
    // If the focus is inside the search bar then try this
    // [self hideKeyboardForFirstResponder:_searchBar];
    [self drawCurtain];
    [MobiusoToast toast: CLOSING_LOCKED_FILE_STRING inView:self.view forDuration:2.0f];
}


- (void) done:(id)sender
{
    [self performAction];
}

#ifdef NOTNOW
- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context
{
    [self.navigationController popViewControllerAnimated:YES];
    
    // It is necessary to 'tickle' the timeout mechanism, if there has been no touch activity
    [[AppDelegate sharedDelegate].timeoutUIApplication resetIdleTimer];
}
#endif
- (void) drawCurtain
{
    //BOOL hidden = [[UIApplication sharedApplication] isStatusBarHidden];
    // DLog(@"%d", hidden);
    // Do any additional setup after loading the view.
    // popup the 'home' view on the top (other things should be cranking in the background
    CGRect frame = [UIScreen mainScreen].bounds;
    self.curtain = [[MobiusoTimedCurtain alloc] initWithFrame: frame delegate: self];
    
    [[self view] addSubview: self.curtain];
    // Temporary
    _progressTimer = [NSTimer timerWithTimeInterval: 0.2 target:self selector:@selector(fakeProgress) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer: _progressTimer forMode:NSRunLoopCommonModes];
    self.curtainProgressValue1 = 0;
    self.curtainProgressValue2 = 5;
    self.curtainActive = NO;
    
}


- (void) fakeProgress
{
    if (self.curtainActive) {
        if (self.curtainProgressValue1 <= 100) [self.curtain showProgress:self.curtainProgressValue1 item:0];
        // if (self.foo2 <= 100) [self.curtain showProgress:self.foo2 item:1];
        self.curtainProgressValue1 += 10; self.curtainProgressValue2 += 12;
        if ((self.curtainProgressValue1 <= 100) /* || (self.foo2 <= 100) */) {
            _progressTimer = [NSTimer timerWithTimeInterval: 0.6 target:self selector:@selector(fakeProgress) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer: _progressTimer forMode:NSRunLoopCommonModes];
        } else {
            [self.curtain hideActivity];
        }
    } else {
        _progressTimer = [NSTimer timerWithTimeInterval: 0.6f target:self selector:@selector(fakeProgress) userInfo:nil repeats:NO];
        self.curtainActive = YES;
        [[NSRunLoop mainRunLoop] addTimer: _progressTimer forMode:NSRunLoopCommonModes];
        
    }
}

- (void) performAction
{
    [self saveChanges];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    // When you popup - you want to reach the safe place - there might have been intermediate locked folders that we need to pop
    [[NSNotificationCenter defaultCenter] postNotificationName: ClipboardNodeUpdateNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
    // It is necessary to 'tickle' the timeout mechanism, if there has been no touch activity
    [[AppDelegate sharedDelegate].timeoutUIApplication resetIdleTimer];
    
}

- (void) dismissAction
{
    // Reinstate the searchbar
    [self.view addSubview:_searchBar];
    
    [self.curtain removeFromSuperview];
    self.curtainActive = NO;
    [_progressTimer invalidate];
    // It is necessary to 'tickle' the timeout mechanism, if there has been no touch activity
    [[AppDelegate sharedDelegate].timeoutUIApplication resetIdleTimer];
}


@end
