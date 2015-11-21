//
//  ContentManager.m
//  SkillsApp
//
//  Created by Harvindar Sharma on 21/01/15.
//  Copyright (c) 2015 Harvindar Sharma. All rights reserved.
//

#import "ContentManager.h"
#import "ZipArchive.h"
#import "AppDelegate.h"
#import "Utilities.h"
#if 0
#import "DataManager.h"
#import "JSON/JSON.h"
#endif

@interface ContentManager ()

@property (nonatomic, retain) NSArray *builtinModules;
@property (nonatomic, retain) NSArray *downloadedModules;
@property (nonatomic, retain) NSArray *sharedModules;


@end

@implementation ContentManager

static ContentManager *sharedContentManager = nil;

+ (id)sharedManager {
    @synchronized(self) {
        if (sharedContentManager == nil)
            sharedContentManager = [[self alloc] init];
    }
    return sharedContentManager;
}


+ (NSArray *) modulesForUser: (NSString *) user ofType: (ModuleTypeId) type InGroup:(NSString*)groupName
{
    
    switch (type) {
        case ModuleTypeBuiltIn:
            // user is ignored in type of module (for now - may be we can offer the samples only as the anonymous user)
            return [sharedContentManager builtinModulesInGroup:groupName];
            
        case ModuleTypeDownloaded:
        {
            if (sharedContentManager.downloadedModules == nil) {
                sharedContentManager.downloadedModules =  [self downloadedModulesForUser:user];
            }
            return sharedContentManager.downloadedModules;
        }
            
        case ModuleTypeShared: // TBD
        default:
            break;
    }
    return nil;
    
}


+ (NSArray *) modulesForUser: (NSString *) user ofType: (ModuleTypeId) type
{
    
    switch (type) {
        case ModuleTypeBuiltIn:
            // user is ignored in type of module (for now - may be we can offer the samples only as the anonymous user)
            return [sharedContentManager builtinModules];
            
        case ModuleTypeDownloaded:
        {
            if (sharedContentManager.downloadedModules == nil) {
                sharedContentManager.downloadedModules =  [self downloadedModulesForUser:user];
            }
            return sharedContentManager.downloadedModules;
        }
            
        case ModuleTypeShared: // TBD
        default:
            break;
    }
    return nil;
    
}

+ (NSArray *) downloadedModulesForUser: (NSString *) user
{
    NSMutableArray *moduleArray = [[NSMutableArray alloc] initWithCapacity:1];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    // First tally any modules downloaded by anonymous user - they are available to all
    NSString *downloadsFolder = [[AppDelegate downloadsFolder] stringByAppendingPathComponent:MODULES_FOLDER] ;
    NSArray *downloadedModules = [fileManager contentsOfDirectoryAtPath: downloadsFolder error:&error];
    if (!error && ([downloadedModules count] > 0)) {
        for (NSString *module in downloadedModules) {
            
            if ([module  isEqual: @".DS_Store"]||[module  isEqual: @"__MACOSX"]) {
                continue;
            }
            NSString *moduleId = [module lastPathComponent];
            NSDictionary *moduleInfo = [self moduleInfoDict:[downloadsFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",module]]];
            if (moduleInfo == nil) {
                
            }
            else{
                NSString *displayName = [moduleInfo objectForKey:@"moduleName"];
                NSString *authorName = [moduleInfo objectForKey:@"author"];
                NSString *timestamp = [moduleInfo objectForKey:@"timestamp"];
                NSString *color = [moduleInfo objectForKey:@"color"];
                NSString *icon = [moduleInfo objectForKey:@"icon"];
                NSString *code = [moduleInfo objectForKey:@"signoffcode"];
                DLog(@"Module: %@ - name=%@, author=%@, timestamp=%@", module, displayName, authorName, timestamp);
                // Avoid __MACOSX or similar items
                if (![module hasPrefix:@"__"]) {
                    NSDictionary *moduleDict = @{ @"name" : [module lastPathComponent],
                                                  @"type" : @"Downloaded",
                                                  @"source" : @"device",
                                                  @"author" : authorName?authorName:@"n/a",
                                                  @"title" : displayName? displayName:moduleId,
                                                  @"timestamp" : timestamp?timestamp:@"",
                                                  @"color" : color?color:@"",
                                                  @"icon" : icon?icon:@"",
                                                  @"signoffcode":code?code:@"1234"
                                                  };
                    [moduleArray addObject: moduleDict];
            }
            }
        }
    }
    // Now, add the modules for the user
//    if (user) {
//        // Currently not defined -
//        NSString *downloadsFolder = [[AppDelegate downloadsFolder]  stringByAppendingPathComponent:MODULES_FOLDER];
//        NSArray *downloadedModules = [fileManager contentsOfDirectoryAtPath:downloadsFolder error:&error];
//        if (!error && ([downloadedModules count] > 0)) {
//            for (NSString *module in downloadedModules) {
//                NSString *moduleId = [module lastPathComponent];
//                NSDictionary *moduleInfo = [self moduleInfoDict:[downloadsFolder stringByAppendingPathComponent:module]];
//                NSString *displayName = [moduleInfo objectForKey:@"moduleName"];
//                NSString *authorName = [moduleInfo objectForKey:@"author"];
//                NSString *timestamp = [moduleInfo objectForKey:@"timestamp"];
//                NSString *color = [moduleInfo objectForKey:@"color"];
//                NSString *icon = [moduleInfo objectForKey:@"icon"];
//                NSString *code = [moduleInfo objectForKey:@"signoffcode"];
//                DLog(@"Module: %@ - name=%@, author=%@, timestamp=%@", module, displayName, authorName, timestamp);
//                
//                
//                DLog(@"Module: %@ - name=%@, author=%@", module, displayName, authorName);
//                NSDictionary *moduleDict = @{ @"name" : moduleId,
//                                              @"type" : @"Downloaded",
//                                              @"author" : @"Unknown",   // Find out the Publisher information
//                                              @"title" : displayName? displayName:moduleId,
//                                              @"author" : authorName?authorName:@"Skyscape",
//                                              @"timestamp" : timestamp?timestamp:@"",
//                                              @"color" : color?color:@"",
//                                              @"icon" : icon?icon:@"",
//                                              @"signoffcode":code?code:@"1234",
//                                              @"source" : @"device"
//                                              };
//                [moduleArray addObject: moduleDict];
//            }
//        }
//    }
    return moduleArray;
    
}

+ (NSDictionary *) moduleInfoDict: (NSString *) path
{
    NSString *modulepath = [path stringByAppendingPathComponent:@"module.json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:modulepath];
    NSError *error = nil;
    
    // Get JSON data into a Foundation object
    if (jsonData == nil) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    return dict;
}

- (void) reset
{
    _builtinModules = nil;
    _downloadedModules = nil;
    _sharedModules = nil;
}

- (NSArray *) builtinModulesInGroup:(NSString*)groupName
{
    //if (_builtinModules == nil) {
        NSArray *modules = [[NSBundle mainBundle] pathsForResourcesOfType:nil
                                                              inDirectory: MODULES_FOLDER];
        NSMutableArray *moduleArray = [[NSMutableArray alloc] initWithCapacity:1];
        
        NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fullPath = [contentRootPath stringByAppendingPathComponent:DO_NOT_BACKUP_FOLDER];
        
        
        NSString *destinationFile = [NSString stringWithFormat:@"%@/modules.json", fullPath];
        
        NSData *jsonData = [NSData dataWithContentsOfFile:destinationFile];
        NSError *error = nil;
        
        if (jsonData == nil) {
            return nil;
        }
        
        // Get JSON data into a Foundation object
        NSDictionary *modulesJSONFile = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    NSDictionary *groupInfo = [modulesJSONFile objectForKey:@"GroupInfo"];
    
    for (int currentGroup = 0; currentGroup < [groupInfo count]; currentGroup++) {
        
        NSMutableArray *modulesArray = [NSMutableArray new];
        
        NSDictionary *groupDetails = [groupInfo objectForKey:[NSString stringWithFormat:@"%@", [[groupInfo allKeys] objectAtIndex:currentGroup ]]];
        
        NSString *currentGroupName = [groupDetails objectForKey:@"GroupName"];
        if (!([groupName isEqual:currentGroupName])) {
            continue;
        }
        NSDictionary *moduleIdList = [groupDetails objectForKey:@"ModuleID"];
        
        
        for (int moduleNumber = 0; moduleNumber < [moduleIdList count]; moduleNumber++) {
            NSString *currentModuleID = [[moduleIdList allKeys] objectAtIndex:moduleNumber];
            [modulesArray addObject:currentModuleID];
        }
        modules = [modulesArray copy];
        
        // Get JSON data into a Foundation object
        
        
        // Each subdirectory is a module...
        for (NSString *moduleId in modules) {
            // Check if the module file exists, if not extract
            
            NSLog(@"%@", moduleId);
            NSFileManager *fm = [NSFileManager defaultManager];
            
            
            //NSString *moduleId = [module objectForKey:@"moduleID"];
            NSString *modulePath = [AppDelegate pathForModuleDirectory: moduleId forModuleType:ModuleTypeBuiltIn];
            NSString *path = [modulePath stringByAppendingPathComponent:@"module.json"];
            
            
            if (![fm fileExistsAtPath:path]) {
                // Extract first
                [self extractContentFromMainBundle:moduleId];
            }
            NSDictionary *moduleInfo = [ContentManager moduleInfoDict:modulePath];
            if (moduleInfo == nil) {
                
            }
            else{
                NSString *displayName = [moduleInfo objectForKey:@"title"];
                NSString *authorName = [moduleInfo objectForKey:@"author"];
                NSString *timestamp = [moduleInfo objectForKey:@"timestamp"];
                NSString *color = [moduleInfo objectForKey:@"color"];
                NSString *icon = [moduleInfo objectForKey:@"icon"];
                NSString *code = [moduleInfo objectForKey:@"signoffcode"];
                DLog(@"Module: %@ - name=%@, author=%@", moduleId, displayName, authorName);
                
                
                NSDictionary *moduleDict = @{ @"name" : moduleId,
                                              @"title" : displayName? displayName:moduleId,
                                              @"type" : @"BuiltIn",
                                              @"author" : authorName?authorName:@"Skyscape",
                                              @"timestamp" : timestamp?timestamp:@"",
                                              @"color" : color?color:@"",
                                              @"icon" : icon?icon:@"",
                                              @"signoffcode":code?code:@"1234",
                                              @"source" : @"bundle"
                                              };
                [moduleArray addObject: moduleDict];
            }
            
        }
    }
        _builtinModules = moduleArray;
    //}
    return _builtinModules;
}

- (NSArray *) builtinModules
{
    //if (_builtinModules == nil) {
    NSArray *modules = [[NSBundle mainBundle] pathsForResourcesOfType:nil
                                                          inDirectory: MODULES_FOLDER];
    NSMutableArray *moduleArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [contentRootPath stringByAppendingPathComponent:DO_NOT_BACKUP_FOLDER];
    
    
    NSString *destinationFile = [NSString stringWithFormat:@"%@/modules.json", fullPath];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:destinationFile];
    NSError *error = nil;
    
    if (jsonData == nil) {
        return nil;
    }
    
    // Get JSON data into a Foundation object
    NSDictionary *modulesJSONFile = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    NSDictionary *groupInfo = [modulesJSONFile objectForKey:@"GroupInfo"];
    
    for (int currentGroup = 0; currentGroup < [groupInfo count]; currentGroup++) {
        
        NSMutableArray *modulesArray = [NSMutableArray new];
        
        NSDictionary *groupDetails = [groupInfo objectForKey:[NSString stringWithFormat:@"%@", [[groupInfo allKeys] objectAtIndex:currentGroup ]]];
        
        NSDictionary *moduleIdList = [groupDetails objectForKey:@"ModuleID"];
        
        
        for (int moduleNumber = 0; moduleNumber < [moduleIdList count]; moduleNumber++) {
            NSString *currentModuleID = [[moduleIdList allKeys] objectAtIndex:moduleNumber];
            [modulesArray addObject:currentModuleID];
        }
        modules = [modulesArray copy];
        
        // Get JSON data into a Foundation object
        
        
        // Each subdirectory is a module...
        for (NSString *moduleId in modules) {
            // Check if the module file exists, if not extract
            
            NSLog(@"%@", moduleId);
            NSFileManager *fm = [NSFileManager defaultManager];
            
            
            //NSString *moduleId = [module objectForKey:@"moduleID"];
            NSString *modulePath = [AppDelegate pathForModuleDirectory: moduleId forModuleType:ModuleTypeBuiltIn];
            NSString *path = [modulePath stringByAppendingPathComponent:@"module.json"];
            
            
            if (![fm fileExistsAtPath:path]) {
                // Extract first
                [self extractContentFromMainBundle:moduleId];
            }
            NSDictionary *moduleInfo = [ContentManager moduleInfoDict:modulePath];
            if (moduleInfo == nil) {
                
            }
            else{
                NSString *displayName = [moduleInfo objectForKey:@"title"];
                NSString *authorName = [moduleInfo objectForKey:@"author"];
                NSString *timestamp = [moduleInfo objectForKey:@"timestamp"];
                NSString *color = [moduleInfo objectForKey:@"color"];
                NSString *icon = [moduleInfo objectForKey:@"icon"];
                NSString *code = [moduleInfo objectForKey:@"signoffcode"];
                DLog(@"Module: %@ - name=%@, author=%@", moduleId, displayName, authorName);
                
                
                NSDictionary *moduleDict = @{ @"name" : moduleId,
                                              @"title" : displayName? displayName:moduleId,
                                              @"type" : @"BuiltIn",
                                              @"author" : authorName?authorName:@"Skyscape",
                                              @"timestamp" : timestamp?timestamp:@"",
                                              @"color" : color?color:@"",
                                              @"icon" : icon?icon:@"",
                                              @"signoffcode":code?code:@"1234",
                                              @"source" : @"bundle"
                                              };
                [moduleArray addObject: moduleDict];
            }
            
        }
    }
    _builtinModules = moduleArray;
    //}
    return _builtinModules;
}

-(void)checkAndUpdateContent
{
    // Later on we will need to iterate over all the modules - for now, it will be just the default Module
    // First the default Module
    //    NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *module = [AppDelegate currentModuleId];
    NSString *contentManifestPath = [AppDelegate pathForModuleFileWithExtension:@"manifest"];
    if([[NSFileManager defaultManager] fileExistsAtPath:contentManifestPath])
    {
        NSString *pathModule = [NSString stringWithFormat: @"Modules/%@/%@", module, module];
        NSString *sourceManifestFilePath = [[NSBundle mainBundle] pathForResource: pathModule ofType:@"manifest"];
        if([self compareSourceManifest:sourceManifestFilePath toDestinationManifest:contentManifestPath])
        {
            [self extractContentFromMainBundle: module];
        }
    }
    else
    {
        [self extractContentFromMainBundle: module];
    }
}

-(void)extractContentFromMainBundle: (NSString *) module
{
    //    NSString *module = [AppDelegate currentModuleId];
    //    NSString *documentDir = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *documentDir = [AppDelegate localDataRoot:module forModuleType:ModuleTypeBuiltIn];
    NSString *bundlePath = [NSString stringWithFormat:@"Modules/%@/%@", module, module];
    NSString *sourceFilePath = [[NSBundle mainBundle] pathForResource: bundlePath ofType:@"zip"];
    if(sourceFilePath)
    {
        [self decompress:sourceFilePath toDestinationPath:documentDir];
    }
}

- (BOOL) decompress: (NSString *)zippedFilePath toDestinationPath: (NSString *) destinationPath
{
    BOOL success = NO;
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    if([zipArchive UnzipOpenFile:zippedFilePath])
    {
        
        if ([zipArchive UnzipFileTo:destinationPath overWrite:YES])
        {
            success = YES;
        }
        
    }
    return success;
}

#if 0
-(NSString *)getContentPathBySkillId:(NSNumber *)skillId
{
    NSDictionary *skillDict = [[DataManager sharedManager] getSkillsBySkillId:skillId];
    NSString *skillFileName = [skillDict objectForKey:@"fileName"];
    
    NSString *htmlPathDirectory = [AppDelegate pathForModuleDirectory];
    NSString *path = [NSString stringWithFormat:@"%@/%@.html", htmlPathDirectory, skillId];
    
    if (skillFileName && [skillFileName compare:@""] != 0) {
        path = [NSString stringWithFormat:@"%@/%@", htmlPathDirectory, skillFileName];
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        return path;
    }
    return nil;
}
#endif

-(NSString *)getNoContentFilePath
{
    NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/nodata.html",contentRootPath, [AppDelegate currentModuleId]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        return path;
    }
    return nil;
}

-(BOOL)compareSourceManifest:(NSString *)sourceManifestFilePath
       toDestinationManifest:(NSString *)destinationFilePath
{
    NSString *sourceStr = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:sourceManifestFilePath]  encoding:NSUTF8StringEncoding];
    NSString *destStr = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:destinationFilePath] encoding:NSUTF8StringEncoding] ;
    
    NSScanner *scanner = [NSScanner scannerWithString: destStr];
    unsigned long long dest, source;
    BOOL success1 = [scanner scanHexLongLong: &dest];
    scanner = [NSScanner scannerWithString: sourceStr];
    BOOL success2 = [scanner scanHexLongLong: &source];
    if (success1 && success2 && (source <= dest)) {
        return NO;
    }
    return YES;
}

- (NSString *) locateSplashFile: (NSString *) dirPath
{
    return [self locateResourceFile: dirPath resourceRootName: @"splash"
                   withResourceType: @"png"];
}

// Given the base directory (or default if dirPath = nil), find the name of the splash file if it exists
- (NSString *) locateSplashFile: (NSString *) dirPath
               withResourceType: (NSString *) type
{
    return [self locateResourceFile: dirPath resourceRootName: @"splash"
                   withResourceType: type];
}

- (NSString *) locateResourceFile: (NSString *) dirPath
                 resourceRootName: (NSString *) root
                 withResourceType: (NSString *) type
{
    
    
    
    NSString *contentRootPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [contentRootPath stringByAppendingPathComponent:DO_NOT_BACKUP_FOLDER];
    
    NSString *foundFile = [NSString stringWithFormat: @"%@/splash.png", fullPath];
    
    return foundFile;
}

+ (NSDictionary *) getJSONObjectFromContentOfFile:(NSString*)JSONFileName
{
    
#if 0
    NSString *fileContent = [self getStringFromFile:JSONFileName];
    if(fileContent == nil)
    {
        return nil;
    }
    NSDictionary *JSONObject = [fileContent JSONValue];
    if(JSONObject == nil)
    {
        return nil;
    }
    else
    {
        return JSONObject;
    }
#endif
    NSError *error;
    NSData *allData = [[NSData alloc]initWithContentsOfFile:JSONFileName options:NSDataReadingMappedIfSafe error:&error];

    return (allData? ([NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error]]) : nil);
}

+ (NSString *)getStringFromFile:(NSString *)fileName
{
    NSError *err;
    
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:[self mapFilePath:fileName] encoding:NSUTF8StringEncoding error: &err] ;
    return fileContent;
}

+ (NSString *) mapFilePath: (NSString *) fileName
{
    NSInteger pos = [fileName rangeOfString: [NSString stringWithFormat: @"/"]].location;
    if ( (pos == NSNotFound) || pos != 0) {
        return [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"/%@",fileName] ofType:nil];
    } else {
        return fileName;
    }
  
}

@end
