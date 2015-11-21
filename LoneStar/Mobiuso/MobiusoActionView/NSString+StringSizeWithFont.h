//
//  NSString+StringSizeWithFont.h
//  SandeepShellProject
//
//  Created by sandeep on 2/23/14.
//  Copyright (c) 2014 Medpresso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (StringSizeWithFont)

- (CGSize) sizeWithFontSafe:(UIFont *)fontToUse;
- (CGRect) boundingRectWithSize:(CGSize)size Font: (UIFont *) fontToUse;

@end
