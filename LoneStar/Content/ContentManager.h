//
//  ContentManager.h
//  SkillsApp
//
//  Created by Harvindar Sharma on 21/01/15.
//  Copyright (c) 2015 Skyscape. All rights reserved.
//

#import <Foundation/Foundation.h>



#define CONTENT_UPDATE_NOTIFICATION @"CONTENT_UPDATED"

typedef enum  {
    ModuleTypeBuiltIn = 0,  // Standard, Retail, Server based
    ModuleTypeDownloaded,   // Custom, Downloaded (mail, flashdrive, web-link, etc)
    ModuleTypeShared,       // Public or through Groups (owned by others)
    ModuleTypeCount
} ModuleTypeId;

#define kBuiltInModule      @"Skyscape"
#define kDownloadedModule   @"Downloaded"
#define kSharedModule       @"Shared"

@interface ContentManager : NSObject

+(id)sharedManager;
-(void)checkAndUpdateContent;
#if 0
-(NSString *)getContentPathBySkillId:(NSNumber *)skillId;
#endif
-(NSString *)getNoContentFilePath;

+ (NSArray *) modulesForUser: (NSString *) user ofType: (ModuleTypeId) type;
+ (NSArray *) modulesForUser: (NSString *) user ofType: (ModuleTypeId) type InGroup:(NSString*)groupName;
- (NSString *) locateSplashFile: (NSString *) dirPath withResourceType: (NSString *) type;


+ (NSDictionary *) getJSONObjectFromContentOfFile:(NSString*)JSONFileName;

@end
