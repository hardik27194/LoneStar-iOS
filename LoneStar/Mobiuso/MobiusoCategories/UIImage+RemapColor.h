//
//  UIImage+RemapColor.h
//  Guidelines
//
//  Created by Sandeep on 3/20/12.
//  Copyright (c) 2012 Mobiuso. All rights reserved.
//
/*!
 
 @category myCategory(myMainClass)
 
 @discussion This is a discussion.
 
 It can span many lines or paragraphs.
 
 */

#import <UIKit/UIKit.h>

@interface UIImage (RemapColor)

+ (UIImage*) RemapColor: (UIColor*) color maskImage: (UIImage*) startImage;

@end
