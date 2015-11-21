//
//  NavigationViewController.m
//  SnapticaToo
//
//  Created by sandeep on 12/31/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import "TOCMainViewController.h"
#import "AppDelegate.h"
//#import "CacheManager.h"
#import "SettingsItemModel.h"

//#import "OldNavigationCell.h"
#import "Utilities.h"
#import "Strings.h"
#if 0
#import "SettingsManager.h"
#endif
#import "SettingsHeaderCell.h"
#import "SettingsLinkCell.h"
#import "SettingsTextCell.h"
#import "SettingsBoolCell.h"
#import "MobiusoActionView.h"
#import "TestTOC.h"



#import "UIImage+RemapColor.h"

@interface TOCMainViewController ()
{
    int                 currentServer;

}
@property (retain, nonatomic) UITextField           *currentResponder;
@property (nonatomic, assign) CGFloat               keyboardHeight;
@property (nonatomic, assign) CGFloat               keyboardMoveOffset;
@property (nonatomic, assign) BOOL                  keyboardVisible;

@end

@implementation TOCMainViewController

#pragma mark - View Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _currentItem = -1;
    
    _logoImage.layer.cornerRadius = 10;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    [_logoImage addGestureRecognizer:gesture];
    _logoImage.userInteractionEnabled = YES;
    _logoImage.clipsToBounds = YES;

    UIImage *image = [UIImage imageNamed:@"bg-dark.jpg"];  // bkg1.png
#undef SETTINGS_DEBUG
#ifdef SETTINGS_DEBUG
    CGRect frame = _bgImageView.frame;
    DLog(@"Frame: %.1f, %.1f, %.1f, %.1f\n", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
#endif
    _bgImageView.frame = _dimmerView.frame = [Utilities applicationFrame];
    _bgImageView.image = image;
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    _dimmerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    
    // Try the TOC from test data
    _items = [TestTOC populateItems: @"toc.json"];
#ifdef SETTINGS_DEBUG
    DLog(@"JSON: %@", [Utilities jsonString: [NSDictionary dictionaryWithObject:_items forKey:@"item"]]);
#endif
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
     
                                               object:nil];

#if 0
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingNeedsRefresh)
                                                 name: LOCAL_NOTIFICATION_SERVER_ADDED     
                                               object:nil];
    [SettingsManager instance].delegate = self;
#endif

}

//
- (void) viewDidDisappear:(BOOL)animated
{
    
#if 0
    [[NSNotificationCenter defaultCenter] postNotificationName: LOCAL_NOTIFICATION_SETTINGS object:nil];
    [SettingsManager instance].delegate = nil;
#endif

}

- (void) back: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#if 0
#pragma mark - convenience methods for view
- (void) settingNeedsRefresh
{
    _items = [SettingsManager populateItems];
    [_tableView reloadData];
}
#endif


#pragma mark - TableView Delegate Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // '4' was added to elongate the line below on the table to make a longer vertical line?  Removing 20150717
    return /* 4 + */ [_items count] + (_currentItem>=0 ? [((SettingsItemModel *)_items[_currentItem]).children count]:0) ;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    SettingsItemModel *item = nil;
    if ((_currentItem < 0) || (row <= _currentItem)) {  // Primary Items
        if (row < [_items count]) {
            item = [_items objectAtIndex: row];
        }
    } else if (row > (_currentItem + [((SettingsItemModel *)[_items objectAtIndex: _currentItem]).children count])) { // Primary Items
        NSUInteger index = row - [((SettingsItemModel *)[_items objectAtIndex: _currentItem]).children count];
        item = (index < [_items count]) ? [_items objectAtIndex: index] : nil;
    } else {    // Secondary Items
        NSArray *subitems = ((SettingsItemModel *)[_items objectAtIndex:_currentItem]).children;
        if (row-_currentItem-1 < [subitems count]) {
            item = [subitems objectAtIndex:row-_currentItem-1];
        }
    }
    
    
    // Check if we are clicking on the main item or the subitem
    // Here we are clicking on the main item
    SettingsCell *returnCell;
    
    if (item) {
        switch (item.type) {
            case SettingsItemStyleHeader:
            {
                SettingsHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsHeaderCell"];
                cell.titleLabel.text = item.title;
                cell.settingsItem = item;
                if (cell.imageLayer == nil) {
                    cell.imageLayer = [CALayer layer];
                    cell.imageLayer.frame = cell.iconImageView.bounds;
                    cell.imageLayer.cornerRadius = 18;
                    [cell.iconImageView.layer addSublayer:cell.imageLayer];
                }
                cell.imageLayer.contents = (__bridge id)([UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:item.icon]]).CGImage;
                cell.iconImageView.hidden = NO;
                cell.iconImageView.contentMode = UIViewContentModeCenter;
                returnCell = cell;
                
            }
                break;
                
            case SettingsItemStyleText:
            case SettingsItemStyleName:
            case SettingsItemStyleEmail:
            case SettingsItemStylePassword:
            {
                // For now
                SettingsTextCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTextCell"];
                if (item.type == SettingsItemStylePassword) {
                    cell.inputText.secureTextEntry = YES;
                    cell.inputText.autocapitalizationType = UITextAutocapitalizationTypeNone;
                } else if (item.type == SettingsItemStyleName) {
                    cell.inputText.autocapitalizationType = UITextAutocapitalizationTypeWords;
                } else {
                    cell.inputText.secureTextEntry = NO;
                    if (item.type == SettingsItemStyleEmail) {
                        cell.inputText.keyboardType = UIKeyboardTypeEmailAddress;
                        cell.inputText.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    }
                }
                cell.titleLabel.text = item.title;
                cell.settingsItem = item;
                //        cell.countLabel.text =  item.count;
                cell.iconImageView.image = [UIImage imageNamed:item.icon];
                cell.iconImageView.hidden = NO;
                if (item.value && ([item.value length] > 0)) {
                    cell.inputText.text = item.value;
                    //                cell.titleLabel.hidden = YES;   // Actually animate it as a label just below the line
                } else {
                    cell.inputText.text = nil;
                    cell.inputText.placeholder = item.placeholder;
                }
                cell.delegate = self;
                returnCell = cell;
                
            }
                break;
                
            case SettingsItemStyleWebRef:
            case SettingsItemStyleWebExternalRef:
            case SettingsItemStyleBundleFileRef:
            case SettingsItemStyleBundleClassRef:
            {
                // For now
                SettingsLinkCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsLinkCell"];
                [cell setLabel: item.title];
                cell.settingsItem = item;
                cell.iconImageView.image = [UIImage imageNamed:item.icon];
                cell.iconImageView.hidden = NO;
                returnCell = cell;
                
            }
                break;
                
            case SettingsItemStyleBOOL:
            {
                SettingsBoolCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsBoolCell"];
                cell.titleLabel.text = item.title;
                //        cell.countLabel.text =  item.count;
                cell.iconImageView.image = [UIImage imageNamed:item.icon];
                cell.iconImageView.hidden = NO;
                cell.settingsItem = item;
                if (item.value) {
                    [cell.boolSwitch setOn:[(NSNumber *) item.value boolValue]];
                    //                cell.titleLabel.hidden = YES;   // Actually animate it as a label just below the line
                } else {
                    // If there is no value - need to set the switch to OFF  to reflect the correct value
                    [cell.boolSwitch setOn:NO];
                }

                
                returnCell = cell;
            }
                break;
                
                
            default:
                break;
        }
    } else {
        SettingsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
        returnCell = cell;
    }

    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor clearColor];
    [returnCell setSelectedBackgroundView:bgColorView];
    returnCell.backgroundColor = [UIColor clearColor];
    returnCell.controller = self;

    return returnCell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // We allow only 1 level of hierarchy
    NSUInteger row = indexPath.row;
    SettingsItemModel *item;
    NSInteger index;
    if ((_currentItem < 0) || (row <= _currentItem)) {
        item = [_items objectAtIndex: row];
        index = row;
    } else if (row > (_currentItem + [((SettingsItemModel *)[_items objectAtIndex: _currentItem]).children count])) {
        index = row - [((SettingsItemModel *)[_items objectAtIndex: _currentItem]).children count];
        item = [_items objectAtIndex: index];
    } else {
        NSArray *subitems = ((SettingsItemModel *)[_items objectAtIndex:_currentItem]).children;
        item = [subitems objectAtIndex:row-_currentItem-1];
        index = -1;
    }

    if (_keyboardVisible) {
        [_currentResponder resignFirstResponder];   // this should close out the keyboard
    } else {
        if (row==_currentItem) { // close out the view
            _currentItem = -1;
            [tableView reloadData]; //
        } else if ((item.children != nil) && (index>=0)) {
            _currentItem = index;
            [tableView reloadData];
        }
    }

}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

// Respond to the dismiss gesture - this closes the view - so let's post a notification for change
-(void)handleTap:(id)sender {
    
    if (((UITapGestureRecognizer *)sender).state != UIGestureRecognizerStateEnded) return;
    
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#define OLDSTYLE

#pragma mark - Keyboard
#ifdef NEWSTYLE
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
        [UIView commitAnimations];
    });
    return YES;
}

- (NSInteger)getKeyBoardHeight:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    NSInteger keyboardHeight = keyboardFrameBeginRect.size.height;
    return keyboardHeight;
}

-(void) keyboardWillShow:(NSNotification*) notification
{
    NSInteger keyboardHeight;
    keyboardHeight = [self getKeyBoardHeight:notification];
    NSInteger scrollViewFrameHeight = self.view.frame.size.height;
    NSInteger textFieldRelativePosition = self.tableView.frame.origin.y - self.tableView.contentOffset.y;
    NSInteger textFieldFrameOffset = scrollViewFrameHeight - textFieldRelativePosition;
    NSInteger movement = MAX(0,keyboardHeight-textFieldFrameOffset); // Offset from where the keyboard will appear.
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.view.frame = CGRectMake(0,-movement,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height);
        [UIView commitAnimations];
    });
}

-(void)keyboardWillHide:(NSNotification*) notification
{
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
}
#endif

#ifdef OLDSTYLE
#define kOFFSET_FOR_KEYBOARD 80.0

- (void)getKeyBoardHeight:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    _keyboardHeight = keyboardFrameBeginRect.size.height;
}

-(void)keyboardWillShow:(NSNotification*) notification
{
    [self getKeyBoardHeight:notification];
    
    _keyboardVisible = YES;
    
    CGRect frame = [[_currentResponder superview] superview].frame;
#ifdef SETTINGS_DEBUG

    DLog(@"current y=%f, height=%f", frame.origin.y, frame.size.height);
    DLog(@"Tableview y=%f, offset=%f", [_tableView frame].origin.y, _tableView.contentOffset.y);
#endif
    
    CGFloat fieldbottom = frame.origin.y + frame.size.height + ([_tableView frame].origin.y  - _tableView.contentOffset.y);
    
    // if the bottom part of the field cell is below the top of the keyboard, we need to move it by that much
    CGFloat topofthekeyboard = (self.view.frame.size.height - _keyboardHeight);
    _keyboardMoveOffset = (fieldbottom > topofthekeyboard) ?  (fieldbottom - topofthekeyboard) : 0;
    // Animate the current view out of the way

    [self setViewMovedUp:YES];
}

-(void)keyboardWillHide:(NSNotification*) notification
{
    _keyboardVisible = NO;
    
    [self setViewMovedUp:NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    _currentResponder = sender;
    
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{

    // move the tableview offset by the amount of offset
    CGPoint offset = _tableView.contentOffset;
    offset.y +=  (movedUp? 1 : -1) * _keyboardMoveOffset;
 
    [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:4.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        _tableView.contentOffset = offset;
        
        
    } completion:^(BOOL finished) {
        
        //        [transitionContext completeTransition:YES];
    }];

}

-(BOOL)textFieldShouldReturn:(UITextField*)textFld;
{
    return YES;
}

#endif


#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldEndEditing: (UITextField *)textFld
{
#ifdef SETTINGS_DEBUG
    DLog(@"Text: %@", textFld.text);
#endif
    
    return YES;
}



-(void) textFieldDidEndEditing: (UITextField *)textFld
{
    
}


/*
#pragma mark - Navigation
 

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
