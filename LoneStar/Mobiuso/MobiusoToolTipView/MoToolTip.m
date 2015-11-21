//
//  MoToolTip.m
//  FlashDrive
//
//  Created by sandeep on 3/13/15.
//  Copyright (c) 2015 Skyscape. All rights reserved.
//

#import "MoToolTip.h"

@implementation MoToolTip

- (instancetype) initWithDict: (NSDictionary *) dict
{
    if (self = [super init]) {
        _target = [dict valueForKey:@"target"];
        _name = [dict valueForKey:@"name"];
        _color = [dict valueForKey:@"color"];
        _textColor = [dict valueForKey:@"textColor"];
        _textFont = [dict valueForKey:@"textFont"];
        _message = [dict valueForKey:@"message"];
        _delegate = [dict valueForKey:@"delegate"];
        _animation = [[dict valueForKey:@"animation"] intValue];
        _geometry = [dict valueForKey:@"geometry"];
        
        if (!_textColor) {
            _textColor = [UIColor whiteColor];
        }
    }
    return self;
}

@end
