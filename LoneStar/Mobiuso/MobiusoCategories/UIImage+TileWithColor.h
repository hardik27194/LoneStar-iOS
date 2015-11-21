//
//  UIImage+TileWithColor.h
//  Guidelines
//
//  Created by Sandeep on 3/13/12.
//  Copyright (c) 2012 MOBIUSO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TileWithColor)

+ (UIImage*) tileWithColor:(UIColor*)color size: (CGSize) size /*using:(UIImage*)startImage*/;

@end
