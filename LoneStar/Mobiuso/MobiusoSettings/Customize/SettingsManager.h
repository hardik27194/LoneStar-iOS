//
//  SettingsManager.h
//  SnapWord
//
//  Created by sandeep on 12/7/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobiusoActionView.h"
//#import "CacheManager.h"

typedef NS_ENUM(NSInteger, SettingActionView) {
    CacheClearActionView = 0,
    XYZActionView
};

#if 0
#ifdef SETTINGSMANAGER_GLOBALS

BOOL                saveOriginalPhoto;
BOOL                saveToCustomAlbum;
NSString            *mysignature;

#else

extern BOOL                 saveOriginalPhoto;
extern BOOL                 saveToCustomAlbum;
extern NSString             *mysignature;

#endif
#endif


@interface SettingsManager : NSObject
{
    SettingActionView   currentActionView;

}

+ (NSString *) mySignature;
+ (void) setMySignature: (NSString *) mySig;
+ (BOOL) saveOriginalPhoto;
+ (BOOL) saveToCustomAlbum;
+ (NSString *) myEmail;
+ (NSString *) myName;
+ (SettingsManager *) instance;
+ (NSMutableArray *) populateItems;

#define kSettingGroupKey                       @"SettingGroupKey"
#define kSettingGroupVersionKey                @"SettingGroupVersionKey"
#define kSettingGroupVersionValue              @"v1.2"

// Beginning of the User Settable Items
#define kSettingGroupUserSettableItems         @"SettingGroupUserSettableItems"

#define kSettingGroupAccountKey                @"SettingAccountGroup"
#define kSettingUserNameKey                    @"SettingUserName"
#define kSettingEmailAddressKey                @"SettingEmailAddress"
#define kSettingPasswordKey                    @"SettingPassword"
#define kSettingMySignatureKey                 @"SettingMySignature"

#define kSettingGroupServerArrayKey            @"SettingServerArrayGroup"

#define kSettingGroupServerKey                 @"SettingServerGroup"
#define kSettingServerNameKey                  @"SettingServerName"
#define kSettingServerAddressKey               @"SettingServerAddress"
#define kSettingServerTypeKey                  @"SettingServerType"

#define kSettingGroupCacheKey                  @"SettingGroupCacheKey"
#define kSettingCacheEnabledKey                @"SettingCacheEnabled"
#define kSettingCacheMaxSizeKey                @"SettingCacheMaxSize"
#define kSettingCacheHelpRefKey                @"SettingCacheHelpRef"

#define kSettingSaveEnabledKey                 @"SettingSaveEnabled"
#define kSettingCustomAlbumKey                 @"SettingCustomAlbum"


#define kSettingGroupAboutKey                  @"SettingGroupAboutKey"
#define kSettingAboutCompanyRefKey             @"SettingAboutCompanyRef"
#define kSettingAboutProductRefKey             @"SettingAboutProduct"
#define kSettingAboutSupportKey                @"SettingGroupAboutSupport"
#define kSettingAboutRateUsKey                 @"SettingGroupAboutRateUs"
#define kSettingAboutInstagramKey              @"SettingGroupAboutInstagram"
#define kSettingAboutFacebookKey               @"SettingGroupAboutFacebook"
#define kSettingAboutFeedbackKey               @"SettingGroupAboutFeedback"

#define kSettingGroupSocialKey                 @"SettingGroupSocialKey"
#define kSettingSocialFacebookKey              @"SettingSocialFacebook"
#define kSettingSocialInstagramKey             @"SettingSocialInstagram"


// End of User Settable Items


// Standalone
#define kWelcomeDefaultHasRunFlowKeyName       @"SettingWelcomeDefaultHasRunFlow"
#define kSettingSoundOnKeyName                 @"SettingSoundOnKeyName"
#define kSettingNavigationLayoutKey            @"SettingNavigationLayout"
#define kSettingPhotoZoomLevelKey              @"SettingPhotoZoomLevelKey"
#define kSettingCurrentServerIndexKey          @"SettingCurrentServerIndexKey"


#ifdef REFERENCE
#define kSettingPlayerName                     @"SettingPlayerName"
#define kSettingClaimCodeForCategory           @"SettingClaimCodeForCategory"
#define kSettingCurrentLevelForCategory        @"currentlevel"
#define kSettingSkippedCountForCategory        @"SettingSkippedCountForCategory"
#define kSettingSkippedLevelListForCategory    @"SettingSkippedLevelListForCategory"

#define kSettingPointsKey                       @"point"
#endif


#define LOCAL_NOTIFICATION_SETTINGS             @"com.mobiuso.Snaptica.SettingsChanged"
#define LOCAL_NOTIFICATION_SERVER_ADDED         @"ServerAdded"


- (void) reset;
- (void) sync;

- (void) setIntVal: (int) val forKey: (NSString *) key;
- (int)  intVal: (NSString *) key;
- (void) setFloatVal: (CGFloat) val forKey: (NSString *) key;
- (CGFloat)  floatVal: (NSString *) key;
- (id) objectForKey: (NSString *) key;
- (void) setValue:(id)value forKey:(NSString *)key;
- (NSDictionary *) currentServerInfo;
- (int) currentServer;
- (void) setCurrentServer: (int) serverIndex;
- (NSMutableArray *) currentServerList;
- (void) actionPressed: (NSMutableDictionary *) dict;
+ (BOOL) downloadBackupFile: (NSURL *) fileUrl;

#ifdef REFERENCE
- (void) setIntVal: (int) val forKey: (NSString *) key inCategory: (NSString *) category;
- (int)  intVal: (NSString *) key inCategory: (NSString *) category;
- (NSMutableDictionary *) category: (NSString *) category;
- (void) setCategoryDictionary: (NSDictionary *) dictionary forCategory: (NSString *) category;
- (void) setValue:(id)value forKey:(NSString *)key  inCategory: (NSString *) category;
- (id) objectForKey: (NSString *) key  inCategory: (NSString *) category;
#endif



@property (nonatomic, retain) NSMutableDictionary   *groupDictionary;
@property (nonatomic, retain) NSMutableDictionary   *groupUserSettableDictionary;
@property (nonatomic, retain) UIViewController      *delegate;

//+ (BOOL) skyscapeShouldBeChecked;
//+ (void) setSkyscapeShouldBeChecked:(BOOL)should;
+ (BOOL) isSoundOn;
+ (void) setSoundOn:(BOOL)should;
//+ (NSUInteger) purchasedCoins;
//+ (void) setPurchasedCoins: (NSUInteger) coins;
+ (void) initSound: (BOOL) initValue;
//+ (NSMutableArray *) populateItems;
//- (void) actionPressed: (NSMutableDictionary *) dict;



// Strings
#define SETTING_MY_ACCOUNT NSLocalizedString(@"MY ACCOUNT", @"MY ACCOUNT")
#define SETTING_NAME NSLocalizedString(@"Name", @"Name")
#define SETTING_EMAIL NSLocalizedString(@"Email", @"Email")
#define SETTING_PASSWORD NSLocalizedString(@"Password", @"Password")
#define SETTING_MY_SIGNATURE NSLocalizedString(@"My Signature", @"")

#define SETTING_MAIN_SERVER NSLocalizedString(@"MAIN SERVER", @"MAIN SERVER")
#define SETTING_PHOTO_SERVER NSLocalizedString(@"PHOTO SERVER", @"PHOTO SERVER")
#define SETTING_SERVER_NAME NSLocalizedString(@"Server Name", @"Server Name")
#define SETTING_SERVER_ADDRESS NSLocalizedString(@"Server Address", @"Server Address")
#define SETTING_SERVER_TYPE NSLocalizedString(@"Server Type", @"Server Type")

#define SETTING_LOCAL_CACHE NSLocalizedString(@"LOCAL CACHE", @"LOCAL CACHE")
#define SETTING_ENABLE_SAVE NSLocalizedString(@"Save Original Photo", @"Save Original Photo")
#define SETTING_CUSTOM_ALBUM NSLocalizedString(@"Save to SNAPTICA PRO Album", @"")
#define SETTING_MORE_INFO NSLocalizedString(@"More Information", @"More Information")

#define SETTING_ABOUT NSLocalizedString(@"ABOUT", @"ABOUT")
#define SETTING_ABOUT_SNAPTICA NSLocalizedString(@"About Snaptica", @"About Snaptica")
#define SETTING_ABOUT_MOBIUSO NSLocalizedString(@"About Team Mobiuso", @"About Team Mobiuso")
#define SETTING_ABOUT_FACEBOOK NSLocalizedString(@"Like Us on Facebook", @"")
#define SETTING_ABOUT_FEEDBACK NSLocalizedString(@"Send feedback", @"")
#define SETTING_ABOUT_RATEUS NSLocalizedString(@"Show Your Love!", @"")

#define SETTING_FEEDBACK_SUBJECT NSLocalizedString(@"Send feedback", @"")
#define SETTING_FEEDBACK_MESSAGE   NSLocalizedString(@"Hey Snaptica Team\n\nHere are my thoughts:\n\n(write your suggestions/feedback or problems here)", @"")

#define SETTING_SOCIAL          NSLocalizedString(@"SOCIAL INSPIRATION", @"")
#define SETTING_SOCIAL_INSTAGRAM NSLocalizedString(@"Samples at Instagram", @"")
#define SETTING_SOCIAL_500PX     NSLocalizedString(@"Inspiration at 500PX", @"")
#define SETTING_SOCIAL_GOOGLE     NSLocalizedString(@"Google Imagination", @"")
#define SETTING_SOCIAL_TELLAFRIEND NSLocalizedString(@"Tell A Friend", @"")

#define SETTING_TELLAFRIEND_SUBJECT NSLocalizedString(@"You will like this", @"")
#define SETTING_TELLAFRIEND_MESSAGE   NSLocalizedString(@"I have been using this app - Snaptica Pro. It allows me to keep track of important events and send personalized cards to my family and friends.<br><br>I think you may love it too! Check it out", @"")

#define NIL_STRING   @""


#define SETTING_LOGIN_BUTTON NSLocalizedString(@"LOGIN", @"LOGIN")
#define SETTING_ADD_SERVER_BUTTON NSLocalizedString(@"NEW", @"NEW")
#define SETTING_DELETE_SERVER_BUTTON NSLocalizedString(@"DELETE", @"DELETE")
#define SETTING_PURGE_CACHE_BUTTON NSLocalizedString(@"CLEAR", @"CLEAR")
#define SETTING_BACKUP_BUTTON NSLocalizedString(@"BACKUP", @"BACKUP")

#define LOCAL_HOST_ADDRESS NSLocalizedString(@"0.0.0.0", @"0.0.0.0")

@end
