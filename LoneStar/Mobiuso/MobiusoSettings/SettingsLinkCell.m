//
//  SettingsLinkCell.m
//  SnapticaToo
//
//  Created by sandeep on 1/23/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//


#import "SettingsLinkCell.h"
#import "SettingsItemModel.h"
#import "Utilities.h"
#import "Theme.h"
#import "UIImage+RemapColor.h"
#import "Configs.h"
#import "MobiusoToast.h"
#import "AppDelegate.h"

@implementation SettingsLinkCell

- (void)awakeFromNib {
    // Initialization code
    self.titleLabel.font = [UIFont fontWithName: @"Avenir-Book" size: 15];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = @"";
    
    
    self.iconImageView.backgroundColor = [UIColor clearColor];
    
    self.lineView.layer.opacity = 0.6;
    self.lineView.backgroundColor = [UIColor blackColor];
    
    // Add a tap gesture recognizer
    self.titleLabel.userInteractionEnabled = YES;
    [self setTapDelegate:self withAction:@selector(handleTap:)];
    
}

- (void) setLabel: (NSString *) str
{
    NSDictionary* attribs = @{NSFontAttributeName:self.titleLabel.font};
    CGSize sz = [str sizeWithAttributes:attribs];
#ifdef SETTINGS_DEBUG
    DLog(@"Size: w=%f, h=%f", sz.width, sz.height);
#endif
    self.titleLabel.text = str;
#if 0
    CALayer *layer = self.titleLabel.layer;

    for (CALayer *lyr in [self.titleLabel.layer sublayers]) {
        [lyr removeFromSuperlayer];
    }
#endif
    
    CALayer *shimLayer = _shimView.layer;
    CGRect frame = [self.titleLabel frame];
    frame.origin.x -= 2; frame.size.width = sz.width + 4;
    shimLayer.frame = frame;
    shimLayer.backgroundColor = [UIColor blackColor].CGColor;
    shimLayer.cornerRadius = 4.0f;
    shimLayer.opacity = 0.5f;
    
#if 0
    CATextLayer *textlayer = [CATextLayer layer];
    textlayer.opacity = 1.0f;
    textlayer.font = (__bridge CFTypeRef)(self.titleLabel.font.fontName);
    textlayer.fontSize = 13;
    textlayer.backgroundColor = [UIColor clearColor].CGColor;
    textlayer.foregroundColor = [UIColor whiteColor].CGColor;
    textlayer.string = str;
    textlayer.frame = [self.titleLabel bounds];
    [layer addSublayer:textlayer];
#endif
    
}

-(void) handleTap:(id) sender
{
    
#ifdef SETTINGS_DEBUG
    DLog(@"Tapped: %@", self.settingsItem.placeholder);
#endif
    
    if (self.settingsItem.type == SettingsItemStyleBundleFileRef) {
        NSArray *classrefunits = [self.settingsItem.placeholder componentsSeparatedByString:@":"];
        
        if ([classrefunits count] == 1) {
            
        } else {
            NSString *container = classrefunits[0];
            NSString *class = classrefunits[1];
            id controller;
            if ([container hasSuffix:@".xib"]) {
                NSString *nibname = [container substringToIndex:([container length]-[@".xib" length])];
                controller = [(UIViewController *) [NSClassFromString(class) alloc]initWithNibName:nibname bundle:nil];
                
            } else {    // has to be storyboard
                NSString *storyboardname = [container hasSuffix:@".storyboard"]? [container substringToIndex:([container length]-[@".storyboard" length])] : container;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardname bundle:nil];
            
                controller = [storyboard instantiateViewControllerWithIdentifier: class];
            
            }
            [self.controller presentViewController:controller animated:YES completion:nil];
        }
        
    } else {
        [self link];
    }
}

- (void) setTapDelegate: (id <UIGestureRecognizerDelegate>) delegate withAction: (SEL) selector
{
    _tapLinkRecognizer = [[UITapGestureRecognizer alloc]
                                          initWithTarget: delegate action: selector]; //
    [_tapLinkRecognizer setDelegate: delegate];
    _tapLinkRecognizer.numberOfTapsRequired = 1;
    [self.titleLabel addGestureRecognizer:_tapLinkRecognizer];
    
    
}

// Local content - PDF, etc
#if 0
- (void) loadBundledFile: (NSString *) localFile {
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource: localFile ofType: nil];
    
    if (thePath) {
        
        NSData *pdfData = [NSData dataWithContentsOfFile:thePath];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:[Utilities applicationFrame]];
        [webView loadData:pdfData MIMEType:@"application/pdf"
                        textEncodingName:@"utf-8" baseURL:nil]; // NSUTF8StringEncoding
        [self.controller.view addSubview:webView];
        
        
    }
    
}
#endif

//     NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"404" ofType:@"html" inDirectory:@"www"]];

// Webview
- (UIWebView *) webView: (NSURL *) url
{
    CGRect frame = [Utilities applicationFrame];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    webView.scalesPageToFit = YES;
    
#ifdef ORIGINAL
    // Add a cancel button to the header
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(frame.size.width - 40, 8, 32, 32);
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[UIImage imageNamed:@"dismissButt"] forState:UIControlStateNormal];   // SimpleCloseLine.png
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
#if 1
    closeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    closeButton.layer.shadowRadius = 2.0f;
    closeButton.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    closeButton.layer.shadowOpacity = 1.0f;
#endif

    [webView addSubview: closeButton];
#else
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(frame.size.width - 40, 8, 32, 32);
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
//    [closeButton setImage:[UIImage imageNamed:@"dismissButt"] forState:UIControlStateNormal];   // SimpleCloseLine.png

    [closeButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"dismissButt"]] forState:UIControlStateNormal];
    closeButton.layer.cornerRadius = 16;
    closeButton.layer.backgroundColor = COLORFROMHEX(0x80000000).CGColor;
    CALayer *sublayer = [CALayer layer];
    sublayer.frame = [closeButton bounds];
    sublayer.contents = (__bridge id)([UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"dismissButt"]].CGImage);
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [webView addSubview: closeButton];
#endif
    
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.controller.view addSubview:webView];
    return webView;
    
}
- (void) loadBundledHtmlFile: (NSString *) link inFolder: (NSString *) folderRef
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource: link ofType:nil inDirectory:folderRef]];
    _webView = [self webView:url];
}

- (void) loadURL: (NSString *) urlString
{
    NSURL *url;
    
    if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:urlString];
    } else {
        NSString *filename = [urlString lastPathComponent];
        NSRange slash = [urlString rangeOfString: @"/"];
        
        NSString *folder = nil;
        if (slash.location != NSNotFound)  {
            
            // This is encrypted file
            folder = [NSString stringWithFormat:@"%@",[urlString substringToIndex:(slash.location)]];
        }

        if (filename) {
            url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType: nil inDirectory:folder]];
        }
        
    }
    if (url) {
        _webView = [self webView: url];
    }
    
}


- (void) link
{
//    [self loadBundledHtmlFile:@"404.html" inFolder:@"www"];
    if (self.settingsItem.type == SettingsItemStyleWebExternalRef) {
        DLog(@"open external browser: %@", self.settingsItem.placeholder);
        [self.controller dismissViewControllerAnimated:NO completion:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.settingsItem.placeholder]];
        }];
    } else if ([self.settingsItem.placeholder hasPrefix:@"mailto://"]) {
        // split the string
        NSString *temp = [self.settingsItem.placeholder substringFromIndex:[@"mailto://" length]];
        NSArray *units = [temp componentsSeparatedByString: @"#SLASH#" ];
        NSString *to, *subject, *message;
        if ([units count] >= 2) {
            subject = units[0];
            message = units[1];
        } else {
            subject = APP_NAME;
            message = units[0];
        }
        to = ([units count] > 2) ? units[2] : nil;
        [self sendMailWithTitle:subject andMessage: message toAddress: to andImage:(to? @"logo.png": @"message1.jpg")];
    } else {
        [self loadURL:self.settingsItem.placeholder];
        
    }
}

- (void) close
{
    [_webView removeFromSuperview];
}


-(void)sendMailWithTitle:(NSString *)title andMessage: (NSString *)message toAddress: (NSString *) toAddress andImage: (NSString *) imageName
{
    
    // Allocs the Mail composer controller
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if (mc) {
        mc.mailComposeDelegate = self;
        [mc setSubject:title];
        [mc setMessageBody:message isHTML:true];
        if (toAddress) {
            NSArray *feedbackEmail = @[toAddress];
            [mc setToRecipients:feedbackEmail];
        }
        
        // Prepare the app Logo to be shared by Email
        NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:imageName]);
        NSString *mimeType = @"image/png";
        NSString *fileName = imageName;
        if ([imageName hasSuffix:@"jpg"]) {
            mimeType = @"image/jpg";
            fileName = imageName;
            
        }
        [mc addAttachmentData:imageData  mimeType:mimeType fileName:fileName];
        
        [self.controller presentViewController:mc animated:true completion:nil];
    } else {
        
        // Show an alert as sharing result when the Document Interaction Controller gets dismissed
        [MobiusoToast toast:NSLocalizedString(@"Please configure Email app!", @"") inView:self.controller.view];
    }
}


// Email delegates ================
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)results error:(NSError *)error {
    NSString *message = nil;
    switch (results) {
        case MFMailComposeResultCancelled: {
            message = NSLocalizedString(@"Email Cancelled", @"");
        }
            break;
            
        case MFMailComposeResultSaved:{
            message = NSLocalizedString(@"Email Saved", @"");
        }
            break;
            
        case MFMailComposeResultSent:{
            message = NSLocalizedString(@"Email Sent", @"");
        }
            break;
            
        case MFMailComposeResultFailed:{
            message = NSLocalizedString(@"Email error, try again", @"");
        }
            break;
            
            
        default: break;
    }
    
    // Dismiss the Email View Controller
    [self.controller dismissViewControllerAnimated:true completion: ^{
        if (message) {
            [MobiusoToast toast:message inView:self.controller.view];
        }
        
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
