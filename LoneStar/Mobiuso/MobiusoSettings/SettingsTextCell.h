//
//  SettingsTextCell.h
//  SnapticaToo
//
//  Created by sandeep on 1/22/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsItemModel.h"
#import "SettingsCell.h"

@interface SettingsTextCell : SettingsCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *inputText;

@property (retain, nonatomic) CALayer *backgroundLayer;
@property (retain, nonatomic) CALayer *imageLayer;
@property (nonatomic, retain) id<UITextFieldDelegate> delegate;

@end
