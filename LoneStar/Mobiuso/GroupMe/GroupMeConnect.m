//
//  GroupMeConnect.m
//  Pro Shot
//
//  Created by sandeep on 8/8/15.
//  Copyright (c) 2015 Mobiuso. All rights reserved.
//

#import "GroupMeConnect.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "Theme.h"
#import "Strings.h"
#import "UIImage+RemapColor.h"
#import "Configs.h"
#import "MobiusoActionView.h"
#import "MobiusoToast.h"


@interface GroupMeConnect()

@property (nonatomic, retain)     UIViewController    *container;
@property (nonatomic, retain)     UIWebView           *authView;
@property (nonatomic, retain)     UIImage             *imageToSend;
@property (nonatomic, retain)     NSArray             *groupItemsArray;
@property (nonatomic, retain)     NSArray             *groupNamesArray;
@property (nonatomic, retain)     NSArray             *userItemsArray;
@property (nonatomic, retain)     NSArray             *userNamesArray;

@end

@implementation GroupMeConnect


static GroupMeConnect *groupMeConnect;
static NSString *groupMeToken = nil;


// If you change the settings during development, just define the OVERWRITE below
#undef OVERWRITE


+ (instancetype) instance
{
    return groupMeConnect;
}

+ (void) load
{
    [super load];
    {
        if (groupMeConnect == nil) {
            groupMeConnect = [[GroupMeConnect alloc] init];
            // Load any items from the sync
        }
    }
}

+ (NSString *) groupMeToken: (UIViewController *) sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey: kGroupMeToken];
    if (token == nil) {
//        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
//        UIViewController *sender = [[appDelegate.window.rootViewController navigationController] topViewController];
//        

        // ActionView
        MobiusoActionView *actionView = [Utilities setupActionView: 1000  withMessage:GROUPME_INTRO_MESSAGE withTitle: GROUPME_INTRO_TITLE placeholderText: nil andButtons:@[@"WILL DO!"] cancelButtonTitle:nil color:RGBColor(237, 20, 91) inView: sender.view andDelegate:nil];
        
        [sender.view bringSubviewToFront: actionView];
        [actionView showWithCompletionBlock:^(MobiusoActionView *actionView, NSInteger buttonIndex, NSString *inputText) {
            
            [GroupMeConnect connectInContainerView:sender];
            
            [[NSNotificationCenter defaultCenter] addObserver:groupMeConnect selector:@selector(groupMeTokenReceived:) name:GroupMeTokenReceiptNotification object:nil];
        }];
        
    }
    return token;
}

+ (void) setGroupMeToken: (NSString *) token
{
    groupMeToken = token;
    
    if (token) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:token   forKey:kGroupMeToken];
        
        __unused BOOL synchronized = [defaults synchronize];
    }

    
}

+ (void) sendImage: (UIImage *) image withContainer: (UIViewController *) sender
{
    groupMeConnect.imageToSend = image;
    groupMeConnect.container = sender;
    NSString *token = [self groupMeToken: sender];
    if (token == nil) {
        // just return, may be we will get a token later...
        return;
    } else {
        [GroupMeConnect send];
    }

}

+ (BOOL) connectInContainerView: (UIViewController *) sender
{
#if 1
    // If there is no Internet connection - don't bother with the connection request
    if (![AppDelegate isNetworkReachable]) {
        return NO;
    }
#endif
    
    groupMeConnect.container = sender;
    
    NSString *urlString = [NSString stringWithFormat:GROUPME_BASE_URL @"/" GROUPME_AUTHORIZE @"?client_id=%@", GROUPME_CLIENT];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error:&error];
    
    // Hnadle the responseData here
    
    if (error) return NO;
    NSString *fileString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if ([fileString hasPrefix:@"<!DOCTYPE html>"]) {
        [self loadLoginView: fileString inView: sender];
    }

    return YES;

}

+ (void) send
{
    NSArray *targetArray = [self groups];
    groupMeConnect.groupItemsArray = targetArray;
    groupMeConnect.groupNamesArray = [[targetArray  valueForKey:@"name"]  sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *direct = [self users]; // @[@"@Kinnell", @"@Krina", @"@Neeta", @"Sandeep"];
    targetArray = [targetArray arrayByAddingObjectsFromArray:direct];
    groupMeConnect.userItemsArray = direct;
    groupMeConnect.userNamesArray = [direct valueForKey:@"name"];

    if (targetArray && ([targetArray count] > 0)) {
        [groupMeConnect popupUserGroups:targetArray];
    }
}

+ (NSArray *) groups
{
    // canned token for now
    // If there is no token, call connect?
    NSString *urlString = [NSString stringWithFormat:@"https://api.groupme.com/v3/groups?token=%@", [self groupMeToken:nil]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error:&error];
    
    // Hnadle the responseData here
    
    if (error) return nil;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];

    NSMutableArray *groupArray = nil;
    
    if (!error && responseDictionary) {
        NSUInteger resultCode = [responseDictionary[@"meta"][@"code"] integerValue];
        if (resultCode == 200) {
            NSArray *grouplist = responseDictionary[@"response"];
            
            groupArray = [[NSMutableArray alloc] init]; //  [grouplist valueForKey:@"name"];
            [grouplist enumerateObjectsUsingBlock: ^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
                NSDictionary *messages = item[@"messages"];
//                NSString *name = item[@"name"];
                NSArray *members = item[@"members"];
                NSUInteger messagecount = [messages[@"count"] integerValue];
                if ((messagecount > 0) || ([members count] > 1)) {
                    [groupArray addObject: item];
                }
            }];
            
        }
    }
//    NSString *fileString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    return  groupArray;
    
}

+ (NSArray *) users
{
    // canned token for now
    // If there is no token, call connect?
    NSString *urlString = [NSString stringWithFormat:@"https://api.groupme.com/v3/chats?token=%@", [self groupMeToken: nil]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error:&error];
    
    // Hnadle the responseData here
    
    if (error) return nil;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
    NSMutableArray *userArray = nil;
    
    if (!error && responseDictionary) {
        NSUInteger resultCode = [responseDictionary[@"meta"][@"code"] integerValue];
        if (resultCode == 200) {
            NSArray *chatlist = responseDictionary[@"response"];
            
            userArray = [[NSMutableArray alloc] init]; //  [grouplist valueForKey:@"name"];
            [chatlist enumerateObjectsUsingBlock: ^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
//                NSDictionary *messages = item[@"messages"];
//                NSString *name = item[@"name"];
                NSDictionary *user = item[@"other_user"];
                if (![userArray containsObject:user]) {
                    [userArray addObject:user];
                }

            }];
            
        }
        
    }
    return userArray;

}


+ (NSDictionary *) uploadImage: (UIImage *) image
{
    // curl -F "file=@/Users/sandeep/the.Photos/9L6C5955.JPG" "https://image.groupme.com/pictures?access_token=f072e320f71e0132268c4e9d801e9a8c"
    // {"payload":{"url":"http://i.groupme.com/5760x3840.jpeg.912b2f06e07a47399ca79f3386264e0b","picture_url":"http://i.groupme.com/5760x3840.jpeg.912b2f06e07a47399ca79f3386264e0b"}}
    
    // Create a file out of this
    if (image) {
        NSData* data = UIImageJPEGRepresentation(image, 1.0);
        
        
        if (data == nil) return nil;
        
        
        // setting up the URL to post to
        NSString *urlString = [NSString stringWithFormat:@"https://image.groupme.com/pictures?access_token=%@",
                               [self groupMeToken: nil]];
        
        DLog(@"[upload=%@]", urlString);
        
        
        //create request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        //Set Params
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        
        NSString *postLength = [NSString stringWithFormat:@"%d", (int)[data length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
        
        
        // setting the body of the post to the request
        [request setHTTPBody:data];
        
        // set URL
        [request setURL:[NSURL URLWithString:UrlSafeString(urlString)]];
        
        NSError *error;
        NSURLResponse *response;
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error:&error];
        
        if (error) return nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        
        
        if (!error && responseDictionary) {
            NSDictionary *payload = responseDictionary[@"payload"];
            //                if (payload)  {
            //                    // use the URL from here
            //                    NSString *pictureUrl = payload[@"url"];
            //                    // Now create the message and send it!
            //
            //                }
            return payload;
        } else {
            return nil;
        }
        
        
        
    }
    
    
    
    return nil;
}

+ (void) loadLoginView: (NSString *) htmlString inView: (UIViewController *) sender
{
    UIWebView *webView = [self buildContainerView:sender];
    
    [webView  setScalesPageToFit:YES];
    webView.delegate = groupMeConnect;
    [webView  loadHTMLString:htmlString baseURL:[NSURL URLWithString: GROUPME_BASE_URL]];
    
    [sender.view addSubview: webView];
    
    groupMeConnect.authView = webView;

    [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:3.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        webView.center = sender.view.center;
    } completion:^(BOOL finished) {
        
    }];

}

+ (UIWebView *) buildContainerView: (UIViewController *) sender
{
    CGAffineTransform transform = CGAffineTransformMake(1.0, 0, 0, 0.9, 0, 0);
    CGRect newRect = CGRectApplyAffineTransform([Utilities applicationFrame], transform);
    newRect.size.height = MIN(newRect.size.height, 320);
    UIWebView *webView = [[UIWebView alloc] initWithFrame: newRect];
    webView.layer.cornerRadius = 0.0f;
    webView.clipsToBounds = YES;
    webView.center = CGPointMake(sender.view.center.x, sender.view.center.y + sender.view.frame.size.height);
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(newRect.size.width - 40, 8, 32, 32);
    [closeButton addTarget:groupMeConnect action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [closeButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"dismissButt"]] forState:UIControlStateNormal];
    closeButton.layer.cornerRadius = 16;
    closeButton.layer.backgroundColor = COLORFROMHEX(0x80000000).CGColor;
    CALayer *sublayer = [CALayer layer];
    sublayer.frame = [closeButton bounds];
    sublayer.contents = (__bridge id)([UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"dismissButt"]].CGImage);
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [webView addSubview: closeButton];

    return webView;
}

#pragma Instance Methods
- (void) sendImage: (UIImage *) image withMessage: (NSString *) message to: (NSDictionary *) userOrGroup
{
    
//    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
//    __block UIView *view = [[mainWindow.rootViewController navigationController] topViewController].view;


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MobiusoToast toast:@"Uploading image" inView: _container.view];
        });

        NSDictionary *uploadImageDict = [GroupMeConnect uploadImage:image];
        //create a CFUUID - it knows how to create unique identifiers
        CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);
        
        //create a string from unique identifier
        NSString * newUniqueIDString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, newUniqueID));
        
        NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];
        
        messageDict[@"source_guid"]  =  newUniqueIDString;
        
        messageDict[@"text"] = message;
        
        messageDict[@"attachments"] =  @[
                                         @{
                                             @"type": @"image",
                                             @"url": uploadImageDict ? uploadImageDict[@"url"] : @"http://i.groupme.com/1024x640.jpeg.7ce580b2a36641eda2bdc9143cd07297"
                                             }];
        
        DLog(@"Found: %@\n %@", message, uploadImageDict);
        
        NSDictionary *finalMessage;
        
        NSString *urlString;
        NSString *groupId = userOrGroup[@"group_id"];
        NSString *accessToken = [GroupMeConnect groupMeToken:nil];
        if (groupId) {
            // POST /groups/:group_id/messages for the group
            urlString = [NSString stringWithFormat:@"https://api.groupme.com/v3/groups/%@/messages?token=%@", groupId, accessToken];
            finalMessage = @{@"message": messageDict };
        } else {
            // POST POST /direct_messages for the individual - need the recipient_id for it
            messageDict[@"recipient_id"] = userOrGroup[@"id"];
            messageDict[@"other_user_id"] = userOrGroup[@"id"];
            urlString = [NSString stringWithFormat:@"https://api.groupme.com/v3/direct_messages?token=%@", accessToken];
            finalMessage = @{@"direct_message": messageDict };
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: urlString]];
        //Set Params
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        
        
        NSError *error;
        NSData *messageData = [NSJSONSerialization dataWithJSONObject:finalMessage
                                                              options:0 // Pass NSJSONWritingPrettyPrinted if you care about the readability of the generated string
                                                                error:&error];
        
        if (! messageData) {
            DLog(@"Got an error: %@", error);
            return;
        }
#ifdef DEBUG
        NSString *postMessage = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
        DLog(@"Post Message: %@", postMessage);
#endif
        NSString *postLength = [NSString stringWithFormat:@"%d", (int)[messageData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [request setValue:accessToken forHTTPHeaderField:@"X-Access-Token"];
        
        // setting the body of the post to the request
        [request setHTTPBody:messageData];
        
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        
        NSURLResponse *response;
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse: &response
                                                                 error:&error];
        
        if (error) return;
        
#ifndef DEBUG
        __unused
#endif
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            // Try the response as string
            DLog(@"Response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            DLog(@"URL: %@", urlString);
            DLog(@"Posted Message: %@", postMessage);
        } else {
            // Check if it is success or not..
            DLog(@"response: %@", responseDictionary);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Give an appropriate message
            [MobiusoToast toast: error? @"Error in Posting the Snap" : @"The Snap is on it's way!"  inView: _container.view];
            
        });
        
    });

}

- (void) close
{
    [_authView removeFromSuperview];
}

#pragma mark - GroupMe Connect Management
-(void)groupMeTokenReceived:(NSNotification *)notification
{
    // Received a message after the connect, so we must dismiss the webview
    // Save the action and work accordingly - for now it is always to get the groups
    [GroupMeConnect send];
    
    
}


#pragma mark - Handle the Popup
#pragma mark - User Groups Selection
#pragma mark - Managing Groups
- (void) popupUserGroups: (NSArray *) groupArray
{
    if (_authView) {
        [_authView removeFromSuperview];
        _authView = nil;
    }
    if ((_groupItemsArray && ([_groupItemsArray count] > 0)) ||
        (_userItemsArray && ([_userItemsArray count] > 0))) {
        
        
        MoPopupListToo *picker = [[MoPopupListToo alloc] initWithHeaderTitle:@"Groups" cancelButtonTitle:nil confirmButtonTitle:@"Selected"];
        picker.delegate = self;
        picker.dataSource = self;
        picker.needFooterView = NO;
        picker.tag = 9999;
        picker.headerBackgroundColor =[Theme mainColor];
        [picker show];
        
    } else {
        MobiusoActionView *actionView = [Utilities setupActionView:1002 withMessage:GROUPME_NONE_MESSAGE withTitle:GROUPME_NONE_TITLE placeholderText:nil andButtons: @[@"OK"] cancelButtonTitle:nil color:[Theme signatureColor] inView: _container.view andDelegate:nil];
        // Just informational message
        [actionView showWithCompletionBlock: nil];
    }
}

/* comment out this method to allow
 PickerView:titleForRow: to work.
 */
- (NSAttributedString *)popupList:(MoPopupListToo *)pickerView
            attributedTitleForRow:(NSInteger)row
{
    
    NSUInteger count = [_groupNamesArray count];
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString: (row<count) ? _groupNamesArray[row] : _userNamesArray[row-count]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
                                            }];
    return att;
}

- (NSString *)popupList:(MoPopupListToo *)pickerView
            titleForRow:(NSInteger)row
{
    NSUInteger count = [_groupNamesArray count];
    return (row<count) ? _groupNamesArray[row] : _userNamesArray[row-count];
}

- (NSInteger)numberOfRowsInPickerView:(MoPopupListToo *)pickerView
{
    return _groupNamesArray.count + _userNamesArray.count;
}

- (void)popupList:(MoPopupListToo *)pickerView didConfirmWithItemAtRow:(NSInteger)row
{
    __block NSUInteger count = [_groupNamesArray count];
    DLog(@"Item: %@", (row<count) ? _groupNamesArray[row] : _userNamesArray[row-count]);
    
    __block NSDictionary *found = nil;
    
    if (row < count) {
        [_groupItemsArray enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            
            NSString *name = item[@"name"];
            if (IS_EQUAL(name, _groupNamesArray[row])) {
                found = item;
                *stop = YES;
                
            }
        }];
    } else {
        [_userItemsArray enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            
            NSString *name = item[@"name"];
            if (IS_EQUAL(name, _userNamesArray[row-count])) {
                found = item;
                *stop = YES;
                
            }
        }];
        
    }
    if (found) {
        // Send a message now...
        [self sendImage: _imageToSend withMessage:SHARING_MESSAGE to:found];
    }
}

- (void) popupListDidClickCancelButton:(MoPopupListToo *)pickerView
{
    _groupNamesArray = nil;
    _groupItemsArray = nil;
}


@end
