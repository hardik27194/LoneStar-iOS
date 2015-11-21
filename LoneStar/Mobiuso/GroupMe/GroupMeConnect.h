//
//  GroupMeConnect.h
//  Pro Shot
//
//  Created by sandeep on 8/8/15.
//  Copyright (c) 2015 Mobiuso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoObject.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "MoPopupListToo.h"

#define GROUPME_CLIENT  @"iMgCLzRxvKkmQGDgLDK5Gl86904ywK1aG4UnZivXvvxcHgOl"
#define GROUPME_BASE_URL    @"https://oauth.groupme.com"
#define GROUPME_AUTHORIZE   @"/oauth/authorize"


#define kGroupMeToken   @"GroupMeToken"

#define GroupMeTokenReceiptNotification @"GroupMeTokenReceived"


@interface GroupMeConnect : NSObject  <UIWebViewDelegate, MoPopupListTooViewDataSource, MoPopupListTooViewDelegate>

+ (void) sendImage: (UIImage *) image withContainer: (UIViewController *) sender;

//+ (BOOL) connectInContainerView: (UIViewController *) view;
+ (NSArray *) groups;
+ (NSString *) groupMeToken: (UIViewController *) sender;
+ (void) setGroupMeToken: (NSString *) token;

@end
