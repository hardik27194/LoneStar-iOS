//
//  SettingsBoolCell.m
//  SnapticaToo
//
//  Created by sandeep on 1/24/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "SettingsBoolCell.h"
#import "Theme.h"

@implementation SettingsBoolCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.font = [UIFont fontWithName: @"Avenir-Book" size: 15];
    UISwitch *switchAppearance = [UISwitch appearance];
    [switchAppearance setOnTintColor:[Theme mainColor]];
    [_boolSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];

}

- (void) setState: (UISwitch *) sender
{
//    DLog(@"Current State is %@", sender.on? @"On" : @"Off");
    self.settingsItem.value = (id) [NSNumber numberWithBool: sender.on];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
 
 [yourSwitchObject addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
*/

@end
