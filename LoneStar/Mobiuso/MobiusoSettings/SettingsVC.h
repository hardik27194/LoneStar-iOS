//
//  SettingsVC.h
//  Snaptica Pro
//
//  Created by Sandeep on 5/17/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Configs.h"
#import "HomeVC.h"
#import "MobiusoVideoActionView.h"
#import "SettingsManager.h"


NSInteger rowsNumber;

#ifdef SETTINGS_GLOBALS
#if 0
BOOL                saveOriginalPhoto;
BOOL                saveToCustomAlbum;
NSString            *mysignature;
#endif

BOOL                feedback;
NSMutableArray      *lightboxAssets;
NSUInteger          lastIndex;
NSMutableArray      *customTextStrings;
UIImage             *launchImage;
BOOL                iapMade;

#else

#if 0
extern BOOL                 saveOriginalPhoto;
extern BOOL                 saveToCustomAlbum;
extern NSString             *mysignature;
#endif

extern BOOL                 feedback;
extern NSMutableArray       *lightboxAssets;
extern NSUInteger           lastIndex;
extern NSMutableArray       *customTextStrings;
extern UIImage              *launchImage;
extern BOOL                 iapMade;

#endif


@interface SettingsVC : UITableViewController
<
MFMailComposeViewControllerDelegate,
MobiusoActionViewDelegate
>

// Switches
@property (strong, nonatomic) IBOutlet UISwitch *originalPhotoSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *customAlbumSwitch;


// Labels
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *saveOriginalLabel;
@property (strong, nonatomic) IBOutlet UILabel *saveToCustomAlbumLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateUsLabel;
@property (strong, nonatomic) IBOutlet UILabel *tellAfriendLabel;
@property (strong, nonatomic) IBOutlet UILabel *sendFeedbackLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutLabel;
@property (strong, nonatomic) IBOutlet UILabel *likeUsonFBLabel;
@property (strong, nonatomic) IBOutlet UILabel *mySignatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *visitUsOnInstagramLabel;


+ (void) incrementLastIndex;
+ (void) syncLightboxAssets;
+ (void) insertCustomString: (NSString *) newString;
+ (void) deleteCustomString: (NSString *) deleteString;
+ (BOOL) isCustomString: (NSString *) givenString;
+ (UIImage *) myLaunchImage;




@end
