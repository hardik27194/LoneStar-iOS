//
//  NavigationViewController.h
//  SnapticaToo
//
//  Created by sandeep on 12/31/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsItemModel.h"
#import "MobiusoActionView.h"



@interface SettingsMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UIImageView  *logoImage;
@property (strong, nonatomic) IBOutlet UIImageView  *bgImageView;
@property (strong, nonatomic) IBOutlet UITableView  *tableView;
@property (strong, nonatomic) IBOutlet UIView       *dimmerView;

@property (retain, nonatomic) NSArray               *items;
@property (nonatomic, assign) NSInteger             currentItem;
@property (retain, nonatomic) UITextField           *currentResponder;
@property (nonatomic, assign) CGFloat               keyboardHeight;
@property (nonatomic, assign) CGFloat               keyboardMoveOffset;
@property (nonatomic, assign) BOOL                  keyboardVisible;

@end
