//
//  SettingsVC.m
//  Snaptica Pro
//
//  Created by Sandeep on 5/17/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#define SETTINGS_GLOBALS

#import "SettingsVC.h"
#import "AboutVC.h"
#import "LightBoxManager.h"
#import "Utilities.h"
#import "Theme.h"
#import "Strings.h"
#import "SnapticaGalleryManager.h"
#import "SettingsHeaderCell.h"
#import "SettingsManager.h"
#import "NSString+Date.h"

#define MY_SIGNATURE_SCREEN 1001

@interface SettingsVC ()
{
    NSUInteger  currentActionId;
    NSArray     *stringTable;
}
@end

@implementation SettingsVC

+ (void) load
{
    [super load];
    // Set the swtches accordingly to saved choices
#ifdef MOVED_TO_NEW_SETTINGS
    saveOriginalPhoto = [[NSUserDefaults standardUserDefaults] boolForKey:@"saveOriginalPhoto"];
    saveToCustomAlbum = [[NSUserDefaults standardUserDefaults] boolForKey:@"saveToCustomAlbum"];
    mysignature = [[NSUserDefaults standardUserDefaults] stringForKey:@"mysignature"];
#endif
    [self loadCustomStrings];
    lastIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastImageIndex"];
    
    lightboxAssets = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"lightboxAssets"]];
    [self performSelector: @selector(updateLightboxAssets) withObject: nil afterDelay: 0.5f];
    
    // Load IAP
    iapMade = [[NSUserDefaults standardUserDefaults] boolForKey:@"iapMade"];
#ifdef SETTINGS_DEBUG
    DLog(@"IAP MADE: %d", iapMade);
#endif
    

}

+ (void) loadCustomStrings
{
    // Here - just add the user's strings - combine with other strings here
    NSMutableArray *userStrings = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"customTextStrings"]];
    NSArray *cannedStrings = @[
                               @"Congratulations", @"Enjoyed the Party", @"Happy Birthday", @"Happy Anniversary", @"Invitation", @"Party Time!", @"Thinking of You", @"Wish You were here!"
                               ];
    customTextStrings = [NSMutableArray arrayWithArray: userStrings];
    if ((userStrings == nil) || ([userStrings count] == 0)) {
        // Don't Sync just yet
        //        [[NSUserDefaults standardUserDefaults] setObject:customTextStrings forKey:@"customTextStrings"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        customTextStrings = [NSMutableArray arrayWithArray: cannedStrings];
    } else {
        [cannedStrings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([userStrings indexOfObject: obj] == NSNotFound) {
                [customTextStrings addObject:obj];
            }
            
        }];
        // Sort?
        //        customTextStrings = [NSMutableArray arrayWithArray: [customTextStrings sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    // Add Todays date in a couple of formats
    [customTextStrings insertObject:[NSString stringDateCompactFromDate:[NSDate date]] atIndex:0];
    
}


+ (void) insertCustomString: (NSString *) newString
{
    NSMutableArray *userStrings = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"customTextStrings"]];
    if ([userStrings indexOfObject: newString] == NSNotFound) {
        [userStrings addObject: newString];
        [[NSUserDefaults standardUserDefaults] setObject:userStrings forKey:@"customTextStrings"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [customTextStrings addObject:newString];
    }
}

+ (void) deleteCustomString: (NSString *) deleteString
{
    NSMutableArray *userStrings = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"customTextStrings"]];
    NSUInteger index;
    if ((index=[userStrings indexOfObject: deleteString]) != NSNotFound) {
        [userStrings removeObjectAtIndex:index];
        [[NSUserDefaults standardUserDefaults] setObject:userStrings forKey:@"customTextStrings"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadCustomStrings];
    }
}

+ (BOOL) isCustomString: (NSString *) givenString
{
    NSMutableArray *userStrings = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"customTextStrings"]];
    return ([userStrings indexOfObject: givenString] != NSNotFound);
}

+ (void) incrementLastIndex
{
    lastIndex++;
    [[NSUserDefaults standardUserDefaults]  setInteger:lastIndex forKey:@"lastImageIndex"];
}

// Get the launch Image based on the device we are on...
+ (UIImage *) myLaunchImage
{
#ifdef NOTNOW
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"mylaunchimagename"];
    UIImage  *launchImage = nil;
    
    if (name == nil)
    {
        // One time hit...
        NSArray *allPngImageNames = [[NSBundle mainBundle] pathsForResourcesOfType:@"png"
                                                                       inDirectory:nil];
        
        for (NSString *imgName in allPngImageNames){
            // Find launch images
            if ([[imgName lastPathComponent] hasPrefix:@"LaunchImage"]){
                UIImage *img = [UIImage imageWithContentsOfFile:imgName];
                // Has image same scale and dimensions as our current device's screen?
                if (img.scale == [UIScreen mainScreen].scale && CGSizeEqualToSize(img.size, [UIScreen mainScreen].bounds.size)) {
                    NSLog(@"Found launch image for current device %@", img.description);
                    [[NSUserDefaults standardUserDefaults] setObject:[imgName lastPathComponent] forKey:@"mylaunchimagename"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    launchImage = img;
                    break;
                }
            }
        }
    } else {
        launchImage = [UIImage imageWithContentsOfFile:name];
    }
    return launchImage;
#endif
    
    if (launchImage == nil) {
        NSString *rootPath = [SnapticaGalleryManager rootDirectory];
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *dirContents0 = [fileManager contentsOfDirectoryAtPath:rootPath error:&error];
        if (error) return nil;
        NSString *path = [[SnapticaGalleryManager rootDirectory] stringByAppendingPathComponent:dirContents0[arc4random()%[dirContents0 count]]];
        
        // the following does not go recursively
        NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:path error:&error];
        ;
        if (error) return nil;
        NSUInteger index = arc4random()%[dirContents count];
        launchImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:dirContents[index]]];
    }
    return launchImage;

}

+ (void) syncLightboxAssets
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in lightboxAssets) {
        // Drop the image attribute - for which the file is already created
        
        NSMutableDictionary *newdict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [newdict removeObjectForKey:@"image"];
        [array addObject:newdict];
    }
    [[NSUserDefaults standardUserDefaults]  setObject:array forKey:@"lightboxAssets"];
}

+ (void) updateLightboxAssets
{
    static BOOL updateInProgress;
    if (updateInProgress) return;
    updateInProgress = YES;
    BOOL update = NO;
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
#ifdef DONTDOTHIS
    NSUInteger i = 0;
    for(NSDictionary *photoInfo in lightboxAssets){
        UIImage *img = [photoInfo objectForKey:@"image"];
        NSDictionary *newDict = nil;
        if ((img == nil) && (newDict = [LightBoxManager loadImage: photoInfo])) {
            update = YES;
            [newArray addObject: newDict];
        } else {
            [newArray addObject: photoInfo];
        }
        i++;
    }
#endif
    if (update) lightboxAssets = newArray;
    updateInProgress = NO;

}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Set Localized text
    _titleLabel.text = NSLocalizedString(@"Settings", @"");
    [self.tableView registerClass:[SettingsHeaderCell class] forCellReuseIdentifier:@"SettingsHeaderCell"];
    NSString *mysignature = [SettingsManager mySignature];
    stringTable = @[
                    NSLocalizedString(@"Save Original Photo", @""),
                    NSLocalizedString(@"Save to SNAPTICA PRO Album", @""),
                    NSLocalizedString(@"Rate Us", @""),
                    NSLocalizedString(@"Tell A Friend", @""),
                    NSLocalizedString(@"Send feedback", @""),
                    NSLocalizedString(@"About", @""),
                    NSLocalizedString(@"Like Us on Facebook", @""),
                    NSLocalizedString(@"Visit Us on Instagram", @""),
                    (_mySignatureLabel.text = mysignature? mysignature : NSLocalizedString(@"My Signature", @""))
                    ];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [Theme mainColor];
    [[UISwitch appearance] setOnTintColor:[UIColor lightGrayColor]];
//    [[UISwitch appearance] setOnTintColor:[UIColor lightGrayColor]];

#if 0
    _saveOriginalLabel.text = NSLocalizedString(@"Save Original Photo", @"");
    _saveToCustomAlbumLabel.text = NSLocalizedString(@"Save to SNAPTICA PRO Album", @"");
    _rateUsLabel.text = NSLocalizedString(@"Rate Us", @"");
    _tellAfriendLabel.text = NSLocalizedString(@"Tell A Friend", @"");
    _sendFeedbackLabel.text = NSLocalizedString(@"Send feedback", @"");
    _aboutLabel.text = NSLocalizedString(@"About", @"");
    _likeUsonFBLabel.text = NSLocalizedString(@"Like Us on Facebook", @"");
    _visitUsOnInstagramLabel.text = NSLocalizedString(@"Visit Us on Instagram", @"");
    _mySignatureLabel.text = mysignature? mysignature : NSLocalizedString(@"My Signature", @"");
    
#endif
    
    // Set the swtches accordingly to saved choices
//    saveOriginalPhoto = [[NSUserDefaults standardUserDefaults] boolForKey:@"saveOriginalPhoto"];
//    saveToCustomAlbum = [[NSUserDefaults standardUserDefaults] boolForKey:@"saveToCustomAlbum"];
    
    [_originalPhotoSwitch setOn:[SettingsManager saveOriginalPhoto]];
    [_customAlbumSwitch setOn:[SettingsManager saveToCustomAlbum]];
}

#pragma mark - Switches in the Settings
- (IBAction)saveOriginalChanged:(UISwitch *)sender {
#ifdef NOTNOW
    if (sender.isOn) {
        saveOriginalPhoto = true;
    } else {
        saveOriginalPhoto = false;
    }
#endif
    // Save choice
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"saveOriginalPhoto"];
}


- (IBAction)saveToCustomAlbum:(UISwitch *)sender {
#ifdef NOTNOW
    if (sender.isOn) {
        saveToCustomAlbum = true;
    } else {
        saveToCustomAlbum = false;
    }
#endif
    // Save choice
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"saveToCustomAlbum"];
}

#pragma mark - Table View Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stringTable count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *simpleTableIdentifier = @"Cell";
    
    SettingsHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsHeaderCell"];
    
    if (cell == nil) {
        cell = [[SettingsHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsHeaderCell"];
    }
    
    cell.backgroundColor = [Theme mainColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = stringTable[indexPath.row];
    cell.textLabel.font = SETTINGS_ITEM_FONT;
    if (cell.imageLayer == nil) {
        cell.imageLayer = [CALayer layer];
        cell.imageLayer.frame = cell.iconImageView.bounds;
        cell.imageLayer.cornerRadius = 18;
        [cell.iconImageView.layer addSublayer:cell.imageLayer];
    }
    cell.imageLayer.contents = (__bridge id)([UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"logo"]]).CGImage;
    cell.iconImageView.hidden = NO;
    cell.iconImageView.contentMode = UIViewContentModeCenter;

    
    const int switchwidth = 64;
    switch (indexPath.row) {
        case 0: // Original Album
        {

            
            _originalPhotoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.bounds.size.width - switchwidth - 20, 10, switchwidth, 24)];
            [cell addSubview:_originalPhotoSwitch];
            [_originalPhotoSwitch setOn: [SettingsManager saveOriginalPhoto]];
            [_originalPhotoSwitch addTarget:self action:@selector(saveOriginalChanged:) forControlEvents:UIControlEventValueChanged];

        }
            break;
            
        case 1: // Custom Album
        {
    
            _customAlbumSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.bounds.size.width - switchwidth - 20, 10, switchwidth, 24)];
            [cell addSubview:_customAlbumSwitch];
            [_customAlbumSwitch setOn: [SettingsManager saveToCustomAlbum ]];
            [_customAlbumSwitch addTarget:self action:@selector(saveToCustomAlbum:) forControlEvents:UIControlEventValueChanged];
        }
            break;
            
        default:
            break;
    }
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: // Save to Album
        {
            
        }
            break;
            
        case 1: // Special Album (Snaptica Pro)
        {
            
        }
            break;
            
        case 2:  // RATE US
            feedback = false;
            [[UIApplication sharedApplication] openURL:[NSURL
            URLWithString: RATE_US_LINK]];
            break;
        
        case 3:{ // TELL A FRIEND
            feedback = false;
            NSString *title = APP_NAME;
            NSString *string1 = NSLocalizedString(@"I really enjoy this app. It makes me feel like a professional photographer, I think you may love it! Check it out: ", @"");
            NSString *message = [NSString stringWithFormat:@"%@ %@", string1, ITUNES_STORE_LINK];
            [self sendMailWithTitle:title andMessage: message];
            break; }
            
        case 4:{ // SEND FEEDBACK
            feedback = true;
            NSString *title = NSLocalizedString(@"Send feedback", @"");
            NSString *message = NSLocalizedString(@"Please describe  your issues/suggestions below:", @"");
            [self sendMailWithTitle:title andMessage: message];
            break; }
            
        case 5:
        {
            // Do About
        }
         
        case 6:{ // LIKE ON FACEBOOK
            feedback = false;
            [[UIApplication sharedApplication] openURL:[NSURL
            URLWithString: FACEBOOK_PAGE_LINK]];
            break; }
 
        case 7:{ // VISIT US ON INSTAGRAM
            feedback = false;
            [[UIApplication sharedApplication] openURL:[NSURL
                                                        URLWithString: INSTAGRAM_URL]];
            break; }
            
        case 8:{ // MY SIGNATURE
            feedback = false;
            
            MobiusoVideoActionView *videoActionView = [Utilities
                                                       setupVideoActionView:MY_SIGNATURE_SCREEN
                                                       withMessage:MYSIGNATURE_STRING
                                                       withTitle:MYSIGNATURE_TITLE
                                                       placeholderText: [SettingsManager mySignature]
                                                       andButtons:@[@"USE THIS"]
                                                       cancelButtonTitle:nil
                                                       color:[Theme mainColor]
                                                       background:@"bkg1"
                                                       inView:self.view
                                                       andDelegate:self];
            
            [self.view bringSubviewToFront:videoActionView];
            [videoActionView show];
            break; }


            
        default: break;
    }
}



-(void)sendMailWithTitle:(NSString *)title andMessage: (NSString *)message  {

    // Allocs the Mail composer controller
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:title];
    [mc setMessageBody:message isHTML:true];
    if (feedback) {
    NSArray *feedbackEmail = @[FEEDBACK_EMAIL_ADDRESS];
    [mc setToRecipients:feedbackEmail];
    }
    
    // Prepare the app Logo to be shared by Email
    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"logo"]);
    [mc addAttachmentData:imageData  mimeType:@"image/png" fileName:@"logo.png"];
    
    [self presentViewController:mc animated:true completion:nil];
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
    [self dismissViewControllerAnimated:true completion: ^{
        if (message) {
            [MobiusoToast toast:message inView:self.view];
        }

    }];

}

#pragma mark - MOBIUSOACTIONVIEW DELEGATE =========
- (void) dismissActionView
{
    
}

- (void) dismissWithClickedButtonIndex:(NSInteger)buttonIndex withText:(NSString *)inputStr
{
    switch (currentActionId) {
        case MY_SIGNATURE_SCREEN:
            switch (buttonIndex) {
                case 0:
                {
                    NSString *mysig = inputStr;
                    if (inputStr && ([inputStr length]> 0)) {
                        [SettingsManager setMySignature: mysig];
                        [[NSUserDefaults standardUserDefaults] setObject: mysig forKey:@"mysignature"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        _mySignatureLabel.text = mysig;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            
        default:
            break;
    }

}

- (void) setCurrentActionViewId:(NSInteger)referenceTag
{
    currentActionId = referenceTag;
}

#pragma mark - DISMISS BUTTON =====================
- (IBAction)dismissButt:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




@end
