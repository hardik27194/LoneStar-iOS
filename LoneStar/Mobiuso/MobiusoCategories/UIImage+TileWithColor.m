//
//  UIImage+TileWithColor.m
//  Guidelines
//
//  Created by Sandeep on 3/13/12.
//  Copyright (c) 2012 Mobiuso. All rights reserved.
//
/*!
 
 @class UIImage+TileWithColor
 
 @discussion 
 
 Given a rectangle, return a tile image in the specified color.  Useful to frame areas to create backgrounds.
 
 TODO:
 
 @history
 
 Initial version.
 
 */

#import "UIImage+TileWithColor.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CGColorSpace.h>

@implementation UIImage (TileWithColor)

#pragma mark Generate images with given fill color
// Convert the image's fill color to the passed in color 
+ (UIImage*) tileWithColor:(UIColor*)color size: (CGSize) size /*using:(UIImage*)startImage*/
{
    // Create the proper sized rect
    CGRect imageRect = CGRectMake(0, 0, size.width, size.height);
    
    // Create a new bitmap context
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, rgbColorSpace,            
                                                                        (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    // Fill with color
    CGContextFillRect(context, imageRect);
    
    // Generate a new image
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage* newImage = /* [UIImage imageWithCGImage:newCGImage scale:self.scale orientation:self.imageOrientation]; */
                        [UIImage imageWithCGImage: newCGImage];
    // Cleanup
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    
    return newImage;
}
@end
