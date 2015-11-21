//
//  TestTOC.m
//  LoneStar
//
//  Created by sandeep on 11/16/15.
//  Copyright © 2015 Medpresso. All rights reserved.
//

#import "TestTOC.h"
#import "SettingsItemModel.h"

@implementation TestTOC

// Flatten and create references for SettingsItemModel
+ (NSMutableArray *) populateItems: (NSString *) filePath
{
    NSError *error;
    // Find the necessary file or the supplied file
//    NSString *basePath = [self mapFilePath:pathKey inCacheZone:NO];
    
    NSString *basePath = [[NSBundle mainBundle] pathForResource: filePath ofType:nil inDirectory:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // Looks like the file exists, load it
    NSData *allData = [[NSData alloc]initWithContentsOfFile:basePath options:NSDataReadingMappedIfSafe error:&error];
    NSDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:&error]];

    
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    /*
     @"title": SETTING_ABOUT,
     @"icon": @"menu-about-72.png",
     @"type" : [NSNumber numberWithInteger:SettingsItemStyleHeader],
     @"children" : @[aboutProduct, aboutSupport,
     aboutRateUs, aboutFacebook, aboutUs],
     @"key": kSettingGroupAboutKey,
*/
    if (dict) {
        // Grab the items and set up
        NSArray *sourceArray = dict[@"items"];
        for (NSDictionary *dict in sourceArray) {
            // Create an entry
            NSMutableDictionary *newItem = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                             @"title" : dict[@"Name"],
                                                                                             @"icon"  : @"menu-cache2-72.png",
                                                                                             @"type" : [NSNumber  numberWithInteger: SettingsItemStyleHeader]
                                                                                             }];
            NSArray *items = dict[@"items"];
            NSMutableArray *childArray = [[NSMutableArray alloc] init];
            for (NSDictionary *childDict in items) {
                NSMutableDictionary *newChildItem = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                 @"title" : childDict[@"Name"],
                                                                                                 @"icon"  : @"menu-cache2-72.png",
                                                                                                 @"iconName" : @"",
                                                                                                @"type" : [NSNumber numberWithInteger:SettingsItemStyleWebRef]
                                                                                                 }];
                
                [childArray addObject: newChildItem];
            }
            newItem[@"children"] = childArray;
            
            [itemsArray addObject:[[SettingsItemModel alloc] initWithDictionary: newItem]];
            
        }
    }
    return itemsArray;
    
}



@end
