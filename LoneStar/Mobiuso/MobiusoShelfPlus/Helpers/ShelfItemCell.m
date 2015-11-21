//
//  ShelfItemCell.m
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "ShelfItemCell.h"
#import <QuartzCore/QuartzCore.h>
//#import "MPAnimation.h"
#import "ModuleLayoutAttributes.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "Theme.h"
#import "UIImage+RemapColor.h"

@interface ShelfItemCell()


@end

@implementation ShelfItemCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor lightTextColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
         /*self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.selectedBackgroundView.backgroundColor = [UIColor orangeColor];*/
    }
    return self;
}

- (void)setModuleName:(NSString *)moduleName
{
    if (![_moduleName isEqualToString:moduleName])
    {
        _moduleName = moduleName;
        self.nameLabel.text = moduleName;
        {
            self.moduleBorderImage.backgroundColor = [UIColor lightGrayColor];
            
            if (_overlayImage) {
                _overlayImageView.image = _overlayImage;
            }


        }
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview)
    {
        self.moduleBorderImage.layer.shadowOpacity = 0.3;
        self.moduleBorderImage.layer.shadowOffset = CGSizeMake(0, 3);
        self.moduleBorderImage.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.moduleImage.bounds,1,1)] CGPath];
    }
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if ([layoutAttributes isKindOfClass:[ModuleLayoutAttributes class]])
    {
        ModuleLayoutAttributes *modAttributes = (ModuleLayoutAttributes *)layoutAttributes;
        self.moduleBorderImage.layer.shadowOpacity = modAttributes.shadowOpacity;
    }
}

-(void)prepareForReuse
{
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
    self.moduleBorderImage.image = nil;
    self.moduleImage.image = nil;
    self.overlayImageView.image = nil;
    self.reminderImageView.image = nil;
    self.overlayImage = nil;
}

-(void)dealloc
{
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
    self.moduleBorderImage.image = nil;
    self.moduleImage.image = nil;
    self.overlayImageView.image = nil;
    self.reminderImageView.image = nil;
    self.overlayImage = nil;
    if (self.selectButton) {
        [self.selectButton removeFromSuperview];
        self.selectButton = nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
