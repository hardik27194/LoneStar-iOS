//
//  MoToolTip.h
//  FlashDrive
//
//  Created by sandeep on 3/13/15.
//  Copyright (c) 2015 Skyscape. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoToolTip : NSObject

@property (nonatomic, retain) id        target;   //
@property (nonatomic, retain) NSString  *name;
@property (nonatomic, retain) NSString  *message;
@property (nonatomic, retain) UIColor   *color;
@property (nonatomic, retain) UIColor   *textColor;
@property (nonatomic, retain) UIFont    *textFont;
@property (nonatomic, retain) id        delegate;
@property (nonatomic, assign) int       animation;
@property (nonatomic, assign) NSString  *geometry;

- (id) initWithDict: (NSDictionary *) dict;

@end
