//
//  UIImage+MaskImage.m
//  Guidelines
//
//  Created by Sandeep on 3/12/12.
//  Copyright (c) 2012 Mobiuso. All rights reserved.
//
/*!
 
 @class UIImage+MaskImage
 
 @discussion 
 Given a UIImage, apply another image as a mask to generate the new image (Photoshop)
 
 TODO:
 
 @history
 
 Initial version.
 
 */

#import "UIImage+MaskImage.h"

@implementation UIImage (MaskImage)

- (UIImage*) maskImage: (UIImage *) maskImage {

	CGImageRef maskRef = maskImage.CGImage; 

	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRelease(mask);

	CGImageRef masked = CGImageCreateWithMask([self CGImage], mask);
    UIImage *returnImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
	return returnImage;

}
@end
