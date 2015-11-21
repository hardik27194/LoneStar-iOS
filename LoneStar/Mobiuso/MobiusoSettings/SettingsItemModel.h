//
//  NavigationModel.h
//  SnapticaToo
//
//  Created by sandeep on 12/31/14.
//  Copyright (c) 2014 Mobiuso. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SettingsItemStyle)
{
    SettingsItemStyleHeader = 0,
    SettingsItemStyleText = 1,  // SimpleText
    SettingsItemStyleEmail = 2, // Email field
    SettingsItemStylePassword = 3, // Password field
    SettingsItemStyleDate = 4,     // Date
    SettingsItemStyleBOOL =5,  // Switch - Yes/No
    SettingsItemStyleWebRef = 6,  // Web reference internal browser
    SettingsItemStyleBundleFileRef = 7,  // Reference to bundle file - PDF, RTF, HTML, etc
                                         // "SplashTransitionViewController.xib:SplashTransitionViewController" or
                                         // "Main.storyboard:AboutVC" (storyboard and identifier
                                         // or just the class name eg "HomeController"
    SettingsItemStyleBundleClassRef = 8,  // Reference to bundle Class Reference
    SettingsItemStyleName = 9,   // Name - so automatically make it upper case, etc
    SettingsItemStyleWebExternalRef = 10,  // Will Switch to external browser - close the view
};

@interface SettingsItemModel : NSObject


@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *count;
@property (nonatomic, retain) id       value;
@property (nonatomic, retain) id       placeholder;
@property (nonatomic, assign) SettingsItemStyle type;
@property (nonatomic, retain) NSArray  *children;
@property (nonatomic, retain) NSString *key;    // if backed by key in the datastore

@property (nonatomic, retain) NSString *actionTitle;    // If a special action for the group is allowed

@property (nonatomic, retain) NSMutableDictionary *settingsDictionary;  // dictionary if backed by the datastore

- (id) initWithDictionary: (NSDictionary *) dict;
- (id) initWithTitle: (NSString *) title andIcon: (NSString *) icon andCount: (NSString *) count;
- (id) initWithTitle: (NSString *) title andIcon: (NSString *) icon;    // style type header
- (id) initWithTitle: (NSString *) title andIcon: (NSString *) icon andDefaultText: (NSString *) defaultValue; // style text input
- (id) initWithTitle: (NSString *) title andIcon: (NSString *) icon andDefaultEmail: (NSString *) defaultValue; // style email input
- (id) initWithTitle: (NSString *) title andIcon: (NSString *) icon andDefaultState: (BOOL) value;

- (void) setValue:(id)value;

@end
