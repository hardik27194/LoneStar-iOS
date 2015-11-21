//
//  SettingsManager.m
//  Snaptica
//
//  Created by sandeep on 12/7/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#define SETTINGSMANAGER_GLOBALS

#import "SettingsManager.h"
#import "Constants.h"
#import "SettingsItemModel.h"
#import "Utilities.h"
#import "Strings.h"
#import "AppDelegate.h"
#import "Configs.h"

#import "MobiusoToast.h"

@import MessageUI;

@interface SettingsManager () <MFMailComposeViewControllerDelegate>

@end


@implementation SettingsManager

//static NSMutableDictionary *settingsDictionary = nil;
static SettingsManager *settings;
//static NSString *settingsPath;


// If you change the settings during development, just define the OVERWRITE below
#undef OVERWRITE


+ (instancetype) instance
{
    return settings;
}

+ (void) load
{
    [super load];
//    @synchronized(self)
    {
        if (settings == nil) {
            settings = [[SettingsManager alloc] init];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; //2
            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"SettingsList.plist"];
            
//            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *bundle;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            settings.groupDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:kSettingGroupKey]];
            
            if (settings.groupDictionary == nil) {
                
                if ((bundle = [[NSBundle mainBundle] pathForResource:@"SettingsList"ofType:@"plist"]) != nil) {
                    // load it from the internal bundle once
                    settings.groupDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
                }
            }
            
            settings.groupUserSettableDictionary = [settings.groupDictionary objectForKey:kSettingGroupUserSettableItems];
            
#ifndef OVERWRITE
            if ((settings.groupUserSettableDictionary == nil) || ([settings.groupUserSettableDictionary count] == 0))
#endif
            {
                settings.groupUserSettableDictionary = [self populateGroupDictionary];
                [settings.groupDictionary setObject:settings.groupUserSettableDictionary forKey:kSettingGroupUserSettableItems];
                [defaults setObject:settings.groupDictionary forKey:kSettingGroupKey];
            }
            
            //
            if (settings.groupDictionary == nil) {
                settings.groupDictionary = [[NSMutableDictionary alloc] init];
                [settings.groupDictionary setObject: kSettingGroupVersionValue forKey: kSettingGroupVersionKey];
            } else {
                // Check if the versions are ok - else upgrade the version
                NSString *verStr = [settings.groupDictionary objectForKey:kSettingGroupVersionKey];
                if (verStr == nil) {
                    // put our version
                    [settings.groupDictionary setObject: kSettingGroupVersionValue forKey: kSettingGroupVersionKey];
                    [defaults setObject:settings.groupDictionary forKey:kSettingGroupKey];
                } else if ([verStr compare: kSettingGroupVersionValue] != 0) {
                    // Now what - need to upgrade to the next version...
                    
                    // For now just clear -
                    
                    // clean object
                    settings.groupDictionary = [[NSMutableDictionary alloc] init];
                    // new version
                    [settings.groupDictionary setObject: kSettingGroupVersionValue forKey: kSettingGroupVersionKey];
                    [defaults setObject:settings.groupDictionary forKey:kSettingGroupKey];
                }
            }
            
#if 0
            saveOriginalPhoto = [settings boolVal:@"saveOriginalPhoto"];
            saveToCustomAlbum = [settings boolVal:@"saveToCustomAlbum"];
            mysignature = [settings objectForKey:@"mysignature"];
#endif
            

        }
    }
    
//    return settings;
    
}

// Keys with the User Info exported
#define keyUserEmailId      @"userEmail"
#define keyUserCustomerId   @"userId"


- (void) setCurrentUser: (NSDictionary *) userInfo
{
    NSDictionary *savedUserInfo = [self currentUser];
    NSString *userId = [savedUserInfo objectForKey:keyUserEmailId];
    NSString *newUserId = [userInfo objectForKey:keyUserEmailId];
    // If it is changed then do the following
    if ((userId==nil) || !IS_EQUAL(userId, newUserId)) {
        [_groupDictionary setObject:userInfo forKey: kSettingCurrentUserIndexKey];
        [self sync];
        [[NSNotificationCenter defaultCenter] postNotificationName: LOCAL_NOTIFICATION_SETTINGS object:nil];
        
    }
}

- (NSDictionary *) currentUser
{
    return [_groupDictionary objectForKey: kSettingCurrentUserIndexKey];
}


+ (id) objectForKey: (NSString *) key inGroup: (NSString *) groupKey
{
    // The key is spread out in number of groups - will need to search
    NSDictionary *groupDict = [settings.groupUserSettableDictionary objectForKey:groupKey];
    
    NSArray *children = [groupDict objectForKey:@"children"];
    
    for (NSDictionary *item in children) {
        if (IS_EQUAL(key, [item objectForKey:@"key"])) {
            return [item objectForKey:@"value"];
        }
    }
    return nil;
    
}

+ (void) setObject: (id) object forKey: (NSString *) key  inGroup: (NSString *) groupKey
{
    // The key is spread out in number of groups - will need to search
    NSDictionary *groupDict = [settings.groupUserSettableDictionary objectForKey:groupKey];
    
    NSArray *children = [groupDict objectForKey:@"children"];
    
    for (NSMutableDictionary *item in children) {
        if (IS_EQUAL(key, [item objectForKey:@"key"])) {
            [item setObject: object forKey:@"value"];
        }
    }
    
}

+ (NSString *) myEmail
{
    return [self objectForKey:kSettingEmailAddressKey inGroup: kSettingGroupAccountKey];
}

+ (NSString *) myName
{
    return [self objectForKey:kSettingUserNameKey inGroup: kSettingGroupAccountKey];
}

+ (NSString *) mySignature
{
    return [self objectForKey:kSettingMySignatureKey inGroup: kSettingGroupAccountKey];
}

+ (BOOL) saveOriginalPhoto
{
    return [[self objectForKey: kSettingSaveEnabledKey  inGroup: kSettingGroupCacheKey] boolValue];
}

+ (BOOL) saveToCustomAlbum
{
    return [[self objectForKey:kSettingCustomAlbumKey  inGroup: kSettingGroupCacheKey] boolValue];
}

+ (void) setMySignature: (NSString *) mysig
{
    [self setObject:mysig forKey: kSettingMySignatureKey  inGroup: kSettingGroupAccountKey];
}

#ifdef REFERENCE
+ (BOOL) skyscapeShouldBeChecked {
    //You should run if not yet run
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kSkyscapeCheckedKeyName];
}

+ (void) setSkyscapeShouldBeChecked:(BOOL)should {
    //ShouldRun is opposite of hasRun
    [[NSUserDefaults standardUserDefaults] setBool:!should forKey:kSkyscapeCheckedKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSUInteger) purchasedCoins
{
    //Has there been a purchase ever
    return [[NSUserDefaults standardUserDefaults] integerForKey:kPurchasedCoins];
    
}

+ (void) setPurchasedCoins: (NSUInteger) coins
{
    // Set user's purchases of coins (accumulated for multiple)
    [[NSUserDefaults standardUserDefaults] setInteger:coins forKey:kPurchasedCoins];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
#endif

+ (NSMutableDictionary *) populateGroupDictionary
{
#if 1
    // Accounts first
    
    // First create the subitems
    NSDictionary *accountName = @{
                                  @"title": SETTING_NAME,
                                  @"icon": @"menu-users-72.png",
                                  @"placeholder": @"Your Name",
                                  @"type" : [NSNumber numberWithInteger:SettingsItemStyleName],
                                  @"key": kSettingUserNameKey,
                                  };

    NSDictionary *accountEmail = @{
                                  @"title": SETTING_EMAIL,
                                  @"icon": @"menu-users-72.png",
                                  @"placeholder": @"Any Valid Email",
                                  @"type" : [NSNumber numberWithInteger:SettingsItemStyleEmail],
                                  @"key": kSettingEmailAddressKey,
                                  };

   __unused NSDictionary *accountPassword = @{
                                  @"title": SETTING_PASSWORD,
                                  @"icon": @"menu-users-72.png",
                                  @"placeholder": @"Set Password",
                                  @"type" : [NSNumber numberWithInteger:SettingsItemStylePassword],
                                  @"key": kSettingPasswordKey,
                                  };
    
    NSDictionary *accountSignature = @{
                                       @"title": SETTING_MY_SIGNATURE,
                                       @"icon": @"menu-users-72.png",
                                       @"placeholder": @"Set Password",
                                       @"type" : [NSNumber numberWithInteger:SettingsItemStyleName],
                                       @"key": kSettingMySignatureKey,
                                       };
    
   NSMutableDictionary *accountDict = [NSMutableDictionary dictionaryWithDictionary: @{
                    @"title": SETTING_MY_ACCOUNT,
                    @"icon": @"menu-users-72.png",
                    @"type" : [NSNumber numberWithInteger:SettingsItemStyleHeader],
                    @"children" : @[accountName, accountEmail /*, accountPassword */, accountSignature],
                    @"key": kSettingGroupAccountKey,
                    @"actionTitle": SETTING_BACKUP_BUTTON
                    }];
    
#ifdef INCLUDE_SERVERS
    // Default Server
    NSDictionary *serverName = @{
                                    @"title": SETTING_SERVER_NAME,
                                    @"icon": @"menu-cloudsettings-72.png",
                                    @"placeholder": @"Name of this server",
                                    @"type" : [NSNumber numberWithInteger:SettingsItemStyleText],
                                    @"key": kSettingServerNameKey,
                                    };

    NSDictionary *serverAddress = @{    // IP Address or network syntax
                                   @"title": SETTING_SERVER_ADDRESS,
                                   @"icon": @"menu-cloudsettings-72.png",
                                   @"placeholder": @"Server",
                                   @"type" : [NSNumber numberWithInteger:SettingsItemStyleText],
                                   @"key": kSettingServerAddressKey,
                                   };
    
    NSDictionary *serverType = @{
                                      @"title": SETTING_SERVER_TYPE,
                                      @"icon": @"menu-cloudsettings-72.png",
                                      @"placeholder": @"LAMP/Google/AWS",
                                      @"type" : [NSNumber numberWithInteger:SettingsItemStyleText],
                                      @"key": kSettingServerTypeKey,
                                      };

    NSMutableDictionary *serverDict = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                                        @"title": SETTING_MAIN_SERVER,
                                                                                        @"icon": @"menu-cloudsettings-72.png",
                                                                                        @"type" : [NSNumber numberWithInteger:SettingsItemStyleHeader],
                                                                                        @"children" : @[serverName, serverAddress, serverType],
                                                                                        @"key": kSettingGroupServerKey,
//                                                                                        @"actionTitle": SETTING_ADD_SERVER_BUTTON
                                                                                        }];
    
    // Servers array
    NSMutableArray *serverListArray = [NSMutableArray arrayWithArray:@[serverDict]];    // single entry for now
#endif
    
    // Cache
    // Default Server
    NSDictionary *savingEnable = @{
                                    @"title": SETTING_ENABLE_SAVE,
                                    @"icon": @"menu-cache2-72.png",
                                    @"type" : [NSNumber numberWithInteger:SettingsItemStyleBOOL],
                                    @"key": kSettingSaveEnabledKey,
                                    };
    
    NSDictionary *customAlbum = @{
                                 @"title": SETTING_CUSTOM_ALBUM,
                                 @"icon": @"menu-cache2-72.png",
                                 @"placeholder": @"256",
                                 @"type" : [NSNumber numberWithInteger:SettingsItemStyleBOOL],
                                 @"key": kSettingCustomAlbumKey,
                                 };

    __unused NSDictionary *cacheInfo = @{
                                   @"title": SETTING_MORE_INFO,
                                   @"icon": @"menu-cache2-72.png",
                                   @"placeholder": @"SnapticaWelcome-Resources/test.pdf",
                                   @"type" : [NSNumber numberWithInteger:SettingsItemStyleBundleFileRef],
                                   @"key": kSettingCacheHelpRefKey,
                                   };

    NSMutableDictionary *cacheDict = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                                       @"title": @"SAVING PHOTOS",
                                                                                       @"icon": @"menu-cache2-72.png",
                                                                                       @"type" : [NSNumber numberWithInteger:SettingsItemStyleHeader],
                                                                                       @"children" : @[savingEnable, customAlbum
#ifdef INCLUDE_SERVERS

                                                                                                       , cacheInfo
#endif
                                                                                                       ],
                                                                                       @"key": kSettingGroupCacheKey,
//                                                                                       @"actionTitle": SETTING_PURGE_CACHE_BUTTON
                                                                                       }];

    NSDictionary *aboutProduct = @{
                                   @"title": SETTING_ABOUT_SNAPTICA,
                                   @"icon": @"menu-about-72.png",
                                   @"placeholder": @"SplashTransitionViewController.xib:SplashTransitionViewController",
                                   @"type" : [NSNumber numberWithInteger:SettingsItemStyleBundleFileRef],
                                   @"key": kSettingAboutProductRefKey,
                                   };
    
    NSDictionary *aboutUs = @{
                                @"title": SETTING_ABOUT_MOBIUSO,
                                @"icon": @"menu-about-72.png",
                                @"placeholder": @"http://www.mobiuso.com",
                                @"type" : [NSNumber numberWithInteger:SettingsItemStyleWebRef],
                                @"key": kSettingAboutCompanyRefKey,
                                };

    NSString *placeholder = [NSString stringWithFormat:@"mailto://%@#SLASH#%@#SLASH#%@", SETTING_FEEDBACK_SUBJECT, SETTING_FEEDBACK_MESSAGE, FEEDBACK_EMAIL_ADDRESS];
    NSDictionary *aboutSupport = @{
                              @"title": SETTING_ABOUT_FEEDBACK,
                              @"icon": @"menu-about-72.png",
                              @"placeholder": placeholder,
                              @"type" : [NSNumber numberWithInteger:SettingsItemStyleWebRef],
                              @"key": kSettingAboutFeedbackKey,
                              };

    NSDictionary *aboutFacebook = @{
                                   @"title": SETTING_ABOUT_FACEBOOK,
                                   @"icon": @"menu-about-72.png",
                                   @"placeholder": FACEBOOK_PAGE_LINK,
                                   @"type" : [NSNumber numberWithInteger:SettingsItemStyleWebRef],
                                   @"key": kSettingAboutFacebookKey,
                                   };

    NSDictionary *aboutRateUs = @{
                                   @"title": SETTING_ABOUT_RATEUS,
                                   @"icon": @"menu-about-72.png",
                                   @"placeholder": RATE_US_LINK,
                                   @"type" : [NSNumber numberWithInteger:SettingsItemStyleWebExternalRef],
                                   @"key": kSettingAboutRateUsKey,
                                   };

    NSMutableDictionary *aboutDict = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                                      @"title": SETTING_ABOUT,
                                                                                      @"icon": @"menu-about-72.png",
                                                                                      @"type" : [NSNumber numberWithInteger:SettingsItemStyleHeader],
                                                                                      @"children" : @[aboutProduct, aboutSupport,
                                                                                                      aboutRateUs, aboutFacebook, aboutUs],
                                                                                      @"key": kSettingGroupAboutKey,
                                                                                      }];


    placeholder = [NSString stringWithFormat:@"mailto://%@#SLASH#%@: %@", SETTING_TELLAFRIEND_SUBJECT, SETTING_TELLAFRIEND_MESSAGE, ITUNES_STORE_LINK];
    NSDictionary *socialTellAFriend = @{
                                      @"title": SETTING_SOCIAL_TELLAFRIEND,
                                      @"icon": @"menu-social-72.png",
                                      @"placeholder": placeholder,
                                      @"type" : [NSNumber numberWithInteger:SettingsItemStyleWebRef],
                                      @"key": kSettingAboutFacebookKey,
                                      };
    
    NSDictionary *socialInstagram = @{
                                    @"title": SETTING_SOCIAL_INSTAGRAM,
                                    @"icon": @"menu-social-72.png",
                                    @"placeholder": INSTAGRAM_URL,
                                    @"type" : [NSNumber numberWithInteger:SettingsItemStyleWebRef],
                                    @"key": kSettingAboutFacebookKey,
                                    };

    NSDictionary *socialGoogleImages = @{
                                  @"title": SETTING_SOCIAL_GOOGLE,
                                  @"icon": @"menu-social-72.png",
                                  @"placeholder": GOOGLEIMAGES_URL,
                                  @"type" : [NSNumber numberWithInteger:SettingsItemStyleWebRef],
                                  @"key": kSettingAboutFacebookKey,
                                  };
    
    NSDictionary *social500Px = @{
                                      @"title": SETTING_SOCIAL_500PX,
                                      @"icon": @"menu-social-72.png",
                                      @"placeholder": WWW500PX_URL,
                                      @"type" : [NSNumber numberWithInteger:SettingsItemStyleWebRef],
                                      @"key": kSettingAboutFacebookKey,
                                      };

    NSMutableDictionary *socialDict = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                                      @"title": SETTING_SOCIAL,
                                                                                      @"icon": @"menu-social-72.png",
                                                                                      @"type" : [NSNumber numberWithInteger:SettingsItemStyleHeader],
                                                                                      @"children" : @[socialTellAFriend, socialInstagram, social500Px, socialGoogleImages],
                                                                                      @"key": kSettingGroupSocialKey,
                                                                                      }];


    NSMutableDictionary *groupDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                                    accountDict, kSettingGroupAccountKey,
#ifdef INCLUDE_SERVERS

                                                                    serverListArray, kSettingGroupServerArrayKey,
#endif
                                            
                                                                    cacheDict, kSettingGroupCacheKey,
                                                                    socialDict, kSettingGroupSocialKey,
                                                                    aboutDict, kSettingGroupAboutKey,
                                            nil];
    return groupDictionary;
#else
    return [[NSMutableDictionary alloc] init];
#endif
}

// Flatten and create references for SettingsItemModel
+ (NSMutableArray *) populateItems
{

    NSMutableDictionary *dict = [self makeMutable: settings.groupUserSettableDictionary];
    NSMutableArray *itemsArray;
    if (dict) {
        itemsArray = [[NSMutableArray alloc] init];
        // Get the known keys and then iterate
        NSMutableDictionary *accountDict = [dict objectForKey: kSettingGroupAccountKey];
        if (accountDict) {
            SettingsItemModel *accountHeaderItem = [[SettingsItemModel alloc] initWithDictionary:accountDict];
            [itemsArray addObject:accountHeaderItem];
        }
        NSMutableArray *serversArray = [dict objectForKey: kSettingGroupServerArrayKey];
        for (NSDictionary *serverDict in serversArray) {
            SettingsItemModel *serverHeaderItem = [[SettingsItemModel alloc] initWithDictionary:serverDict];
            [itemsArray addObject:serverHeaderItem];
        }
        NSMutableDictionary *cacheDict = [dict objectForKey: kSettingGroupCacheKey];
        if (cacheDict) {
            SettingsItemModel *cacheHeaderItem = [[SettingsItemModel alloc] initWithDictionary:cacheDict];
            [itemsArray addObject:cacheHeaderItem];
        }
        NSMutableDictionary *socialDict = [dict objectForKey: kSettingGroupSocialKey];
        if (socialDict) {
            SettingsItemModel *socialHeaderItem = [[SettingsItemModel alloc] initWithDictionary:socialDict];
            [itemsArray addObject:socialHeaderItem];
        }
        NSMutableDictionary *aboutDict = [dict objectForKey: kSettingGroupAboutKey];
        if (aboutDict) {
            SettingsItemModel *aboutHeaderItem = [[SettingsItemModel alloc] initWithDictionary:aboutDict];
            [itemsArray addObject:aboutHeaderItem];
        }
    }
    // Update the entry
    settings.groupUserSettableDictionary = dict;
    [settings.groupDictionary setObject:settings.groupUserSettableDictionary forKey:kSettingGroupUserSettableItems];
    return itemsArray;
    
}


#if 0

+ (void) addServer
{
    settings.groupUserSettableDictionary = [self makeMutable: settings.groupUserSettableDictionary];
    NSMutableDictionary *dict = settings.groupUserSettableDictionary;
    if (dict) {
        NSMutableArray *serversArray = [dict objectForKey: kSettingGroupServerArrayKey];
        NSMutableDictionary *newServer = [(NSDictionary *) serversArray[0] mutableCopy];
        // There are 3 variables (children) for each server - let's prime them with some values
        NSArray *arr = [newServer objectForKey:@"children"];
        [newServer setObject:[NSString stringWithFormat:@"PHOTO SERVER %d", (int)[serversArray count]] forKey:@"title"];
        [newServer setObject: SETTING_DELETE_SERVER_BUTTON forKey:@"actionTitle"];  // we need only 1 button to be added - not on subsequent servers
        NSMutableArray *newarr = [[NSMutableArray alloc] init];
        if (arr != nil) {
            // Change each value...
            for (NSDictionary *dict in arr) {
                NSMutableDictionary *newdict = [dict mutableCopy];
                [newdict removeObjectForKey:@"value"];
                [newarr addObject:newdict];
            }
            [newServer setObject:newarr forKey:@"children"];
        }
        [serversArray addObject:newServer];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: LOCAL_NOTIFICATION_SERVER_ADDED object:nil];


}

+ (void) deleteServer: (NSDictionary *) dictionary
{
    settings.groupUserSettableDictionary = [self makeMutable: settings.groupUserSettableDictionary];
    NSMutableDictionary *dict = settings.groupUserSettableDictionary;
    if (dict) {
        NSMutableArray *serversArray = [dict objectForKey: kSettingGroupServerArrayKey];
        int found = -1;
        for (int i=0; i < [serversArray count]; i++) {
            if (dictionary == (NSDictionary *) [serversArray objectAtIndex:i]) {
                found = i;
                break;
            }
        }
        
        if (found >= 0) {
            // Remove this entry
            [serversArray removeObjectAtIndex:found];
            
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: LOCAL_NOTIFICATION_SERVER_ADDED object:nil];
    
}
#endif

+ (NSMutableDictionary *) makeMutable: (NSDictionary *) settingsDictionary
{
    NSMutableDictionary *dict = [settingsDictionary mutableCopy];

    if (dict) {
        // Get the known keys and then iterate
        NSMutableDictionary *accountDict = [[dict objectForKey: kSettingGroupAccountKey] mutableCopy];
        if (accountDict) {
            NSMutableArray *newChildrenArray = [[NSMutableArray alloc] init];
            NSArray *childrenArray = [accountDict objectForKey:@"children"];
            // For each child entry, we need to do the same
            for (NSDictionary *child in childrenArray) {
                [newChildrenArray addObject:[child mutableCopy] ];
            }
            [accountDict setObject:newChildrenArray forKey:@"children"];
            [dict setObject:accountDict forKey:kSettingGroupAccountKey];
            

        }
        NSMutableArray *serversArray = [dict objectForKey: kSettingGroupServerArrayKey];
        NSMutableArray *newServersArray = [[NSMutableArray alloc] init];
        for (NSDictionary *serverDict in serversArray) {
            NSMutableDictionary *newDict = [serverDict mutableCopy];
            NSMutableArray *newChildrenArray = [[NSMutableArray alloc] init];
            NSArray *childrenArray = [newDict objectForKey:@"children"];
            // For each child entry, we need to do the same
            for (NSDictionary *child in childrenArray) {
                [newChildrenArray addObject:[child mutableCopy] ];
            }
            [newDict setObject:newChildrenArray forKey:@"children"];
            [newServersArray addObject:newDict];
        }
        [dict setObject:newServersArray forKey:kSettingGroupServerArrayKey];
        NSMutableDictionary *cacheDict = [[dict objectForKey: kSettingGroupCacheKey] mutableCopy];
        if (cacheDict) {
            NSMutableArray *newChildrenArray = [[NSMutableArray alloc] init];
            NSArray *childrenArray = [cacheDict objectForKey:@"children"];
            // For each child entry, we need to do the same
            for (NSDictionary *child in childrenArray) {
                [newChildrenArray addObject:[child mutableCopy] ];
            }
            [cacheDict setObject:newChildrenArray forKey:@"children"];
            [dict setObject:cacheDict forKey:kSettingGroupCacheKey];
        }
        NSMutableDictionary *aboutDict = [[dict objectForKey: kSettingGroupAboutKey] mutableCopy];
        if (aboutDict) {
            NSMutableArray *newChildrenArray = [[NSMutableArray alloc] init];
            NSArray *childrenArray = [aboutDict objectForKey:@"children"];
            // For each child entry, we need to do the same
            for (NSDictionary *child in childrenArray) {
                [newChildrenArray addObject:[child mutableCopy] ];
            }
            [aboutDict setObject:newChildrenArray forKey:@"children"];
            [dict setObject:aboutDict forKey:kSettingGroupAboutKey];
        }
    }

    return dict;
    
}

- (NSDictionary *) mapServerDictionary: (NSDictionary *) serverDict
{
    NSDictionary *dict;
    NSArray *arr = [serverDict objectForKey:@"children"];
    NSDictionary *name = arr[0]; //
    NSString *hostName = [name objectForKey:@"value"];
    if (hostName == nil) {
        hostName = kServerName;
    }
    NSDictionary *addr = arr[1]; //
    NSString *hostAddr = [addr objectForKey:@"value"];
    if (hostAddr == nil) {
        hostAddr = kServer;
    }
    NSDictionary *type = arr[2]; // [arr[1] objectForKey:@"value"];
    NSString *hostType = [type objectForKey:@"value"];
    if (hostType == nil) {
        hostType = kServerType;
    }
    dict = @{
             @"serverName"    : hostName,
             @"serverAddress" : hostAddr,
             @"serverType"    : hostType
             };
    return dict;
}

- (void) setCurrentServer: (int) serverIndex
{
    int currentServer = [self intVal:kSettingCurrentServerIndexKey];
    // If it is changed then do the following
    if (serverIndex != currentServer) {
        [self setIntVal:serverIndex forKey:kSettingCurrentServerIndexKey];
        [[NSNotificationCenter defaultCenter] postNotificationName: LOCAL_NOTIFICATION_SETTINGS object:nil];
    }

}


+ (void) initSound: (BOOL) initValue
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSettingSoundOnKeyName] == nil) {
        [SettingsManager setSoundOn:initValue];
    }
}

+ (BOOL) isSoundOn {
    //Is the sound set
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSettingSoundOnKeyName];
}

+ (void) setSoundOn:(BOOL)should {
    // Set user's preference for the sound
    [[NSUserDefaults standardUserDefaults] setBool:should forKey:kSettingSoundOnKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Server Information
- (int) currentServer
{
    return [self intVal:kSettingCurrentServerIndexKey];
}

- (NSDictionary *) currentServerInfo
{
    
    int serverIndex =  [self intVal: kSettingCurrentServerIndexKey];
    NSDictionary *dict;
    if (serverIndex < 0) {
        NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
        [newdict setObject:[NSString stringWithFormat: @"MY %@", IS_IPAD?@"iPAD":@"iPHONE"] forKey:@"serverName"];
        [newdict setObject:LOCAL_HOST_ADDRESS forKey:@"serverAddress"];
        [newdict setObject:@"Photo Roll" forKey:@"serverType"];
        dict = (NSDictionary *) newdict;
    } else {
        NSMutableArray *serversArray = [settings.groupUserSettableDictionary objectForKey: kSettingGroupServerArrayKey];
        if (serverIndex < [serversArray count]) {
            NSDictionary *serverDict = [serversArray objectAtIndex:serverIndex];
            dict = [self mapServerDictionary:serverDict];
            
        }
    }
    return  dict;
}


- (NSMutableArray *) currentServerList
{
    NSMutableArray *serversArray = [settings.groupUserSettableDictionary objectForKey: kSettingGroupServerArrayKey];
    NSMutableArray *serverList = [[NSMutableArray alloc] init];
    for (NSDictionary *serverDict in serversArray) {
        [serverList addObject: [self mapServerDictionary:serverDict]];
    }
    return serverList;
}



- (void) reset
{
#ifdef REFERENCE
    [settingsDictionary setObject:[NSNumber numberWithInteger:(INITIAL_POINTS+[Settings purchasedCoins])] forKey:kSettingPointsKey];
    NSDictionary *currentCategoryList = [NSDictionary dictionaryWithDictionary:_categoryList];
    // We are going to change the categoryList
    for (NSString *cat in currentCategoryList) {
        [self setIntVal:0 forKey:kSettingCurrentLevelForCategory inCategory:cat];
    }
#endif
    // [settingsDictionary setObject:[NSNumber numberWithInt:0] forKey:@"currentlevel"];
    [self sync];
}

- (void) sync
{
//    [settingsDictionary writeToFile: settingsPath atomically:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    [defaults setObject:_groupDictionary   forKey:kSettingGroupKey];
    BOOL synchronized = [defaults synchronize];
    if (!synchronized) {
        DLog(@"Error saving Caching List to Defaults");
    }
    
}

- (void) setIntVal: (int) val forKey: (NSString *) key
{
    [_groupDictionary setObject:[NSNumber numberWithInt: val] forKey: key];
    [self sync];
}

- (int) intVal: (NSString *) key
{
    id number = [_groupDictionary objectForKey: key];
    return (number!=nil) ? [(NSNumber *) number intValue] : -1;

}


- (void) setFloatVal: (CGFloat) val forKey: (NSString *) key
{
    [_groupDictionary setObject:[NSNumber numberWithFloat: val] forKey: key];
    [self sync];
}

- (CGFloat) floatVal: (NSString *) key
{
    return [[_groupDictionary objectForKey: key] floatValue];
    
}


- (void) setBoolVal: (BOOL) val forKey: (NSString *) key
{
    [_groupDictionary setObject:[NSNumber numberWithBool: val] forKey: key];
    [self sync];
}

- (BOOL) boolVal: (NSString *) key
{
    return [[_groupDictionary objectForKey: key] boolValue];
    
}

- (void) setValue:(id)value forKey:(NSString *)key
{
    [_groupDictionary setObject:value forKey:key];
    [self sync];
}

- (id) objectForKey: (NSString *) key
{
    return [_groupDictionary objectForKey: key];
    
}



#ifdef REFERENCE
// Always returns an instance of a category (creates an empty one if it does not have 1
- (NSMutableDictionary *) category: (NSString *) category
{
    return [self.categoryList objectForKey: category];
}

- (void) setCategoryDictionary: (NSDictionary *) dictionary forCategory: (NSString *) category
{
    [settings.categoryList setObject: dictionary forKey: category];
    [self sync];
}

- (void) setIntVal: (int) val forKey: (NSString *) key inCategory: (NSString *) category
{
    NSMutableDictionary *singleCategoryDict = [NSMutableDictionary dictionaryWithDictionary: [self category:category]];
    [singleCategoryDict setObject:[NSNumber numberWithInt: val] forKey: key];
    [self.categoryList setObject: singleCategoryDict forKey: category];
}

- (int) intVal: (NSString *) key inCategory: (NSString *) category
{
    NSMutableDictionary *singleCategoryDict = [self.categoryList objectForKey: category];
    if ([singleCategoryDict objectForKey: key] == nil) return -1;
    return [[singleCategoryDict objectForKey: key] intValue];
    
}

- (void) setValue:(id)value forKey:(NSString *)key  inCategory: (NSString *) category
{
    NSMutableDictionary *singleCategoryDict = [NSMutableDictionary dictionaryWithDictionary: [self category:category]];
    [singleCategoryDict setObject:value forKey: key];
    [self.categoryList setObject: singleCategoryDict forKey: category];
}

- (id) objectForKey: (NSString *) key  inCategory: (NSString *) category
{
    NSMutableDictionary *singleCategoryDict = [self.categoryList objectForKey: category];
    return [singleCategoryDict objectForKey: key];
    
}
#endif

#pragma mark - Actions to be performed on the Headers (like Login, Clear Cache, etc)
#pragma mark - Action Classes
- (void) actionPressed: (NSMutableDictionary *) dict
{
    NSString *dictTitle = [dict objectForKey:@"title"];
    if (IS_EQUAL(dictTitle, SETTING_MY_ACCOUNT)) {
        // Try to Backup
        DLog(@"Backup Important Items: %@", dict);
        [self backupAction];
        
        
    } else if (IS_EQUAL(dictTitle, SETTING_MAIN_SERVER)) {
        // Photo Server Add
        DLog(@"Add New Server: %@", dict);
//        [SettingsManager addServer];
        
        
    } else if (IS_EQUAL(dictTitle, SETTING_LOCAL_CACHE)) {
        // Photo Server Add
        DLog(@"Purge Cache: %@", dict);
//        [self menuClearCacheAction];
        
        
    } else if (IS_EQUAL(dictTitle, SETTING_DELETE_SERVER_BUTTON)) {
        NSString *actionTitle = [dict objectForKey:@"actionTitle"];
        if (IS_EQUAL(actionTitle, SETTING_DELETE_SERVER_BUTTON)) {
//            [SettingsManager deleteServer:dict];
        }
        
        
    } else if (IS_EQUAL(dictTitle, SETTING_DELETE_SERVER_BUTTON)) {
        NSString *actionTitle = [dict objectForKey:@"actionTitle"];
        if (IS_EQUAL(actionTitle, SETTING_DELETE_SERVER_BUTTON)) {
            //            [SettingsManager deleteServer:dict];
        }
        
        
    } else {
        // Just Beep
        // This should not really reach here
    }
    
    
}

- (void) backupAction
{
#if 0
    NSString *archivePath = [CacheManager backupArchive];

    // It will be sent to the person whose address we may know...
    if (archivePath) {
        NSString *toaddr = [SettingsManager myEmail];
        NSString *myname = [SettingsManager myName];
        NSString *mysig = [SettingsManager mySignature];
        
        [self sendMailWithTitle:@"Backup"
                     andMessage: [NSString stringWithFormat: @"Backup from SnapticaPro%@%@\n\n%@", myname?@" for ":@"",  myname?myname:@"", mysig?mysig:@""]
                     attachment: archivePath toAddress:(!toaddr?@"toaddress":toaddr)];
    }
#endif

}

- (void)sendMailWithTitle:(NSString *)title andMessage: (NSString *)message attachment: (NSString *) fileName toAddress: (NSString *) toAddress
{
    
    UIViewController *controller = [[AppDelegate sharedDelegate] topController];

    // Allocs the Mail composer controller
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if (mc) {
        mc.mailComposeDelegate = self;
        [mc setSubject:title];
        [mc setMessageBody:message isHTML:true];
        if (toAddress) {
            NSArray *feedbackEmail = @[toAddress];
            [mc setToRecipients:feedbackEmail];
        }
        
        // Prepare the file to be shared by Email
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:fileName];
        NSString *mimeType = @"application/snapx";
        [mc addAttachmentData:fileData  mimeType:mimeType fileName: @"backup.snapx"];
        
        [controller presentViewController:mc animated:true completion:nil];
    } else {
        
        // Show an alert as sharing result when the Document Interaction Controller gets dismissed
        [MobiusoToast toast:NSLocalizedString(@"Please configure your Email app!", @"") inView: controller.view];
    }
}


// Email delegates ================
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)results error:(NSError *)error {
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
    [controller dismissViewControllerAnimated:true completion: ^{
        if (message) {
            UIViewController *controller = [[AppDelegate sharedDelegate] topController];
            [MobiusoToast toast:message inView:controller.view];
        }
        
    }];
    
}

// Sort of Restore action when someone tries to download the tags files
+ (BOOL) downloadBackupFile: (NSURL *) fileUrl
{
#if 0
    if ([fileUrl isFileURL]) {
        // We can hand it off to the CacheManager to handle the file and restore tags (they need to be merged to be on the safe side...
        
        BOOL restored = [CacheManager restoreArchive:[fileUrl path]];
        
        // Do the toast...
        [MobiusoToast toast: restored? @"Restored" : @"Failed to Restore"];
        
    }
#endif
    return YES;
}


@end
