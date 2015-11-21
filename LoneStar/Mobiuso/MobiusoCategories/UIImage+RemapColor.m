//
//  UIImage+RemapColor.m
//  Guidelines
//
//  Created by Sandeep on 3/20/12.
//  Copyright (c) 2012 Mobiuso. All rights reserved.
//
/*!
 
 @class UIImage+RemapColor
 
 @discussion 
 
 Treats an image as a mask and converts the black pixels to something else (as specified)
 
 TODO:
 
 @history
 
 Initial version.
 
 */

#import "UIImage+RemapColor.h"

@implementation UIImage (RemapColor)

#pragma mark Generate images with given fill color
// Convert the image's fill color to the passed in color
+ (UIImage*) RemapColor: (UIColor*) color maskImage: (UIImage*) startImage
{
    // Create the proper sized rect
    CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(startImage.CGImage), CGImageGetHeight(startImage.CGImage));
    
    // Create a new bitmap context
    CGContextRef context = CGBitmapContextCreate(NULL, imageRect.size.width, imageRect.size.height, 8, 0, CGImageGetColorSpace(startImage.CGImage), (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
    
    // Use the passed in image as a clipping mask
    CGContextClipToMask(context, imageRect, startImage.CGImage);
    // Set the fill color
    CGContextSetFillColorWithColor(context, color.CGColor);
    // Fill with color
    CGContextFillRect(context, imageRect);
    
    // Generate a new image
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage* newImage = [UIImage imageWithCGImage:newCGImage scale:startImage.scale orientation:startImage.imageOrientation];
    
    // Cleanup
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    
    return newImage;
}

@end
