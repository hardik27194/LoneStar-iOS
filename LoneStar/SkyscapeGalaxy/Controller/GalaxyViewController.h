//
//  NavigationViewController.h
//  SnapticaToo
//
//  Created by sandeep on 12/31/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobiusoActionView.h"
#import "MoArcMenu.h"


@protocol GalaxyViewControllerDelegate <NSObject>

@optional

- (BOOL) handleSettings: (NSUInteger) index;

@end

@interface GalaxyViewController : UIViewController <MoArcMenuDelegate, MobiusoActionViewDelegate>


@property (strong, nonatomic) IBOutlet UIImageView  *bgImageView;
@property (strong, nonatomic) IBOutlet UITableView  *tableView;
@property (strong, nonatomic) IBOutlet UIView       *dimmerView;
@property (strong, nonatomic) IBOutlet UIImageView  *appIconView;

@property (retain, nonatomic) NSArray               *items;
@property (nonatomic, assign) NSInteger             currentItem;
@property (retain, nonatomic) UITextField           *currentResponder;
@property (nonatomic, assign) CGFloat               keyboardHeight;
@property (nonatomic, assign) CGFloat               keyboardMoveOffset;
@property (nonatomic, assign) BOOL                  keyboardVisible;
@property (nonatomic, copy) NSString *selectedAppItunesLink;


@property (nonatomic, assign) NSInteger             currentActionViewId;

@property (nonatomic, assign) NSObject<GalaxyViewControllerDelegate> *settingsDelegate;


#define APP_NOT_INSTALLED_TITLE NSLocalizedString(@"NOT INSTALLED", @"NOT INSTALLED")
//#define APP_NOT_INSTALLED_MESSAGE NSLocalizedString(@"Sorry the Skyscape Galaxy App %@ is not installed", @"Sorry the Skyscape Galaxy App is not installed")
#define APP_NOT_INSTALLED_MESSAGE NSLocalizedString(@"Sorry %@ App is not installed..", @"Sorry the Skyscape Galaxy App is not installed")

@end
