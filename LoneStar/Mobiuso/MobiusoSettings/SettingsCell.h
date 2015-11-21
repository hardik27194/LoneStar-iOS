//
//  SettingsCell.h
//  SnapticaToo
//
//  Created by sandeep on 1/22/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsItemModel.h"


@interface SettingsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) SettingsItemModel *settingsItem;

@property (nonatomic, retain) UIViewController *controller;

@end
