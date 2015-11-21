//
//  MobiusoShelfPlusViewController.m
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15 - Based on IntroducingCollectionViews (Conference & Speakers hierarchy)
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "MoShelfPlusViewController.h"
#import "MoShelfPlusDataSource.h"
#import "ShelfItemCell.h"
#import "GridLayout.h"
#import "MoShelfPlusStickyHeader.h"
#import "LineLayout.h"
#import "CoverFlowLayout.h"
#import "StacksLayout.h"
#import "SpiralLayout.h"
#import "ModuleTypeHeader.h"
#import "UIImage+RemapColor.h"
#import "UIImage+ImageEffects.h"
#import "AppDelegate.h"
#import "Theme.h"
#import "MobiusoBubblePopup.h"
#import "Utilities.h"
#import "MoProgressView.h"
#import "HomeVC.h"

#define HELP_BUBBLE_TAG 20140811

#define MARK_BUTTON_TAG_BASE 10000
#define INFO_BUTTON_TAG_BASE 20000
#define SELECT_BUTTON_TAG_BASE 30000
#define SHOW_HIDE_BUTTON_TAG_BASE 40000

#define FILTER_SWITCH_TAG_BASE  201502070
#define ACTION_BUTTON_TAG_BASE  201502071
#define ACTION_PANEL_CLOSE_BUTTON_TAG 201502072
#define FILTER_PANEL_CLOSE_BUTTON_TAG 201502073

@interface MoShelfPlusViewController ()<UIGestureRecognizerDelegate>
{
    UILongPressGestureRecognizer *longTapGestureRecognizer;
    BOOL                        selectionMode;
    BOOL                        selectionModeAll;

    UIImageView                 *filterPanel;
    UIImageView                 *actionPanel;
    
    BOOL                        keyboardShowing;

}

@property (nonatomic, retain) NSMutableArray    *selectedItems;

@property (nonatomic, assign) ShelfLayout       layoutStyle;

@property (nonatomic, strong) UINib             *headerNib;

@property (nonatomic, assign) NSUInteger        currentDataSourceIndex;

@end

@implementation MoShelfPlusViewController

#pragma mark - Init Methods
- (id)init
{
    self = [super init];
    if (self)
    {
        [self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self doInit];
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self)
    {
        [self doInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self doInit];
    }
    return self;
}

- (void)doInit
{
    _layoutStyle = ShelfLayoutGrid;
#if STICKY_HEADER   // Sticky Header
    self.headerNib = [UINib nibWithNibName:@"MoShelfPlusStickyHeader" bundle:nil];
#endif
}

#pragma mark - Layout
- (void) reload
{
    [self.collectionView reloadData];
}

- (void) refresh
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(self.view.frame.size.width - 40, 8, 32, 32);
        [_closeButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed: @"dismissButtWHITE"/* @"closeThin.png"*/]] forState:UIControlStateNormal];
        [self.view addSubview:_closeButton];
    } else {
        _closeButton.frame = CGRectMake(self.view.frame.size.width - 40, 8, 32, 32);
        
    }

    if (selectionMode) {
        [self showActionPanel];
    } else {
        [self hideActionPanel];
    }

    [self reload];
}

// Parallax stuff
#if STICKY_HEADER   // Sticky Header
- (void)reloadLayout {
    
    GridLayout *layout = (id)self.collectionView.collectionViewLayout;
    
    if ([layout isKindOfClass:[GridLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, [MoShelfPlusStickyHeader maxHeight]);
        layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(self.view.frame.size.width, 110);
//        layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height);
        layout.parallaxHeaderAlwaysOnTop = YES;
        
        // If we want to disable the sticky header effect
        layout.disableStickyHeaders = YES;
    }
    
}
#endif

#pragma mark - Action Panel
- (void) showActionPanel
{

    if (actionPanel == nil) {
        NSArray *actionItems = nil;
        if ([_dataSources[_currentDataSourceIndex] respondsToSelector:@selector(actionMenuItems)]) {
            actionItems = [_dataSources[_currentDataSourceIndex] actionMenuItems];
        }

        CGRect frame = [Utilities applicationFrame];
        CGRect basepanelFrame = CGRectMake(0, frame.size.height - 60, frame.size.width, 60);
        
        if (IS_IOS8) {
            // Blur Effect
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            [bluredEffectView setFrame:basepanelFrame];
            
            
            // Vibrancy Effect
            UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
            UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
            // vibrancyEffectView.backgroundColor = COLORFROMHEX(0xff990000);
            [vibrancyEffectView setFrame:bluredEffectView.bounds];
            // Add Vibrancy View to Blur View
            [bluredEffectView addSubview:vibrancyEffectView];
            // Add Label to Vibrancy View
            //            [self.view addSubview: bluredEffectView];
            actionPanel = (id) bluredEffectView;
            
        } else {
            
            UIImageView *actionPanelView = [[UIImageView alloc] initWithFrame:basepanelFrame];
            actionPanelView.backgroundColor = COLORFROMHEX(0xa0000000);
            actionPanel = (id) actionPanelView;
        }
        
        
        [self.view addSubview:actionPanel];
        actionPanel.userInteractionEnabled = YES;
        
        if (actionItems) {
            CGFloat buttonX = frame.size.width - 50; int i = 0;
            for (NSDictionary *item in actionItems) {
                UIButton* showButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, 8, 36, 36)];
                [showButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:[item objectForKey:@"image"]]] forState:UIControlStateNormal];
                [actionPanel addSubview:showButton];
                

                [showButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                showButton.tag = ACTION_BUTTON_TAG_BASE + i;
                
                UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonX, 44, 36, 14)];
                showLabel.textColor = [UIColor whiteColor];
                showLabel.textAlignment = NSTextAlignmentCenter;
                showLabel.text = [item objectForKey:@"title"];
                showLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
                showLabel.alpha = 1.0;
                [actionPanel addSubview:showLabel];
                buttonX -= 50;
                i++;
            }
        }
#if 0
        UIButton* showButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 50, 8, 36, 36)];
        [showButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-forward-72.png"]] forState:UIControlStateNormal];
        [actionPanel addSubview:showButton];
        [showButton addTarget:self action:@selector(openLocalSelected:) forControlEvents:UIControlEventTouchUpInside];
        showButton.tag = ACTION_BUTTON_TAG_BASE + 0;
        
        UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 50, 44, 36, 14)];
        showLabel.textColor = [UIColor whiteColor];
        showLabel.textAlignment = NSTextAlignmentCenter;
        showLabel.text = @"SHOW";
        showLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        showLabel.alpha = 1.0;
        [actionPanel addSubview:showLabel];
        
        UIButton* tagButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 100, 8, 36, 36)];
        [tagButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-tag-72.png"]] forState:UIControlStateNormal];
        [actionPanel addSubview:tagButton];
        [tagButton addTarget:self action:@selector(menuTagAction) forControlEvents:UIControlEventTouchUpInside];
        tagButton.tag = ACTION_BUTTON_TAG_BASE + 1;
        
        UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 100, 44, 36, 14)];
        tagLabel.textColor = [UIColor whiteColor];
        tagLabel.textAlignment = NSTextAlignmentCenter;
        tagLabel.text = @"TAG";
        tagLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        tagLabel.alpha = 1.0;
        [actionPanel addSubview:tagLabel];
#endif
        
        UIButton* allButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 8, 36, 36)];
        [allButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-checkmark-solid-72.png"]] forState:UIControlStateNormal];
        [actionPanel addSubview:allButton];
        [allButton addTarget:self action:@selector(menuSelectAllAction) forControlEvents:UIControlEventTouchUpInside];
        allButton.tag = ACTION_BUTTON_TAG_BASE + 4;
        
        UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 44, 36, 14)];
        allLabel.textColor = [UIColor whiteColor];
        allLabel.textAlignment = NSTextAlignmentCenter;
        allLabel.text = @"ALL";
        allLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        allLabel.alpha = 1.0;
        [actionPanel addSubview:allLabel];
        
        UIButton* noneButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 8, 36, 36)];
        [noneButton setImage: [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-nocheckmark-72.png"]] forState:UIControlStateNormal];
        [actionPanel addSubview:noneButton];
        [noneButton addTarget:self action:@selector(menuSelectNoneAction) forControlEvents:UIControlEventTouchUpInside];
        noneButton.tag = ACTION_BUTTON_TAG_BASE + 3;
        
        UILabel *noneLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 44, 36, 14)];
        noneLabel.textColor = [UIColor whiteColor];
        noneLabel.textAlignment = NSTextAlignmentCenter;
        noneLabel.text = @"NONE";
        noneLabel.font = [UIFont fontWithName:@"Roboto-Light" size:10];
        noneLabel.alpha = 1.0;
        [actionPanel addSubview:noneLabel];
        
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.tag = ACTION_PANEL_CLOSE_BUTTON_TAG;
        closeButton.frame = CGRectMake(frame.size.width/2 - 16, frame.size.height - 90, 32, 32);
        [closeButton addTarget:self action:@selector(clearPanelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setImage:[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"SimpleCloseLine.png"]] forState:UIControlStateNormal];
        closeButton.layer.cornerRadius = 16;
        closeButton.layer.backgroundColor = COLORFROMHEX(0x80000000).CGColor;
        CALayer *sublayer = [CALayer layer];
        sublayer.frame = [closeButton bounds];
        sublayer.contents = (__bridge id)([UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"SimpleCloseLine.png"]].CGImage);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview: closeButton];
        
    } else {
        actionPanel.hidden = NO;
        [self.view viewWithTag:ACTION_PANEL_CLOSE_BUTTON_TAG].hidden = NO;
        
    }
    
}

- (void) hideActionPanel
{
    if (actionPanel) {
        actionPanel.hidden = YES;
        [self.view viewWithTag:ACTION_PANEL_CLOSE_BUTTON_TAG].hidden = YES;
    }
    //    [self addElasticMenu:EMOrientationRight stripDirection:EMDirectionHorizontalFront];
}

- (void) actionButtonPressed: (id) sender
{
    UIButton *actionButton = sender;
    NSUInteger index = actionButton.tag - ACTION_BUTTON_TAG_BASE;
    
    if ([_dataSources[_currentDataSourceIndex] respondsToSelector:@selector(actionMenuItems)]) {
        NSArray *actionItems = [_dataSources[_currentDataSourceIndex] actionMenuItems];
        SEL actionSelector = NSSelectorFromString([actionItems[index] objectForKey:@"action"]);
        IMP imp = [_dataSources[_currentDataSourceIndex] methodForSelector: actionSelector];
        void (*func)(id, SEL, NSArray *) = (void *)imp;
        
        if ([_dataSources[_currentDataSourceIndex] respondsToSelector: actionSelector]) {
            func(_dataSources[_currentDataSourceIndex], actionSelector, _selectedItems);
            // [self performSelector:aSelector];
        }
    }
    // Almost invariably we will need to do a reload...
    [self hideActionPanel];
    [self refresh];

}


- (void) clearPanelButtonPressed: (UIButton *) sender
{
    switch (sender.tag) {
        case FILTER_PANEL_CLOSE_BUTTON_TAG:
//            currentSearchType = NavSearchTypeNone;
            [self refresh];
            break;
            
        case ACTION_PANEL_CLOSE_BUTTON_TAG:
            selectionMode = NO;
            _selectedItems = [[NSMutableArray alloc] init];
            
            [self hideActionPanel];
            [self refresh];
            break;
            
            
        default:
            break;
    }
}

- (void) menuClearFilterAction
{
    DLog(@"Clear Search Action");
//    currentSearchType = NavSearchTypeNone;
    //    [self reload];
    [self refresh];
}

- (void) menuSelectAllAction
{
    //    if (BuiltInPhotoGallery)
    {
        
        _selectedItems = [[NSMutableArray alloc] init];
        selectionModeAll = YES;
        // Show all visible items to have been selected and set a bit
        for (ShelfItemCell *cell in self.collectionView.visibleCells)
        {
            [_selectedItems addObject:cell.itemReference];
        }
        
        [self refresh];
        
    }
}

- (void) menuSelectNoneAction
{
    //    if (BuiltInPhotoGallery)
    {
        
        selectionModeAll = NO;
        _selectedItems = [[NSMutableArray alloc] init];
        
        [self refresh];
        
    }
}

#pragma mark - ========
- (void) setBackgroundEffect
{
    CALayer *layer = self.collectionView.layer;

    if (_background) {

//        UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:0.25];    // COLORFROMHEX(0x10d71341); //
                                                                         //    UIImage *blurred =  [screenshot applyBlurWithRadius:12 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
        UIImage *blurred = _background; //  [_background applyTintEffectWithColor:tintColor];
        layer.contents = (__bridge id)(blurred.CGImage);
        layer.contentsGravity = kCAGravityResizeAspectFill;
//        MLog(@"Background Image size: %lu", CGImageGetHeight(_background.CGImage) * CGImageGetBytesPerRow(_background.CGImage)); // Takes up to 16MB
        MLog(@"Blurred Image size: %@", [HomeVC displayMemory: CGImageGetHeight(blurred.CGImage) * CGImageGetBytesPerRow(blurred.CGImage)]); // Takes up to 16MB
        
    } else {
            self.collectionView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"wild_oliva.png"]]; //  // Wood-Planks
    }
    
}

- (void) setupDataSourceAtIndex: (NSUInteger) dataSourceIndex
{
    MoShelfPlusDataSource *dataSource;
    
    if (_dataSources && (dataSourceIndex < [_dataSources count])) {
        _currentDataSourceIndex = dataSourceIndex;
        dataSource = _dataSources[dataSourceIndex];
    } else {
        dataSource = [MoShelfPlusDataSource all];
    }
    
    [dataSource refresh];
    [self.collectionView setDataSource: dataSource];
    [self.collectionView reloadData];
}

#pragma mark - MoShelfPlusViewControllerDelegate
- (void) setSwitchControl: (ADVSegmentedControl *) segmentControl
{
    // We will reach here on every reload - don't need to set this up repeatedly...
    if (segmentControl.tag != SEGMENT_CONTROL_TAG) {
        NSMutableArray *segmentArray = [[NSMutableArray alloc] init];
        for (MoShelfPlusDataSource *datasource in _dataSources) {
            [segmentArray addObject:datasource.shortTitle];
        }
        segmentControl.items = segmentArray;
        segmentControl.font = [UIFont fontWithName:[Theme fontName] size:14];
        segmentControl.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        segmentControl.selectedIndex = _currentDataSourceIndex;
        [segmentControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
}

- (void) selectorControlTapped:(id)sender
{
    DLog(@"Selector Control Tapped for Action");
    MoShelfPlusDataSource *datasource = _dataSources[_currentDataSourceIndex];
    if (datasource &&  [datasource respondsToSelector:@selector(selectorControlTapped:)]) {
        [datasource performSelector:@selector(selectorControlTapped:) withObject:sender afterDelay:0.01f];
    }
}


- (void) cellWillAppear:(UICollectionViewCell <MoShelfPlusSelectionDelegate> *)cell atIndexPath: (NSIndexPath *) indexPath
{
    // Update any values...
    if (selectionMode) {
        //
        // First check if the item is in the selected Item
        //
        int founditem = -1;
        BOOL itemSelected = NO;
        id item = cell.itemReference;
        
        for (int i=0; i < (int) [_selectedItems count] ; i++) {
            id itm = _selectedItems[i];
            if (((![item isKindOfClass:[NSString class]]) && ([item class] == [itm class]) && (itm == item)) || (([item isKindOfClass:[NSString class]]) && IS_EQUAL(itm, item))) {  // PLain equality // it may be needed in Datasource
                founditem = i;
                break;
            }
        }
        if (founditem >= 0) {
            [_selectedItems replaceObjectAtIndex:founditem withObject:item];    // Does not make sense...
            itemSelected = YES;
        } else if (selectionModeAll) {
            // We are considering all items to be selected
            // add the item
            [_selectedItems addObject:item];
            itemSelected = YES;
        }
        
        if (cell.selectButton == nil) {
            CGSize size = cell.frame.size;
            cell.selectButton = [[MoRippleTap alloc]
                                 initWithFrame:CGRectMake(size.width/2-24, size.height/2-24, 48, 48)
                                 andImage: (itemSelected?[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-checkmark-solid-72.png"]]: [UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed:@"menu-plus-solid-72.png"]])
                                 andTarget:@selector(tapOnSelectButton:)
                                 andBorder:YES
                                 delegate:self
                                 ];
            cell.selectButton.rippleOn = YES;
            cell.selectButton.alpha = 0.9;
            cell.selectButton.rippleColor = [UIColor whiteColor];
            [cell addSubview:cell.selectButton];
        } else {
            // load the correct image based on the status
            [cell bringSubviewToFront:cell.selectButton];
            [cell.selectButton setImage: (itemSelected?[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-checkmark-solid-72.png"]]: [UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed:@"menu-plus-solid-72.png"]])];
        }
        cell.selectButton.tag = SELECT_BUTTON_TAG_BASE + (indexPath.section << 12 | indexPath.row);
        
        
    } else {
        if (cell.selectButton) {
            [cell.selectButton removeFromSuperview];
            cell.selectButton = nil;
        }
    }
    
}

- (BOOL) toggleImageSelection: (id) photoItem
{
    // Check if we are selected or not
    __block NSInteger found = NSNotFound;
    [_selectedItems enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {

        if ((([item isKindOfClass:[NSDictionary class]]) && (photoItem == item)) || (([item isKindOfClass:[NSString class]]) && IS_EQUAL(photoItem, item))) {  // PLain equality for dictionary // it may be needed in Datasource
            found = idx;
            *stop = YES;
        }
    }];

    if (found == NSNotFound) {
        [_selectedItems addObject:photoItem];
    } else {
        [_selectedItems removeObjectAtIndex:found];
        selectionModeAll = NO;  // Turn off if it was ON
    }
    return (found == NSNotFound);
}

- (void)tapOnSelectButton:(id)sender {
    
//    NSUInteger row = ((MoRippleTap *)sender).tag - SELECT_BUTTON_TAG_BASE;
    UIView *view = sender;
    while ((view = [view superview])) {
        if ([view isKindOfClass:[UICollectionViewCell class]]) {
            break;
        }
    }

    if (view) {
        UICollectionViewCell <MoShelfPlusSelectionDelegate> *cell = (UICollectionViewCell <MoShelfPlusSelectionDelegate> *) view;
        id item = cell.itemReference;
        BOOL selected = [self toggleImageSelection: item];
        [(MoRippleTap *) sender setImage: selected?[UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"menu-checkmark-solid-72.png"]]: [UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed:@"menu-plus-solid-72.png"]]];
    }
}

#pragma mark - Segment View Delegate
- (void) segmentValueChanged: (ADVSegmentedControl *) sender
{
    DLog(@"Segment Value: %ld", (long) [sender selectedIndex]);
    [self setupDataSourceAtIndex:(long) [sender selectedIndex]];
    //    _segmentClicked = YES;
    //    [self setDashboardPage:_segmentControl.selectedIndex];
    //    _segmentClicked = NO;
    
    
}

#pragma mark - View Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    // ADD PROGRESS HUD ================
    self.hud = [[MoProgressView alloc] initWithView:self.view];
    [self.view addSubview:self.hud];

    _selectedItems = [[NSMutableArray alloc] init];     // initially none selected...

    [self.collectionView setCollectionViewLayout:[[GridLayout alloc] init]];
    
    [self setupDataSourceAtIndex:0];
    
	// Do any additional setup after loading the view.
    [self.collectionView registerClass:[SmallModuleTypeHeader class] forSupplementaryViewOfKind:[SmallModuleTypeHeader kind] withReuseIdentifier:[MoShelfPlusDataSource smallHeaderReuseID]];
    [self.collectionView reloadData];
    
    [self setBackgroundEffect];

    // init gesture for Selection of multiple items
    longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongTapForSelection:)];
    longTapGestureRecognizer.minimumPressDuration = 0.75;
    [self.view addGestureRecognizer:longTapGestureRecognizer];

    // Sticky Header
#if STICKY_HEADER// Sticky Header
    [self reloadLayout];
    
    // Also insets the scroll indicator so it appears below the search bar
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self.collectionView registerNib:self.headerNib
          forSupplementaryViewOfKind:GridLayoutHeaderStickyHeader
                 withReuseIdentifier:@"header"];
    // End of Sticky Header
#endif
    

#ifdef DO_INSERT
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
#endif
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handle2FingerTap:)];
    tap2.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:tap2];
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handle3FingerTap:)];
    tap3.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer:tap3];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.collectionView addGestureRecognizer:pinch];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
    swipeUp.delegate = self;
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.collectionView addGestureRecognizer:swipeUp];
    
    // Here we add the keyboard notification - register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
     
                                               object:nil];
    
    keyboardShowing = NO;
   
    
    
    // Close Button, etc
    [self refresh];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog(@"\n\n>>>>>> Memory Warning received.\n\n");
}

#if 0
- (void) viewWillDisappear:(BOOL)animated
{
    DLog(@"\n\n>>>>>> viewWillDisappear.\n\n");
    
}
#endif


- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)backAction
{
    [self  dismissViewControllerAnimated:YES completion: ^{
        if ([_delegate respondsToSelector:@selector(dismissedShelfPlusController:)]) {
            [_delegate dismissedShelfPlusController:self];
        }
        self.collectionView = nil;
        self.dataSources = nil;
        self.background = nil;

    }];
}

- (NSUInteger) switchCount
{
    return (_dataSources? [_dataSources count] : 1);
    
}

- (void)setLayoutStyle:(ShelfLayout)layoutStyle animated:(BOOL)animated
{
    if (layoutStyle == self.layoutStyle)
        return;
    
    UICollectionViewLayout *newLayout = nil;
    BOOL delayedInvalidate = NO;
    
    switch (layoutStyle)
    {
        case ShelfLayoutGrid:
            newLayout = [[GridLayout alloc] init];
#if STICKY_HEADER
        {
            GridLayout *layout = (GridLayout *) newLayout;
            layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, [MoShelfPlusStickyHeader maxHeight]);
            layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(self.view.frame.size.width, [MoShelfPlusStickyHeader minHeight]);
            layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height);
            layout.parallaxHeaderAlwaysOnTop = YES;
            
            // If we want to disable the sticky section header effect
            layout.disableStickyHeaders = YES;
        }
#endif

            break;
            
        case ShelfLayoutLine:
            newLayout = [[LineLayout alloc] init];
            delayedInvalidate = YES;
            break;
            
        case ShelfLayoutCoverFlow:
            newLayout = [[CoverFlowLayout alloc] init];
            delayedInvalidate = YES;
            break;
            
        case ShelfLayoutStacks:
            newLayout = [[StacksLayout alloc] init];
            break;
            
        case ShelfLayoutSpiral:
            newLayout = [[SpiralLayout alloc] init];
            break;
            
        default:
            break;
    }
    
    if (!newLayout)
        return;
    
    self.layoutStyle = layoutStyle;
    [self.collectionView setCollectionViewLayout:newLayout animated:animated];
    self.collectionView.pagingEnabled = (layoutStyle == ShelfLayoutSpiral);
    
    if (delayedInvalidate)
    {
        [self.collectionView.collectionViewLayout performSelector:@selector(invalidateLayout) withObject:nil afterDelay:0.4];
    }
    
    // WORKAROUND: There's a UICollectionView bug where the supplementary views from StacksLayout are leftover and remain in other layouts
    /*if (layoutStyle != SpeakerLayoutStacks)
    {
        NSMutableArray *leftoverViews = [NSMutableArray array];
        for (UIView *subview in self.collectionView.subviews)
        {
            // Find all the leftover supplementary views
            if ([subview isKindOfClass:[SmallConferenceHeader class]])
            {
                [leftoverViews addObject:subview];
            }
        }
        
        // remove them from the view hierarchy
        for (UIView *subview in leftoverViews)
            [subview removeFromSuperview];
    }*/
}

- (BOOL)layoutSupportsInsert
{
    return self.layoutStyle == ShelfLayoutSpiral;
}

- (BOOL)layoutSupportsDelete
{
    return self.layoutStyle == ShelfLayoutSpiral;
}

#pragma mark - UICollectionView Delegate - CELL SELECTED

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"Tapped: %ld, %ld", (long)indexPath.section, (long)indexPath.row);
//    MoShelfPlusSections *shelfSections = (MoShelfPlusSections *)self.collectionView.dataSource;
//    NSDictionary *shelfItem = [shelfSections itemAtIndexPath:indexPath];
//    [AppDelegate setCurrentModuleInfo:shelfItem];
//    [[NSNotificationCenter defaultCenter] postNotificationName:CONTENT_UPDATE_NOTIFICATION object:nil];
    
    if (keyboardShowing) {
        [_stickyHeaderCell.searchBar resignFirstResponder];
    }
    
    if ((![_delegate respondsToSelector:@selector(shelfPlusController:didSelectItemAtPath:)]) ||
        (![_delegate shelfPlusController:self didSelectItemAtPath:indexPath])) {
        [self backAction];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]])
    {
        // recognize pinch gesture only if we're in stacks layout and pinch is on a stack
        if (self.layoutStyle != ShelfLayoutStacks)
            return NO;
        
        CGPoint touchPoint = [touch locationInView:self.collectionView];
        NSIndexPath* cellPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
        return cellPath != nil;
    }
    else if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
    {
        // recognize swipe gesture only if we're in a layout that supports delete
        if (![self layoutSupportsDelete])
            return NO;
        
        CGPoint touchPoint = [touch locationInView:self.collectionView];
        NSIndexPath* cellPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
        return cellPath != nil;
    }
    
    return YES;
}

#pragma mark - Rotation
#pragma mark - Rotation support

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         __unused UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         //         DLog(@"Orientation: %ld", orientation);
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self refresh];
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
}


#pragma mark - Touch gesture

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (![self layoutSupportsInsert])
        return;
    
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    
    int sectionCount = (int)[self.collectionView numberOfSections];
    for (int section = 0; section < sectionCount; section++)
    {
        NSString *kind = (self.layoutStyle == ShelfLayoutStacks)? [SmallModuleTypeHeader kind] : UICollectionElementKindSectionHeader;
        UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        
        if (attributes)
        {
            if (CGRectContainsPoint(attributes.frame, point))
            {
                int itemCount = (int)[self.collectionView numberOfItemsInSection:section];
                id shelfSections = self.collectionView.dataSource;
                if ([shelfSections restoreModuleInSection:section])
                {
                    // WORKAROUND: inserting cell to empty section often yields NSInternalInconsistencyException in UICollectionView
                    // we'll just call reloadData instead
                    if (itemCount == 0)
                        [self.collectionView reloadData];
                    else
                        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:itemCount inSection:section]]];
                }
                
                break;
            }
        }
    }
}

- (void)handle2FingerTap:(UITapGestureRecognizer *)gestureRecognizer
{
    ShelfLayout newLayout = self.layoutStyle + 1;
    if (newLayout >= ShelfLayoutCount)
        newLayout = 0;
    [self setLayoutStyle:newLayout animated:YES];
}

- (void)handle3FingerTap:(UITapGestureRecognizer *)gestureRecognizer
{
    ShelfLayout newLayout = self.layoutStyle - 1;
    if ((int)newLayout < 0)
        newLayout = ShelfLayoutCount - 1;
    [self setLayoutStyle:newLayout animated:YES];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    StacksLayout *stacksLayout = (StacksLayout *)self.collectionView.collectionViewLayout;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint initialPinchPoint = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath* pinchedCellPath = [self.collectionView indexPathForItemAtPoint:initialPinchPoint];
        if (pinchedCellPath)
            [stacksLayout setPinchedStackIndex:pinchedCellPath.section];
    }
    else if (stacksLayout.pinchedStackIndex >= 0)
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            stacksLayout.pinchedStackScale = gestureRecognizer.scale;
            stacksLayout.pinchedStackCenter = [gestureRecognizer locationInView:self.collectionView];
        }
        
        else
        {
            if (stacksLayout.pinchedStackScale > 2.5)
            {
                // switch to GridLayout
                [self setLayoutStyle:ShelfLayoutGrid animated:YES];
            }
            else
            {
                // collapse items back into stack
                
                // WORKAROUND: There's a UICollectionView bug where the supplementary views are leftover after animation completes
                NSMutableArray *leftoverViews = [NSMutableArray array];
                for (UIView *subview in self.collectionView.subviews)
                {
                    // Find all the supplementary views
                    if ([subview isKindOfClass:[SmallModuleTypeHeader class]])
                    {
                        [leftoverViews addObject:subview];
                    }
                }
                
                stacksLayout.collapsing = YES;
                [self.collectionView performBatchUpdates:^{
                    stacksLayout.pinchedStackIndex = -1;
                    stacksLayout.pinchedStackScale = 1.0;
                } completion:^(BOOL finished) {
                    stacksLayout.collapsing = NO;
                    // manually remove leftover supplementary views from the view hierarchy
                    for (UIView *subview in leftoverViews)
                        [subview removeFromSuperview];
                }];
            }
        }
    }
}

- (void)handleSwipeUp:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (![self layoutSupportsDelete])
        return;

    CGPoint startPoint = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath* cellPath = [self.collectionView indexPathForItemAtPoint:startPoint];
    if (cellPath)
    {
        MoShelfPlusDataSource *shelfSections = (MoShelfPlusDataSource *)self.collectionView.dataSource;
        NSUInteger itemCount = [self.collectionView numberOfItemsInSection:cellPath.section];
        if ([shelfSections deleteModuleAtPath:cellPath])
        {
            // WORKAROUND: deleting last cell from section often yields NSInternalInconsistencyException in UICollectionView
            // we'll just call reloadData instead
           if (itemCount <= 1)
                [self.collectionView reloadData];
            else
                [self.collectionView deleteItemsAtIndexPaths:@[cellPath]];
        }
    }
}

- (void)onLongTapForSelection:(UILongPressGestureRecognizer *)gestureRecognizer
{
#if  defined(PHOTO_NAV_DEBUG)
    DLog(@"Long tap");
#endif
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        selectionMode = !selectionMode;
        if (!selectionMode) {
#if 0
            // clear everything and scram
            for (id selitem in _selectedItems) {
            }
#endif
            _selectedItems = [[NSMutableArray alloc] init];
            selectionModeAll = NO;
        } else {
            if (1) {
                double fX = [gestureRecognizer locationInView:self.collectionView].x;
                double fY = [gestureRecognizer locationInView:self.collectionView].y;
                
                
                //                    NSIndexPath *indexPath = nil;
                for (UICollectionViewCell <MoShelfPlusSelectionDelegate> *cell in self.collectionView.visibleCells)
                {
                    float fSX = cell.frame.origin.x;
                    float fEX = cell.frame.origin.x + cell.frame.size.width;
                    float fSY = cell.frame.origin.y;
                    float fEY = cell.frame.origin.y + cell.frame.size.height;
                    
                    if (fX >= fSX && fX <= fEX && fY >= fSY && fY <= fEY)
                    {
                        // NOT NEEDED indexPath = [_collectionView indexPathForCell:cell];
//                        PhotoObject *item = ((PhotoCell *) cell).item;
//                        item.imageSelected = YES;   // initially it will be
// Get a reference to the item selected and add it to the array
                        [_selectedItems addObject:cell.itemReference];
                        break;
                    }
                }
            }
            
        }
        [self refresh];
    }
}

#pragma mark - Close Button Action
-(IBAction) closeBtnClick:(id)sender;
{
    [self backAction];
}

#pragma mark - Keyboard
#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillShow {
    // Animate the current view out of the way
    keyboardShowing = YES;
}

-(void)keyboardWillHide {
    keyboardShowing = NO;
}


#pragma mark - MoShelfPlusStickyHeaderDelegate Methods
- (void) infoButtonPressed: (id) sender
{
    MobiusoBubblePopup *bubblePop = [[MobiusoBubblePopup alloc] initWithFrame:[self.view bounds] withOrientation:MBOrientationNorthWest andDuration:15.0f];
    bubblePop.delegate = self;
    bubblePop.tag = HELP_BUBBLE_TAG;
    [self.view addSubview:bubblePop];
    
    NSString *stickyTitle = [_dataSources[_currentDataSourceIndex] title];
    [bubblePop showMessage: _helpInformation withTitle:stickyTitle andSubtitle: @"Usage Information"];
}


- (void) searchButtonPressed:(id)sender
{
    [self.collectionView setContentOffset:CGPointMake(0, 0)];
    [_stickyHeaderCell.searchBar performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1.0f];
    
    
}


@end
