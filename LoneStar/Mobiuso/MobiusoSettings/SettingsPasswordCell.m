//
//  SettingsPasswordCell.m
//  SnapticaToo
//
//  Created by sandeep on 1/23/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "SettingsPasswordCell.h"

@implementation SettingsPasswordCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.inputText.secureTextEntry = YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
