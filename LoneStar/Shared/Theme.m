//
//  Theme.m
//
//  Created by Sandeep on 06/01/2013.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//

#import "Theme.h"
#import "Utilities.h"

#import "UIImage+RemapColor.h"


@implementation Theme


+ (NSUInteger) buttonHeight {
    CGFloat ht = [Utilities applicationFrame].size.height;
    return (ht < 500) ? 32 : 40; // f04445 d94141
}

+(UIColor*)mainColor{
    return COLORFROMHEX(0xfff46366); // COLORFROMHEX(0xff34aadc)
}


+(UIColor*)signatureColor{
    return COLORFROMHEX(0xfff7b913); //  COLORFROMHEX(0xff34aadc);// 3f9bc5 5bb1d9 [UIColor colorWithRed:0.0 green:166.0/255 blue:124.0/255 alpha:1.0f];
}

+(UIColor*)signatureLightColor{
    return COLORFROMHEX(0xff8bd4f3);// 5bb1d9 [UIColor colorWithRed:0.0 green:166.0/255 blue:124.0/255 alpha:1.0f];
}

+(UIColor*) altColor{
    return COLORFROMHEX(0xffbfc947);
}

+(UIColor*)backgroundColor{
    return COLORFROMHEX(0xff85b8cc);// 5bb1d9 [UIColor colorWithRed:0.0 green:166.0/255 blue:124.0/255 alpha:1.0f];
}

+(UIColor*)neutralColor{
    return [UIColor colorWithWhite:0.7f alpha:1.0f];
}


+(UIColor*)neutralColorLight{
    return [UIColor colorWithWhite:0.9f alpha:1.0f];
}


+(UIColor*)redColor {
    return COLORFROMHEX(0xffd34117);// 5bb1d9 [UIColor colorWithRed:0.0 green:166.0/255 blue:124.0/255 alpha:1.0f];
}

+(UIColor *) patternColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"shl.png"]];
}


+(NSString*)lightFontName{
    return @"HelveticaNeue-Light"; //     UIFont *font = [UIFont fontWithName:@"Avenir-Black" size: isIpad? 32: 24];

}

+(NSString*)ultraLightFontName{
    return @"HelveticaNeue-LightItalic";
}

+(NSString*)fontName{
    return @"Avenir-Book"; // HelveticaNeue-LightItalic
}


+(NSString*)boldFontName{
    return @"Avenir-Black"; //     UIFont *font = [UIFont fontWithName:@"Avenir-Black" size: isIpad? 32: 24];
    
}

+(NSString*)boldItalicFontName{
    return @"Avenir-BlackOblique";
}

+(UIImage*)switchOnBackground{
    UIColor* onColor = [Theme mainColor];
    return [Utilities createSolidColorImageWithColor:onColor andSize:CGSizeMake(70, 30)];
}

+(UIImage*)switchOffBackground{
    
    UIColor* offColor = [UIColor colorWithRed:33.0/255 green:36.0/255 blue:39.0/255 alpha:1.0];
    return [Utilities createSolidColorImageWithColor:offColor andSize:CGSizeMake(70, 30)];
}

+(UIImage*)switchThumb{
    return [Utilities createSolidColorImageWithColor:[UIColor colorWithWhite:0.7f alpha:1.0f] andSize:CGSizeMake(30, 29)];
}

+(UIColor*)switchTextOffColor{
    return [UIColor whiteColor];
}

+(UIColor*)switchTextOnColor{
    return [UIColor whiteColor];
}

+(UIFont*)switchFont{
    return [UIFont fontWithName:[Theme lightFontName] size:12.0f];
}

+(UIImage *) backgroundImage
{
    return [UIImage imageNamed:@"shl.png"];
}

+(void)styleNavigationBarWithTextColor:(UIColor*)color{
    
    // UIImage* menubarImage = [Utilities createWhiteGradientImageWithSize:CGSizeMake(320, 44)];
    UIImage* menubarImage = [Utilities createSolidColorImageWithColor: [UIColor whiteColor] andSize:CGSizeMake(320, (IS_IOS7?64:44))];
    UINavigationBar* navAppeareance = [UINavigationBar appearance];
    
    [navAppeareance setBackgroundImage:menubarImage forBarMetrics:UIBarMetricsDefault];
    
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor clearColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: color,
                                                            NSFontAttributeName: [UIFont fontWithName:[Theme lightFontName] size:16.0f],
                                                            // NSShadowAttributeName: shadow // don't want now
                                                            }];
}


+(void)styleTabBar:(UITabBarController *)tabVC withBackgroundColor:(UIColor*)color andTextColor:(UIColor*)textColor {
    
    
    UITabBar* tabBarAppearance = [UITabBar appearance];
    
    UIImage* tabBackground = [Utilities createSolidColorImageWithColor:color andSize:CGSizeMake(320, 49)];
    [tabBarAppearance setBackgroundImage:tabBackground];
    
    NSArray *items = tabVC.tabBar.items;
    for (int idx = 0; idx < items.count; idx++) {
        UITabBarItem *item = items[idx];
        
        NSString* imageName = [NSString stringWithFormat:@"tabbar-tab%d", idx+1];
        UIImage *selectedImage = [UIImage imageNamed:imageName];
        UIImage *unselectedImage = [UIImage imageNamed:imageName];
        // [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        item = [item initWithTitle:imageName image:unselectedImage selectedImage:selectedImage];
    }
    
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      textColor, NSForegroundColorAttributeName,
      [UIFont fontWithName:[Theme lightFontName] size:12], NSFontAttributeName,
      nil]
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      textColor, NSForegroundColorAttributeName,
      [UIFont fontWithName:[Theme lightFontName] size:14], NSFontAttributeName,
      nil]
                                             forState:UIControlStateSelected];
}

#ifdef NOTNOW
+(void)styleSegmentedControlWithFontName:(NSString*)fontName andSelectedColor:(UIColor*)selectedColor andUnselectedColor:(UIColor*)unselectedColor andDidviderColor:(UIColor*)dividerColor{
    
    UIFont* font = [UIFont fontWithName:fontName size:13.0f];
    
    UIImage* segmentedBackground = [Utilities createSolidColorImageWithColor:unselectedColor andSize:CGSizeMake(50, 30)];
    
    UIImage* segmentedSelectedBackground = [Utilities createSolidColorImageWithColor:selectedColor andSize:CGSizeMake(50, 30)];
    
    UIImage* segmentedDividerImage = [Utilities createSolidColorImageWithColor:dividerColor andSize:CGSizeMake(1, 30)];
    
    UISegmentedControl *segmentedAppearance = [UISegmentedControl appearance];
    [segmentedAppearance setBackgroundImage:segmentedBackground forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [segmentedAppearance setBackgroundImage:segmentedSelectedBackground forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [segmentedAppearance setDividerImage:segmentedDividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [segmentedAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIColor whiteColor], UITextAttributeTextColor,
                                                 font, UITextAttributeFont,[NSValue valueWithCGSize:CGSizeMake(0.0,0.0)], UITextAttributeTextShadowOffset,
                                                 nil] forState:UIControlStateNormal];
    
    [segmentedAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIColor whiteColor], UITextAttributeTextColor,
                                                 font, UITextAttributeFont, [NSValue valueWithCGSize:CGSizeMake(0.0,0.0)], UITextAttributeTextShadowOffset,
                                                 nil] forState:UIControlStateSelected];
    
}

+(void)styleSliderWithMaxTrackColor:(UIColor*)maxColor andMinTrackColor:(UIColor*)minColor{
    
    UISlider* sliderAppearance = [UISlider appearance];
    
    UIImage* maxTrackImage = [[Utilities createSolidColorImageWithColor:maxColor andSize:CGSizeMake(30, 4)] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    
    UIImage* minTrackImage = [[Utilities createSolidColorImageWithColor:minColor andSize:CGSizeMake(30, 4)] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    
    UIImage* thumbImage = [Utilities createSolidCircleImageWithColor:maxColor andSize:CGSizeMake(20, 20)];
    
    [sliderAppearance setThumbImage:thumbImage forState:UIControlStateNormal];
    [sliderAppearance setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [sliderAppearance setMinimumTrackImage:minTrackImage forState:UIControlStateNormal];
    [sliderAppearance setMaximumTrackImage:maxTrackImage forState:UIControlStateNormal];
    
}

+(void)styleProgressViewWithTrackColor:(UIColor*)trackColor andProgressColor:(UIColor*)progressColor{
    UIProgressView* progressAppearance = [UIProgressView appearance];
    
    UIImage* trackImage = [[Utilities createSolidColorImageWithColor:trackColor andSize:CGSizeMake(30, 2)] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    UIImage* progressImage = [[Utilities createSolidColorImageWithColor:progressColor andSize:CGSizeMake(30, 2)] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
   
    [progressAppearance setTrackImage:trackImage];
    [progressAppearance setProgressImage:progressImage];

}
#endif

+(void)styleBackButtonWithTextColor:(UIColor*)color{
    
    UIBarButtonItem* barButtonAppearance = [UIBarButtonItem appearance];
    
    if (IS_IOS7) {
        UIImage* backButtonImage = [[UIImage RemapColor:color maskImage: [UIImage imageNamed:@"back.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        
        [barButtonAppearance setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        UIImage* backButtonLandscapeImage = [[UIImage imageNamed:@"back-landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
        
        [barButtonAppearance setBackButtonBackgroundImage:backButtonLandscapeImage forState:UIControlStateNormal barMetrics:UIBarMetricsCompact];   // was UIBarMetricsLandscapePhone
    }
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor clearColor];
    [barButtonAppearance setTitleTextAttributes: @{
                                                   NSForegroundColorAttributeName: color,
                                                   NSFontAttributeName: [UIFont fontWithName:[Theme lightFontName] size:16.0f],
                                                   NSShadowAttributeName: shadow // don't want now
                                                   }
                                       forState: UIControlStateNormal];
    
}

+(void)styleBarButtonWithTextColor:(UIColor*)color{
    
    UIBarButtonItem* barButtonAppearance = [UIBarButtonItem appearance];
    
    UIImage* barButtonImage = [Utilities createSolidColorImageWithColor:[UIColor colorWithWhite:1.0 alpha:0.3] andSize:CGSizeMake(10, 10)];
    
    [barButtonAppearance setBackgroundImage:barButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonAppearance setBackgroundImage:barButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsCompact];   // was UIBarMetricsLandscapePhone
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor clearColor];
    [barButtonAppearance setTitleTextAttributes: @{
                                                   NSForegroundColorAttributeName: color,
                                                   NSFontAttributeName: [UIFont fontWithName:[Theme lightFontName] size:14.0f],
                                                   NSShadowAttributeName: shadow // don't want now
                                                   }
                                       forState: UIControlStateNormal];
    
    
}


#define QUILT_BLOCK_WIDTH     160
#define QUILT_BLOCK_HEIGHT    32
static CGFloat quilt_block_width = QUILT_BLOCK_WIDTH;
static CGFloat quilt_block_height = QUILT_BLOCK_HEIGHT;

+ (CGSize) blockPixels
{
    CGRect frame = [Utilities applicationFrame];
    quilt_block_width = frame.size.width / 2;
    quilt_block_height = (IS_IPAD? QUILT_BLOCK_HEIGHT*1.5 : QUILT_BLOCK_HEIGHT);
    return CGSizeMake(quilt_block_width, quilt_block_height);
    
}



- (id) init
{
    if (self = [super init]) {
        
    }
    return self;
}
@end
