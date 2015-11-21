//
//  SettingsBackgroundView.m
//  SnapticaToo
//
//  Created by sandeep on 1/22/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "SettingsBackgroundView.h"

@implementation SettingsBackgroundView

void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint,
                   CGColorRef color) {
    
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect paperRect = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    // CGColorRef color = [UIColor whiteColor].CGColor;
//    CGColorRef color =  // [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5].CGColor;
//    [UIColor colorWithPatternImage: [UIImage imageNamed:@"bg.png"]].CGColor;
    
    // CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Droid Sans" size: 14].fontName);
    // CGContextSetFont(context, cgFont);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, self.bounds);    // Add in color section
    CGContextSetAlpha(context, 0.7);
    
    CGColorRef separatorColor = [UIColor whiteColor].CGColor;
    
    // Add at bottom
    CGPoint startPoint = CGPointMake(paperRect.origin.x + 54,
                                     paperRect.origin.y + paperRect.size.height - 24);
    CGPoint endPoint = CGPointMake(paperRect.origin.x + paperRect.size.width - 12,
                                   paperRect.origin.y + paperRect.size.height - 24);
    
    draw1PxStroke(context, startPoint, endPoint, separatorColor);
    
    
}


@end
