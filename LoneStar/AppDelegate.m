//
//  AppDelegate.m
//  LoneStar
//
//  Created by sandeep on 10/30/15.
//  Copyright © 2015 Medpresso. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsManager.h"
#import "Utilities.h"
#import "Constants.h"
#import "SSGalaxyManager.h"
#import "MobiusoToast.h"
#import "EncryptionUtilities.h"
#import "Strings.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark
static NSString     *_currentUserName;
static NSString     *_currentUserId;
static NSString     *_currentModuleId;
static NSDictionary *_currentModuleInfo;
static NSString     *_mixpanelDistinctId;

+ (AppDelegate *)sharedDelegate {
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Utilities for getting the current Controller & View
- (UIView *) visibleView
{
    return  [self topController].view;
}

- (UIViewController *) topController
{
    UIViewController *controller = self.window.rootViewController;
    
    UINavigationController *nav = controller.navigationController;
    if (nav) {
        return nav.visibleViewController;
    } else {
        if ([controller isKindOfClass:[UINavigationController class]]) {
            nav = (UINavigationController *) controller;
            return nav.visibleViewController;
        } else {
            UIViewController *lastController = controller;
            // traverse until you reach the end...
            while ((controller=controller.presentedViewController) != nil) {
                lastController = controller;
            }
            return lastController;
        }
    }
}


#pragma mark - Local Folders in the Sandbox
// Avoid Name collision with same files for different modules that will be downloaded
// This will be in the Do Not Backup category.  Anything that needs to be saved, must go in a different root directory
+ (NSString *) localDataRoot
{
    NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [contentRootPath stringByAppendingPathComponent:DO_NOT_BACKUP_FOLDER];
    
    
    return   [fullPath stringByAppendingPathComponent: [self currentModuleId]];
    
}

+ (NSString *) localDataRootForModule:(NSString*)moduleId
{
    NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [contentRootPath stringByAppendingPathComponent:DO_NOT_BACKUP_FOLDER];
    
    
    return   [fullPath stringByAppendingPathComponent: moduleId];
    
}

+ (NSString *) localDataRoot: (NSString *) moduleId forModuleType: (ModuleTypeId) modType
{
    
    NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath;
    
    NSString *root = nil;
    switch (modType) {
        case ModuleTypeBuiltIn:
            fullPath = [contentRootPath stringByAppendingPathComponent:DO_NOT_BACKUP_FOLDER];
            root = [fullPath stringByAppendingPathComponent: moduleId];
            break;
            
        default:
            break;
    }
    return  root;
    
}

// Files that are saved or generated must be in the "Stash" directory, else, they will not be backed up or updated...
+ (NSString *) localStashRoot
{
    NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return   [[contentRootPath stringByAppendingPathComponent:STASH_FOLDER] stringByAppendingPathComponent: (_currentModuleId?_currentModuleId:kDefaultModule)];
}

// Module file with a convention of basename = module name
+ (NSString *) pathForModuleFileWithExtension: (NSString *) fileExtension
{
    NSString *dataRoot = [self localDataRoot];
    NSString *module = _currentModuleId? _currentModuleId : kDefaultModule;
    return [NSString stringWithFormat:@"%@/%@/%@.%@", dataRoot, module, module, fileExtension];
}

+ (NSString *) pathForModuleFileWithModuleId:(NSString*)moduleID WithExtension: (NSString *) fileExtension
{
    NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [contentRootPath stringByAppendingPathComponent:DO_NOT_BACKUP_FOLDER];
    
    
    NSLog(@"path is %@", [NSString stringWithFormat:@"%@/%@/%@.%@", fullPath, moduleID, moduleID, fileExtension]);
    return [NSString stringWithFormat:@"%@/%@/%@/%@.%@", fullPath, moduleID, moduleID, moduleID, fileExtension];
}

// Any file in the Module specific data directory - supply fully qualified path
+ (NSString *) pathForModuleFile: (NSString *) filename
{
    NSString *dataRoot = [self localDataRoot];
    NSString *module = [self currentModuleId];
    return [NSString stringWithFormat:@"%@/%@/%@", dataRoot, module, filename];
}


//
+ (NSString *) pathForModuleDirectory
{
    NSString *dataRoot = [self localDataRoot];
    NSString *module = [self currentModuleId];
    return [NSString stringWithFormat:@"%@/%@", dataRoot, module];
}

//
+ (NSString *) pathForModuleDirectory: (NSString *) moduleId forModuleType: (ModuleTypeId) modType
{
    NSString *dataRoot = [self localDataRoot:moduleId forModuleType:modType];
    return [NSString stringWithFormat:@"%@/%@", dataRoot, moduleId];
}

#pragma mark - Accessing the data on the server
// Any file from the server in the given module path, with module followed by
+ (NSString *) serverUrlForModuleFileWithExtension: (NSString *) fileExtension
{
    NSString *module = [self currentModuleId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@.%@", kServer, kCompany, kProduct, module, module, fileExtension];
    
}

+ (NSString *) serverUrlForModuleFileWithExtensionForModule:(NSString*)moduleId withExtension: (NSString *) fileExtension
{
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@.%@", kServer, kCompany, kProduct, moduleId, moduleId, fileExtension];
    
}

// Any file from the server in the given module path
+ (NSString *) serverUrlForModuleFile: (NSString *) filename
{
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@", kServer, kCompany, kProduct, [self currentModuleId], filename];
    
}

#pragma mark - Users & Modules
+ (NSString *) currentUserName
{
    return _currentUserName;
}

+ (NSString *) currentUserId
{
    return _currentUserId;
}

+ (NSString *) currentModuleId
{
    return _currentModuleId? _currentModuleId : kDefaultModule;
}

+ (NSDictionary *) currentModuleInfo
{
    return _currentModuleInfo? _currentModuleInfo : nil;
}

+ (NSString *) mixpanelDistinctId
{
    return _mixpanelDistinctId;
}

// Allow the Module ID to be set
+ (void) setCurrentModuleInfo: (NSDictionary *) moduleInfo
{
    
    if (moduleInfo == nil) {
        _currentModuleInfo = nil;
        _currentModuleId = nil;
        SettingsManager *sm = [SettingsManager instance];
        //[sm setValue:moduleInfo forKey:kSettingCurrentModuleInfoIndexKey];
        [sm setValue:@"" forKey:kSettingCurrentModuleIndexKey];
    }
    else{
        NSString *moduleId = [moduleInfo objectForKey:@"name"];
        //    if (!IS_EQUAL(moduleId, _currentModuleId))
        {
            _currentModuleInfo = moduleInfo;
            _currentModuleId = moduleId;
            SettingsManager *sm = [SettingsManager instance];
            [sm setValue:moduleInfo forKey:kSettingCurrentModuleInfoIndexKey];
            [sm setValue:moduleId forKey:kSettingCurrentModuleIndexKey];
#if 0   // TBD
            // Reset the content
            [[DataManager sharedManager ] resetContent];
            [[ContentManager sharedManager] checkAndUpdateContent];
            [[DataManager sharedManager] loadJsonData];
#endif
            
        }
    }
    
}


+ (NSString *) syncFolder
{
    return [[Utilities applicationSavePath] stringByAppendingPathComponent:CLOUD_SYNC_FOLDER];
}

+ (NSString *) pictFolder
{
    return [[[Utilities applicationSavePath] stringByAppendingPathComponent:CLOUD_SYNC_FOLDER] stringByAppendingPathComponent:PICTURES_FOLDER];
}


+ (NSString *) pictRoot
{
    return   [[self pictFolder] stringByAppendingPathComponent: (_currentUserId?_currentUserId:kAnonymousUser) /*_currentHostString*/];
    
}


+ (NSString *) downloadsFolder
{
    return [[Utilities applicationSavePath] stringByAppendingPathComponent:DOWNLOADS_FOLDER];
}

//
- (UIView *) rootView
{
    return [[self.window rootViewController] view];
}

#pragma Initialization and Refresh upon changes in settings etc.
// Set up the server to be used and the User ID, etc.  Also any other configuration stuff can go here
- (void) updateServerUser
{
    // Get the current Host from the Settings Manager
    SettingsManager *sm = [SettingsManager instance];
    
    NSDictionary *userDict = [sm currentUser];
    if (userDict) {
        _currentUserId = [userDict objectForKey:keyUserCustomerId];
        _currentUserName = [userDict objectForKey:keyUserEmailId];
    }
    
    if (_currentUserId == nil) {
        _currentUserId = kAnonymousUser;
    }
    
    if (_currentUserName == nil) {
        _currentUserName = kAnonymousUser;
    }
    
    if (_currentModuleId == nil) {
        _currentModuleId = [sm objectForKey:kSettingCurrentModuleIndexKey];
        _currentModuleInfo = [sm objectForKey:kSettingCurrentModuleInfoIndexKey];
        NSArray *modules = [ContentManager modulesForUser:_currentUserId ofType:ModuleTypeBuiltIn]; // [sm.modulesDictionary objectForKey:@"modules"];
        if ((_currentModuleId == nil || [_currentModuleId  isEqual: @""]) &&
            ([modules count] >= 1)) {
            NSDictionary *module = modules[0];
            [AppDelegate setCurrentModuleInfo:module];
        }
        
    }
}

#pragma mark - ONe time initialization
- (void) checkAndCreateFolders
{
    BOOL isDir = NO;
    NSError *error;
    NSString *appSavePath = [Utilities applicationSavePath];
    NSString *fullPath = [appSavePath stringByAppendingPathComponent:DO_NOT_BACKUP_FOLDER];
    
    // For transient data that can be recreated
    if (! [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:NO attributes:nil error:&error];
        //NSURL *folderUrl = [NSURL URLWithString:fullPath];
        [Utilities addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:fullPath]];
        
    }
    
    // For sync data - such as profiles and any other data that needs to be synced between platforms
    NSString *cachePath = [fullPath stringByAppendingPathComponent:CACHE_FOLDER]; isDir = NO;
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    
    // For sync data - such as profiles and any other data that needs to be synced between platforms
    NSString *persistPath = [appSavePath stringByAppendingPathComponent:CLOUD_SYNC_FOLDER]; isDir = NO;
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:persistPath isDirectory:&isDir] && isDir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:persistPath withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    
    // For pictures data -
    NSString *picturesPath = [persistPath stringByAppendingPathComponent:PICTURES_FOLDER]; isDir = NO;
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:picturesPath isDirectory:&isDir] && isDir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:picturesPath withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    
    // For Downloads data - these are to be preserved/backedup
    NSString *downloadsPath = [persistPath stringByAppendingPathComponent:DOWNLOADS_FOLDER]; isDir = NO;
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:downloadsPath isDirectory:&isDir] && isDir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadsPath withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    
    // For PDF data - these are to be preserved/backedup
    NSString *pdfPath = [appSavePath stringByAppendingPathComponent:PDF_INBOX]; isDir = NO;
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:pdfPath isDirectory:&isDir] && isDir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:pdfPath withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    // For Stashed items - these are to be preserved/backedup
    NSString *stashPath = [appSavePath stringByAppendingPathComponent:STASH_FOLDER]; isDir = NO;
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:stashPath isDirectory:&isDir] && isDir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:stashPath withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    
    // For Trashed data -
    NSString *trashPath = [appSavePath stringByAppendingPathComponent:TRASH_FOLDER]; isDir = NO;
    
    if (! [[NSFileManager defaultManager] fileExistsAtPath:trashPath isDirectory:&isDir] && isDir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:trashPath withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    
}

#pragma mark - Help document display
+ (BOOL) showHelpDocument
{
    return YES;
}

#pragma mark - Copy Files to the Skyscape associated Account (or Anonymous)
- (BOOL) downloadFile: (NSURL *) fileUrl
{
    if ([fileUrl isFileURL]) {
        // Copy the file
        NSString *downloadsfolder = [AppDelegate downloadsFolder];
        NSString *filename = [fileUrl lastPathComponent];
        NSData *data = [NSData dataWithContentsOfURL:fileUrl];
        
        NSString *newpath = [downloadsfolder stringByAppendingPathComponent:filename];   // may need a path...
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        
        [fileManager createDirectoryAtPath:downloadsfolder
               withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (!error) {
            BOOL created = [fileManager createFileAtPath:newpath contents:data attributes:nil];
            
            if (!created) return NO;   // Error
            
            // Now remove the supplied file
            [fileManager removeItemAtURL:fileUrl error:&error];
        }
        
        FileType ftype = [Utilities fileType:filename];
        if (ftype == FileTypeSHSH) {
            //
            // make sure we create any dummy files needed
            //
            //
            NSString *basefilename = [Utilities basenameIfEncryptedfile:filename]; // [filename substringToIndex:index.location];
            NSString *lockFileString = [NSString stringWithFormat:LOCK_PREFIX @"%@", basefilename];
            NSString *lockPath = [downloadsfolder stringByAppendingPathComponent:lockFileString];
            NSString *passwordHash = [EncryptionUtilities factoryPassword];
            NSData *passwordData = [passwordHash dataUsingEncoding:NSUTF8StringEncoding];
            
            BOOL created = [fileManager createFileAtPath:lockPath contents:passwordData attributes:nil];
            
            if (!created) {
                Alert(@"Unable to create the lock file", @"An error has occurred");
            }
            
        } else if ((ftype == FileTypeSHUB) || (ftype == FileTypeZIP)) {
            // Unzip the file at Newpath
            // If the user is not defined, then
            __unused NSString *userId = [AppDelegate currentUserId];
            // Insert the user ID
            //            if (!((userId == nil) || IS_EQUAL(userId, kAnonymousUser))) {
            //                downloadsfolder = [downloadsfolder stringByAppendingPathComponent:userId];
            //            }
            
            
            [Utilities decompress:newpath toDestinationPath:[downloadsfolder stringByAppendingPathComponent:MODULES_FOLDER]];
        }
        
        // Delete the original File so that Inbox is not cluttered
        [fileManager removeItemAtURL:fileUrl error:&error];
        
        
        
        // Do the toast...
        [MobiusoToast toast: [NSString stringWithFormat:@"%@ [%@]", DOWNLOAD_STRING, [filename stringByDeletingPathExtension]]];
        
        [[ContentManager sharedManager] reset];
        
    }
    return YES;
}


+ (NSOperationQueue *)backgroundQueue
{
    static dispatch_once_t once;
    static id _backgroundQueue;
    
    dispatch_once(&once, ^{
        _backgroundQueue = [[NSOperationQueue alloc] init];
        [_backgroundQueue setMaxConcurrentOperationCount:4];
    });
    
    return _backgroundQueue;
}

#pragma mark - MixPanel
+(NSDictionary *)getUserProfileForMixpanel{
    
    NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [contentRootPath stringByAppendingPathComponent:DO_NOT_BACKUP_FOLDER];
    NSString *destinationFile = [NSString stringWithFormat:@"%@/modules.json", fullPath];
    
    NSDictionary *mixPanelPeopleProfile = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:destinationFile]){
        NSData *jsonData = [NSData dataWithContentsOfFile:destinationFile];
        
        NSError *error = nil;
        
        if (jsonData == nil) {
            // return nil;
        }
        
        // Get JSON data into a Foundation object
        NSDictionary *modulesJSONFile = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        NSString *firstName = [modulesJSONFile objectForKey:@"FirstName"];
        NSString *lastName = [modulesJSONFile objectForKey:@"LastName"];
        NSString *profession = [modulesJSONFile objectForKey:@"Profession"];
        NSString *speciality = [modulesJSONFile objectForKey:@"Speciality"];
        NSString *accountCreationDate = [modulesJSONFile objectForKey:@"AccountCreatedOn"];
        
        mixPanelPeopleProfile = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [AppDelegate currentUserId],@"customerId",
                                 [AppDelegate currentUserName],@"$email",
                                 firstName,@"$first_name",
                                 lastName,@"$last_name",
                                 profession,@"Profession",
                                 speciality,@"Speciality",
                                 accountCreationDate,@"AccountCreatedOn",nil];
    }
    return mixPanelPeopleProfile;
}

#if 0
+(NSString *)getDistinctIdForMixpanel{
    
    NSString *currentUserId = [AppDelegate currentUserId];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    if([currentUserId isEqualToString:kAnonymousUser]){
        if(_mixpanelDistinctId == nil){
            currentUserId = [mixpanel distinctId];
            _mixpanelDistinctId = [currentUserId copy];
        }else{
            currentUserId = _mixpanelDistinctId;
        }
        
    }
    return currentUserId;
}
#endif

@end
