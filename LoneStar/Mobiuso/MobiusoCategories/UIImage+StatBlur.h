//
//  UIImage+StackBlur.h
//  stackBlur
//
//  Created by Sandeep on 2/21/12.
//  Copyright (c) 2012 Mobiuso. All rights reserved.
//
//
// StatBlur implementation on iOS
//
//

#import <Foundation/Foundation.h>


@interface UIImage (StatBlur) 

//
//  Use as:
//    	source=[UIImage imageNamed:@"testIma.jpg"];
//      imagePreview.image=source;
//
//      ....
//      
//      imagePreview.image=[source statBlur: (CGFloat) floatval]; // floatval from 1 to N for progressively higher blurring radius


- (UIImage*) statBlur:(NSUInteger)radius;
- (UIImage *)imageWithGaussianBlur;


@end

