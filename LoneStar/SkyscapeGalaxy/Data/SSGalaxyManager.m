//
//  SSGalaxyManager.m
//  FlashDrive
//
//  Created by sandeep on 3/21/15.
//  Copyright (c) 2015 Skyscape. All rights reserved.
//

#import "SSGalaxyManager.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "Utilities.h"
#import "EncryptionUtilities.h"

@import UIKit;

@implementation SSGalaxyManager

//static NSMutableDictionary *settingsDictionary = nil;
static SSGalaxyManager *ssGalaxyManager;
//static NSString *settingsPath;


+ (SSGalaxyManager *) instance
{
    @synchronized(self) {
        if (ssGalaxyManager == nil) {
            ssGalaxyManager = [[SSGalaxyManager alloc] init];
            
            /*
             
             SSAppSML = 0,
             SSAppSnapWord = 1,
             SSAppFlashDrive = 2,
             SSAppSkillsHub = 3,
             SSAppNTrack = 4,
             SSAppTestZapp = 5,
             
             */
            
            ssGalaxyManager.skyscapeAppTable = @[
                                                 @{    // SSAppSML
                                                     keyDisplayName: @"Medical Library",
                                                     keyAppIdentifier: @"com.medpresso.MySkyscape"
                                                     },
                                                 @{    // SSAppSnapWord
                                                     keyDisplayName: @"SnapWord",
                                                     keyAppIdentifier: @"com.medpresso.SnapWord"
                                                     },
                                                 @{    // SSAppFlashDrive
                                                     keyDisplayName: @"Flash Drive",
                                                     keyAppIdentifier: @"FlashDrive"
                                                     },
                                                 @{    // SSAppSkillsHub
                                                     keyDisplayName: @"Skills Hub",
                                                     keyAppIdentifier: @"com.medpresso.Skills"
                                                     },
                                                 @{    // SSAppNTrack
                                                     keyDisplayName: @"NTrack 2",
                                                     keyAppIdentifier: @"com.medpresso.nTrack"
                                                     },
                                                 @{    // SSAppTestZapp
                                                     keyDisplayName: @"TestZapp",
                                                     keyAppIdentifier: @"com.medpresso.TestZapp"
                                                     },
                                                 @{
                                                     
                                                     },
                                                 
                                                 ];
            
            
            
        }
    }
    
    return ssGalaxyManager;
    
}

// Return array index in the supplied array.  If match is found by checking the value in "key" to be "value"
// return -1 if no value matches
+ (NSUInteger) keyExists:(NSString *)key withValue:(NSString *)value inArray: (NSArray *) array {
    
    NSPredicate *predExists = [NSPredicate predicateWithFormat:
                               @"%K MATCHES[c] %@", key, value];
    
    // Return valid index or NSNotFound
    return [array indexOfObjectPassingTest:
            ^(id obj, NSUInteger idx, BOOL *stop) {
                return [predExists evaluateWithObject:obj];
            }];
}

+ (NSDictionary *) getApp: (NSString *) bundleId
{
    // If the reference exists, use it - else create a new reference
    // Setup the Pasteboard
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:kAppListPasteBoardName create:NO];
    
    NSData *data = [pasteboard valueForPasteboardType:kAppListType];
    NSMutableArray *list;   // It contains an array of dictionaries
    
    NSData *decryptedData = (data != nil) ? [EncryptionUtilities decrypt:data withPassword:kAppListPassword] : nil;
    
    NSUInteger found = NSNotFound;
    
    if ((decryptedData) &&
        (list = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData]) &&
        (NSNotFound != (found = [self keyExists:keyAppIdentifier withValue:bundleId inArray:list])) ) {
        return [list objectAtIndex:found];
    } else {
        return nil;
    }
}

+ (NSDictionary *) getSkyscapeApp: (SkyscapeAppID) skyscapeAppId
{
    // If the reference exists, use it - else create a new reference
    // Setup the Pasteboard
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"com.medpresso.galaxy.applist" create:NO];
    
    NSData *data = [pasteboard valueForPasteboardType:kAppListPasteBoardName];
    NSMutableArray *list;   // It contains an array of dictionaries
    
    NSData *decryptedData = (data != nil) ? [EncryptionUtilities decrypt:data withPassword:kAppListPassword] : nil;
    
    NSUInteger found = NSNotFound;
    
    if ((decryptedData) &&
        (list = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData]) &&
        (NSNotFound != (found = [self keyExists:keyAppSkyscapeId withValue:[NSString stringWithFormat:@"%ld", (long) skyscapeAppId] inArray:list])) ) {
        return [list objectAtIndex:found];
    } else {
        return nil;
    }
}

+ (NSDictionary *) getSkyscapeUser
{
    NSDictionary *dict = [self getSkyscapeApp: SSAppSML];
    NSString *pasteboardType = [dict objectForKey:keyExportIdentifier];
    
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName: pasteboardType create:NO];
    NSData *userData =  [pasteboard valueForPasteboardType: kAppPasteBoardType];
    
    NSDictionary *payload = [NSKeyedUnarchiver unarchiveObjectWithData: userData];
    
    // Now extract the payload (which will be a dictionary with keyValue Pairs
    NSDictionary *userDict = [payload objectForKey: keyAppPayload];
    
    return userDict;
    
}


+ (NSString *) setAppReference: (NSString *) appName
                 skyscapeAppId: (SkyscapeAppID) appIdX
                   appBundleID: (NSString *) bundleId
              appVersionNumber: (NSString *) versionNumber
                appBuildNumber: (NSString *) buildNumber
                        appURL: (NSString *) appURLScheme
                       appIcon: (UIImage *) appIcon
                  appStoreLink: (NSString *) appStoreLink
{
    // If the reference exists, use it - else create a new reference
    // Setup the Pasteboard
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:kAppListPasteBoardName create:YES];
    [pasteboard setPersistent:YES]; // Makes sure the pasteboard lives beyond app termination.
    
    NSData *data = [pasteboard valueForPasteboardType:kAppListType];
    NSMutableArray *list = nil;   // It contains an array of dictionaries
    
    NSData *decryptedData = (data != nil) ? [EncryptionUtilities decrypt:data withPassword:kAppListPassword] : nil;
    
    NSUInteger found = NSNotFound;
    NSString *uniquePasteboardType;
    
    if ((decryptedData) &&
        (list = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData]) &&
        (NSNotFound != (found = [self keyExists:keyAppName withValue:appName inArray:list])) ) {
        // Create a new dictionary item - just in case things are updated (esp name, etc)
        NSMutableDictionary *appDict = [NSMutableDictionary
                                        dictionaryWithDictionary: [list objectAtIndex:found]];
        // maintain the exportID - update other values
        [appDict setObject:appName forKey:keyAppName];
        [appDict setObject:[NSString stringWithFormat:@"%ld", (long) appIdX] forKey:keyAppSkyscapeId];
        [appDict setObject:bundleId forKey: keyAppIdentifier];
        [appDict setObject:UIImagePNGRepresentation(appIcon) forKey: keyAppIconPNG];
        [appDict setObject:versionNumber forKey: keyVersionNumber];
        [appDict setObject:buildNumber forKey: keyBuildNumber];
        [appDict setObject: ((appURLScheme==nil) ? [NSNull null] : appURLScheme) forKey:keyAppURLScheme];
        [appDict setObject: ((appStoreLink==nil) ? [NSNull null] : appStoreLink) forKey:keyAppStoreLink];
        // leave the unique export Id as is...
        uniquePasteboardType = [appDict objectForKey:keyExportIdentifier];
        
        
        // now replace the original entry with the new one...
        [list replaceObjectAtIndex:found withObject:appDict];
    } else {
        //create a CFUUID - it knows how to create unique identifiers
        CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);
        
        //create a string from unique identifier
        NSString * newUniqueIDStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, newUniqueID));
        
        uniquePasteboardType = [NSString stringWithFormat: @"%@.%@", bundleId, newUniqueIDStr];
        CFRelease(newUniqueID);
        if (list==nil) {
            list = [[NSMutableArray alloc] init];
        }
        NSString *appIdStr = [NSString stringWithFormat:@"%ld", (long) appIdX];
        NSDictionary *dict = @{
                               keyAppName: appName,
                               keyAppSkyscapeId: appIdStr,
                               keyAppIdentifier: bundleId,
                               keyAppIconPNG: UIImagePNGRepresentation(appIcon),
                               keyVersionNumber: versionNumber,
                               keyBuildNumber: buildNumber,
                               keyAppURLScheme: ((appURLScheme==nil) ? [NSNull null] : appURLScheme),
                               keyExportIdentifier: uniquePasteboardType
                               };
        [list addObject: dict];
    }
    
    // Write The Data
    NSData *rawData = [NSKeyedArchiver archivedDataWithRootObject:list];
    // Now Encrypt this
    //--------
    
    
    [pasteboard setData: [EncryptionUtilities encrypt:rawData withPassword:kAppListPassword] forPasteboardType:kAppListType];
    return uniquePasteboardType;
}

+ (void) setAppCookie: (NSData *) payload forAppIdentifier: (NSString *)bundleId forPasteBoard: (NSString *) pasteBoardName
{
    
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName: pasteBoardName create:YES];
    [pasteboard setPersistent:YES]; // Makes sure the pasteboard lives beyond app termination.
    
    NSDictionary *dict = @{
                           keyAppIdentifier : bundleId,
                           keyAppPayload : payload
                           };
    [pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forPasteboardType:kAppPasteBoardType];
    
    
}


@end
