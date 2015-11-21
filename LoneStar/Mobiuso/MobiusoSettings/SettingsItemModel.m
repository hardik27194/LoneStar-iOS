//
//  NavigationModel.m
//  SnapticaToo
//
//  Created by sandeep on 12/31/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import "SettingsItemModel.h"
#import "SettingsManager.h"

@implementation SettingsItemModel

@synthesize actionTitle = _actionTitle;

- (id) initWithDictionary: (NSMutableDictionary *) dict
{
    if (self = [super init]) {
        _title = [dict objectForKey:@"title"];
        _icon = [dict objectForKey:@"icon"];
        _value = [dict objectForKey:@"value"];
        _placeholder = [dict objectForKey:@"placeholder"];
        _type = [[dict objectForKey:@"type"] integerValue];
        NSArray *childrenDictArray = [dict objectForKey:@"children"];
        if (childrenDictArray) {
            NSMutableArray *children = [[NSMutableArray alloc] init];
            for (NSDictionary *childDict in childrenDictArray) {
                SettingsItemModel *child = [[SettingsItemModel alloc] initWithDictionary:childDict];
                [children addObject: child];
            }
            _children = children;
        }
        _key = [dict objectForKey:@"key"];
        _actionTitle = [dict objectForKey:@"actionTitle"];
        
        _settingsDictionary = dict; // keep this reference around to change the value if needed...
    }
    return self;
}

- (id) initWithTitle: (NSString *) title andIcon: (NSString *) icon
{
    if (self = [super init]) {
        _title = title;
        _icon = icon;
        _type = SettingsItemStyleHeader;
    }
    return self;
}

- (id) initWithTitle: (NSString *) title andIcon: (NSString *) icon andCount: (NSString *) count
{
    if (self = [self initWithTitle:title andIcon:icon]) {
        _count = count;
    }
    return self;
}

- (id) initWithTitle: (NSString *) title andIcon: (NSString *) icon andDefaultState: (BOOL) value
{
    if (self = [self initWithTitle:title andIcon:icon]) {
        _placeholder  = [NSNumber numberWithBool:value];
        _type = SettingsItemStyleBOOL;
    }
    return self;
}

- (id) initWithTitle: (NSString *) title andIcon: (NSString *) icon andDefaultText: (NSString *) value;
{
    if (self = [self initWithTitle:title andIcon:icon]) {
        _placeholder  = value;
        _type = SettingsItemStyleText;
    }
    return self;
}

- (id) initWithTitle: (NSString *) title andIcon: (NSString *) icon andDefaultEmail: (NSString *) defaultValue
{
    if (self = [self initWithTitle:title andIcon:icon andDefaultText:defaultValue]) {
        _type = SettingsItemStyleEmail;
    }
    return self;
    
}

- (void) setKey:(NSString *)key
{
    _key = key;
    // At this time load the defaults
    id val = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (val) {
        _value = val;
    }
}

- (void) setValue:(id)value
{
    _value = value;
    if (_key) {
        if (_settingsDictionary) {
            // write into the dictionary itself
            [_settingsDictionary setObject:value forKey:@"value"];
            [[SettingsManager instance] sync];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:value forKey:_key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
}

- (NSDictionary *) dictionaryWithValuesForKeys:(NSArray *)keys
{
    return @{
             @"title": _title,
             @"icon": _icon,
             @"value": _value,
             @"placeholder": _placeholder,
             @"type" : [NSNumber numberWithInteger:_type],
             @"children" : _children,
             @"key": _key,
             @"actionTitle": _actionTitle
             };
}
@end
