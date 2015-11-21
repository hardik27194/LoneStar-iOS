//
//  Constants.h
//  LoneStar
//
//  Created by sandeep on 7/10/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

//#import "SSGalaxyManager.h"

#ifdef MACOS
#define UIColor NSColor
#endif
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define MAKERGBHEX(r,g,b) ((0xff << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff))

#define MAKERGBAHEX(r,g,b,a) (((a & 0xff) << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff))
#define RGBColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

//
//   | alpha | red | green | blue |
//   For example 0x8099bcd0
//
#define COLORFROMHEX(rgba) [UIColor colorWithRed:((rgba & 0xff0000) >> 16)/255.0 green:((rgba & 0xff00) >> 8)/255.0 blue:((rgba & 0xff))/255.0 alpha:((rgba & 0xff000000) >> 24)/255.0]

#define ALPHAFROMHEX(argb) (( (argb & 0xff000000) >> 24)/255.0)

// This is defined in Math.h
#define M_PI   3.14159265358979323846264338327950288   /* pi */

// Our conversion definition
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

// Splash Screen Animations etc
#define MO_ANIMATION_APPEAR		@"Appear"
#define MO_ANIMATION_DISAPPEAR	@"Disappear"
#define MO_ANIMATION_LINGER     @"Linger"

#define MO_ANIMATE_ARROWS		YES
#define MO_SPLASH_CIRCLE_SIZE   108.0f
#define MO_SPLASH_CIRCLE_ROTATIONS  100
#define MO_SPLASH_CIRCLE_DECELERATIONS 2

#define ENABLESINGLEGROUP 1
#define NO_MOBIUSO_PACKAGE
#define NO_ELASTIC_MENU

#define APP_PROTOCOL    @"LoneStar-" PRODUCT_CODE

// File System Constants
#define DO_NOT_BACKUP_FOLDER    @"DoNotBackup"
#define CLOUD_SYNC_FOLDER       @"Sync"
#define PICTURES_FOLDER         @"Pictures"
#define DOWNLOADS_FOLDER        @"Downloads"
#define STASH_FOLDER            @"Stash"
#define TRASH_FOLDER            @"Trash"
#define CACHE_FOLDER            @"Cache"
#define PDF_INBOX               @"Sync" @"/" @"Downloads" @"/" "PDF"

#define STARTER_FILE_NAME       @"Starter File"


#define LOCK_PREFIX             @"."
#define ENCRYPTED_FILE_UTI      @".shsh"
#define PDF_FILE_UTI            @".pdf"
#define TAGS_FILE_UTI           @".tags"
#define EXIF_FILE_UTI           @".exif"
#define MARKED_FILENAME         @"MarkedFiles.txt"
#define DIRECTORY_LISTNAME      @".dirlist"
#define DISALLOWED_FILENAME     @"dirlist"
#define DISALLOWED_CHARACTERS   @"#&;,'?"
#define DISALLOWED_FILENAME_CHARACTERS    @":/" DISALLOWED_CHARACTERS
#define EXTENSION_SEPARATOR     @"."

#define THUMBNAIL_PREFIX        @"#Thumb#"
#define METAFILE_PREFIX        @"#Meta#"

#define FAUX_URL_PREFIX         @"faux://"


#define ENCRYPTED_FILE_APPLICATION  @"com.mobiuso.document.Shsh"
#define DOWNLOAD_FILE_PASS_PHRASE_RAW   @"This is Mobiuso's Secret Pass Phrase - No one could dream this up" // This is not saved anywhere
#define DOWNLOAD_FILE_PASS_PHRASE   @"c3f3cd58379da4361adb246828f7e3dbf9d04501" // Result of the pass phrase @"This is Mobiuso's Secret Pass Phrase - No one could dream this up" using Utilities getMD5Hash:[Utilities getSHA1Hash:DOWNLOAD_FILE_PASS_PHRASE]

#define HTML_FILE_APPLICATION  @"com.mobiuso.document.sky"


#define WELCOME_RESOURCES       @"Welcome-Resources"

// Defaults and such
#define kAppDefaultsAccountIndex    @"AppDefaultsAccountIndex"
#define kAppDefaultsFolderIndex     @"AppDefaultsFolderIndex"

#define kWebsiteReference           @"http://www.skyscape.com/install"

#define kApplicationRoot            @"com.medpresso.FlashDrive"

// Notifications
#define kGalaxyAppStateChanged      @"kGalaxyAppStateChanged"

// Process, Threads, etc
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kTestServer                 @"http://drive.skyscape.com" // @"http://54.225.255.140" // @"localhost"    // @"107.20.64.108"
#define kLocalServer                @"http://localhost" // @"localhost"    // @"107.20.64.108"

// Define or undefine LOCALSERVER

#if LOCAL_SERVER
#define kServer                     kLocalServer
#define kAlbums                     @"the.Photos"
#else
#define kServer                     kTestServer
#define kAlbums                     @"drive"
#endif

#define kServerName                 @"Default"
#define kServerType                 @"LAMP"

#define kXMPPServerDomain       @"im.mobiuso.com" // @"localhost"    // @"54.225.255.140"
#define kUserServer             @"http://54.225.255.140/"
#define kXMPPServer             @"http://54.225.255.140/"
#define kCompany                @"Skyscape"
//#define kProduct                @"FlashDrive"
//#define kProductTitle           @"Flash Drive"
#define kUserDBFileName         @"users"
#define kApplicationGroup       @"group.com.medpresso.Skyscape"
#define kClientUniqueID         @"group.com.medpresso.Skyscape.UniqueID"



#define kAnonymousUser          @"anonymous"

#define kSkyscapeGalaxyHomeURL  @"medpresso://"
#define kMyURLScheme            kProduct @"://"

#define kMySkyscapeAppId        SSAppFlashDrive

// For Elastic Menu Override
#define HINT_IMAGE_BOTTOM_TO_TOP @"menu-compass-solid-72.png"
#define HINT_IMAGE_TOP_TO_BOTTOM @"menu-compass-solid-72.png"
#define HINT_IMAGE_LEFT_TO_RIGHT @"menu-compass-solid-72.png"
#define HINT_IMAGE_RIGHT_TO_LEFT @"menu-compass-solid-72.png"

#define ELASTIC_MENU_BUTTON_TOUCH_ONLY  1

#define STANDARD_WALLPAPER  1
#define HIDE_WELCOME_NAVIGATIONBAR 1