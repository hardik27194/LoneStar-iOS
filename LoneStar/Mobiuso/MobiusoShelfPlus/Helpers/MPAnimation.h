//
//  MPAnimation.h
//  EnterTheMatrix
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPAnimation : NSObject

+ (UIImage *)renderImageFromView:(UIView *)view;
+ (UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame;
+ (UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame transparentInsets:(UIEdgeInsets)insets;
+ (UIImage *)renderImageForAntialiasing:(UIImage *)image withInsets:(UIEdgeInsets)insets;
+ (UIImage *)renderImageForAntialiasing:(UIImage *)image;
+ (UIImage *)renderImage:(UIImage *)image withMargin:(CGFloat)width color:(UIColor *)color;

@end
