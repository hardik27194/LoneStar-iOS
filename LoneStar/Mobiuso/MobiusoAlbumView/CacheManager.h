//
//  CacheManager.h
//  SnapticaToo
//
//  Created by sandeep on 12/14/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoObject.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@import MapKit;
@import Photos;

#define BuiltInPhotoGallery (currentServer < 0)

#define kSettingCacheKey                            @"kSettingCacheKey"
#define kSettingFoldersListVersionKey               @"kSettingFoldersListVersionKey"
#define kSettingFoldersBeingCachedListKey           @"kSettingFoldersBeingCachedListKey"       // Flat for the list of folders being cached
#define kSettingFoldersListVersionValue             @"v1"
#define kSettingFileByURLListKey                    @"kSettingFileByURLListKey"
#define kSettingFileByNameListKey                   @"kSettingFileByNameListKey"
#define kSettingFilePerFolderListKey                @"kSettingFilePerFolderListKey"
#define kSettingFolderMetaDataListKey               @"kSettingFolderMetaDataListKey"
#define kSettingLocationToPlacemarksKey             @"kSettingLocationToPlacemarksKey"
#define kSettingAddressToLocationsKey               @"kSettingAddressToLocationsKey"
#define kSettingAreaOfInterestKey                   @"kSettingAreaOfInterestKey"

// For Cache Stuff
typedef NS_ENUM(NSInteger, FileSystemZone) {
    FileSystemZoneCache = 0,
    FileSystemZoneStash,
    FileSystemZoneGroupCommon
};

@interface CacheManager : NSObject <PHPhotoLibraryChangeObserver>

@property (retain) NSMutableDictionary   *foldersBeingCachedList;   // dictionary of Issue Items (by title)
@property (retain) NSMutableDictionary   *filesByUrlList;   // dictionary of Issue Items (by title)
@property (retain) NSMutableDictionary   *filesPerFolderCachingList;   // dictionary of Issue Items (by title)
@property (retain) NSMutableDictionary   *cacheDictionary;
@property (retain) NSMutableDictionary   *locationToPlacemarks;   // dictionary of Locations to Placemarks (giving detailed reverse geocoded address information)
@property (retain) NSMutableDictionary   *addressToLocations;   // dictionary of typed addresses resolved through Forward Geocoding...

@property (nonatomic, retain) NSOperationQueue      *builtinPhotosQueue;   // Do the work for the Builtin Photo roll priming work

#ifdef USE_ASSETLIBRARY
@property (strong)            NSMutableDictionary   *assetDictionary;
#endif
@property (strong)            NSDate                *assetTimestamp;
@property (strong)            NSMutableArray        *assetUpdateList;
@property (strong)            NSMutableArray        *areaOfInterestList;

@property (strong)            NSNumber              *geocoderLock;

// For managing cache run loop
@property (strong, nonatomic) NSCondition *condition;
@property (strong, nonatomic) NSThread *aThread;

// use this property to indicate that you want to lock _aThread
@property (nonatomic) BOOL lock;

// use the property to sync the defaults on a periodic interval
@property (assign)  BOOL   syncNeeded;

@property (assign)  BOOL   rebuildPhotosCache;

// Check if Folder name is in the list
- (id) findFolderBeingCachedByName: (NSString *) name;
- (BOOL) removeFolderBeingCachedByName: (NSString *) name;
- (void) addFolderBeingCached: (id) item forName: (NSString *) name;

// Initialize a (new) server
- (void) setupServerCacheList;

// Files being Cached
- (BOOL) purgeFileInCache: (NSString *) pathKey;
- (BOOL) purgeDirectory: (NSString *) pathKey;

- (BOOL) fileExistsInCache: (NSString *) cacheKey;
- (NSData *) fileData: (NSString *) pathKey;
// cache can be regenerated
- (NSString *) cacheData: (NSData *) data forFile: (NSString *) pathKey; // returns the full path of the cached file
- (NSString *) filePath: (NSString *) pathKey;
- (NSDictionary *) infoDirectory: (NSString *) pathKey;

// stash is the local copy (possibly updated and hence not possible to regenerate if changed)
- (NSString *) stashData : (NSData *) data forFile: (NSString *) pathKey; // returns the full path of the stashed file

// Download Image
- (void)downloadImageWithURL:(NSURL *)url withPath: (NSString *) pathKey completionBlock:(void (^)(BOOL succeeded, UIImage *image, NSString *errorString))completionBlock;
// Download File (returning data)
- (void)downloadFileWithURL:(NSURL *)url withPath: (NSString *) pathKey completionBlock:(void (^)(BOOL succeeded, NSData *filedata, NSString *errorString))completionBlock;

- (NSDictionary *) locationPlacemarks: (CLLocationCoordinate2D) location;
- (void) setLocationPlacemark: (NSDictionary *) placemarkDict forLocation: (CLLocationCoordinate2D) location;

- (CLLocation *) locationForAddress: (NSString *) address;
- (void) setLocation: (CLLocation *) location forAddress: (NSString *) address;
- (NSDictionary *) mapToPlacemarkDict: (NSArray *) placemarks;

- (NSDictionary *) updateTagsForPhoto: (PHAsset *) photoAsset withTags: (NSArray *) tags;
- (NSArray *) tagsForPhoto: (PHAsset *) photoAsset;


// Class Methods

#pragma mark - Tags Management
// Updates the tags (appends if there are existing tags already defined for this photo
+ (NSDictionary *) updateTagsForPhoto: (PHAsset *) photoAsset withTags: (NSArray *) tags;
// Sets the tags (overwrites the previous ones) if there are existing tags already defined for this photo
+ (BOOL) setTagsForPhoto: (PHAsset *) photoAsset withTags: (NSArray *) tags;

+ (NSArray *) tagsForPhoto: (PHAsset *) photoAsset;

+ (NSURL *) audioTagForPhoto: (PHAsset *) photoAsset;
+ (BOOL) hasAudioTagForPhoto: (PHAsset *) photoAsset;
+ (BOOL) setAudioTagForPhoto: (PHAsset *) photoAsset;

+ (NSArray *) tagsForAllPhotos;
+ (NSArray *) areasOfInterest;


+ (NSDictionary *) infoForPhoto: (PHAsset *) photoAsset;+ (NSString *) tagsPathKey: (PHAsset *) photoAsset;
//
+ (NSString *) mapFilePath: (NSString *) pathKey inFileSystemZone: (FileSystemZone) fileZone;
// If the file path component has special chars, replace them to '#'
+ (NSString *) flattenFilePath: (NSString *) component;
// The file components are separated by :, replace them to '/'
+ (NSString *) unFlattenFilePath: (NSString *) component;

+ (NSString *) cacheData: (NSData *) data forFile: (NSString *) pathKey;

+ (NSString *) stashData : (NSData *) data forFile: (NSString *) pathKey;


+ (NSString *) stashCommonData : (NSData *) data forFile: (NSString *) pathKey;

+ (NSString *) cacheStashData: (NSData *) data forFile: (NSString *) pathKey inZone: (FileSystemZone) fileZone;

@end
