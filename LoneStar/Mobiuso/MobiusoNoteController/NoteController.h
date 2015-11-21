//
//  NoteController.h
//  ShshDox
//
//  Created by sandeep on 7/10/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import "MoProgressView.h"
#import "MobiusoTimedCurtain.h"
#import "ClipboardManager.h"
#import "MoArcMenu.h"


@interface NoteController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate, MoProgressViewDelegate, MobiusoTimedCurtainDelegate, MobiusoActionViewDelegate, MoArcMenuDelegate>

- (id) initWithFilePath: (NSString *) filePath andPassword: (NSString *) passwd;

@end
