//
//  SettingsLinkCell.h
//  SnapticaToo
//
//  Created by sandeep on 1/23/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "SettingsCell.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SettingsLinkCell : SettingsCell <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapLinkRecognizer;

@property (strong, nonatomic) IBOutlet UIView *shimView;

@property (nonatomic, retain) UIWebView *webView;

- (void) setLabel: (NSString *) str;


@end
