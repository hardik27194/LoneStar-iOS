//
//  ConferenceHeader.m
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "ModuleTypeHeader.h"
#import "ModuleType.h"
#import <QuartzCore/QuartzCore.h>
#import "ModuleLayoutAttributes.h"
#import "MaskingTapeView.h"
#import "Theme.h"

#define MARGIN_HORIZONTAL_LARGE 20
#define MARGIN_HORIZONTAL_SMALL 10
#define MARGIN_VERTICAL_LARGE 5
#define MARGIN_VERTICAL_SMALL 3

@interface ModuleTypeHeader()

@property (strong, nonatomic) IBOutlet UILabel *moduleNameLabel;
@property (nonatomic, assign, getter = isBackgroundSet) BOOL backgroundSet;
@property (nonatomic, assign, getter = isSmall) BOOL small;
@property (nonatomic, assign) BOOL centerText;
@property (nonatomic, strong) MaskingTapeView *backgroundView;

@end

@implementation ModuleTypeHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _moduleNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, frame.size.width, 13)];
        _moduleNameLabel.font = [UIFont fontWithName:[Theme fontName] size:16];

#ifdef DO_MASKINGTAPE_VIEW
        _conferenceNameLabel.textColor = [UIColor blackColor];
#else
        _moduleNameLabel.textColor = [UIColor whiteColor];
#endif
        _moduleNameLabel.textAlignment = NSTextAlignmentCenter;
        [self setBackground];
        [self addSubview:_moduleNameLabel];
        _small = NO;
        _centerText = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        _small = NO;
        _centerText = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if ([layoutAttributes isKindOfClass:[ModuleLayoutAttributes class]])
    {
        ModuleLayoutAttributes *conferenceAttributes = (ModuleLayoutAttributes *)layoutAttributes;
        self.centerText = conferenceAttributes.headerTextAlignment == NSTextAlignmentCenter;
    }    
}


- (void)setBackground
{
    if (self.isBackgroundSet)
        return;

#ifdef DO_MASKINGTAPE_VIEW
    _backgroundView = [[MaskingTapeView alloc] initWithFrame:self.conferenceNameLabel.bounds];
    [self insertSubview:_backgroundView belowSubview:self.conferenceNameLabel];
    [self.conferenceNameLabel setBackgroundColor:[UIColor clearColor]];
    
    [self setBackgroundSet:YES];
#endif
    
}

- (CGFloat)horizontalMargin
{
    return self.isSmall? MARGIN_HORIZONTAL_SMALL : MARGIN_HORIZONTAL_LARGE;
}

- (CGFloat)verticalMargin
{
    return self.isSmall? MARGIN_VERTICAL_SMALL : MARGIN_VERTICAL_LARGE;
}

- (void)layoutSubviews
{
    [self.moduleNameLabel sizeToFit];
    CGRect labelBounds = CGRectInset(self.moduleNameLabel.bounds, -[self horizontalMargin], -[self verticalMargin]);
    
    if (self.centerText)
    {
        self.moduleNameLabel.bounds = (CGRect){CGPointZero, labelBounds.size};
        self.moduleNameLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    else
    {
        CGFloat leftMargin = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad? 20 : 5;
        self.moduleNameLabel.frame = (CGRect){{leftMargin, roundf((self.bounds.size.height - labelBounds.size.height)/2)}, labelBounds.size};
    }
    
    [self.backgroundView setFrame:self.moduleNameLabel.frame];
}

#pragma mark - Properties

- (void)setCenterText:(BOOL)centerText
{
    _centerText = centerText;
    [self setNeedsLayout];
}

- (void)setConference:(NSString *)title
{
    [self setBackground];
    self.moduleNameLabel.text = title;
    [self layoutSubviews];        
}

@end

NSString *kSmallModuleTypeHeaderKind = @"ModuleTypeHeaderSmall";

@implementation SmallModuleTypeHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.moduleNameLabel.font = [UIFont fontWithName:[Theme fontName] size:16];
#ifndef DO_MASKINGTAPE_VIEW
        self.moduleNameLabel.textColor = [UIColor whiteColor];
#endif

        self.small = YES;
        self.centerText = YES;
    }
    return self;
}

+ (NSString *)kind
{
    return (NSString *)kSmallModuleTypeHeaderKind;
}

@end
