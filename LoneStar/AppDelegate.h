//
//  AppDelegate.h
//  LoneStar
//
//  Created by sandeep on 10/30/15.
//  Copyright © 2015 Medpresso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate *)sharedDelegate;
- (UIView *) visibleView;
- (UIViewController *) topController;

@property (nonatomic, retain) NSString  *returnAppUrlScheme;
@property (nonatomic, retain) NSString  *returnAppSessionToken;
@property (nonatomic, assign) BOOL shouldStartRotate;

+ (NSString *) currentUserName;
+ (NSString *) currentUserId;
+ (NSString *) currentModuleId;
+ (NSDictionary *) currentModuleInfo;

+ (NSString *) mixpanelDistinctId;
+ (void) setCurrentModuleInfo: (NSDictionary *) moduleInfo;
+ (BOOL) showHelpDocument;

- (void) updateServerUser;

+ (NSString *) localDataRoot;
+ (NSString *) localDataRootForModule:(NSString*)moduleId;

+ (NSString *) localDataRoot: (NSString *) moduleId forModuleType: (ModuleTypeId) modType;
// Files that are saved or generated must be in the "Stash" directory, else, they will not be backed up or updated...
+ (NSString *) localStashRoot;
// Module file with a convention of basename = module name
+ (NSString *) pathForModuleFileWithExtension: (NSString *) fileExtension;
+ (NSString *) pathForModuleFileWithModuleId:(NSString*)moduleID WithExtension: (NSString *) fileExtension;

// Any file in the Module specific data directory - supply fully qualified path
+ (NSString *) pathForModuleFile: (NSString *) filename;
// Any file in the Module specific data directory - supply fully qualified path
+ (NSString *) pathForModuleDirectory;
+ (NSString *) pathForModuleDirectory: (NSString *) moduleId forModuleType: (ModuleTypeId) modType;

// Any file from the server in the given module path, with file with basename as module and file extension that is specified (eg zip, manifest, timestamp, etc
+ (NSString *) serverUrlForModuleFileWithExtension: (NSString *) fileExtension;
+(NSString *) serverUrlForModuleFileWithExtensionForModule:(NSString*)moduleId withExtension: (NSString *) fileExtension;

// Any file from the server in the given module path
+ (NSString *) serverUrlForModuleFile: (NSString *) filename;

+ (NSOperationQueue *)backgroundQueue;
+ (NSString *) syncFolder;
+ (NSString *) pictFolder;

+ (NSString *) pictRoot;

+ (NSString *) downloadsFolder;//

#if 0
+(NSDictionary *)getUserProfileForMixpanel;
+(NSString *)getDistinctIdForMixpanel;
#endif

- (UIView *) rootView;

@end

