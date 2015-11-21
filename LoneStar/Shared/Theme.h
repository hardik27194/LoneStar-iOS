//
//  Theme.h
//  Manage the common Theme related Choices
//
//  Created by Sandeep on 06/01/2013.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface Theme : NSObject

+ (NSUInteger) buttonHeight;

+(UIColor*)mainColor;

+(UIColor*)signatureColor;

+(UIColor*)signatureLightColor;

+(UIColor*) altColor;

+(UIColor*)backgroundColor;

+(UIColor*)neutralColor;

+(UIColor*)neutralColorLight;

+(UIColor*)redColor;

+(UIColor *) patternColor;

+(NSString*)lightFontName;

+(NSString*)ultraLightFontName;

+(NSString*)fontName;

+(NSString*)boldFontName;

+(NSString*)boldItalicFontName;

+(UIImage *) backgroundImage;

+(UIImage*)switchOnBackground;

+(UIImage*)switchOffBackground;

+(UIImage*)switchThumb;

+(UIColor*)switchTextOffColor;

+(UIColor*)switchTextOnColor;

+(UIFont*)switchFont;

+(void)styleNavigationBarWithTextColor:(UIColor*)color;

+(void)styleTabBar:(UITabBarController *)tabVC withBackgroundColor:(UIColor*)color andTextColor:(UIColor*)textColor;

#ifdef NOTNOW

+(void)styleSegmentedControlWithFontName:(NSString*)fontName andSelectedColor:(UIColor*)selectedColor andUnselectedColor:(UIColor*)unselectedColor andDidviderColor:(UIColor*)dividerColor;

+(void)styleSliderWithMaxTrackColor:(UIColor*)maxColor andMinTrackColor:(UIColor*)minColor;

+(void)styleProgressViewWithTrackColor:(UIColor*)trackColor andProgressColor:(UIColor*)progressColor;
#endif

+(void)styleBackButtonWithTextColor:(UIColor*)color;

+(void)styleBarButtonWithTextColor:(UIColor*)color;

+ (CGSize) blockPixels;

#ifdef NOTNOW
- (void)customizeTweetCell:(FeedCell *)cell;
- (void)customizeTweetProfileCell:(ProfileCell*)cell;
- (void)customizeViewiPad:(UIView *)view;
- (void)customizeView:(UIView *)view;
- (void)customizeFeediPadCell:(FeediPadCell *)cell;

- (void)customizeFeedProfileiPadCell:(ProfileiPadView*)cell ;
#endif

@end
