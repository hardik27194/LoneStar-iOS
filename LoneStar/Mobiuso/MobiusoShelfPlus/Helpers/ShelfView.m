//
//  ShelfView.m
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "ShelfView.h"
#import <QuartzCore/QuartzCore.h>

const NSString *kShelfViewKind = @"ShelfView";

@implementation ShelfView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
//        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtle_dots.png"]]];  // Apple-Wood
//        self.layer.shadowOpacity = 0.5;
//        self.layer.shadowOffset = CGSizeMake(0,5);
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect shadowBounds = CGRectMake(0, -5, self.bounds.size.width, self.bounds.size.height + 5);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowBounds].CGPath;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (NSString *)kind
{
    return (NSString *)kShelfViewKind;
}

@end
