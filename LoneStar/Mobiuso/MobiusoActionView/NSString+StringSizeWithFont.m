//
//  NSString+StringSizeWithFont.m
//  SandeepShellProject
//
//  Created by sandeep on 2/23/14.
//  Copyright (c) 2014 Medpresso. All rights reserved.

//  Work around to handle the sizeWithFont: deprecation in iOS7 onwards
//  Replace sizeWithFont: with sizeWithFontSafe:
//

#import "NSString+StringSizeWithFont.h"

@implementation NSString (StringSizeWithFont)

- (CGSize) sizeWithFontSafe:(UIFont *)fontToUse
{
#ifdef PRE_IOS7
    if ([self respondsToSelector:@selector(sizeWithAttributes:)])
    {
        NSDictionary* attribs = @{NSFontAttributeName:fontToUse};
        return ([self sizeWithAttributes:attribs]);
    }
    // The following is used only in versions earlier than iOS6 where sizeWithAttributes: is not available
    return ([self sizeWithFont:fontToUse]);
#else
    NSDictionary* attribs = @{NSFontAttributeName:fontToUse};
    return ([self sizeWithAttributes:attribs]);
#endif
}


- (CGRect) boundingRectWithSize:(CGSize)size Font: (UIFont *) fontToUse
{
#ifdef PRE_IOS7
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSDictionary* attribs = @{NSFontAttributeName:fontToUse};
        
        return ([self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:attribs context:nil]);
    }
    // The following is used only in versions earlier than iOS6 where sizeWithAttributes: is not available
    CGSize sizenew = [self sizeWithFont: fontToUse
                 constrainedToSize: size
                     lineBreakMode: NSLineBreakByWordWrapping /*UILineBreakModeWordWrap*/];
    return CGRectMake(0, 0, sizenew.width, sizenew.height);
    
#else
    NSDictionary* attribs = @{NSFontAttributeName:fontToUse};
    
    return ([self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:attribs context:nil]);
#endif
}

@end
