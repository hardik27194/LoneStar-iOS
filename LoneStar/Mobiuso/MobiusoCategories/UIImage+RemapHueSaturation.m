//
//  UIImage+RemapHueSaturation.m
//  Guidelines
//
//  Created by sandeep on 9/13/12.
//  Copyright (c) 2012 Mobiuso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+RemapHueSaturation.h"

@implementation UIImage (RemapHueSaturation)

//+ (UIImage*) remap: (UIImage*) originalImage withHue: (float) hue andSaturation:(float) saturation
//{
//    
//    CIImage *beginImage = [CIImage imageWithData:UIImagePNGRepresentation(originalImage)];
//    
//    CIContext* context = [CIContext contextWithOptions:nil];
//    
//    CIFilter* hueFilter = [CIFilter filterWithName:@"CIHueAdjust" keysAndValues:kCIInputImageKey, beginImage, @"inputAngle", [NSNumber numberWithFloat:hue], nil];
//    
//    CIImage *outputImage = [hueFilter outputImage];
//    
//    CIFilter* saturationFilter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, outputImage, @"inputSaturation", [NSNumber numberWithFloat:saturation], nil];
//    
//    outputImage = [saturationFilter outputImage];
//    
//    
//    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
//    
//    
//    UIImage *processed;
//    if ( [[[UIDevice currentDevice] systemVersion] intValue] >= 4 && [[UIScreen mainScreen] scale] == 2.0 )
//    {
//        processed = [UIImage imageWithCGImage:cgimg scale:2.0 orientation:UIImageOrientationUp];
//    }
//    else
//    {
//        processed = [UIImage imageWithCGImage:cgimg];
//    }
//    
//    CGImageRelease(cgimg);
//    
//    
//    return processed;
//    
//}

@end
