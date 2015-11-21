//
//  SSGalaxyManager.h
//  FlashDrive
//
//  Created by sandeep on 3/21/15.
//  Copyright (c) 2015 Skyscape. All rights reserved.
//
//
//  Internal Use Only - Create a Public wrapper and header file for third parties

#import <Foundation/Foundation.h>

// Known Skyscape Galaxy Apps - Main list
typedef enum {
    SSAppSML = 0,
    SSAppSnapWord = 1,
    SSAppFlashDrive = 2,
    SSAppSkillsHub = 3,
    SSAppNTrack = 4,
    SSAppTestZapp = 5,
    SSAppMedpressoBuzz = 6,
    SSAppCount        // Insert as necessary - these will be compiled in the latest versions
} SkyscapeAppID;

// Basic Default App Table Keys - these are 'static items' that don't change with user interactions
#define keyDisplayName      @"appDisplayName"
#define keyAppSkyscapeId    @"appId"
#define keyAppIconPNG       @"appIcon"
#define keyAppName          @"appName"
#define keyAppIdentifier    @"appBundleId"
#define keyVersionNumber    @"appVersion"
#define keyBuildNumber      @"appBundleNo"
#define keyAppURLScheme     @"appURLScheme"
#define keyAppStoreLink     @"appStoreLink"

// Global App List (and status) Pasteboard
#define kAppListPasteBoardName  @"com.medpresso.galaxy.applist"
#define kAppListType            @"com.medpresso.galaxy.applist"

// App driven Dictionary Keys - usually the items that can change dynamically
// These are saved in a pasteboard that is not obvious for third parties to guess
#define keyExportIdentifier @"exportId" // will contain

#define keyAppPayload       @"appPayload"

#define kAppPasteBoardType  @"appPayload"

#define kAppListPassword    @"This is a Special Password for GalaxyAppList Not for External Knowledge - " \
@"Please don't Share this"

// Keys with the User Info exported
#define keyUserEmailId      @"userEmail"
#define keyUserCustomerId   @"userId"

@interface SSGalaxyManager : NSObject

@property (nonatomic, retain) NSArray *skyscapeAppTable;    // Ordered list of App ID information

+ (NSString *) setAppReference: (NSString *) appName
                 skyscapeAppId: (SkyscapeAppID) appId
                   appBundleID: (NSString *) bundleId
              appVersionNumber: (NSString *) versionNumber
                appBuildNumber: (NSString *) buildNumber
                        appURL: (NSString *) appURLScheme
                       appIcon: (UIImage *) appIcon
                  appStoreLink: (NSString *) appStoreLink;

+ (NSDictionary *) getApp: (NSString *) bundleId;
+ (NSDictionary *) getSkyscapeApp: (SkyscapeAppID) skyscapeAppId;

+ (void) setAppCookie: (NSData *) payload forAppIdentifier: (NSString *)bundleId forPasteBoard: (NSString *) pasteBoardName;

+ (NSDictionary *) getSkyscapeUser;


@end
