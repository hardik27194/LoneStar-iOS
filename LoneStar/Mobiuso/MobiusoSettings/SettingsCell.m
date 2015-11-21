//
//  SettingsCell.m
//  SnapticaToo
//
//  Created by sandeep on 1/22/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "SettingsCell.h"
#import "SettingsBackgroundView.h"
#import "Constants.h"

@implementation SettingsCell

- (void)awakeFromNib {
    // Initialization code
    _titleLabel.font = [UIFont fontWithName: @"Avenir-Black" size: 13];
    _titleLabel.textColor = [UIColor whiteColor];
    
    _iconImageView.backgroundColor = [UIColor clearColor];

    self.lineView.layer.opacity = 0.6;
    self.lineView.backgroundColor = [UIColor blackColor];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.lineView.layer.opacity = 0.6;
    self.lineView.backgroundColor = [UIColor blackColor];
}

@end
