//
//  CacheManager.m
//  SnapticaToo
//
//  Manages Cache and Stash
//  Cache can be recreated from the server
//  Stash is the locally modified files that need to be synced with the cloud
//
//  Created by sandeep on 12/14/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import "CacheManager.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import <ImageIO/ImageIO.h>
#import <mach/mach_time.h>		// time metrics
#import "NSString+Date.h"
#import "NSDate+Compare.h"
#import "Configs.h"
#ifdef TRACK_LOCATION
#import "MoLocationManager.h"
#endif

@implementation CacheManager

- (id) init
{
    if (self = [super init]) {
#if 1
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.cacheDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:kSettingCacheKey]];
        if (self.cacheDictionary == nil) {
            self.cacheDictionary = [[NSMutableDictionary alloc] init];
            [self.cacheDictionary setObject: kSettingFoldersListVersionValue forKey: kSettingFoldersListVersionKey];
        } else {
            // Check if the versions are ok - else upgrade the version
            NSString *verStr = [self.cacheDictionary objectForKey:kSettingFoldersListVersionKey];
            if (verStr == nil) {
                // put our version
                [self.cacheDictionary setObject: kSettingFoldersListVersionValue forKey: kSettingFoldersListVersionKey];
                [defaults setObject:self.cacheDictionary forKey:kSettingCacheKey];
            } else if ([verStr compare: kSettingFoldersListVersionValue] != 0) {
                // Now what - need to upgrade to the next version...
                
                // For now just clear -
                
                // clean object
                self.cacheDictionary = [[NSMutableDictionary alloc] init];
                // new version
                [self.cacheDictionary setObject: kSettingFoldersListVersionValue forKey: kSettingFoldersListVersionKey];
                [defaults setObject:self.cacheDictionary forKey:kSettingCacheKey];
            }
        }
        [self setupServerCacheList];
        [self setupLocationToPlacemarksCacheList];
        [self setupAreaOfInterestCacheList];
        [self setupAddressToLocationCacheList];
#ifdef USE_ASSETLIBRARY
        [self setupAssetLibrary];
#endif
        _syncNeeded = NO;
        
        // Do any initialization work here
        [self performSelectorInBackground:@selector(startWorker) withObject:nil];
#endif
    }
    return self;
}

- (void) setupServerCacheList
{
    id dict;
    NSString *folderCacheForServerKey = [NSString stringWithFormat:@"%@@%@", kSettingFoldersBeingCachedListKey, [AppDelegate currentHostFolder]];
    if ((dict=[self.cacheDictionary objectForKey: folderCacheForServerKey]) == nil) {
        self.foldersBeingCachedList = [[NSMutableDictionary alloc] init];
        [self.cacheDictionary setObject:self.foldersBeingCachedList forKeyedSubscript:folderCacheForServerKey];
    } else {
        self.foldersBeingCachedList = [NSMutableDictionary dictionaryWithDictionary: dict];
    }
    
    NSString *filesCacheForServerKey = [NSString stringWithFormat:@"%@@%@", kSettingFileByURLListKey, [AppDelegate currentHostFolder]];

    if ((dict=[self.cacheDictionary objectForKey: filesCacheForServerKey]) == nil) {
        self.filesByUrlList = [[NSMutableDictionary alloc] init];
        [self.cacheDictionary setObject:self.filesByUrlList forKeyedSubscript:filesCacheForServerKey];
    } else {
        self.filesByUrlList = [NSMutableDictionary dictionaryWithDictionary: dict ];
    }
}

- (void) setupLocationToPlacemarksCacheList
{
    NSDictionary *dict;
    if ((dict=[self.cacheDictionary objectForKey: kSettingLocationToPlacemarksKey]) == nil) {
        self.locationToPlacemarks = [[NSMutableDictionary alloc] init];
        [self.cacheDictionary setObject:self.locationToPlacemarks forKeyedSubscript:kSettingLocationToPlacemarksKey];
    } else {
        self.locationToPlacemarks = [NSMutableDictionary dictionaryWithDictionary: dict];
    }
}

- (void) setupAreaOfInterestCacheList
{
    NSArray *dict;
    if ((dict=[self.cacheDictionary objectForKey: kSettingAreaOfInterestKey]) == nil) {
        self.areaOfInterestList = [[NSMutableArray alloc] init];
        [self.cacheDictionary setObject:self.areaOfInterestList forKey:kSettingAreaOfInterestKey];
    } else {
        self.areaOfInterestList = [NSMutableArray arrayWithArray: dict];
    }
}

- (void) setupAddressToLocationCacheList
{
    NSDictionary *dict;
    if ((dict=[self.cacheDictionary objectForKey: kSettingAddressToLocationsKey]) == nil) {
        self.addressToLocations = [[NSMutableDictionary alloc] init];
        [self.cacheDictionary setObject:self.addressToLocations forKeyedSubscript:kSettingAddressToLocationsKey];
    } else {
        self.addressToLocations = [NSMutableDictionary dictionaryWithDictionary: dict];
    }
}

#ifdef USE_ASSETLIBRARY
- (void) setupAssetLibrary
{

    [self debugCleanup];

    
    // First check our current cache file timestamp
    NSError *error = nil;
    NSString *basePath = [self mapFilePath:@":all.json" inCacheZone:NO];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:basePath error:&error];
    
    if ((!error) && (fileAttributes != nil)) {
        NSData *allData = [[NSData alloc]initWithContentsOfFile:basePath options:NSDataReadingMappedIfSafe error:&error];
        _assetDictionary = [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            // Delete the assets dictionary
            [fileManager removeItemAtPath:basePath error:&error];
            _assetDictionary = nil; // just to make sure
        } else {
            // Looks like the file exists, compare the timestamps
            DLog(@"Initial assetDictionary count=%ld", [_assetDictionary count]);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSString *timestampDate = [_assetDictionary objectForKey:@"timestamp"];
            if (timestampDate) {
                _assetTimestamp = [dateFormatter dateFromString:timestampDate];
            } else {
                _assetTimestamp = [fileAttributes objectForKey:NSFileModificationDate];
            }
        }
        
    }
    if (!_assetDictionary) {
        _assetDictionary = [NSMutableDictionary dictionaryWithDictionary: @{@"timestamp" : [NSString stringDateFromDate:[NSDate date]]}];
    }

}
#endif


- (void) syncToFile: (NSMutableDictionary *) dictionary withPathKey: (NSString *) filePathKey
{
#ifdef CACHE_DEBUG

    DLog(@"Items in Dictionary = %ld, (%@)", (unsigned long)[dictionary count], filePathKey);
#endif
    // Put the timestamp key
    [dictionary setObject:[NSString stringDateFromDate:[NSDate date]] forKey:@"timestamp"];
    NSError *error = nil;
    NSData *jsonFullData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
    __unused NSString *fullpath = [self stashData:jsonFullData forFile:filePathKey];
    
#ifdef CACHE_DEBUG
    DLog(@"Full path of stashed File: %@", fullpath);
#endif
    
}

- (void) sync {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    @synchronized(self.cacheDictionary) {
        NSString *folderCacheForServerKey = [NSString stringWithFormat:@"%@@%@", kSettingFoldersBeingCachedListKey, [AppDelegate currentHostFolder]];
        [self.cacheDictionary setObject:self.foldersBeingCachedList forKey:folderCacheForServerKey];
        
        NSString *filesCacheForServerKey = [NSString stringWithFormat:@"%@@%@", kSettingFileByURLListKey, [AppDelegate currentHostFolder]];
        [self.cacheDictionary setObject:self.filesByUrlList forKey:filesCacheForServerKey];
        
        // Locations stuff - this is done through main UI so no multi-threading consideration
        [self.cacheDictionary setObject:self.addressToLocations forKey:kSettingAddressToLocationsKey];

        // Add the following for debug
//        [self.cacheDictionary removeObjectForKey: kSettingLocationToPlacemarksKey];   //         20150208 DEBUG
        
        [self.cacheDictionary setObject:self.locationToPlacemarks forKey: kSettingLocationToPlacemarksKey];
 
        
        [self.cacheDictionary setObject:self.areaOfInterestList forKey: kSettingAreaOfInterestKey];

        [defaults setObject:self.cacheDictionary   forKey:kSettingCacheKey];
        
        __unused BOOL synchronized = [defaults synchronize];
    }
    
#ifdef CACHE_DEBUG

    if (!synchronized) {
        DLog(@"Error saving Caching List to Defaults");
    }
#endif
}



#ifdef NOTNOW
- (NSArray*) sortFavs: (NSMutableArray *)favs
{
    NSSortDescriptor *folderNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects: folderNameDescriptor, nil];
    
    return [favs sortedArrayUsingDescriptors:sortDescriptors];
}
#endif

#pragma mark - utility function
- (NSDictionary *) logMetaDataFromData:(NSData*)data
{
#ifdef CACHE_DEBUG
    DLog(@" %@",NSStringFromSelector(_cmd));
#endif
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    CFDictionaryRef imageMetaData = CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
#ifdef CACHE_DEBUG
    DLog (@"%@",imageMetaData);
#endif
    return (__bridge NSDictionary *) imageMetaData;
}

#pragma mark - Files Being eed

// Remove the File being Cached (if so)
- (BOOL) purgeFileInCache: (NSString *) pathKey
{
    BOOL exists = ([_filesByUrlList objectForKey:pathKey] != nil);
    if (exists) {
        [_filesByUrlList removeObjectForKey:pathKey];
    }
    return exists;
}

// Remove all files in a given directory
// If pathKey is null then everything goes...
- (BOOL) purgeDirectory: (NSString *) pathKey
{
    BOOL found = NO;

    // NSString *path = [self flattenFilePath: pathKey];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    for (NSString *key in _filesByUrlList) {
        if ((pathKey == nil) || ([key hasPrefix:pathKey])) {
#ifdef CACHE_DEBUG
            DLog(@"Key: %@", key);
#endif
            
//            NSString *imagePath = _filesByUrlList[key];
            NSString *basePath = [self filePath:key];

            if ([fileManager fileExistsAtPath:basePath]) {
                // remove this entry
                NSError *error = nil;
                [fileManager removeItemAtPath:basePath error:&error];
                if (error == nil) {
                    [removeArray addObject:key];
                }
                found = YES;
            }
        }
    }
    if (found) {
        [_filesByUrlList removeObjectsForKeys:removeArray];
    }

    return found;
}

- (NSDictionary *) infoDirectory: (NSString *) pathKey
{
//    NSString *description = @"";
    
    // NSString *path = [self flattenFilePath: pathKey];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSUInteger size = 0;
    NSUInteger totalsize = 0;
    NSUInteger count = 0;
    NSUInteger totalcount = 0;
    for (NSString *key in [_filesByUrlList copy]) {
//            DLog(@"Key: %@", key);
             NSString *basePath = [self filePath:key];
            
            if ([fileManager fileExistsAtPath:basePath]) {
                
                // stat this entry
                NSError *error = nil;
                NSDictionary *infoDict = [fileManager attributesOfItemAtPath:basePath error: &error];
                
                if (error == nil) {
                    NSString *sizeStr = [infoDict objectForKey:NSFileSize];
                    NSUInteger thisSize = [sizeStr integerValue];
                    totalsize += thisSize;
                    totalcount++;
                    if ([key hasPrefix:pathKey]) {
                        size += thisSize;
                        count++;
                    }
                    
                }
            }
    }
    
    return @{
             @"size": [NSNumber numberWithInteger: size],
             @"count": [NSNumber numberWithInteger: count],
             @"totalsize": [NSNumber numberWithInteger: totalsize],
             @"totalcount": [NSNumber numberWithInteger: totalcount]
             };
    
}


#pragma mark - Files in Cache
// File exists - given the URL
- (BOOL) fileExistsInCache: (NSString *) pathKey
{
    return ([_filesByUrlList objectForKey:pathKey] != nil);
}

// If the file path component has special chars, replace them to '#'
-(NSString *) flattenFilePath: (NSString *) component {
    NSRange r;
    NSString *s = [component copy];
    while ((r = [s rangeOfString:@"[/:]" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@"#"];
    return s;
}

// The file components are separated by :, replace them to '/'
-(NSString *) unFlattenFilePath: (NSString *) component {
    NSRange r;
    NSString *s = [component copy];
    while ((r = [s rangeOfString:@"[:]" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@"/"];
    return s;
}

- (NSData *) fileData: (NSString *) pathKey
{
    NSString *imagePath = [self filePath:pathKey];

    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    
    
    if (data == nil) {
        // we must remove this entry as the file is gone
        [_filesByUrlList removeObjectForKey:pathKey];
        return nil;
    }
    return data;
    
}

- (NSString *) filePath: (NSString *) pathKey
{
    NSString *imagePath = [_filesByUrlList objectForKey:pathKey];
    if (imagePath) {
        // Modify the basePath to remove the application Path (on Simulator it keeps changing)
        NSString *appSavePath = [Utilities applicationSavePath];
        NSRange index = [imagePath rangeOfString:appSavePath];
        if (index.location != 0) {
            imagePath = [appSavePath stringByAppendingString: imagePath];
        }
        // Make sure that it exists, if not, we should remove this because the entry is removed...
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:imagePath]) {
            // remove this entry
            [_filesByUrlList removeObjectForKey:pathKey];
            return nil;
        }

    }
    
    return imagePath;

}

- (NSString *) mapFilePath: (NSString *) pathKey inCacheZone: (BOOL) cacheZone
{
    NSString *root;
    NSString *pathKeyToUse;
    if (cacheZone) {
        root = [AppDelegate cacheRoot];
        pathKeyToUse = [self flattenFilePath: pathKey];
    } else {
        root = [AppDelegate pictRoot];
        pathKeyToUse = [self unFlattenFilePath:pathKey];
    }
    return [root stringByAppendingPathComponent:pathKeyToUse];
    
}

- (BOOL) fileExists: (NSString *) pathKey inCacheZone: (BOOL) cacheZone
{
    NSString *basePath = [self mapFilePath:pathKey inCacheZone:cacheZone];
#ifdef CACHE_DEBUG
    DLog(@"checking the %@ file [%@]: %@", cacheZone? @"CACHE" : @"STASH", basePath, pathKey);
#endif
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:basePath];
    
}

- (BOOL) clone: (NSString *) file withDictionary: (NSDictionary *) dict
{
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    CacheManager *cm = [AppDelegate cacheManager];
    NSString *fullpath = [cm stashData:jsonData forFile:file];
#ifdef CACHE_DEBUG

    DLog(@"result=%@", fullpath);
#endif
    
    return (fullpath!=nil);
    
}

- (NSString *) cacheData: (NSData *) data forFile: (NSString *) pathKey
{
    return [self cacheStashData:data inRoot:[AppDelegate cacheRoot] forFile:pathKey inZone: YES];
}

- (NSString *) stashData : (NSData *) data forFile: (NSString *) pathKey
{
    return [self cacheStashData:data inRoot:[AppDelegate pictRoot] forFile:pathKey inZone: NO];
}


- (NSString *) cacheStashData: (NSData *) data inRoot: (NSString *) root forFile: (NSString *) pathKey inZone: (BOOL) cacheZone
{
    // Write the file in the local file system...

#if 0
    NSString *basePath;
    if (cacheZone) {
        basePath = [root stringByAppendingPathComponent: [self flattenFilePath: pathKey]];
    } else {
        NSString *path = [self unFlattenFilePath:pathKey];
        basePath = [root stringByAppendingString:path];
    }
#ifdef CACHE_DEBUG
    DLog(@"%@ing the file [%@]: %@", cacheZone? @"Cach" : @"Stash", basePath, pathKey);
#endif
#endif
    NSString *basePath = [self mapFilePath:pathKey inCacheZone:cacheZone];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL created;
    
    // Overwrite the file...
    NSError *err = nil;
    if ([fileManager fileExistsAtPath:basePath]) {
        [fileManager removeItemAtPath:basePath error:&err];
        if (err) {
            DLog(@"CacheStashData (%@): Error removing existing file: %@", pathKey, err);
        }
    }
    /*if (![fileManager fileExistsAtPath:basePath]) */ {
        // Check if the directory exists
        NSString *dir = [basePath stringByDeletingLastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:dir
                                           withIntermediateDirectories:YES attributes:nil error:&err]) {
                DLog(@"cacheStashData (%@): Error creating directory: %@", pathKey, err);
                return nil;
            }
        }

    }
    created = [fileManager createFileAtPath:basePath contents:data attributes:nil];
    
    if (!created) return nil;   // Error
    
    // IMPORTANT
    // Modify the basePath to remove the application Path (on Simulator it keeps changing)
    NSString *appSavePath = [Utilities applicationSavePath];
    NSRange index = [basePath rangeOfString:appSavePath];
    NSString *relativePath = basePath;
    if (index.location == 0) {
        relativePath = [basePath substringFromIndex:(index.location+index.length)];
    }
    
    
//    [self sync];    // optimize this with the cron manager for Cache
    @synchronized(_filesByUrlList) {
        [_filesByUrlList setObject:relativePath forKey:pathKey];
        _syncNeeded = YES;
    }
    
    return basePath;
}

#pragma mark - Folders Being Cached
// Folders being Cached
- (id) findFolderBeingCachedByName: (NSString *) name
{
    id item;
    if ((item = [_foldersBeingCachedList objectForKey:name]) != nil) {
        return item;
    } else {
        return nil;
    }
}

- (BOOL) removeFolderBeingCachedByName: (NSString *) name
{
    if ([_foldersBeingCachedList objectForKey:name]) {
        [_foldersBeingCachedList removeObjectForKey:name];
        [self sync];
#ifdef NOTNOW
        [self triggerCaching];  // trigger the changed condition for the worker thread
#endif
        return TRUE;
    } else {
        return FALSE;
    }
}

- (void) addFolderBeingCached: (id) item forName: (NSString *) name
{
    [_foldersBeingCachedList setObject: item forKey: name];
    [self sync];
#ifdef NOTNOW
    [self triggerCaching];  // trigger the changed condition for the worker thread
#endif
    
}

#pragma mark - Net Connection and Downloads - does not hit the server if not needed
- (void)downloadImageWithURL:(NSURL *)url withPath: (NSString *) pathKey completionBlock:(void (^)(BOOL succeeded, UIImage *image, NSString *errorString))completionBlock
{
    //
    // If the cache has the file, then return it
    //
    
    if ([self fileExistsInCache: pathKey]) {
        // Load up the image and return the reference
        NSData *data = [self fileData: pathKey];
        if (data) {
            completionBlock(YES,[UIImage imageWithData: data], nil);
            return;
        }
    }
    __weak CacheManager *weakSelf = self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   // Tuck the data to the Cache...
                                   [weakSelf cacheData: data forFile: pathKey];
                                   
                                   
                                   // if the path key has JPG in it try this..
#ifdef CACHE_DEBUG
                                   DLog(@"Pathkey: %@", pathKey);
#endif
                                   
                                   NSDictionary *properties = [weakSelf logMetaDataFromData:data];
                                   NSString *extension = [Utilities extensionFromName:pathKey];
                                   if (IS_EQUAL(extension, @"jpg") && (properties != nil)) {
                                       NSString *basename = [Utilities basenameWithoutExtension:pathKey extension:extension];
                                       NSString *exifPathKey = [basename stringByAppendingString:EXIF_FILE_UTI];
                                       NSError *error;
                                       NSData *jsonData = [NSJSONSerialization dataWithJSONObject: properties
                                                                                          options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                                            error:&error];
                                       
                                       [weakSelf cacheData:jsonData forFile:exifPathKey];
                                       properties = nil;
                                       
                                   }
                                   

                                   UIImage *image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
                                   completionBlock(YES,image, nil);
                               } else{
                                   NSString *errorMessage;
                                   if ([error code] == kCFURLErrorNotConnectedToInternet) {
                                       errorMessage = @"No Connection to Internet";
                                   } else {
                                       errorMessage = [error localizedDescription];
                                   }
                                   completionBlock(NO, nil, errorMessage);
                               }
                           }];
}

- (void)downloadFileWithURL:(NSURL *)url withPath: (NSString *) pathKey completionBlock:(void (^)(BOOL succeeded, NSData *filedata, NSString *errorString))completionBlock
{
    //
    // If the cache has the file, then return it
    //
    //    CacheManager *cm = [AppDelegate sharedDelegate].cacheManager;
    
    //    NSString *pathKey = [NSString stringWithFormat:@"%@:%@", self.root, fileName];
    
    if ([self fileExistsInCache: pathKey]) {
        // Load up the image and return the reference
        NSData *data = [self fileData: pathKey];
        if (data) {
            completionBlock(YES, data, nil);
            return;
        }
    }
    __weak CacheManager *weakSelf = self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   // Tuck the data to the Cache...
                                   [weakSelf cacheData: data forFile: pathKey];
                                   completionBlock(YES, data, nil);
                               } else{
                                   NSString *errorMessage;
                                   if ([error code] == kCFURLErrorNotConnectedToInternet) {
                                       errorMessage = @"No Connection to Internet";
                                   } else {
                                    errorMessage = [error localizedDescription];
                                   }
                                   completionBlock(NO,nil, errorMessage);
                               }
                           }];
}

#pragma mark - Location Caching
// returns the array of Placemarks objects [CLPlacemark] - Given a location
- (NSDictionary *) locationPlacemarks: (CLLocationCoordinate2D) location
{
    NSString *key = [NSString stringWithFormat:@"%f:%f", location.latitude, location.longitude];
    NSDictionary *dict = [self.locationToPlacemarks objectForKey:key];
    return dict;
}

- (void) setLocationPlacemark: (NSDictionary *) placemarkDict forLocation: (CLLocationCoordinate2D) location
{
    NSString *key = [NSString stringWithFormat:@"%f:%f", location.latitude, location.longitude];
    
    if( [NSJSONSerialization isValidJSONObject:placemarkDict]) {

        @synchronized(self.locationToPlacemarks) {
            [self.locationToPlacemarks setObject: placemarkDict forKey:key];
            NSArray *arealist = [placemarkDict objectForKey:@"areaofinterest"];
            if (arealist) {
                for (NSString *poi in arealist) {
                    if ([_areaOfInterestList indexOfObject:poi] == NSNotFound) {
                        [_areaOfInterestList addObject:poi];
                    }
                }
            }
        }
    } else {
        DLog(@"Problem with the placemark [%@], object=%@", key, placemarkDict);
    }
    
//    if ([self.locationToPlacemarks count] > 2200) {
//        DLog(@"%d: placemarks - count location: [%f:%f]", [self.locationToPlacemarks count], location.latitude, location.longitude);
//    }
    
    _syncNeeded = YES;
}

- (CLLocation *) locationFromString: (NSString *) locationString
{
    NSArray *items = [locationString componentsSeparatedByString: @":"];
    if ([items count] != 2) {
        return nil;
    }
    CGFloat latitude = [items[0] floatValue];
    CGFloat longitude = [items[1] floatValue];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    return location;

}
- (CLLocation *) locationForAddress: (NSString *) address
{
    
    
    NSDictionary *dict = [self.addressToLocations objectForKey:[address lowercaseString]];
    NSString *locationString;
    if (!dict || !(locationString = [dict objectForKey:@"location"])) return nil;
    
    return [self locationFromString:locationString];
    
    
}

- (void) setLocation: (CLLocation *) location forAddress: (NSString *) address
{
    [self.addressToLocations setObject:@{
                                         @"timestamp" : [NSString stringDateFromDate:[NSDate date]],
                                         @"location" : [NSString stringWithFormat:@"%f:%f", location.coordinate.latitude, location.coordinate.longitude]
                                         } forKey:[address lowercaseString]];
    _syncNeeded = YES;
}


#pragma mark - Location and Geocoding
- (BOOL) isMapLocationZero: (CLLocationCoordinate2D) location
{
    return((location.latitude == 0.0) && (location.longitude == 0.0));
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Worker thread to manage cache
- (void) startWorker
{
    _rebuildPhotosCache = YES;

    // give some time for the UI to do its thing before starting this
    [NSThread sleepForTimeInterval:(5)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self startBuiltinWorker];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        [self syncWorker];

    });

#ifdef NOTNOW
    // Start working now
    // start with the thread locked, update the boolean var
    self.lock = YES;
    
    // create the NSCondition instance
    self.condition = [[NSCondition alloc]init];
    
    // create the thread and start
    self.aThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadLoop) object:nil];
    [self.aThread start];
    
    // trigger the caching once
    [self triggerCaching];
#endif
    
}

// Do this on a low priority basis - every 30 seconds or so, it will have a low overhead if no syncing is required
- (void) syncWorker
{
        while (YES) {
            @synchronized(_filesByUrlList) {
                if (_syncNeeded ) {
                    if (_rebuildPhotosCache) {
                        
                        DLog(@"Did not Sync by the SyncWorker");
                    } else {
                        [self sync];
#ifdef CACHE_DEBUG
                        DLog(@"Sync'ed by the SyncWorker");
#endif
                        _syncNeeded = NO;
                    }
                }
                
            }
            [NSThread sleepForTimeInterval:(30)];
        }
    
}

#define BUILTIN_DEBUG 1

#ifdef BUILTIN_DEBUG
#define CONCURRENT_COUNT    1
#else
#define CONCURRENT_COUNT    1   // For now - not sure of the behavior
#endif

//static NSTimeInterval bgtime;

- (void) startBuiltinWorker
{
    // The bulk of our work here is going to be loading the files and looking up metadata
    // Thus, we see a major speed improvement by loading multiple photos simultaneously
    //
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    // We also start the background trick to make sure that we are keeping the background work alive
#ifdef TRACK_LOCATION
    [[MoLocationManager instance] startTrackingLocation];
#endif
    
    while (YES) {
        
        if (_rebuildPhotosCache) {
            _builtinPhotosQueue = [[NSOperationQueue alloc] init];
            [_builtinPhotosQueue setMaxConcurrentOperationCount: CONCURRENT_COUNT];
            
            PHFetchResult *assetsFetchResult;
            
            
            // NOTE: Optimization
            // It will be good to have the options to fetch only those images that changed since the last update
            // Unfortunately can't see a way to get the predicate to do that.  So brute force to getting everything...
            //
            assetsFetchResult = [PHAsset fetchAssetsWithOptions:nil];
#ifdef CACHE_DEBUG

            DLog(@"Cache Builtin Update count: %ld", (unsigned long)[assetsFetchResult count]);
#endif
            
#ifdef USE_ASSETLIBRARY
            if (_assetDictionary == nil) {
                _assetDictionary = [NSMutableDictionary dictionaryWithDictionary: @{@"timestamp" : [NSString stringDateFromDate:[NSDate date]]}];
            }
#endif
            
            
            
            const int64_t kDefaultTimeoutLengthInNanoSeconds = 5000000000; // 5 Seconds
            uint64_t	startTime  = mach_absolute_time();
            _geocoderLock = [NSNumber numberWithInt:0];
            _assetUpdateList = [[NSMutableArray alloc] init];
            NSMutableDictionary *placemarksWorkDictionary = [[NSMutableDictionary alloc] init];
            // Loop through all the assets
            for (PHAsset *photoAsset in assetsFetchResult) {
                NSDictionary *placemarkDict = nil;
                if (![self isMapLocationZero:photoAsset.location.coordinate]) {
#ifdef CACHE_DEBUG
                    DLog(@">>>>%@ - %f:%f", photoAsset.localIdentifier, photoAsset.location.coordinate.latitude, photoAsset.location.coordinate.longitude);
#endif
                    placemarkDict = [self locationPlacemarks:photoAsset.location.coordinate];
                    if (!placemarkDict) {
                        // just need a unique list of keys
                        
                        [placemarksWorkDictionary setObject:photoAsset.location forKey:[NSString stringWithFormat:@"%f:%f",
                                                                        photoAsset.location.coordinate.latitude,
                                                                        photoAsset.location.coordinate.longitude]];
                    }
                }
#ifdef USE_ASSETLIBRARY
                if ((_assetTimestamp == nil) ||  [_assetTimestamp isEarlierThan:photoAsset.modificationDate]) {
                    
                    if (_assetTimestamp) {
                        DLog(@"Adding: %@", photoAsset.localIdentifier);
                        [_assetUpdateList addObject: photoAsset.localIdentifier];
                    }

                    [self createCacheItemForPhoto:photoAsset withPlacemark:placemarkDict];

                } else {
                    //
                   DLog(@"Skipping: %@", photoAsset.localIdentifier);
                    
                }
#endif
                
            }
#ifdef USE_ASSETLIBRARY
            [self syncToFile:_assetDictionary withPathKey:@":all.json"];
            
#ifdef CACHE_DEBUG
            uint64_t finishTime = mach_absolute_time();
            uint32_t ms = (uint32_t)DeltaMAT(startTime, finishTime);
            DLog(@"\n\nDONE ASSET CACHING: %u milliseconds\n\n", ms);
            
            
#endif
#endif
            
            
            
            //
            // ------------- Handle Locations For Fast Access
            //
            
            
            startTime = mach_absolute_time();
            
            // Placemark Retrieval
#ifdef CACHE_DEBUG

            DLog(@"Locations to Retrieve: %ld", (unsigned long)[placemarksWorkDictionary count]);
#endif
            
#ifdef DEBUG_EXTRA
            NSUInteger count = [placemarksWorkDictionary count];
#endif
            for (NSString *locationString in placemarksWorkDictionary) {
                __block CLLocation *assetLocation = placemarksWorkDictionary[locationString];
                [_builtinPhotosQueue addOperationWithBlock:
                 ^{
                     // Check the availability of the location
                     CLGeocoder *geocoder = [[CLGeocoder alloc] init];
#if 0 // DEBUG
                     CLLocation *assetLocationX = [self locationFromString: locationString];
                     DLog(@"<<<<< %f:%f", assetLocationX.coordinate.latitude, assetLocationX.coordinate.longitude);
#endif
                     
                        {
                             // Try to limit the geocoder requests - no need to wrap in the lock as it does not need to be precise
                             if ([_geocoderLock intValue] > 10) {
                                 //[NSThread sleepForTimeInterval:1]; // sleep for a second before firing the next one...
                             }
                             
                             @synchronized (_geocoderLock) {
                                 _geocoderLock = [NSNumber numberWithInt:([_geocoderLock intValue]+1)];
                             }
                             dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                             
                             [geocoder reverseGeocodeLocation:assetLocation completionHandler:
                              ^(NSArray* placemarks, NSError* error){
                                  
                                  NSDictionary *placemarkDict = [self mapToPlacemarkDict:placemarks];
                                  
                                  if (error == nil) {
                                      // Keep it for reference so we don't need to call it again
                                      [self setLocationPlacemark:placemarkDict forLocation: assetLocation.coordinate];
               
                                  } else {
                                      DLog(@"[%f:%f] >> Error (%@)", assetLocation.coordinate.latitude, assetLocation.coordinate.longitude, [error description]);
                                  }
                                  
//                                  [self createCacheItemForPhoto:photoAsset withPlacemark:placemarkDict];
                                  dispatch_semaphore_signal(semaphore);
                                  @synchronized (_geocoderLock) {
                                      _geocoderLock = [NSNumber numberWithInt:([_geocoderLock intValue]-1)];
                                  }
                                  
                              }
                              ];
                             
                             // Time out
                             dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, kDefaultTimeoutLengthInNanoSeconds);
                             if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
                                 DLog(@"%@ timed out", locationString);
                                 // Cancel this geocoder request - completion block will be called reduce the count
                                 [geocoder cancelGeocode];
                             }
#ifdef DEBUG_EXTRA
                             else {
                                 unsigned long opcount = [_builtinPhotosQueue operationCount];
                                 if ((opcount % 50) == 0) {
                                     DLog(@"Remaining OpCount to work on = %ld", opcount);
                                 }
                             }
#endif
                            
                             
                         }
                     
                     
                     
                 }];
#ifdef DEBUG_EXTRA
                count--;
                if ((count % 50) == 0) {
                    DLog(@"Remaining Count to work on = %ld", (unsigned long) count);
                    DLog(@"Number of operations count = %ld", (unsigned long)[_builtinPhotosQueue operationCount]);
                }
#endif
            }
            
#ifdef DEBUG_EXTRA
            DLog(@"Number of operations count = %ld", (unsigned long)[_builtinPhotosQueue operationCount]);
#endif
            [_builtinPhotosQueue waitUntilAllOperationsAreFinished];
            
            [self syncToFile:_locationToPlacemarks withPathKey:@":locations.json"];
            placemarksWorkDictionary = nil;
#ifdef DEBUG
            uint64_t finishTime2 = mach_absolute_time();
            uint32_t ms2 = (uint32_t)DeltaMAT(startTime, finishTime2);
            DLog(@"\n\nDONE GEOCODER OPERATIONS: %u milliseconds\n\n", ms2);
#endif

            if (_areaOfInterestList) {
                // sort it...
                [_areaOfInterestList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"items" : _areaOfInterestList}];
                [self syncToFile:dict withPathKey:@":poi.json"];
            }
            
            // Need not do it - but just in case...
            @synchronized (_geocoderLock) {
                while ([_geocoderLock intValue] > 0) {
                    // Wait for some time
                    DLog(@"Waiting on geocoder instances: %d", [_geocoderLock intValue]);
                    [NSThread sleepForTimeInterval:5];
                }
            }

#ifdef DEBUG_MORE
            // Validate the Placemarks dictionary
            
            for (NSString *locationkey in _locationToPlacemarks) {
                NSArray *placemarksarray = _locationToPlacemarks[locationkey];
                assert([placemarksarray count] != 0);
                if( ![NSJSONSerialization isValidJSONObject:placemarksarray]) {
                    DLog(@"Problem: %@", placemarksarray);
                }
            }
#endif
    
        }

        _rebuildPhotosCache = NO;   // It will be set if there is a change

        [NSThread sleepForTimeInterval:(
#ifdef DEBUG
                                        10
#else
                                        30
#endif
                                        )];

//        DLog(@"BG time remaining: %f",bgtime=[[UIApplication sharedApplication] backgroundTimeRemaining]);
    }   // Infinite Loop

}

- (NSDictionary *) updateTagsForPhoto: (PHAsset *) photoAsset withTags: (NSArray *) tags
{
    NSError *error = nil;
    NSString *pathKey = [NSString stringWithFormat:@":Photos:%@", [[photoAsset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"#SLASH#"] stringByAppendingString:TAGS_FILE_UTI]];
    NSString *basePath = [self mapFilePath:pathKey inCacheZone:NO];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:basePath error:&error];
    
    NSMutableDictionary *dict;
    
    NSArray *tagsArray;
    // First we have to read the file
    if ((!error) && (fileAttributes != nil)) {
        // Looks like the file exists, load it
        NSData *allData = [[NSData alloc]initWithContentsOfFile:basePath options:NSDataReadingMappedIfSafe error:&error];
        dict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error]];
        tagsArray = [[dict objectForKey: @"tags" ] arrayByAddingObjectsFromArray:tags];
        [dict setObject:tagsArray forKey:@"tags"];
    } else {
//        tagsArray = tags;
        dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"tags": tags}];
    }
    
    error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    __unused NSString *fullpath =  [self stashData:jsonData forFile:pathKey];

    
    return dict;
}

- (NSArray *) tagsForPhoto: (PHAsset *) photoAsset
{
    NSError *error = nil;
    NSString *pathKey = [NSString stringWithFormat:@":Photos:%@", [[photoAsset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"#SLASH#"] stringByAppendingString:TAGS_FILE_UTI]];
    NSString *basePath = [self mapFilePath:pathKey inCacheZone:NO];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:basePath error:&error];
    
    NSMutableDictionary *dict;
    
    NSArray *tagsArray = nil;
    // First we have to read the file
    if ((!error) && (fileAttributes != nil)) {
        // Looks like the file exists, load it
        NSData *allData = [[NSData alloc]initWithContentsOfFile:basePath options:NSDataReadingMappedIfSafe error:&error];
        dict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error]];
        tagsArray = [dict objectForKey: @"tags"];
    }
    return tagsArray;
}

- (NSDictionary *) mapToPlacemarkDict: (NSArray *) placemarks
{
    NSMutableDictionary *placemarkDict = [[NSMutableDictionary alloc] init];
    if (placemarks && ([placemarks count] > 0)) {
        CLPlacemark *placemark = placemarks[0]; // just use the first item, ignore the rest
        // It is not clear what elements are available - compile the list accordingly...
        if (placemark.locality) [placemarkDict setObject:placemark.locality forKey: @"city"];
        if (placemark.administrativeArea) [placemarkDict setObject:placemark.administrativeArea forKey: @"state"];
        if (placemark.country) [placemarkDict setObject:placemark.country forKey: @"country"];
        if (placemark.thoroughfare) [placemarkDict setObject:placemark.thoroughfare forKey: @"street"];
        if (placemark.subThoroughfare) [placemarkDict setObject:placemark.subThoroughfare forKey: @"streetno"];
        if (placemark.ISOcountryCode) [placemarkDict setObject:placemark.ISOcountryCode forKey: @"countrycode"];
        if (placemark.addressDictionary) [placemarkDict setObject:placemark.addressDictionary forKey: @"addressdictionary"];
        if (placemark.areasOfInterest) [placemarkDict setObject:placemark.areasOfInterest forKey: @"areaofinterest"];
        // ZIP code?
    }
    return placemarkDict;
}

- (NSDictionary *) mapPhotoAsset: (PHAsset *) photoAsset
{
    return @{
             @"timestamp" : [NSString stringDateFromDate:[NSDate date]],    // current timestamp
             @"title" : photoAsset.localIdentifier,
             @"pixelWidth": [NSNumber numberWithInteger:photoAsset.pixelWidth],
             @"pixelHeight": [NSNumber numberWithInteger:photoAsset.pixelHeight],
             @"creationDate" : [NSString stringDateFromDate:photoAsset.creationDate],
             @"modificationDate" : [NSString stringDateFromDate:photoAsset.modificationDate],
             @"location" : [NSString stringWithFormat:@"%f:%f", photoAsset.location.coordinate.latitude, photoAsset.location.coordinate.longitude]
             };
}

// Class Methods
#pragma mark - Tags Management
// Updates the tags (appends if there are existing tags already defined for this photo
+ (NSDictionary *) updateTagsForPhoto: (PHAsset *) photoAsset withTags: (NSArray *) tags
{
    NSError *error = nil;
    NSString *pathKey = [self tagsPathKey:photoAsset];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [self infoForPhoto:photoAsset]];
    // First we have to read the file
    if (dict) {
        // Looks like the file exists, combine the old entries
        // Make it unique
        NSArray *tagsArray = dict[@"tags"];
        if (tagsArray && ([tagsArray count] > 0)) {
            tagsArray = [tagsArray arrayByAddingObjectsFromArray:tags];
        } else {
            tagsArray = tags;
        }
        [dict setObject:tagsArray forKey:@"tags"];
    } else {
        dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"tags": tags}];
    }
    
    error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    __unused NSString *fullpath =  [self stashCommonData:jsonData forFile:pathKey];
    
    
    return dict;
}

// Sets the tags (overwrites the previous ones) if there are existing tags already defined for this photo
+ (BOOL) setTagsForPhoto: (PHAsset *) photoAsset withTags: (NSArray *) tags
{
    NSError *error = nil;
    NSString *pathKey = [self tagsPathKey:photoAsset];
    NSMutableDictionary *dict;
    
    dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"tags": tags}];
    
    error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    __unused NSString *fullpath =  [self stashCommonData:jsonData forFile:pathKey];
    
    return (error==nil);
}

+ (NSArray *) tagsForPhoto: (PHAsset *) photoAsset
{
    NSError *error = nil;
    NSString *pathKey = [self tagsPathKey:photoAsset];
    NSString *basePath = [self mapFilePath:pathKey inFileSystemZone:FileSystemZoneGroupCommon];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:basePath error:&error];
    
    NSMutableDictionary *dict;
    
    NSArray *tagsArray = nil;
    // First we have to read the file
    if ((!error) && (fileAttributes != nil)) {
        // Looks like the file exists, load it
        NSData *allData = [[NSData alloc]initWithContentsOfFile:basePath options:NSDataReadingMappedIfSafe error:&error];
        dict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error]];
        tagsArray = [dict objectForKey: @"tags"];
    }
    return tagsArray;
}

+ (NSURL *) audioTagForPhoto: (PHAsset *) photoAsset
{
    NSString *pathKey = [self audioPathKey:photoAsset];
    NSString *basePath = [self mapFilePath:pathKey inFileSystemZone:FileSystemZoneGroupCommon];
    
    return [NSURL fileURLWithPath:basePath];
    
}

+ (BOOL) hasAudioTagForPhoto: (PHAsset *) photoAsset
{
    NSError *error = nil;
    NSString *pathKey = [self audioPathKey:photoAsset];
    NSString *basePath = [self mapFilePath:pathKey inFileSystemZone:FileSystemZoneGroupCommon];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:basePath error:&error];
    
    return((!error) && (fileAttributes != nil)) ;
}

+ (BOOL) setAudioTagForPhoto: (PHAsset *) photoAsset
{
    return FALSE;
}

+ (NSArray *) tagsForAllPhotos
{
    //
    // ------------- Handle Tag Files
    //
    NSArray *sortedAllTagsArray = nil;
    
#ifdef DEBUG
    uint64_t startTime = mach_absolute_time();
#endif
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dir = [[AppDelegate commonRoot] stringByAppendingPathComponent:@"Photos"];
    DLog(@"Common Dir: %@: ", dir);
    NSMutableArray *allTagsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *frequencyMap = [[NSMutableDictionary alloc] init];
    
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:dir error:&error];
    if (!error) {
#ifdef FREQUENCY_MAP
        __block NSInteger max = 0; __block NSInteger singleitemcount = 0; __block NSInteger twoitemcount = 0;
#endif
        [dirContents enumerateObjectsUsingBlock:^(NSString *fileItem, NSUInteger idx, BOOL *stop){
            NSError *error = nil;
            NSString *subdir = [dir stringByAppendingPathComponent:fileItem];
            NSDictionary *infoDict = [fileManager attributesOfItemAtPath: subdir error: &error];
            //                    DLog(@"File Item: %@: Type: %@", fileItem, [infoDict objectForKey: NSFileType]);
            if (IS_EQUAL(NSFileTypeRegular, [infoDict objectForKey: NSFileType]) && [fileItem hasSuffix:TAGS_FILE_UTI] ) {
                //                        DLog(@"Tags file: %@", fileItem);
                NSData *allData = [[NSData alloc]initWithContentsOfFile:[dir stringByAppendingPathComponent: fileItem] options:NSDataReadingMappedIfSafe error:&error];
                NSDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error]];
                NSArray *tagsArray = [dict objectForKey: @"tags"];
                for (NSString *tag in tagsArray) {
                    NSNumber *count = frequencyMap[[tag lowercaseString]];
                    if (count) {
#ifdef FREQUENCY_MAP
                        NSInteger newcount = [count integerValue]+1;
                        if (newcount > max) max = newcount;
                        frequencyMap[[tag lowercaseString]] = [NSNumber numberWithInteger:newcount];
                        if (newcount == 2) {singleitemcount--; twoitemcount++;}
                        if (newcount == 3) twoitemcount--;
#endif
                    } else {
                        frequencyMap[[tag lowercaseString]] = [NSNumber numberWithInteger:1];
                        [allTagsArray addObject:tag];
#ifdef FREQUENCY_MAP
                        singleitemcount++;
#endif
                    }
                }
            }
            
        }];
        //
#ifdef FREQUENCY_MAP
        DLog(@"Number of Unique Tags: %ld, max frequency = %ld, only once = %ld, occuring twice = %ld", [allTagsArray count], max, singleitemcount, twoitemcount);
#else
#endif
        sortedAllTagsArray = [allTagsArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        DLog(@"%ld Items\n%@", (unsigned long)[sortedAllTagsArray count], sortedAllTagsArray);
    }
#ifdef DEBUG
    uint64_t finishTime1 = mach_absolute_time();
    uint32_t ms = (uint32_t)DeltaMAT(startTime, finishTime1);
    DLog(@"\n\nDONE TAGS LOADING: %u milliseconds\n\n", ms);
    
    
#endif

    return sortedAllTagsArray;
}

+ (NSArray *) areasOfInterest
{
    NSError *error = nil;
    NSString *pathKey = @":poi.json";
    NSString *basePath = [self mapFilePath:pathKey inFileSystemZone:FileSystemZoneStash];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:basePath error:&error];
    
    NSMutableDictionary *dict;
    
    NSArray *tagsArray = nil;
    // First we have to read the file
    if ((!error) && (fileAttributes != nil)) {
        // Looks like the file exists, load it
        NSData *allData = [[NSData alloc]initWithContentsOfFile:basePath options:NSDataReadingMappedIfSafe error:&error];
        dict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error]];
        tagsArray = [dict objectForKey: @"items"];
    }
    return tagsArray;
    
}

+ (NSDictionary *) infoForPhoto: (PHAsset *) photoAsset
{
    NSError *error = nil;
    NSString *pathKey = [self tagsPathKey:photoAsset];
    NSString *basePath = [self mapFilePath:pathKey inFileSystemZone:FileSystemZoneGroupCommon];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:basePath error:&error];
    
    NSMutableDictionary *dict = nil;
    
    // First we have to read the file
    if ((!error) && (fileAttributes != nil)) {
        // Looks like the file exists, load it
        NSData *allData = [[NSData alloc]initWithContentsOfFile:basePath options:NSDataReadingMappedIfSafe error:&error];
        dict = [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error];
    }
    return dict;
    
}

+ (NSString *) tagsPathKey: (PHAsset *) photoAsset
{
    return [NSString stringWithFormat:@":Photos:%@", [[photoAsset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"#SLASH#"] stringByAppendingString:TAGS_FILE_UTI]];
}

+ (NSString *) audioPathKey: (PHAsset *) photoAsset
{
    return [NSString stringWithFormat:@":Photos:%@", [[photoAsset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"#SLASH#"] stringByAppendingString:AUDIOTAGS_FILE_UTI]];
}

//
+ (NSString *) mapFilePath: (NSString *) pathKey inFileSystemZone: (FileSystemZone) fileZone
{
    NSString *root;
    NSString *pathKeyToUse;
    switch (fileZone) {
        case FileSystemZoneCache:
            root = [AppDelegate cacheRoot];
            pathKeyToUse = [self flattenFilePath: pathKey];
            break;
        case FileSystemZoneStash:
            root = [AppDelegate pictRoot];
            pathKeyToUse = [self unFlattenFilePath:pathKey];
            break;
        case FileSystemZoneGroupCommon:
            root = [AppDelegate commonRoot];
            pathKeyToUse = [self unFlattenFilePath:pathKey];
            break;
    }
    return [root stringByAppendingPathComponent:pathKeyToUse];
    
}

// If the file path component has special chars, replace them to '#'
+ (NSString *) flattenFilePath: (NSString *) component {
    NSRange r;
    NSString *s = [component copy];
    while ((r = [s rangeOfString:@"[/:]" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@"#"];
    return s;
}

// The file components are separated by :, replace them to '/'
+ (NSString *) unFlattenFilePath: (NSString *) component {
    NSRange r;
    NSString *s = [component copy];
    while ((r = [s rangeOfString:@"[:]" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@"/"];
    return s;
}

+ (NSString *) cacheData: (NSData *) data forFile: (NSString *) pathKey
{
    return [self cacheStashData:data forFile:pathKey inZone: FileSystemZoneCache];
}

+ (NSString *) stashData : (NSData *) data forFile: (NSString *) pathKey
{
    return [self cacheStashData:data forFile:pathKey inZone: FileSystemZoneStash];
}

+ (NSString *) stashCommonData : (NSData *) data forFile: (NSString *) pathKey
{
    return [self cacheStashData:data  forFile:pathKey inZone: FileSystemZoneGroupCommon];
}


+ (NSString *) cacheStashData: (NSData *) data forFile: (NSString *) pathKey inZone: (FileSystemZone) fileZone
{
    // Write the file in the local file system...
    
#if 0
    NSString *basePath;
    if (cacheZone) {
        basePath = [root stringByAppendingPathComponent: [self flattenFilePath: pathKey]];
    } else {
        NSString *path = [self unFlattenFilePath:pathKey];
        basePath = [root stringByAppendingString:path];
    }
#ifdef CACHE_DEBUG
    DLog(@"%@ing the file [%@]: %@", cacheZone? @"Cach" : @"Stash", basePath, pathKey);
#endif
#endif
    NSString *basePath = [self mapFilePath:pathKey inFileSystemZone:fileZone];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL created;
    
    // Overwrite the file...
    NSError *err = nil;
    if ([fileManager fileExistsAtPath:basePath]) {
        [fileManager removeItemAtPath:basePath error:&err];
        if (err) {
            DLog(@"CacheStashData (%@): Error removing existing file: %@", pathKey, err);
        }
    }
    /*if (![fileManager fileExistsAtPath:basePath]) */ {
        // Check if the directory exists
        NSString *dir = [basePath stringByDeletingLastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:dir
                                           withIntermediateDirectories:YES attributes:nil error:&err]) {
                DLog(@"cacheStashData (%@): Error creating directory: %@", pathKey, err);
                return nil;
            }
        }
        
    }
    created = [fileManager createFileAtPath:basePath contents:data attributes:nil];
    
    if (!created) return nil;   // Error
    
    // IMPORTANT
    // Modify the basePath to remove the application Path (on Simulator it keeps changing)
    NSString *appSavePath = [Utilities applicationSavePath];
    NSRange index = [basePath rangeOfString:appSavePath];
    NSString *relativePath = basePath;
    if (index.location == 0) {
        relativePath = [basePath substringFromIndex:(index.location+index.length)];
    }
    
    
    //    //    [self sync];    // optimize this with the cron manager for Cache
    //    @synchronized(_filesByUrlList) {
    //        [_filesByUrlList setObject:relativePath forKey:pathKey];
    //        _syncNeeded = YES;
    //    }
    
    return basePath;
}

#ifdef USE_ASSETLIBRARY
- (NSDictionary *) createCacheItemForPhoto: (PHAsset *) photoAsset withPlacemark: (NSDictionary *) placemark
{
    
    NSDictionary *photodict = [self mapPhotoAsset:photoAsset];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:photodict ];
    
//    if (![self isMapLocationZero:photoAsset.location.coordinate]) {
//        [dict setObject:[NSString stringWithFormat:@"%f:%f", photoAsset.location.coordinate.latitude,
//                                                             photoAsset.location.coordinate.longitude] forKey:@"location"];
//    }
    
    if (placemark) {
        [dict setObject:placemark forKey:@"placemark"];
    }
    
#ifdef WRITE_INDIVIDUAL_CACHE
    NSString *pathKey = [NSString stringWithFormat:@":Photos:%@", [[photoAsset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"#SLASH#"] stringByAppendingString:SNAPTICA_FILE_UTI]];
    NSError *error = nil;
    NSString *basePath = [self mapFilePath:pathKey inCacheZone:NO];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:basePath error:&error];

    BOOL writeit = YES;
    
    if ((!error) && (fileAttributes != nil)) {
        // Looks like the file exists, compare the timestamps
        NSDate *fileModDate;
        if ((fileModDate = [fileAttributes objectForKey:NSFileModificationDate])) {
            //            DLog(@"Modification date: %@\n", fileModDate);
            if ([fileModDate isLaterThan:photoAsset.modificationDate]){
                writeit = NO;
            } else {
                // Delete the file so that there is no error
                // TODO - update the tags...
                [fileManager removeItemAtPath:basePath error:&error];
            }
        }
        
    }
    
    if (writeit) {
        // Create something quickly...
        NSError *error = nil;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        __unused NSString *fullpath = [self stashData:jsonData forFile:pathKey];
        
#ifdef DEBUG_XTRA
        DLog(@"Full path of stashed Info File: %@", fullpath);
#endif
        
    }

#endif

    
    @synchronized(_assetDictionary) {
        [_assetDictionary setObject:dict forKey: photoAsset.localIdentifier];
    }
    return dict;
}
#endif

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    _rebuildPhotosCache = YES;  // It will be picked up later
#ifdef CACHE_DEBUG
    DLog(@"Cache - Photos Library Changed");
#endif
}

#ifdef DEBUG
- (void) debugCleanup
{
#if 0
    // Use this to clean up if necessary
    for (PHAsset *photoAsset in [PHAsset fetchAssetsWithOptions:nil]) {
        NSString *pathKey = [NSString stringWithFormat:@":Photos:%@", [[photoAsset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"#SLASH#"] stringByAppendingString:SNAPTICA_FILE_UTI]];
        NSError *error = nil;
        if ([self fileExists:pathKey inCacheZone:NO]) {
            NSString *basePath = [self mapFilePath:pathKey inCacheZone:NO];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            [fileManager removeItemAtPath:basePath error:&error];
        }
        
    }
#endif
    
}
#endif

#ifdef  BUILTIN_DEBUG
extern uint64_t DeltaMAT(uint64_t then, uint64_t now)
{
    uint64_t delta = now - then;
    
    /* Get the timebase info */
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    
    /* Convert to nanoseconds */
    delta *= info.numer;
    delta /= info.denom;
    
    return (uint64_t)((double)delta / 1e6); // ms
}
#endif
@end
