//
//  Configs.h
//  LoneStar


#ifndef Pro_Shot_Configs_h
#define Pro_Shot_Configs_h


#define NOTIFICATIONS
#define LOCATION_REQUEST_INUSE_AUTH
#undef  LOCATION_REQUEST_ALWAYS_AUTH
#undef  TRACK_LOCATION


// Config for various Build Options
#define IMAGEEDITOR_HANDOFF_TO_HOMEVIEW

// APP INFO ================================
#define APP_NAME @"StandAlone"

// Replace "XXXXXXX" with your own App ID, you can find it by clicking on "More -> About This App" button in iTunes Connect, copy the Apple ID and paste it here
#define RATE_US_LINK @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=993981129"

// Replace the link below with the one of your app
#if 1
#define ITUNES_STORE_LINK @"https://itunes.apple.com/US/app/id912628188?mt=8"   // ShshDox to test
#else
#define ITUNES_STORE_LINK @"https://itunes.apple.com/US/app/id993981129?mt=8"
#endif


#define FEEDBACK_EMAIL_ADDRESS @"support@mobiuso.com"
//-----------------------------------------------------------------------------


// COLORS ===============================
#define MAIN_COLOR [UIColor colorWithRed:47.0/255.0 green:55.0/255.0 blue:65.0/255.0 alpha:1.0]
#define LIGHT_COLOR [UIColor colorWithRed:246.0/255.0 green:247.0/255.0 blue:251.0/255.0 alpha:1.0]
#define PURPLE_COLOR [UIColor colorWithRed:209.0/255.0 green:118.0/255.0 blue:220.0/255.0 alpha:1.0]
//-----------------------------------------------------------------------------


// FONTS ===============================
#define MAIN_FONT [UIFont fontWithName:@"BebasNeue" size:14] // HelveticaNeue-Thin
#define NAVBAR_FONT [UIFont fontWithName:@"BebasNeue" size:24]
#define NAVBAR_ITEM_FONT [UIFont fontWithName:@"Avenir Next" size:16]
#define TITLE_FONT [UIFont fontWithName:@"BebasNeue" size:27]
#define SETTINGS_ITEM_FONT [UIFont fontWithName:@"Avenir-Black" size:18]
//-----------------------------------------------------------------------------


// YOUR INSTAGRAM PAGE URL =====================================
#define INSTAGRAM_URL @"http://instagram.com/SnapticaPro"

// 500 PX
#define WWW500PX_URL @"http://500px.com/popular"

// GOOGLE IMAGES
#define GOOGLEIMAGES_URL @"http://images.google.com"

//-----------------------------------------------------------------------------


// YOUR FACEBOOK PAGE URL =====================================
#define FACEBOOK_PAGE_LINK @"https://www.facebook.com/mobiuso"
//-----------------------------------------------------------------------------


// SHARING MESSAGE FOR TWITTER, FACEBOOK AND MAIL ===================
#define SHARING_TITLE @"Hi there!"
#define SHARING_MESSAGE @"[via #SnapticaPro]"
#define SHARING_GALLERY_MESSAGE @"[via #SnapticaPro]"
#define FACEBOOK_LOGIN_ALERT @"Please go to Settings and link your Facebook account to this device!"
#define TWITTER_LOGIN_ALERT @"Please go to Settings and link your Twitter account to this device!"
//-----------------------------------------------------------------------------


// IN-APP PURCHASE PRODUCT ID ========================
#define IAP_PRODUCT @"com.mobiuso.SnapticaPro.premium"

// GROUPME
#define SNAPTICA_SIGNATURE  @"com.mobiuso.SnapticaPro"

//#define kMyURLScheme            kCustomURLScheme

//-----------------------------------------------------------------------------


// FREE ITEMS AVAILABLE WITH NO IAP ================
#define freeStickers 10     +1
#define freeFrames   6      +1
#define freeBorders  8      +1
#define freeTextures 8      +1
//-----------------------------------------------------------------------------

// how many seconds you want
#define DISPLAY_OVERLAY_PERSISTENCE     2.0f 


#endif
