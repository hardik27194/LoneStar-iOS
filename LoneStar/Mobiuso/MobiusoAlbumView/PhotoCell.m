//
//  PhotoCell.m
//
//
//  Created by Sandeep Shah on 01/04/2015.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//
//

#import "PhotoCell.h"
#import "PhotoObject.h"

@implementation PhotoCell

- (void) adjustShim
{
    CGRect frame = _infoButton.frame;
#ifdef NOTNOW
        if (IS_IOS8) {
            // Blur Effect
            
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            [bluredEffectView setFrame:frame];
            
            
            // Vibrancy Effect
            UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
            UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
            // vibrancyEffectView.backgroundColor = COLORFROMHEX(0xff990000);
            [vibrancyEffectView setFrame:bluredEffectView.bounds];
            // Add Vibrancy View to Blur View
            [bluredEffectView addSubview:vibrancyEffectView];
            // Add Label to Vibrancy View
            //            [self.view addSubview: bluredEffectView];
            [_shimView removeFromSuperview];
            _shimView = (id) bluredEffectView;
            [self addSubview:_shimView];
            
        } else {
            _shimView.backgroundColor = [UIColor blackColor];
            _shimView.alpha = 0.5;
            _shimView.frame = frame;
        }
#endif
    
    _shimView.layer.cornerRadius = frame.size.width/2;

}

- (void)setItem:(PhotoObject *)item {
    if ([_item isEqual:item] && (!_item.image)) {
        return;
    }
    [self adjustShim];
    
    _item = item;
    
    _imageView.image = (_item.image ? _item.image : [UIImage imageNamed:_item.imageName]);
    NSString *title = _item.title;
    NSRange fileextension = [title rangeOfString: @"." options:NSBackwardsSearch];

    if ((fileextension.location != NSNotFound) && ((title.length - fileextension.location) > 1)) {
        title = [title substringToIndex:fileextension.location];
    }
    
    _fileNameLabel.text = title;
    if (item.itemType == PhotoItem) {
    }
    // _textLabel.textColor = [UIColor colorWithRed:0.29f green:0.29f blue:0.29f alpha:1.00f];
    NSUInteger size = [_item.size integerValue];
    NSString *unit;
    if (size > (1024*1024)) { unit = @" MB"; size /= (1024*1024); }
    else if (size > 1024) { unit = @" KB"; size /= 1024; }
    else { unit = @""; }
    _fileSizeLabel.text = [NSString stringWithFormat:@"[%ld%@]", (unsigned long)size, unit];
    _fileSizeLabel.textColor = [UIColor colorWithRed:0.72f green:0.72f blue:0.72f alpha:1.00f];
}

@end
