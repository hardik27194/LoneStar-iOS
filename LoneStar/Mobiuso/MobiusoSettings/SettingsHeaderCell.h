//
//  SettingsHeaderCell.h
//  SnapticaToo
//
//  Created by sandeep on 1/22/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsCell.h"
#import "MoArcMenu.h"

@interface SettingsHeaderCell : SettingsCell

@property (strong, nonatomic) IBOutlet UIButton *actionButton;


@property (retain, nonatomic) CALayer *backgroundLayer;
@property (retain, nonatomic) CALayer *imageLayer;



@end
