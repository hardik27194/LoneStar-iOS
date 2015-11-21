//
//  SettingsHeaderCell.m
//  SnapticaToo
//
//  Created by sandeep on 1/22/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "SettingsHeaderCell.h"
#import "SettingsManager.h"
#import "UIImage+ScaleAndCrop.h"

@implementation SettingsHeaderCell

- (void)awakeFromNib {
    // Initialization code
    self.titleLabel.font = [UIFont fontWithName: @"Avenir-Black" size: 15];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.iconImageView.backgroundColor = [UIColor clearColor];
    
    if (_backgroundLayer == nil) {
        _backgroundLayer = [CALayer layer];
        _backgroundLayer.backgroundColor = [UIColor blackColor].CGColor;
        _backgroundLayer.frame = self.iconImageView.bounds;
        _backgroundLayer.opacity = 0.6;
        _backgroundLayer.borderColor = [UIColor grayColor].CGColor;
        _backgroundLayer.borderWidth = 0;
        _backgroundLayer.cornerRadius = 18;
        [self.iconImageView.layer addSublayer:_backgroundLayer];
        
    }
    
    
    self.iconImageView.layer.cornerRadius = 18;
    
    self.lineView.layer.opacity = 0.6;
    self.lineView.backgroundColor = [UIColor blackColor];
    /*
     let background = UIImage(named: "border-button")?.resizableImageWithCapInsets(UIEdgeInsetsMake(10, 10, 10, 10))
     let backgroundTemplate = background!.imageWithRenderingMode(.AlwaysTemplate)
     
     button.setBackgroundImage(backgroundTemplate, forState: .Normal)
     button.setTitle(text, forState: .Normal)
     button.titleLabel?.font = UIFont(name: MegaTheme.fontName, size: 11)
     button.tintColor = UIColor.whiteColor()
*/
}

- (void) setSettingsItem:(SettingsItemModel *)item
{
    if (item) {
        super.settingsItem = item;
        if (item.actionTitle) {
            [_actionButton setBackgroundImage:[[UIImage imageNamed:@"border-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10,10,10,10)]  forState:UIControlStateNormal];
            [_actionButton setTitle:item.actionTitle forState:(UIControlStateNormal)];
            [_actionButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

            _actionButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:10];
            _actionButton.tintColor = [UIColor whiteColor];
            _actionButton.hidden = NO;
        } else {
            _actionButton.hidden = YES;
        }
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) actionButtonPressed: (UIButton *) sender
{
#ifdef DEBUG

    NSString *title = self.titleLabel.text;
    DLog(@"Action Pressed: %@", title);

#endif
    
    // TODO
#if 1
    [[SettingsManager instance] actionPressed:self.settingsItem.settingsDictionary];
#endif
    
}

@end
