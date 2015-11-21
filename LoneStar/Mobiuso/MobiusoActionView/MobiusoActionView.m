//
//  MobiusoActionView
//  MobiusoActionView
//
//  Created by sandeep on 12/20/14.
//  Updated 07/13/2015
//  Copyright (c) 2014 Sandeep. All rights reserved.
//  Updated 09/09/2015
//


#import "MobiusoActionView.h"
#import "UIColor+FlatColors.h"
#import "NSString+StringSizeWithFont.h"
#import "Constants.h"
#import "Theme.h"
#import "UIImage+RemapColor.h"


#undef DEBUG
@interface MobiusoActionView ()
{
    UILabel                     *overlayTitle;
    
    UITextView                  *overlayDetails;
    
    UITextView                  *inputField;
    
    CGRect                      paneFrame;
    
    PaneState                   paneState;    // shows the current state
    
    CAShapeLayer                *shapeLayer;
    
    BOOL                        addedCancelButton;
    
    BOOL                        inputExpected;
    
    BOOL                        keyboardShowing;
    
    
    ActionCompletionBlock       actionCompletionBlock;
    
#if 0 // Menu Experiments - fails to remove the standard items
    UIMenuController            *menu;
#endif
    
    UIButton                    *clearTextButton;
    
    UIButton                    *popupButton;
    UITableView                 *popupTableView;
    UIButton                    *okButton;
    BOOL                        popupTableVisible;
    
    NSArray                     *filteredPopupArray;
    NSString                    *filterString;
    
    NSTimer                     *searchToFireTimer;
    
    UITapGestureRecognizer      *tapRecognizer;
    UIPanGestureRecognizer      *panRecognizer;
}

@end


@implementation MobiusoActionView
@synthesize popupArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup: frame];
    }
    return self;
}

- (id) initWithTitle: (NSString *) title
            delegate: (id<MobiusoActionViewDelegate>) delegate
          andMessage: (NSString *) message
     placeholderText: (NSString *) suggestion
   cancelButtonTitle: (NSString *) cancelButtonTitle
   otherButtonTitles: (NSArray *) buttonTitleArray
               color: (UIColor *) color
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    return [self initWithTitle:title delegate:delegate andMessage:message placeholderText:suggestion cancelButtonTitle:cancelButtonTitle otherButtonTitles:buttonTitleArray color:color frame:frame];
}

- (id) initWithTitle: (NSString *) title
            delegate: (id<MobiusoActionViewDelegate>) delegate
          andMessage: (NSString *) message
     placeholderText: (NSString *) suggestion
   cancelButtonTitle: (NSString *) cancelButtonTitle
   otherButtonTitles: (NSArray *) buttonTitleArray
               color: (UIColor *) color
               frame: (CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonArray = [NSMutableArray arrayWithArray:buttonTitleArray];
        self.actionTitle = title;
        self.paneColor = color;
        self.buttonTextColor = color;
        _messageStr = message;
        // Let there be an explicit cancel button if a text entry is indicated
        if ((suggestion != nil) || (cancelButtonTitle != nil)) {
            [self.buttonArray addObject: ((cancelButtonTitle!=nil)? cancelButtonTitle:@"CANCEL")];
            addedCancelButton = YES;
        }
        inputExpected = (suggestion != nil);
        self.placeholderText = suggestion;
        self.delegate = delegate;
        self.secureTextEntry = NO;
    }
    return self;
    
}

- (void) setMessageStr:(NSString *)str
{
    _messageStr = str;
    CGRect frame = [[UIScreen mainScreen] bounds];
    [self setup:frame];
}



- (UIView *) setupBackgroundView
{
    // Blur Effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [bluredEffectView setFrame:self.bounds];
    
    
    // Vibrancy Effect
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    // vibrancyEffectView.backgroundColor = COLORFROMHEX(0xff990000);
    [vibrancyEffectView setFrame:self.bounds];
    // Add Vibrancy View to Blur View
    [bluredEffectView addSubview:vibrancyEffectView];
    // Add Label to Vibrancy View
    return bluredEffectView;
    
}

- (void) refresh
{
    
}

- (void) setup: (CGRect)frame
{
    //? self.frame = frame;
    self.backgroundColor = [UIColor clearColor];
    self.paneColor = (self.paneColor==nil) ? [UIColor grayColor] : self.paneColor;
    
    CGFloat k = ([Theme buttonHeight] < 40) ? 8 : 16;
    
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:tapRecognizer];
    
    _shadedView = [self setupBackgroundView];
    [self addSubview: _shadedView];
    
    CGSize size = CGSizeMake(frame.size.width - TEXT_MARGIN, 500);
    UIFont *messageFont = [UIFont fontWithName:@"Helvetica Neue" size:16];
    CGRect rect = [self.messageStr boundingRectWithSize:size Font:messageFont];
    NSUInteger buttonCount = [self.buttonArray count];
    
    CGRect rect2 = CGRectZero;
    
    UIFont *inputTextFont;
    if (inputExpected) {
        inputTextFont = [UIFont fontWithName:@"Avenir Next Condensed" size:18];
        rect2 = [self.placeholderText boundingRectWithSize:size Font:inputTextFont];
        
    }
    
    CGFloat buttonTop = rect.size.height + MOACTION_TITLE_HEIGHT + k*6 + rect2.size.height + k*2 + 24;
    CGFloat viewHeight =  buttonTop + buttonCount * ([Theme buttonHeight] + k);
    CGRect viewFrame = frame;
    viewFrame.origin.y = frame.size.height - viewHeight;
    viewFrame.size.height = viewHeight;
    paneFrame = viewFrame;
    
    viewFrame.origin.y += viewFrame.size.height;    // initially outside the view...
    
    _pane = [[UIView alloc] initWithFrame:viewFrame];
    _pane.backgroundColor = self.paneColor;
    [self addShapeLayer:_pane];
    
    
    [_shadedView addSubview:_pane];
    
    // We add the dragging action for closing (only if there is no editable text)
    if (!inputExpected) {
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [_pane addGestureRecognizer:panRecognizer];
    }
    
    
    overlayTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, frame.size.width, 32)];
    overlayTitle.textColor = [UIColor whiteColor];
    overlayTitle.textAlignment = NSTextAlignmentCenter;
    overlayTitle.text = self.actionTitle;
    overlayTitle.font = [UIFont fontWithName:@"Helvetica Neue" size:24];
    
    
    overlayDetails = [[UITextView alloc] initWithFrame:CGRectMake(TEXT_MARGIN/2, k*2 + MOACTION_TITLE_HEIGHT, frame.size.width - TEXT_MARGIN, rect.size.height + 32)];
    overlayDetails.textColor = [UIColor whiteColor];
    overlayDetails.backgroundColor = [UIColor clearColor];
    overlayDetails.font = messageFont;
    overlayDetails.textContainerInset = UIEdgeInsetsMake(0, 12, 0, 12);
    overlayDetails.editable = NO;
    overlayDetails.text = self.messageStr;
    overlayDetails.clearsOnInsertion = NO;
    
    
    
    
    [_pane addSubview:overlayTitle];
    //[_pane addSubview:self.movieReleaseDate];
    [_pane addSubview:overlayDetails];
    
    if (inputExpected) {
        CGRect inputFieldRect = CGRectMake((TEXT_MARGIN-24)/2, k*2 + MOACTION_TITLE_HEIGHT + rect.size.height + k*2, frame.size.width - TEXT_MARGIN + 24 /* inset */, rect2.size.height + 16 + k /* inset */);
        inputField = [[UITextView alloc] initWithFrame:inputFieldRect];
        // Secure Text or Not
        inputField.secureTextEntry = _secureTextEntry;
        
        inputField.textColor = [UIColor whiteColor];
        inputField.backgroundColor = COLORFROMHEX(0x50000000);
        inputField.font = inputTextFont;
        inputField.textContainerInset = UIEdgeInsetsMake(k/2, 12, 12, k/2);
        inputField.editable = YES;
        inputField.text = self.placeholderText;
        // Auto capitalization and security stuff
        inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        inputField.returnKeyType = UIReturnKeyDone;
        
        
        inputField.layer.cornerRadius = 6.0f;
        inputField.delegate = self;
        
        //         inputField.clearsOnInsertion = YES;
        
        [_pane addSubview:inputField];
        
        // Here we add the keyboard notification
        // register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide)
                                                     name:UIKeyboardWillHideNotification
         
                                                   object:nil];
        
        
#if 0 // For debugging
        popupArray = @[@"One", @"two", @"three", @"One", @"two", @"three", @"One", @"two", @"three"];
#endif
        
        if (popupArray) {
            popupButton = [UIButton buttonWithType: UIButtonTypeCustom];
            
            [popupButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed: @"menu-plus-solid-72.png"] ] forState:UIControlStateNormal];
            [popupButton setFrame:CGRectMake(inputFieldRect.size.width - 32, 6,26,26)];
            [popupButton addTarget:self action:@selector(didPressPopup:) forControlEvents: UIControlEventTouchUpInside];
            [inputField addSubview:popupButton];
            //            popupButton.hidden = ([self.placeholderText length] == 0);
            popupTableVisible = NO;
        }
        
        clearTextButton = [UIButton buttonWithType: UIButtonTypeCustom];
        
        [clearTextButton setImage: [UIImage imageNamed: @"SimpleCloseSolid.png"] forState:UIControlStateNormal];
        [clearTextButton setFrame:CGRectMake(inputFieldRect.size.width - (popupArray? 64:32), 6,26,26)];
        [clearTextButton addTarget:self action:@selector(didPressClear:) forControlEvents: UIControlEventTouchUpInside];
        [inputField addSubview:clearTextButton];
        clearTextButton.hidden = ([self.placeholderText length] == 0);
        
#if 0 // Menu Experiments - fails to remove the standard items
        menu = [UIMenuController sharedMenuController];
        UIMenuItem* miCustom1 = [[UIMenuItem alloc] initWithTitle:@"Custom 1" action:@selector(onCustom1:)];
        UIMenuItem* miCustom2 = [[UIMenuItem alloc] initWithTitle: @"Custom 2" action:@selector(onCustom2:)];
        menu.menuItems = @[miCustom1, miCustom2];
        [menu setTargetRect:inputFieldRect inView:_pane];
        [menu update];
#endif
        
    }
    
    
    // Add buttons as necessary
    CGRect buttonframe = CGRectMake(0, 0, [Theme buttonHeight], [Theme buttonHeight]);
    int i = 0;
    CGFloat top = buttonTop;
    UIColor *randomColor = [UIColor whiteColor];
    for (NSString *buttonTitle in self.buttonArray) {
        UIView *view = [[UIView alloc]initWithFrame:buttonframe];
        view.center = CGPointMake(160, top);
        top += [Theme buttonHeight] + k;
        view.backgroundColor = randomColor;
        view.layer.cornerRadius = [Theme buttonHeight]/2;
        view.tag = BUTTON_TAG_BASE+i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonTapped:)];
        [view addGestureRecognizer:tap];
        
        UILabel *buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [Theme buttonHeight], [Theme buttonHeight])];
        buttonLabel.textColor = self.buttonTextColor;
        buttonLabel.textAlignment = NSTextAlignmentCenter;
        buttonLabel.text = buttonTitle;
        buttonLabel.font = [UIFont fontWithName:@"Roboto-Light" size:18];
        buttonLabel.tag =BUTTON_TITLE_TAG_BASE+i;
        buttonLabel.alpha = 0;
        
        
        [view addSubview:buttonLabel];
        
        [_pane addSubview:view];
        
        i++;
    }
    
    paneState = PaneStateClosed;
    
}

- (UIBezierPath *) pathAtInterval: (CGRect) rect withOffset: (CGFloat) yOffset
{
    // CGFloat yOffset= 20.0;
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(0.0, 0)];
    [bezierPath addQuadCurveToPoint: CGPointMake(width, 0) controlPoint: CGPointMake(width / 2.0, yOffset + /*sideToCenterDelta*/ 0)];
    [bezierPath addLineToPoint:CGPointMake(width, height)];
    [bezierPath addLineToPoint:CGPointMake(0.0f, height)];
    [bezierPath closePath];
    return bezierPath;
    
}

- (void)addShapeLayer: (UIView *) view
{
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [[self pathAtInterval:view.frame withOffset:0.0f] CGPath];
    // shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [self.paneColor CGColor];
    [view.layer addSublayer:shapeLayer];
}

#if 0
- (void) setPaneColor:(UIColor *)paneColor
{
    _paneColor = paneColor;
    self.buttonTextColor = paneColor;
    
    _pane.backgroundColor = paneColor;
    // adjust the textcolors as well
    for (int i=0; i<=[self.buttonArray count]; i++) {
        UILabel *label = (UILabel *)[_shadedView viewWithTag:(BUTTON_TITLE_TAG_BASE+i)];
        label.textColor = paneColor;
    }
}

- (void) setTextColor:(UIColor *)color
{
    self.buttonTextColor = color;
    
    // adjust the textcolors as well
    for (int i=0; i<=[self.buttonArray count]; i++) {
        UILabel *label = (UILabel *)[_shadedView viewWithTag:(BUTTON_TITLE_TAG_BASE+i)];
        label.textColor = color;
    }
}
#endif


- (void) drawPane: (NSNumber *) speed
{
    CGFloat delta = [speed floatValue];
#ifdef DEBUG
    DLog(@"Delta: %f", delta);
#endif
    
    shapeLayer.path = [[self pathAtInterval: _pane.frame withOffset: ((delta>30.0f)? -30.0f: -delta)] CGPath];
    shapeLayer.fillColor = [self.paneColor CGColor];
}

- (void)didPan:(UIPanGestureRecognizer *)recognizer
{
    if (popupTableVisible) return;
    CGPoint point = [recognizer translationInView:self];  // self.superview
    _pane.center = CGPointMake(_pane.center.x, _pane.center.y + point.y);
    [recognizer setTranslation:CGPointZero inView:self]; // self.superview
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];    // // self.superview
        velocity.x = 0;
        [self actionView:self draggingEndedWithVelocity:velocity];
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self actionViewBeganDragging:self];
    }
}

- (void)didTap:(UITapGestureRecognizer *)tapRecognizer
{
    if (popupTableVisible) return;
    DLog(@"tapped on the draggable view - closing");
    if (keyboardShowing) {
        // Hide the keyboard
        [inputField resignFirstResponder];
    } else {
        if (actionCompletionBlock) {
            actionCompletionBlock(self, -1, nil);
        } else {
            
            if([(NSObject *)self.delegate respondsToSelector:@selector(dismissActionView)]){
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(dismissActionView) withObject:nil waitUntilDone:NO];
            }
        }
        [self animateToggle];
    }
}


- (void) buttonTapped:(UITapGestureRecognizer *)recognizer
{
    // DLog(@"tapped on the button: %d", [tapRecognizer view].tag);
    // Dismiss the view
    [self animateToggle];
    [inputField resignFirstResponder];  // Hide the Keyboard
    NSInteger buttonIndex = ([recognizer view].tag - BUTTON_TAG_BASE);
    if (actionCompletionBlock) {
        actionCompletionBlock(self, buttonIndex, (inputExpected? inputField.text : nil));
    } else {
        [self.delegate dismissWithClickedButtonIndex: buttonIndex withText:(inputExpected? inputField.text : nil)];
    }
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void) viewWillCompleteAnimation
{
#ifdef ACTION_DEBUG
    DLog(@"Animation complete");
#endif
    for (int i=0; i<= [self.buttonArray count]; i++) {
        UIView *view = [_shadedView viewWithTag:(BUTTON_TAG_BASE+i)];
        UILabel *label = (UILabel *)[_shadedView viewWithTag:(BUTTON_TITLE_TAG_BASE+i)];
        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             // CGFloat amount = 100;
                             BOOL opening = paneState == PaneStateClosed;
                             CGRect frame = view.frame;
                             frame.size.width = (opening? 240: [Theme buttonHeight]);
                             frame.origin.x = (opening?  (self.frame.size.width - 240)/2 : (self.frame.size.width - [Theme buttonHeight])/2);
                             view.frame = frame;
                             view.layer.cornerRadius = opening? 0 : (frame.size.height/2);
                             
                             label.frame = [view bounds];
                             label.alpha = opening? 1.0f : 0.0f;
                         } completion:^(BOOL finished) {
                             
                         }];
        
    }
    paneState = (paneState== PaneStateClosed)? PaneStateOpen : PaneStateClosed;
    if (paneState== PaneStateClosed) self.alpha = 0.0f;
}

- (void) show
{
    [self setup: self.frame];
    [self animateToggle];
}

// Allow to write the whole action in a complete block
- (void) showWithCompletionBlock: (void (^)(MobiusoActionView *actionView, NSInteger buttonIndex, NSString *inputTxt)) block
{
    actionCompletionBlock = block;
    [self show];
}
// Open with Animation
- (void) animateToggle
{
    // where should the action pane be headed (center)
    CGPoint targetCenterPoint = CGPointMake(paneFrame.size.width/2, (paneState== PaneStateClosed) ? (paneFrame.origin.y + (paneFrame.size.height / 2)) : (paneFrame.origin.y + (paneFrame.size.height * 2)));
    if (self.springAnimation) {
        // close it
        [self.animator removeAnimation:self.springAnimation];
        self.springAnimation = nil;
    }
    if (paneState== PaneStateClosed) self.alpha = 1.0f;
    self.springAnimation = [MoSpringAnimation animationWithView: _pane delegate: self target: targetCenterPoint velocity: CGPointZero];
    [self.animator addAnimation:self.springAnimation];
    
}

#pragma mark - Keyboard
#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillShow {
    // Animate the current view out of the way
    keyboardShowing = YES;
    if (self.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    keyboardShowing = NO;
    if (self.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}


-(void)textViewDidBeginEditing:(UITextView *)sender
{
    
    _currentResponder = sender;
    if  (self.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    
    clearTextButton.hidden = ([sender.text length] == 0);
    searchToFireTimer = nil;
    
    
#if 0 // Menu Experiments - fails to remove the standard items
    [menu setMenuVisible:YES animated:YES];
#endif
    
#if 0
    if ([sender.text isEqualToString:_placeholderText]) {
        //        sender.text = @"";
        NSRange range = {0, [_placeholderText length]};
        sender.selectedRange = range;
        //        sender.textColor = [UIColor whiteColor]; //optional
    }
#endif
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    clearTextButton.hidden = ([textView.text length] == 0);
    //    [textView resignFirstResponder];
}

- (void) textViewDidChange:(UITextView *)textView
{
    // Put a delay of 3 seconds
    // Fire IAP timer
    if (searchToFireTimer) {
        [searchToFireTimer invalidate];
    }
    searchToFireTimer = [NSTimer scheduledTimerWithTimeInterval:1.0  target:self selector:@selector(searchToFire:)  userInfo:nil repeats:NO];
    
}

#if 0
- (BOOL)textViewShouldEndEditing: (UITextView *)textView
{
    [textView resignFirstResponder];
    return true;
}
#endif

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    
#ifdef ENFORCE_TEXT_LIMIT_COUNT
    if (textView.text.length + text.length > ENFORCE_TEXT_LIMIT_COUNT){
        if (location != NSNotFound){
            [textView resignFirstResponder];
        }
        return NO;
    }
    else
#endif
        if (location != NSNotFound){
            [textView resignFirstResponder];
            return NO;
        }
    return YES;
}

- (void) searchToFire: (NSTimer *) timer
{
    if ([inputField.text length] > 0) {
        [self didPressPopup:nil];
    }
    searchToFireTimer = nil;
}

- (void) didPressClear: (id) sender
{
    inputField.text = @"";
    [inputField becomeFirstResponder];
}

- (void) didPressPopup: (id) sender
{
    if (!popupTableView) [self setupPopupTable];
    [self showPopupTableView];
    [popupTableView reloadData];
}

- (void) setupPopupTable
{
    /* Custom Strings TABLEVIEW =======================*/
    
    CGFloat top = _pane.frame.origin.y + inputField.frame.origin.y;
    CGRect clipboardTableRect = CGRectMake(0, top /*self.frame.size.height*/, self.frame.size.width, 0 /* 220 */);
    popupTableView = [[UITableView alloc]initWithFrame: clipboardTableRect style:UITableViewStylePlain];
    
    popupTableView.backgroundColor = COLORFROMHEX(0xe0000000);
    popupTableView.rowHeight = 50;
    popupTableView.scrollEnabled = true;
    popupTableView.showsVerticalScrollIndicator = true;
    popupTableView.userInteractionEnabled = true;
    popupTableView.bounces = true;
    
    popupTableView.delegate = self;
    popupTableView.dataSource = self;
    
    //    DLog(@"CUSTOM STRINGS LIST:  %@", [ClipboardManager nodes]);
    
    [self addSubview:popupTableView];
    
}

- (void) setupPopupTableCount
{
    filterString = inputField.text;
    filteredPopupArray = popupArray;
    if ([[filterString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        NSArray *components = [filterString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (components && ([components count] > 0)) {
            filterString = components[[components count] -1];
        }
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", filterString];
        filteredPopupArray = [popupArray filteredArrayUsingPredicate:pred];
    }
    
}



#pragma mark - SHOW / HIDE CLIPBOARD TABLEVIEW ======================
-(void)showPopupTableView {
    [self setupPopupTableCount];
    if ([filteredPopupArray count] == 0) {
        if (popupTableVisible) [self hidePopupTableView];
        return;
    }
    popupTableVisible = YES;
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^ {
        CGRect ftbFrame = popupTableView.frame;
        CGFloat top = _pane.frame.origin.y + inputField.frame.origin.y;
        NSInteger count = [filteredPopupArray count];
        NSInteger height = ((count < 5)? (count*50) : 220);
        ftbFrame.origin.y = top - height;
        ftbFrame.size.height = height;
        popupTableView.frame = ftbFrame;
    } completion:^(BOOL finished) {
        if (!okButton) {
            okButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [okButton setImage:[UIImage imageNamed:@"ttOkButt"] forState:UIControlStateNormal];
            okButton.backgroundColor = COLORFROMHEX(0xe0000000);
            okButton.layer.cornerRadius = 10.0f;
            [okButton addTarget:self action:@selector(hidePopupTableView) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:okButton];
        }
        okButton.frame = CGRectMake(self.frame.size.width - 40, popupTableView.frame.origin.y-40, 40, 40);
        [self removeGestureRecognizer:tapRecognizer];
    }];
    
}
-(void)hidePopupTableView {
    [okButton removeFromSuperview];
    okButton = nil;
    popupTableVisible = NO;
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^ {
        CGRect ftbFrame = popupTableView.frame;
        CGFloat top = _pane.frame.origin.y + inputField.frame.origin.y;
        ftbFrame.size.height = 0;
        ftbFrame.origin.y = top; // self.frame.size.height;
        popupTableView.frame = ftbFrame;
    } completion:^(BOOL finished) {
        [self addGestureRecognizer:tapRecognizer];
    }];
    
}

#pragma mark - Popup Table Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    // Filter table if there is a partial entry (special consideration about the last word only)
    return [filteredPopupArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *itemArray = filteredPopupArray;
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSString *fontStr1 = [itemArray objectAtIndex:indexPath.row];
    cell.textLabel.text = fontStr1; // [itemArray objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName: @"Roboto Condensed Light" size:18];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
#if 0   // NO Delete button
    {    // All files can be deleted
         // Put up a delete button
        UIButton *delButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [delButton setTitle: @"DELETE" /*setImage:[UIImage imageNamed:@"ttAddTextButt"]*/ forState:UIControlStateNormal];
        delButton.titleLabel.font = [UIFont fontWithName:@"Miso" size:14];
        delButton.titleLabel.textColor = [UIColor whiteColor];
        //        _addButton.userInteractionEnabled = NO;
        delButton.frame = CGRectMake(0, 0, 50, 30);
        delButton.backgroundColor = [UIColor clearColor];
        delButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        CALayer *layer = delButton.layer;
        layer.borderColor = [Theme mainColor].CGColor;
        layer.borderWidth = 1;
        layer.backgroundColor = [UIColor blackColor].CGColor;
        // This will allow the file to be deleted...
        [delButton addTarget:self action:@selector(pushedDeleteKeywordBtn:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = delButton;
    }
#endif
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *keyword = [filteredPopupArray objectAtIndex: indexPath.row];
    DLog(@"Got Node: %@", keyword);
    [self hidePopupTableView];
    
    NSString *text = [inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (filterString) {
        NSRange range = [text rangeOfString:filterString options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            text = [[text substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    inputField.text = [NSString stringWithFormat:@"%@%@%@", text, (([text length]>0)? @" " : @""), keyword];
}

- (void) pushedDeleteKeywordBtn: (id) sender
{
    
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // Remove the string
    DLog(@"Clicked Accessory Button: %ld", (long)indexPath.row);
}

#pragma mark - UIMenuController experiments
#if 0 // Menu Experiments - fails to remove the standard items
      // Try the popup Menu
- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    BOOL result = NO;
    if(@selector(copy:) == action ||
       @selector(onCustom1:) == action ||
       @selector(onCustom2:) == action) {
        result = YES;
    }
    return result;
}

- (void) onCustom1: (UIMenuController*) sender
{
    DLog(@"custom 1");
}

- (void) onCustom2: (UIMenuController*) sender
{
    DLog(@"custom 2");
}

#endif


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4]; // if you want to slide up the view
    
    CGRect rect = self.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.frame = rect;
    
    [UIView commitAnimations];
}

// Dragging
#pragma mark - Dragging Support
- (void)actionView:(MobiusoActionView *)view draggingEndedWithVelocity:(CGPoint)velocity
{
    // PaneState targetState = velocity.y >= 0 ? PaneStateClosed : PaneStateOpen;
    // paneState = targetState;
    // Do it only if it is in the correct direction
    if (velocity.y >= 0) {
        [self animateToggle];
    } else {
        // Spring back to the original position..
        // we fake the fact that we are open -
        paneState = PaneStateClosed;
        [self animateToggle];
    }
    // [self startAnimatingView:view initialVelocity:velocity];
}

- (void)actionViewBeganDragging:(MobiusoActionView *)view
{
    if (self.springAnimation) {
        // close it
        [self.animator removeAnimation:self.springAnimation];
        self.springAnimation = nil;
    }
}


@end
