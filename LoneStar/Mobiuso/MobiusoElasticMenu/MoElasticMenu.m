//
//  MoElasticMenu.m
//  MoElasticMenu
//
//  Sandeep Shah - Original Design - Dec 2013 .
//  Sandeep Shah - Massive Redesign (20140205), ARC compatible.
//  Copyright 2012-2014 Sandeep Shah. All rights reserved.
//  Based on the original WaveToolbar (WaveCustomView) design - implemented by Harvindar Sharma & Sandeep Shah
//
//  You must compile with ARC if you are including in a project that is non-arc
//  Use "-fobjc-arc" for compile time flags
//
/*!
 
 @class MoElasticMenu.h
 
 @discussion
 
 
 TODO:
 
 @history
 
 Initial version.
 
 
 TODO
  Also the touch cancellation is at the bottom (for Horizontal) regardless of whether the touch sensitive strip
 is at the top or the bottom. 
 
 Ideally the cancellation happens in the direction of the touch sensitive area
 
 */

#import "MoElasticMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

// Some configuration Details
// If the second layer is behind the first layer (in Z order)
// then define SECONDLAYERBEHIND
//
#define SECONDLAYERBEHIND    // second layer is in the front


@implementation MoElasticMenuItem
@synthesize menuTitle;
@synthesize menuImageName;
@synthesize menuHighlightImageName;
@synthesize defaultImage;
@synthesize target;
@synthesize action;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.action = nil;
        self.target = nil;
        self.menuTitle = nil;
        self.menuImageName = nil;
        self.menuHighlightImageName = nil;
        self.defaultImage = nil;
    }
    return self;
}

@end

@interface MoElasticMenu()
- (void) backToNormal: (BOOL) animated;
- (void) configureView;
- (void) menuPosition: (NSSet *) touches withTouchBegin: (BOOL) isBegin;
- (void) reposition: (CGPoint) tapPoint withTouchBegin: (BOOL) isBegin touchSpeed: (CGFloat) speed stripAnimation: (BOOL) anim;
- (void) setBubbleText:(NSString *)itemName;
@end

@implementation MoElasticMenu

@synthesize lastTouchTimestamp = _lastTouchTimestamp;
@synthesize lastTouchPoint = _lastTouchPoint;
@synthesize secondLayerThreshold = _secondLayerThreshold;
@synthesize menuItemCount = _menuItemCount;
@synthesize menuItemLayersArray = _menuItemLayersArray;
@synthesize menuItemHighlightedLayersArray = _menuItemHighlightedLayersArray;
@synthesize menuItemNamesArray = _menuItemNamesArray;
@synthesize moreLayer = _moreLayer;
@synthesize moreHighlightLayer = _moreHighlightLayer;
@synthesize lessLayer = _lessLayer;
@synthesize lessHighlightLayer = _lessHighlightLayer;


@synthesize menuItemWithMarginWidth = _menuItemWithMarginWidth;
@synthesize menuItemWidth = _menuItemWidth;
@synthesize menuItemHeight = _menuItemHeight;
@synthesize maxMenuCount = _maxMenuCount;
@synthesize menuStartXOrY = _menuStartXOrY;
@synthesize menu2StartXOrY = _menu2StartXOrY;
@synthesize menuTotalWidthOrHeight = _menuTotalWidthOrHeight;
@synthesize menu2TotalWidthOrHeight = _menu2TotalWidthOrHeight;
@synthesize delegate = _delegate;
@synthesize currentIndex = _currentIndex;
@synthesize bubbleLayer = _bubbleLayer;
@synthesize bubbleTextLayer = _bubbleTextLayer;
@synthesize isActive = _isActive;
@synthesize hasMoreItems = _hasMoreItems;
@synthesize secondLayerActive = _secondLayerActive;
@synthesize inAnimation = _inAnimation;
@synthesize quickSingleTap = _quickSingleTap;
@synthesize singleTapTimer = _singleTapTimer;
@synthesize secondLayerHintLayer = _secondLayerHintLayer;
@synthesize secondLayerHintHighlightLayer = _secondLayerHintHighlightLayer;
@synthesize moreChoicesTimer = _moreChoicesTimer;
@synthesize moreHintName = _moreHintName;
@synthesize lessHintName = _lessHintName;

@synthesize firstLayer = _firstLayer;
@synthesize secondLayer = _secondLayer;
@synthesize shimLayer = _shimLayer;
@synthesize font = _font;
@synthesize fullLayer = _fullLayer;
@synthesize baseLayer = _baseLayer;
@synthesize hintLayer = _hintLayer;
@synthesize instructionsImageLayer = _instructionsImageLayer;
@synthesize hint2Layer = _hint2Layer;
@synthesize baseFrame = _baseFrame;
@synthesize fullFrame = _fullFrame;
@synthesize touchOrientation = _touchOrientation;
@synthesize stripDirection = _stripDirection;
@synthesize menuItems = _menuItems;

@synthesize demoTimer = _demoTimer;
@synthesize demoDelay = _demoDelay;
@synthesize demoAnimation = _demoAnimation;
@synthesize demoHelpMessage = _demoHelpMessage;
@synthesize popMessageButton = _popMessageButton;

@synthesize elasticMenuPopImage = _elasticMenuPopImage;

#pragma mark - initialize
- (id)initWithFrame:(CGRect)frame stripDirection: (EMDirectionType) direction  withMenuItems:(NSArray *)menuItemsArray
{
    self = [self initWithFrame:frame touchDirection:EMOrientationBottom stripDirection: direction withDelegate:nil];
    if (self != nil) {
        self.menuItems = menuItemsArray;
        self.menuItemCount = (int) [menuItemsArray count];
        // self.stripDirection = direction;
    }
    return self;
}

- (id)initWithFullFrame:(CGRect)fullFrame touchDirection: (EMOrientationType) orient stripDirection: (EMDirectionType) direction  withMenuItems:(NSArray *)menuItemsArray
{
    self = [self initWithFullFrame:fullFrame touchDirection: orient stripDirection: direction withDelegate:nil];
    if (self != nil) {
        self.menuItems = menuItemsArray;
        self.menuItemCount = (int) [menuItemsArray count];
    }
    return self;
    
}

- (id)initWithFullFrame:(CGRect)frame touchDirection: (EMOrientationType) orient stripDirection: (EMDirectionType) direction withDelegate:(id <MoElasticMenuDelegate>)del
{
    CGRect touchFrame = frame;
    _touchOrientation = orient;
    UIViewAutoresizing mask;
    NSString *where;
    NSString *dir;
    
    switch (orient) {
        case EMOrientationRight:
            touchFrame.origin.x = frame.size.width - TOUCH_WINDOW_DIMENSION;
            touchFrame.size.width = TOUCH_WINDOW_DIMENSION;
            touchFrame.origin.y = 0.4 * touchFrame.size.height;
            touchFrame.size.height -= touchFrame.origin.y;  // get to about 60%
            mask = UIViewAutoresizingFlexibleLeftMargin;
            where = @"right";
            break;
            
        case EMOrientationLeft:
            touchFrame.size.width = TOUCH_WINDOW_DIMENSION;
            touchFrame.origin.y = 0.4 * touchFrame.size.height;
            touchFrame.size.height -= touchFrame.origin.y;  // get to about 60%
            mask = UIViewAutoresizingFlexibleRightMargin;
            where = @"left";
            break;
            
        case EMOrientationTop:
            touchFrame.size.height = TOUCH_WINDOW_DIMENSION + 20;
            mask = UIViewAutoresizingFlexibleBottomMargin;
            where = @"top";
            break;
            
        case EMOrientationBottom:
        default:
            touchFrame.origin.y = frame.size.height - TOUCH_WINDOW_DIMENSION;
            touchFrame.size.height = TOUCH_WINDOW_DIMENSION;
            mask = UIViewAutoresizingFlexibleTopMargin;
            where = @"bottom";
            break;
            
    }
    dir = (stripHorizontal(_stripDirection))? @"left or right" : @"top or bottom";
    _demoHelpMessage = [NSString stringWithFormat: @"Slide your finger or thumb from the %@ edge and move it %@ along the edge of the menu until your desired selection is highlighted.\n\nWhen you lift your finger, the item will be selected.\n", where, dir];
    self = [self init:touchFrame touchDirection:orient stripDirection: direction withDelegate:del];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        self.autoresizingMask = mask;
        _fullFrame = frame;
        self.frame = frame; // FRAMECHANGE
        [self configureHint];
    }
    
    return self;
}

// ????
- (id)initWithFrame:(CGRect)frame touchDirection: (EMOrientationType) orient stripDirection: (EMDirectionType) direction withDelegate:(id <MoElasticMenuDelegate>)del
{
    if (self = [self initWithFrame:frame touchDirection:orient stripDirection: direction withDelegate:del]) {
        [self configureHint];
    }
    return self;
}
// CORE INIT
// frame is the input for the area which accepts touch for starting the menu
// orient tells whether this area is on the top, left, bottom or right of the parent ('full frame')
// by default 'fullFrame' is defined as the parent's view frame.  It could be overridden by the
// init method where full frame is specified.
//
- (id)init:(CGRect)frame touchDirection: (EMOrientationType) orient stripDirection: (EMDirectionType) direction withDelegate:(id <MoElasticMenuDelegate>)del
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.stripDirection = direction;

        //self.controlsCount = [self.delegate menuItemCount];
        self.isActive = NO;
        self.delegate = (NSObject <MoElasticMenuDelegate> *) del;
        self.moreChoicesTimer = nil;
        self.hasMoreItems = NO;
        self.lastTouchTimestamp = 0;
        self.demoDelay = 0.0f;  // by default no demo...
        self.userInteractionEnabled = NO;
        _menuItemHighlightedLayersArray = nil;
        _menuItemLayersArray = nil;
        _menuItemNamesArray = nil;
        
        _baseFrame = frame;
        _fullFrame = self.superview.bounds; // by default we use the superview's frame - overridden if Fullframe passed
        _touchOrientation = orient; // by default it is SOUTH

        
        // Keep our frame to be full frame and adjust the touchFrame location
        self.frame = _fullFrame;
        self.backgroundColor = [UIColor purpleColor];
        _fullLayer = [CALayer layer];
        _fullLayer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wild_oliva.png"]].CGColor;
        _fullLayer.opacity = 0.0;   // not visible (full transparency)
        _fullLayer.frame = _fullFrame;
        
        [self.layer addSublayer: _fullLayer];

        UIFont *headlineFont = [UIFont fontWithName:@"Avenir" size:20];
        if (headlineFont == nil) headlineFont = [UIFont systemFontOfSize:20];
        CATextLayer *hlayer = [self createTextLayer:COLORFROMHEX(0xffffffff) font: headlineFont size: 20];
        hlayer.string = @"Tap for more information";
        hlayer.frame = CGRectMake(0, 100, _fullFrame.size.width, 100);
        [_fullLayer addSublayer:hlayer];

        _baseLayer = [CALayer layer];
        _baseLayer.backgroundColor = [UIColor blackColor].CGColor;
        _baseLayer.opacity = 1.0;   // fully visible (no transparency)
        [self.layer addSublayer:_baseLayer];
        
        // add a small layer on the top
        _hintLayer = [self createLayer:[UIColor colorWithPatternImage:[UIImage imageNamed:@"nasty_fabric.png"]] strokeColor:COLORFROMHEX(0x80ffffff)];
        _hintLayer.opacity = 0.85f;
        _hintLayer.shadowOpacity = 1.0f;
        _hintLayer.borderColor = COLORFROMHEX(0x50ffffff).CGColor;
        _hintLayer.borderWidth = 4;
        [_fullLayer addSublayer:_hintLayer];
        
        // add a small layer on the top
        _hint2Layer = [self createTextLayer:COLORFROMHEX(0xffffffff) font: headlineFont size: 16];
        _hint2Layer.string = @"CANCEL";
        
        // _hint2Layer.borderColor = COLORFROMHEX(0x50ffffff).CGColor;
        //_hint2Layer.borderWidth = 4;
        [_fullLayer addSublayer:_hint2Layer];
        
        
        self.font = [UIFont fontWithName:@"Ropa Sans" size: FONTSIZE];
        if (self.font == nil) self.font = [UIFont systemFontOfSize:FONTSIZE];
        
        _bubbleLayer = [CALayer layer];
        _bubbleLayer.backgroundColor = COLORFROMHEX(0x80d71341).CGColor;
        _bubbleLayer.cornerRadius = 5;
        _bubbleLayer.hidden = YES;
        
        _bubbleLayer.speed = 4;
        _bubbleTextLayer = [CATextLayer layer];
        _bubbleTextLayer.backgroundColor = [UIColor clearColor].CGColor;
        _bubbleTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
        _bubbleTextLayer.font = (__bridge CFTypeRef)(self.font.fontName);
        _bubbleTextLayer.fontSize = FONTSIZE;
        _bubbleTextLayer.zPosition = 0;
        
        [_bubbleLayer addSublayer:_bubbleTextLayer];
        [self.layer addSublayer:_bubbleLayer];
        
        _firstLayer = [self createLayer:COLORFROMHEX(0xffffffff) strokeColor:COLORFROMHEX(0xffffffff)];
        
        _shimLayer = [self createLayer:COLORFROMHEX(0xff9FCBED) strokeColor:COLORFROMHEX(0xff9FCBED)];
        
        _secondLayer = [self createLayer:COLORFROMHEX(0xffffffff) strokeColor:COLORFROMHEX(0x50ffffff)];
        

        if ((_stripDirection == EMDirectionHorizontalBehind) || (_stripDirection == EMDirectionVerticalBehind)) {
            [self.layer addSublayer: _secondLayer];
            [self.layer addSublayer: _shimLayer];
            [self.layer addSublayer: _firstLayer];
        } else {
            [self.layer addSublayer: _firstLayer];
            [self.layer addSublayer: _shimLayer];
            [self.layer addSublayer: _secondLayer];
        }
        
        
    }
    return self;
}

// Typically will be done by the controller on orientation change, etc
- (void) setFullFrame:(CGRect)frame
{
    // if demo is active .. trash it
    if (_demoAnimation) {
        [self squashAnimation];
    }
    if (_demoTimer != nil) {
        [_demoTimer invalidate];
        _demoTimer = nil;
        // reset the demo
        [self performDemo: _demoDelay];
    }

    CGRect touchFrame = frame;
    switch (_touchOrientation) {
        case EMOrientationRight:
            touchFrame.origin.x = frame.size.width - TOUCH_WINDOW_DIMENSION;
            touchFrame.size.width = TOUCH_WINDOW_DIMENSION;
            break;
            
        case EMOrientationLeft:
            touchFrame.size.width = TOUCH_WINDOW_DIMENSION;
            break;
            
        case EMOrientationTop:
            touchFrame.size.height = TOUCH_WINDOW_DIMENSION + 20;
            break;
            
        case EMOrientationBottom:
        default:
            touchFrame.origin.y = frame.size.height - TOUCH_WINDOW_DIMENSION;
            touchFrame.size.height = TOUCH_WINDOW_DIMENSION;
            break;
            
    }
    _baseFrame = touchFrame;
    _fullFrame = frame;
    [self reconfigure];
}

// Perform Demo - if the client desires the demo for hinting the user about how to do this, this will be called.
// There is no 'gaurantee' that the demo will be fired - as there will be some delay before the demo starts up - and if
// the user already uses the feature, then there is no need to show the demo
// There will be a 'callback' if the demo is fired, so the client code can note it (persistently) so as to not fire the demo
// in future
- (void) performDemo: (CGFloat) initialDelayTime
{
    _demoDelay = (initialDelayTime==0.0f)? DEFAULT_DEMO_DELAY: initialDelayTime;
    _demoTimer = [NSTimer timerWithTimeInterval: _demoDelay target:self selector:@selector(doDemo) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_demoTimer forMode:NSRunLoopCommonModes];
        

}

#pragma mark - Layers Factory Methods

- (CAShapeLayer *) createLayer: (UIColor *) fill strokeColor: (UIColor *) stroke
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.strokeColor = [stroke CGColor];
    layer.fillColor = [fill CGColor];
    layer.opacity = 1.0;
    
    layer.shadowOffset = CGSizeMake(0, 8);
    layer.shadowRadius = 16;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.15;
    return layer;
}

- (CATextLayer *) createTextLayer: (UIColor *) foregroundColor font: (UIFont *) font size: (CGFloat) fontSize
{
    CATextLayer *layer = [CATextLayer layer];
    layer.opacity = 1.0f;
    layer.shadowOpacity = 1.0f;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.foregroundColor = [foregroundColor CGColor];
    layer.font = (__bridge CFTypeRef)(font.fontName);
    layer.fontSize = fontSize;
    layer.zPosition = 0;
    layer.alignmentMode = kCAAlignmentCenter;
    
    layer.shadowOffset = CGSizeMake(0, 8);
    layer.shadowRadius = 16;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.15;
    return layer;
}

- (CALayer *) createMenuLayer: (UIImage *) image withOpacity: (CGFloat) opacity
{
    CALayer *menuItemLayer = [[CALayer alloc]init];
    menuItemLayer.opacity = opacity;
    menuItemLayer.frame = CGRectMake(0, 0, 10, 10);
    menuItemLayer.backgroundColor = [UIColor clearColor].CGColor;
    [menuItemLayer setCornerRadius:5];
    [menuItemLayer setBorderColor:[UIColor clearColor].CGColor];
    menuItemLayer.hidden = YES;
    menuItemLayer.speed = 4;
    
    menuItemLayer.contents = (id) image.CGImage;
    return menuItemLayer;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark - View Related

- (void)fillFrame
{
    self.frame = _fullFrame;
    self.clipsToBounds = NO;
    
    _fullLayer.frame = _fullFrame;
    
}

- (void)configureView
{
    // Adjust some parameters first
    if (stripHorizontal(_stripDirection)) {
        // Along the X dimension and Heights to be considered
        _menuTotalWidthOrHeight = self.frame.size.width - (MARGIN*2);
        _menuStartXOrY = MARGIN;
        _menuItemWidth = MAXMENUITEMWIDTH;
        _menuItemHeight = MAXMENUITEMHEIGHT;
        // calculate max # of items
        _maxMenuCount = _menuTotalWidthOrHeight / (_menuItemWidth + MINMENUITEMMARGIN);
        int itemCount = ((_menuItemCount <= _maxMenuCount)? _menuItemCount : _maxMenuCount);
        _menuItemWithMarginWidth = _menuTotalWidthOrHeight / itemCount;
        if(_menuItemWithMarginWidth < MAXMENUITEMWIDTH)
        {
            _menuItemWidth = MINMENUITEMWIDTH;
            _menuItemHeight = MINMENUITEMHEIGHT;
        }
        if (_menuTotalWidthOrHeight > (itemCount * (_menuItemWidth + MINMENUITEMMARGIN))) {
            _menuTotalWidthOrHeight = (itemCount * (_menuItemWidth + MINMENUITEMMARGIN)) + MINMENUITEMMARGIN;
            _menuItemWithMarginWidth = _menuTotalWidthOrHeight / itemCount;
        }
    } else {
        // Along the Y dimension and Heights to be considered
        _menuTotalWidthOrHeight = self.frame.size.height - (MARGIN*2);
        _menuStartXOrY = MARGIN;
        _menuItemWidth = MAXMENUITEMWIDTH;
        _menuItemHeight = MAXMENUITEMHEIGHT;
        // calculate max # of items
        _maxMenuCount = _menuTotalWidthOrHeight / (_menuItemHeight + MINMENUITEMMARGIN);
        int itemCount = ((_menuItemCount <= _maxMenuCount)? _menuItemCount : _maxMenuCount);
        _menuItemWithMarginWidth = _menuTotalWidthOrHeight / itemCount;
        if(_menuItemWithMarginWidth < MAXMENUITEMWIDTH)
        {
            _menuItemWidth = MINMENUITEMWIDTH;
            _menuItemHeight = MINMENUITEMHEIGHT;
        }
        if (_menuTotalWidthOrHeight > (itemCount * (_menuItemHeight + MINMENUITEMMARGIN))) {
            _menuTotalWidthOrHeight = (itemCount * (_menuItemHeight + MINMENUITEMMARGIN)) + MINMENUITEMMARGIN;
            _menuItemWithMarginWidth = _menuTotalWidthOrHeight / itemCount;
        }
    }
    // NSLog(@">>> _menuStartXOrY=%f",_menuStartXOrY);
    
    if (_maxMenuCount < _menuItemCount) {
        // you need to split it into 2
        _hasMoreItems = YES;
        _menu2TotalWidthOrHeight = ((_menuItemCount - _maxMenuCount + 1) * (_menuItemWidth + MINMENUITEMMARGIN)) + MINMENUITEMMARGIN;
        _menu2StartXOrY = ((stripHorizontal(_stripDirection)) ? self.frame.size.width : self.frame.size.height) - _menu2TotalWidthOrHeight - MARGIN;
        // create layers for the hint icons
        
    } else {
        // _menuTotalWidth = _controlsCount * (
        _secondLayer = nil;
        _shimLayer = nil;
        _maxMenuCount = _menuItemCount; // set this to the maximum number of items.
    }
    // abc _menuStartX = self.frame.size.width - _menuTotalWidth - MARGIN;
    
#ifdef NOTNEEDED
    [self addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
#endif
    
        
    [self fillFrame];
    
    
    _menuItemLayersArray = [[NSMutableArray alloc] init];
    _menuItemHighlightedLayersArray = [[NSMutableArray alloc] init];
    _menuItemNamesArray = [[NSMutableArray alloc] init];
    UIImage *menuImage, *menuHighlightImage;
    NSString *menuItemName;
    // if there is a second layer needed, then we have one extra item for layers (put in the end)
    // This item will be the hint for opening more items
    int count = _menuItemCount;
    // xyz if (_hasMoreItems) count += 2;
    for(int i = 0; i<count; i++)
    {
        // xyz menuImage = ((i==(count-2)) && (_hasMoreItems)) ? [UIImage imageNamed:@"ElasticMenuMore2Line.png"]: (((i==(count-1)) && (_hasMoreItems))? [UIImage imageNamed:@"ElasticMenuMore2CloseLine.png"] : [self getMenuItemImageForIndex:i]);
        menuImage = [self getMenuItemImageForIndex:i];
        CALayer *menuItemLayer = [self createMenuLayer:menuImage withOpacity:0.7];
        [_menuItemLayersArray addObject: menuItemLayer];
        
        // xyz menuHighlightImage = ((i==(count-2)) && (_hasMoreItems)) ? [UIImage imageNamed:@"ElasticMenuMore2Solid.png"]: (((i==(count-1)) && (_hasMoreItems))? [UIImage imageNamed:@"ElasticMenuMore2CloseSolid.png"] : [self getMenuItemHighlightImageForIndex:i]);
        menuHighlightImage =  [self getMenuItemHighlightImageForIndex:i];
        CALayer *menuItemHighlightLayer = [self createMenuLayer:menuHighlightImage withOpacity:1.0];
        [_menuItemHighlightedLayersArray addObject: menuItemHighlightLayer];

        // xyz menuItemName = ((i==(count-2)) && (_hasMoreItems)) ? @"More...": (((i==(count-1)) && (_hasMoreItems))? @"Less..." : [self getMenuItemTitleForIndex:i]);
        menuItemName = [self getMenuItemTitleForIndex:i];
        [_menuItemNamesArray addObject: menuItemName];
        
#ifdef XYZ
        if ((i < (_maxMenuCount-(_hasMoreItems?1:0)))
            || ((_hasMoreItems) && (i == _menuItemCount))
            || ((_hasMoreItems) && (i == (_menuItemCount+1)))) {
            [_firstLayer addSublayer: menuItemLayer];
            [_firstLayer addSublayer: menuItemHighlightLayer];
        } else {
            [_secondLayer addSublayer: menuItemLayer];
            [_secondLayer addSublayer: menuItemHighlightLayer];
        }
#endif
        if (i < (_maxMenuCount-(_hasMoreItems?1:0))) {
            [_firstLayer addSublayer: menuItemLayer];
            [_firstLayer addSublayer: menuItemHighlightLayer];
        } else {
            [_secondLayer addSublayer: menuItemLayer];
            [_secondLayer addSublayer: menuItemHighlightLayer];
        }
    }
    
    //  add on items here
    if (_hasMoreItems) {
        _moreLayer = [self createMenuLayer:[UIImage imageNamed:@"ElasticMenuMore2Line.png"] withOpacity:0.7];
        _moreHighlightLayer = [self createMenuLayer:[UIImage imageNamed:@"ElasticMenuMore2Solid.png"] withOpacity:1.0];
        _moreHintName = @"More...";
        [_firstLayer addSublayer: _moreLayer];
        [_firstLayer addSublayer: _moreHighlightLayer];
        _lessLayer = [self createMenuLayer:[UIImage imageNamed:@"ElasticMenuMore2CloseLine.png"] withOpacity:0.7];
        _lessHighlightLayer = [self createMenuLayer:[UIImage imageNamed:@"ElasticMenuMore2CloseSolid.png"] withOpacity:1.0];
        _lessHintName = @"Less...";
        if ((_stripDirection == EMDirectionHorizontalBehind) || (_stripDirection == EMDirectionVerticalBehind)) {
            [_firstLayer addSublayer: _lessLayer];
            [_firstLayer addSublayer: _lessHighlightLayer];
        } else {
            
            [_secondLayer addSublayer: _lessLayer];
            [_secondLayer addSublayer: _lessHighlightLayer];
        }
    }
    _secondLayerActive = NO;
    // NSLog(@">>> _menuStartXOrY=%f",_menuStartXOrY);
    //_bubbleTextLayer.transform = CATransform3DMakeRotation((stripHorizontal(_stripDirection)?0.0:90.0) / 180.0 * M_PI, 0.0, 0.0, 1.0);
    // _bubbleLayer.transform = CATransform3DMakeRotation((stripHorizontal(_stripDirection)?0.0:30.0) / 180.0 * M_PI, 0.0, 0.0, 1.0);
    
}

#define FINGERDELTA -7  // depends on the offset of the finger from the center
#define TRANSPARENCYDELTA   -16

// Define these in the Theme file so the caller can specify the image to be used
#ifndef HINT_IMAGE_BOTTOM_TO_TOP
#define HINT_IMAGE_BOTTOM_TO_TOP @"Triangle-drag-icon-BT.png"
#define HINT_IMAGE_TOP_TO_BOTTOM @"Triangle-drag-icon-TB.png"
#define HINT_IMAGE_LEFT_TO_RIGHT @"Triangle-drag-icon-LR.png"
#define HINT_IMAGE_RIGHT_TO_LEFT @"Triangle-drag-icon-RL.png"
#endif

- (void) configureHint
{
    if (_elasticMenuPopImage) {
        [_elasticMenuPopImage removeFromSuperview];
    }
   // NSLog(@"%f, %f, %f, %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);

    // NOTE : ICON IMAGE NAMES CAN BE OVERRIDDEN IN THEME.H
    
    NSString *iconName = HINT_IMAGE_BOTTOM_TO_TOP;
    CGRect frame = CGRectMake(-36+TRANSPARENCYDELTA, -32+TRANSPARENCYDELTA, 64, 64);
    CGRect outerFrame = self.frame;
    
    NSString *overlayImage = @"Finger-drag-overlay-new.png";
    // UIViewAutoresizing mask;
    NSString * slideMessage;
    CGFloat deltaX = -140;
    
    switch (_touchOrientation) {
        case EMOrientationRight:
            iconName = HINT_IMAGE_RIGHT_TO_LEFT;
            slideMessage = @"Slide from the Right Edge";
            deltaX = -200;
            frame.origin.y = outerFrame.size.height-60;
            frame.origin.x += outerFrame.size.width - 8;
            //mask = (UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleLeftMargin);
            break;
            
        case EMOrientationLeft:
            iconName = HINT_IMAGE_LEFT_TO_RIGHT;
            deltaX = 20;
            slideMessage = @"Slide from the Left Edge";
            frame.origin.y = self.frame.size.height-60;
            frame.origin.x = 12+TRANSPARENCYDELTA;
            //mask = (UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleLeftMargin);
            break;
            
        case EMOrientationTop:
            iconName = HINT_IMAGE_TOP_TO_BOTTOM;
            slideMessage = @"Slide from the Top Edge";
            //overlayImage = @"Finger-drag-overlay-vertical.png";
            frame.origin.x = self.frame.size.width-64;
            frame.origin.y = 32+TRANSPARENCYDELTA;
            //mask = (UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleLeftMargin);
            break;
            
        case EMOrientationBottom:
        default:
            iconName = HINT_IMAGE_BOTTOM_TO_TOP;
            slideMessage = @"Slide from the Bottom Edge";
            // overlayImage = @"Finger-drag-overlay-vertical.png";
            frame.origin.x = self.frame.size.width-64;
            frame.origin.y += self.frame.size.height - 16;
            //mask = (UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleLeftMargin);
            break;
            
    }
    UIImage *overlay = [UIImage imageNamed: overlayImage];

#ifdef GLOW_WANTED
    UIImageView *glowView = [[UIImageView alloc] initWithFrame:frame];
    glowView.image = [UIImage imageNamed:@"GlowEffect-Orange.png"];
    glowView.alpha = 0.2;
    [glowView setAutoresizingMask: mask];

    [self glow:glowView.layer];
    [self addSubview: glowView];
#endif
    
    _elasticMenuPopImage = [[UIImageView alloc] initWithFrame: frame];
    CALayer *baseImageLayer = [CALayer layer];
    baseImageLayer.frame = [_elasticMenuPopImage bounds];
    baseImageLayer.contents = (id)([UIImage imageNamed:iconName].CGImage);
    _elasticMenuPopImage.alpha = 1.0f;
    baseImageLayer.opacity = 0.8f;
    [_elasticMenuPopImage.layer addSublayer:baseImageLayer];
    
#ifdef ELASTIC_MENU_BUTTON_TOUCH_ONLY
    _baseFrame = frame;
#endif

    UIImageView *topImage = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 64, 64)];
    CALayer *topImageLayer = [CALayer layer];
    topImageLayer.frame = [topImage bounds];
    topImageLayer.contents = (id)(overlay.CGImage);
    topImage.alpha = 0.0f;
//    topImage.image = overlay;
    topImage.userInteractionEnabled = YES;
    [topImage.layer addSublayer:topImageLayer];
    
    //[_elasticMenuPopImage setAutoresizingMask: mask];
    if (_demoDelay > 0.0f) {
        _demoTimer = [NSTimer timerWithTimeInterval: _demoDelay target:self selector:@selector(doDemo) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_demoTimer forMode:NSRunLoopCommonModes];
        
    }
    [self addSubview:_elasticMenuPopImage];
    [_elasticMenuPopImage addSubview: topImage];
    
    // add couple of layers for animation and demo
    CAShapeLayer *outerCircle = [self createLayer:COLORFROMHEX(0x80d71341) strokeColor:COLORFROMHEX(0x80d71341)];
    outerCircle.opacity = 0;
    //outerCircle.position = CGPointMake(24, 24);
    CAShapeLayer *innerCircle = [self createLayer:COLORFROMHEX(0x80d71341) strokeColor:COLORFROMHEX(0x80d71341)];
    innerCircle.opacity = 0;
    //innerCircle.position = CGPointMake(32, 32);
    CALayer *layer = topImage.layer;
    
    // add a small layer on the top
    UIFont *headlineFont = [UIFont fontWithName:@"Avenir" size:20];
    if (headlineFont == nil) headlineFont = [UIFont systemFontOfSize:20];
    CATextLayer *hintText = [self createTextLayer:COLORFROMHEX(0xffffffff) font: headlineFont size: 20];
    hintText.string = slideMessage;
    hintText.frame = CGRectMake(deltaX, -24, 280, 100);
    
    [layer insertSublayer:hintText atIndex:0];
    [layer insertSublayer:innerCircle atIndex:0];
    [layer insertSublayer:outerCircle atIndex:0];

    _fullLayer.opacity = 1.0;
    _fullLayer.frame = _fullFrame;

}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (CGRectEqualToRect(_fullFrame, CGRectZero)) {
        _fullFrame = self.superview.bounds; // by default we use the superview's frame
    }
    [self backToNormal:NO];
}

-(void)setBubbleText:(NSString *)itemName
{
    self.bubbleTextLayer.string = itemName;
    UIFont *bubbleFont = self.font; // [UIFont systemFontOfSize:14];
    CGSize bubbleTextSize = [itemName sizeWithFontSafe:bubbleFont];
    self.bubbleTextLayer.frame = CGRectMake(3, 2, bubbleTextSize.width, bubbleTextSize.height);
    self.bubbleLayer.frame = CGRectMake(0, 0, bubbleTextSize.width + 6, bubbleTextSize.height + 4);
}

#pragma mark - Restore the normal state
-(void) backToNormal: (BOOL) animated
{
    
    _elasticMenuPopImage.hidden = NO;
    _fullLayer.opacity = 0.0f;  // Not visible

    if (animated) {
        [self addLayerAnimation:_firstLayer duration: SLIDEOUT_ANIMATION_DURATION/2 distance: -1.0f onCompletion:self];
        [self addLayerAnimation:_secondLayer duration: SLIDEOUT_ANIMATION_DURATION/2 distance: -1.0f onCompletion:nil];
        [self addLayerAnimation:_shimLayer duration: SLIDEOUT_ANIMATION_DURATION/2 distance: -1.0f onCompletion:nil];
        [self addLayerAnimation:_bubbleLayer duration: (SLIDEOUT_ANIMATION_DURATION*2.3) distance: -1.0f onCompletion:nil];

    } else {
        // FRAMECHANGE self.frame = self.baseFrame;
    }
    for(int i =0 ; i< self.menuItemLayersArray.count;i++)
    {
        CALayer *tlayer = [self.menuItemLayersArray objectAtIndex:i];
        CALayer *tlayer2 = [self.menuItemHighlightedLayersArray objectAtIndex:i];
        if (animated) {
            // raining out kind of animation
            [self addLayerAnimation:tlayer duration: (SLIDEOUT_ANIMATION_DURATION*1.5) distance: 200.0 onCompletion:nil];
            [self addLayerAnimation:tlayer2 duration: (SLIDEOUT_ANIMATION_DURATION*2.3) distance: 50.0 onCompletion:nil];
        } else {
            tlayer.opacity = 0.7;
            tlayer.hidden = YES;
            tlayer2.hidden = YES;
        }
    }
    
    if (!animated) {
        self.firstLayer.hidden = YES;
        self.secondLayer.hidden = YES;
        self.shimLayer.hidden = YES;
        self.bubbleLayer.hidden = YES;
    }
    
    // If the timer is active, invalidate it
    if (_moreChoicesTimer) {
        [_moreChoicesTimer invalidate];
        _moreChoicesTimer = nil;
    }
    _secondLayerActive = NO;
    _inAnimation = animated;    // indicate that we are in the midst of animation
}

- (void) squashAnimation
{
    UIImageView *topImageView = [[_elasticMenuPopImage subviews] objectAtIndex:0];
    CALayer * layer = topImageView.layer;
    NSArray *layers = [layer sublayers];
    // hide the added sublayers (hintText, outerCircle, innerCircle)
    [[layers objectAtIndex:0]  setOpacity:0.0f];
    [[layers objectAtIndex:1]  setOpacity:0.0f];
    [[layers objectAtIndex:2]  setOpacity:0.0f];
    // FRAMECHANGE self.frame = _baseFrame;
    _fullLayer.opacity = 0.0f;
    _demoAnimation = NO;
    [_instructionsImageLayer removeFromSuperlayer];
    
}


#pragma mark - animation delegate methods
- (void)animationDidStop:(CAAnimation*)animation finished:(BOOL)finished
{
    if([[animation valueForKey:@"name"] isEqual:@"slide"] && finished) {
        [self removeAnimations: NO];
    } else if ([[animation valueForKey:@"name"] isEqual:@"slide-demo"] && finished) {
        [[[self.layer sublayers] objectAtIndex:0] removeFromSuperlayer];
        UIImageView *topImageView = [[_elasticMenuPopImage subviews] objectAtIndex:0];
        CALayer * layer = topImageView.layer;
        CGPoint endPoint = layer.position;
        if ((_touchOrientation == EMOrientationRight) || (_touchOrientation==EMOrientationLeft)) {
            endPoint.y += 100;
        } else {
            endPoint.x += 100;
        }
        layer.position = endPoint;
        layer.opacity = 0.0f;

        
        if (_demoDelay > 0.0f) {
            _demoDelay *= 1.5f;
            // recreate the timer
            if (_demoTimer != nil) {
                [_demoTimer invalidate];
            }
            _demoTimer = [NSTimer timerWithTimeInterval: _demoDelay target:self selector:@selector(doDemo) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:_demoTimer forMode:NSRunLoopCommonModes];
        }
    } else if ([[animation valueForKey:@"name"] isEqual:@"circle"] && finished) {
        // NSLog(@"Animation done");
        [self squashAnimation];
    }
}

- (void) removeAnimations: (BOOL) remove
{
    if (remove) {
        [_firstLayer removeAllAnimations];
        [_secondLayer removeAllAnimations];
        [_shimLayer removeAllAnimations];
        [_bubbleLayer removeAllAnimations];
        for(int i =0 ; i< self.menuItemLayersArray.count;i++)
        {
            CALayer *tlayer = [self.menuItemLayersArray objectAtIndex:i];
            [tlayer removeAllAnimations];
            tlayer = [self.menuItemHighlightedLayersArray objectAtIndex:i];
            [tlayer removeAllAnimations];
        }
    }
    CGPoint endPoint = _firstLayer.position;
    endPoint.y -= _fullFrame.size.height;
    _firstLayer.position = endPoint;
    endPoint = _secondLayer.position;
    endPoint.y -= _fullFrame.size.height;
    _secondLayer.position = endPoint;
    endPoint = _shimLayer.position;
    endPoint.y -= _fullFrame.size.height;
    _shimLayer.position = endPoint;
    endPoint = _bubbleLayer.position;
    endPoint.y -= _fullFrame.size.height;
    _bubbleLayer.position = endPoint;
    
    _firstLayer.hidden = YES;
    _secondLayer.hidden = YES;
    _shimLayer.hidden = YES;
    _bubbleLayer.hidden = YES;
    // FRAMECHANGE self.frame = self.baseFrame;
    for(int i =0 ; i< self.menuItemLayersArray.count;i++)
    {
        CALayer *tlayer = [self.menuItemLayersArray objectAtIndex:i];
        tlayer.hidden = YES;
        tlayer = [self.menuItemHighlightedLayersArray objectAtIndex:i];
        tlayer.hidden = YES;
    }
    
    _inAnimation = NO;
}

#pragma mark - animations

- (void) addLayerAnimation: (CALayer *) layer duration: (CGFloat) timeinseconds distance: (CGFloat) dist onCompletion: (id) delegate
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = timeinseconds;
    
    animation.fromValue = [NSValue valueWithCGPoint:layer.position];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    if (delegate != nil) {
        animation.delegate = self;
        animation.removedOnCompletion = YES;    // was NO
        [animation setValue:@"slide" forKey:@"name"];
    }
    
    CGPoint endPoint = layer.position;
    endPoint.y += (dist<0.0)?_fullFrame.size.height : dist;   // drop it below the full frame
    layer.position = endPoint;
    [layer addAnimation:animation forKey:@"slide"];
}

- (void) glow: (CALayer *) layer
{
    // CALayer *layer = view.layer;
    // grow from its original value
    layer.transform = CATransform3DMakeScale(1.15, 1.05, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.autoreverses = YES;
    animation.duration = 1.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = 20; // HUGE_VALF;  // Count for animation
    [layer addAnimation:animation forKey:@"pulseAnimation"];
}

- (void) doDemo
{
    UIImageView *topImageView = [[_elasticMenuPopImage subviews] objectAtIndex:0];
    CALayer * layer = topImageView.layer;
    
    // CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    NSString *keyPath; BOOL horizontal = YES; CGFloat mult, startx, starty, endx, endy;
    NSString *swipeInstructionName = @"SwipingInstructions-BT.png";
    
    switch (_touchOrientation) {
        case EMOrientationRight:
            keyPath = @"position.x";
            startx = 1.0f;
            starty = 0.5;
            endx = 0.0f;
            endy = 0.5f;
            mult = 1.0f;
            swipeInstructionName = @"SwipingInstructions-RL.png";
            break;
            
        case EMOrientationLeft:
            keyPath = @"position.x";
            mult = -1.0f;
            startx = 0.0f;
            starty = 0.5;
            endx = 1.0f;
            endy = 0.5f;
            swipeInstructionName = @"SwipingInstructions-LR.png";
            break;
            
        case EMOrientationTop:
            keyPath = @"position.y";
            horizontal = NO;
            mult = -1.0f;
            startx = 0.5f;
            starty = 0.0;
            endx = 0.5f;
            endy = 1.0f;
            swipeInstructionName = @"SwipingInstructions-TB.png";
            break;
            
        case EMOrientationBottom:
        default:
            keyPath = @"position.y";
            horizontal = NO;
            mult = 1.0f;
            startx = 0.5f;
            starty = 1.0;
            endx = 0.5f;
            endy = 0.0f;
            swipeInstructionName = @"SwipingInstructions-BT.png";
            break;
            
    }
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];;
    
    animation.duration = 2.0f;
    
    CGPoint endPoint = layer.position;
    CGFloat basePosition = horizontal? endPoint.x : endPoint.y;
    // CGPoint origPoint = endPoint;
    if (horizontal) {
        endPoint.y -= 100;
    } else {
        endPoint.x -= 100;
    }
    // layer.position = endPoint;
    // animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(endPoint.x + 10, endPoint.y)];
    animation.values = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat: (basePosition + mult * 7.0f)],
                        [NSNumber numberWithFloat: (basePosition + mult * 9.0f)],
                        [NSNumber numberWithFloat: (basePosition + mult * 11.0f)],
                        [NSNumber numberWithFloat: (basePosition + mult * 15.0f)],
                        [NSNumber numberWithFloat: (basePosition + mult * 20.0f)],
                        [NSNumber numberWithFloat: (basePosition + mult * 7.0f)],
                        [NSNumber numberWithFloat: (basePosition + mult * 3.0f)],
                        [NSNumber numberWithFloat: (basePosition - mult * 3.0f)],
                        [NSNumber numberWithFloat: (basePosition - mult * 8.0f)],
                        [NSNumber numberWithFloat: (basePosition - mult * 14.0f)],
                        [NSNumber numberWithFloat: (basePosition - mult * 13.0f)],
                        [NSNumber numberWithFloat: (basePosition - mult * 12.0f)],
                        [NSNumber numberWithFloat: (basePosition - mult * 10.0f)],
                        [NSNumber numberWithFloat: (basePosition - mult * 8.0f)],
                        [NSNumber numberWithFloat: (basePosition - mult * 6.0f)],
                        [NSNumber numberWithFloat: (basePosition - mult * 3.0f)],
                        [NSNumber numberWithFloat: (basePosition)], nil];

    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.delegate = self;
    animation.removedOnCompletion = YES;    // was NO
    [animation setValue:@"slide-demo" forKey:@"name"];
    // animation.autoreverses = YES;
    
    // layer.position = CGPointMake(endPoint.x - 10, endPoint.y);
    // layer.backgroundColor = [UIColor blueColor].CGColor;
    [layer addAnimation:animation forKey:@"slide"];
    layer.position = endPoint; // CGPointMake(endPoint.x, endPoint.y);
    layer.opacity = 1.0f;

#ifdef STYLE1
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 5.2;
    CGFloat initPos = layer.position.x;

    animation.values = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat: (initPos + 4.0f)],
                        [NSNumber numberWithFloat: (initPos - 7.0f)],
                        [NSNumber numberWithFloat: (initPos - 8.0f)],
                        [NSNumber numberWithFloat: (initPos - 9.0f)],
                        [NSNumber numberWithFloat: (initPos - 13.0f)],
                        [NSNumber numberWithFloat: (initPos - 12.0f)],
                        [NSNumber numberWithFloat: (initPos - 10.0f)], nil];
    
    [layer setValue:[NSNumber numberWithInt:160] forKeyPath:animation.keyPath];
    [layer addAnimation:animation forKey:@"slide"];
#endif
    // self.backgroundColor = [UIColor lightGrayColor];
    // add a layer that overlays the cell adding a subtle gradient effect

    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    gradientLayer.type = kCAGradientLayerAxial;
    gradientLayer.colors = @[(id)[[UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0] CGColor],
                             (id)[[UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.8] CGColor],
                             (id)[[UIColor colorWithRed:0.8 green:0.4 blue:0.5 alpha:0.7] CGColor],
                             (id)[[UIColor colorWithRed:0.8 green:0.4 blue:0.5 alpha:0.5] CGColor],
                             (id)[[UIColor colorWithRed:0.8 green:0.4 blue:0.5 alpha:0.0] CGColor]];
    gradientLayer.locations = @[@0.00f, @0.02f, @0.10f, @0.50f, @0.70f];
    gradientLayer.startPoint = CGPointMake(startx, starty);
    gradientLayer.endPoint = CGPointMake(endx, endy);

    // CAGradientLayer* gradientLayer = [self blueGradient];
    gradientLayer.frame = [self bounds];
    gradientLayer.opacity = 0.0;
    
    CABasicAnimation* transition =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    transition.removedOnCompletion = FALSE;
    transition.fillMode = kCAFillModeForwards;
    transition.duration = 2.0;
    transition.beginTime = 0;
    transition.autoreverses = YES;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.toValue = [NSNumber numberWithFloat: 1.0];
    
    [gradientLayer addAnimation:transition forKey:@"opacity"];
    
    [self.layer insertSublayer:gradientLayer atIndex:0];

    
    // add a small layer to 'pulse'
    //CAShapeLayer *circle = [self createLayer:COLORFROMHEX(0x80d71341) strokeColor:COLORFROMHEX(0x80d71341)];
    //circle.frame = CGRectMake(0, 0, 64, 64);
    // circle.opacity = 0.3f;
    
    CAShapeLayer *outerCircle = [[layer sublayers] objectAtIndex:0];
    outerCircle.opacity = 0.3;
    outerCircle.frame = CGRectMake(0+FINGERDELTA, 0+FINGERDELTA, 48, 48);
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:outerCircle.frame];
    outerCircle.path = circlePath.CGPath;

    UIBezierPath *circlePath2 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-24+FINGERDELTA, -24+FINGERDELTA, 96, 96)];

    CABasicAnimation* transition2 =  [CABasicAnimation animationWithKeyPath: @"path"];
    transition2.removedOnCompletion = FALSE;
    transition2.fillMode = kCAFillModeForwards;
    transition2.repeatCount = 2.0;
    transition2.duration = 1;
    transition2.beginTime = 0;
    transition2.autoreverses = YES;
    transition2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition2.fromValue = (__bridge id)(circlePath.CGPath);
    transition2.toValue = (__bridge id)circlePath2.CGPath;
    transition2.delegate = self;
    [transition2 setValue:@"circle" forKey:@"name"];
    
    [outerCircle addAnimation:transition2 forKey:@"animatePath"];

    CAShapeLayer *innerCircle = [[layer sublayers] objectAtIndex:1];
    innerCircle.opacity = 0.4;
    innerCircle.frame = CGRectMake(4+FINGERDELTA, 4+FINGERDELTA, 32, 32);
    
    UIBezierPath *circlePath3 = [UIBezierPath bezierPathWithOvalInRect:innerCircle.frame];
    innerCircle.path = circlePath3.CGPath;

    UIBezierPath *circlePath4 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-4+FINGERDELTA, -4+FINGERDELTA, 48, 48)];
    
    CABasicAnimation* transition3 =  [CABasicAnimation animationWithKeyPath: @"path"];
    transition3.removedOnCompletion = FALSE;
    transition3.fillMode = kCAFillModeForwards;
    transition3.repeatCount = 4.0;
    transition3.duration = 1.0;
    transition3.beginTime = 0;
    transition3.autoreverses = YES;
    transition3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition3.fromValue = (__bridge id)(circlePath3.CGPath);
    transition3.toValue = (__bridge id)circlePath4.CGPath;
    transition3.delegate = self;
    [transition3 setValue:@"circle" forKey:@"name"];
    
    [innerCircle addAnimation:transition3 forKey:@"animatePath"];
    
    CALayer *hintText = [[layer sublayers] objectAtIndex:2];
    hintText.opacity = 1.0f;

    _demoAnimation = YES;
    
    _fullLayer.frame = _fullFrame;
    _fullLayer.opacity = 0.9f;
    _instructionsImageLayer = [CALayer layer];
    UIImage *swipeImage = [UIImage imageNamed:swipeInstructionName];
    CGFloat x = (_fullFrame.size.width - swipeImage.size.width) / 2;
    CGFloat y = (_fullFrame.size.height - swipeImage.size.height) / 2;
    _instructionsImageLayer.frame = CGRectMake(x, y, swipeImage.size.width, swipeImage.size.height);
    _instructionsImageLayer.contents = (id)(swipeImage.CGImage);
    _instructionsImageLayer.contentsScale = 2.0f;
    _instructionsImageLayer.opacity = 1.0f;
    [_fullLayer addSublayer:_instructionsImageLayer];
    // _baseLayer.backgroundColor = [UIColor blackColor].CGColor;
    //_hint2Layer.frame = _fullFrame;
    //_hintLayer.frame = _fullFrame;
    //self.frame = _fullFrame;
    //self.clipsToBounds = NO;
    //[self addMenuActionHints: @"Some text" threshold:100.0f showRect:NO];

    [self addMenuActionHints: @"Tap anywhere for more info" threshold:REDZONEOFFSET showRect:NO];
}

#ifdef NOTNOW
- (void) jiggle: (CALayer *) layer
{
    CAKeyframeAnimation *animation;
    
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 1.0f;
    animation.cumulative = YES;
    animation.repeatCount = 10;
    animation.beginTime = 2.0f;
    animation.values = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat: 0.0],
                        [NSNumber numberWithFloat: RADIANS(-9.0)],
                        [NSNumber numberWithFloat: 0.0],
                        [NSNumber numberWithFloat: RADIANS(9.0)],
                        [NSNumber numberWithFloat: 0.0], nil];
    
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    animation.removedOnCompletion = YES;
    animation.delegate = self;
    animation.removedOnCompletion = YES;    // was NO
    [animation setValue:@"jiggle" forKey:@"name"];

    layer.anchorPoint = CGPointMake(0.5f, 0.90f);
    
    [layer addAnimation:animation forKey:@"jiggle"];
}
#endif

- (void) wiggle: (CALayer *) layer
{
    CAKeyframeAnimation *animation;
    
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.7;
    animation.cumulative = YES;
    animation.repeatDuration = SECONDLAYER_POPUP_DELAY*2;
    animation.values = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat: 0.0],
                        [NSNumber numberWithFloat: RADIANS(-9.0)],
                        [NSNumber numberWithFloat: 0.0],
                        [NSNumber numberWithFloat: RADIANS(9.0)],
                        [NSNumber numberWithFloat: 0.0], nil];
    
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    animation.removedOnCompletion = YES;
    animation.delegate = self;
    [animation setValue:@"wiggle" forKey:@"name"];
    
    [layer addAnimation:animation forKey:@"wiggle"];
}

- (void) toggleSecondLayer
{
    self.moreChoicesTimer = nil;
    // If there was any animation active, clear it
    if (_secondLayerActive) {
        [_lessHighlightLayer removeAllAnimations];
        _lessHighlightLayer.hidden = YES;
    } else {
        [_moreHighlightLayer removeAllAnimations];
        _moreHighlightLayer.hidden = YES;
    }
    _secondLayerActive = !_secondLayerActive;
    if (_secondLayerActive) {
        _secondLayerThreshold = _lastTouchPoint;
    }
    [self reposition:_lastTouchPoint withTouchBegin:NO touchSpeed: 0.0f stripAnimation: YES];
    
}

// The following is used to see if we should cancel the active state completely
// Does not matter if the main layer or the second layer is active - it is meant for the user
// to drag finger towards the starting point enough so that we know that lifting the finger will
// mean cancellation
//
- (BOOL) inRedZone: (CGPoint) point
{
    BOOL isInRedZone = NO;
    CGFloat delta;
    if (stripHorizontal(_stripDirection)) {
        delta = (_touchOrientation == EMOrientationTop) ? point.y : (_fullFrame.size.height - point.y);
    } else {
        delta = (_touchOrientation == EMOrientationLeft) ? point.x : (_fullFrame.size.width - point.x);
    }
    isInRedZone = (delta < REDZONEOFFSET)? YES: NO;
    return isInRedZone;

}
// (_secondLayerThreshold.y - tapPoint.y) < - ORANGEZONEOFFSET
- (BOOL) inOrangeZone: (CGPoint) point
{
    BOOL isInOrangeZone = NO;
    CGFloat delta;
    if (stripHorizontal(_stripDirection)) {
        delta = (_touchOrientation == EMOrientationTop) ? (_secondLayerThreshold.y - point.y - (_menuItemHeight + (ELASTIC_MENU_MARGIN*2) + ELASTIC_MENU_DELTA)) : (point.y - _secondLayerThreshold.y);
    } else {
        delta = (_touchOrientation == EMOrientationLeft) ? ( _secondLayerThreshold.x - point.x) : (point.x - _secondLayerThreshold.x);
    }
    isInOrangeZone = (delta > ORANGEZONEOFFSET)? YES: NO;
    return isInOrangeZone;
    
}

//
// for horizontal strip offset is from the bottom (or the active edge of the full rectangle)
// for vertical strip, the offset is for the width along the active edge of the full rectangle
//
- (CGRect) hintRedZoneRect: (CGFloat) offset
{
    CGRect frame = _fullFrame;
    if (stripHorizontal(_stripDirection)) {
        // reduce the height by the provided offset amount
        frame.size.height -= offset;
        // decide if you are at the top or the bottom of the full frame
        // except for one orientation, the redzone is at the bottom
        if (_touchOrientation ==  EMOrientationTop) {
            frame.origin.y += offset;
        }
    } else {
        frame.size.width -= offset;
        if (_touchOrientation ==  EMOrientationLeft) {
            frame.origin.x += offset;
        }
    }
    return frame;
    
}

#pragma mark - Reposition - bulk of the position work

- (void) menuPosition: (NSSet *) touches withTouchBegin: (BOOL) isBegin
{
    UITouch *touch = touches.anyObject;
    CGPoint tapPoint = [touch locationInView:self];
    CGFloat speed = 0.0;
    if (_lastTouchTimestamp > 0) {
        speed = sqrt((pow((tapPoint.x - _lastTouchPoint.x), 2) + pow((tapPoint.y - _lastTouchPoint.y),2)))/(touch.timestamp - _lastTouchTimestamp);
        // NSLog(@"Timestamp: %f, x=%f, y=%f, speed=%f", touch.timestamp, tapPoint.x, tapPoint.y, speed);
    }
    _lastTouchTimestamp = touch.timestamp;
    // NSLog(@"speed=%f", speed);
    // If demo was about to be fired - cancel it and never show again in this reincarnation
    if (_demoTimer != nil) {
        [_demoTimer invalidate];
        _demoTimer = nil;
        _demoDelay = 0.0f;
    }
    [self reposition:tapPoint withTouchBegin:isBegin touchSpeed: speed stripAnimation:NO];
    
}

- (void) reposition: (CGPoint) tapPoint withTouchBegin: (BOOL) isBegin touchSpeed: (CGFloat) speed stripAnimation: (BOOL) toggle
{
    
   // NSLog(@"... _menuStartXOrY=%f",_menuStartXOrY);
    
    if ([self inRedZone:tapPoint])/*  (_fullFrame.size.height - tapPoint.y < REDZONEOFFSET) */
    {
        _isActive = NO;
        _secondLayerActive = NO;
    } else if (_secondLayerActive && [self inOrangeZone:tapPoint]) {
        self.secondLayerActive = NO;
        _secondLayer.hidden = YES;
        _shimLayer.hidden = YES;
        _lessHighlightLayer.hidden = YES;
    } else {
        _isActive = YES;
    }
    
    _lastTouchPoint = tapPoint;
    
    CGFloat menuStripOrigin = (_secondLayerActive ?_menu2StartXOrY:_menuStartXOrY);
    // The following is relative (either in the main layer or second layer if it is active..
    
    CGFloat tapPointSelectionAxis; // along x if menu strip is horizontal
    CGFloat tapPointActivityAxis;   // along y if menu strip is horizontal
    if (stripHorizontal(_stripDirection)) {
        tapPointSelectionAxis = tapPoint.x;
        tapPointActivityAxis = tapPoint.y;
    } else {
        tapPointSelectionAxis = tapPoint.y;
        tapPointActivityAxis = tapPoint.x;
    }
    NSInteger activeControlIndex = (tapPointSelectionAxis - menuStripOrigin) / self.menuItemWithMarginWidth;
    
    // NSLog(@"TapPoint.x=%f, MenuStripOrigin=%f, Active Menu Index=%ld", tapPoint.x, menuStripOrigin, activeControlIndex);
    // Figure out Where we are ...
    if (_quickSingleTap) {
        activeControlIndex = 0;
    } else {
    if((tapPointSelectionAxis - menuStripOrigin) < 0)
    {
        activeControlIndex = 0;
        // Now wiggle the more item and use timer to toggle back to single layer
        if (_secondLayerActive) {
            if (_moreChoicesTimer == nil) /* && (speed < 20.0f) )*/ {
                // xyz CALayer *moreItemHighlightLayer = [self.menuItemHighlightedLayersArray     objectAtIndex: (_menuItemCount+1)];
                [self wiggle: _lessHighlightLayer];
                _moreChoicesTimer = [NSTimer timerWithTimeInterval: SECONDLAYER_POPUP_DELAY target:self selector:@selector(toggleSecondLayer) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:self.moreChoicesTimer forMode:NSRunLoopCommonModes];
            }
            activeControlIndex = -1;
        }
    } else if ((activeControlIndex >= _maxMenuCount) && (!_secondLayerActive)) {
        activeControlIndex = _maxMenuCount - 1;
    } else if ((activeControlIndex >= (_menuItemCount + 1 - _maxMenuCount)) && (_secondLayerActive)) {
        activeControlIndex = _menuItemCount - _maxMenuCount - 1;
    } else if (_secondLayerActive && (_moreChoicesTimer != nil)) {
        // we moved away - towards the right of the starting X for the 2nd layer
        [_moreChoicesTimer invalidate]; _moreChoicesTimer = nil;
        // stop wiggling!
        // xyz CALayer *moreItemHighlightLayer = [self.menuItemHighlightedLayersArray objectAtIndex: ((_secondLayerActive)?(_menuItemCount+1):_menuItemCount)];
        // xyz [moreItemHighlightLayer removeAllAnimations];
        [_lessHighlightLayer removeAllAnimations];
        
    }
    }
    // NSLog(@"Active Menu Index=%ld", activeControlIndex);
    
    if (!_secondLayerActive && _isActive) {
        if ((activeControlIndex == (_maxMenuCount - 1)) &&
            (_hasMoreItems)) {
            // timer - about 2 seconds
            //
            CALayer *moreItemHighlightLayer = _moreHighlightLayer; // xyz [self.menuItemHighlightedLayersArray objectAtIndex: (_menuItemCount)];
            // if we have a timer set, but we are moving too fast, then delay the timer once again,
            // until we reduce the speed somewhat
            if ((_moreChoicesTimer != nil) && (speed >= 40.0f)) {
                [_moreChoicesTimer invalidate];
                _moreChoicesTimer = nil;
                [moreItemHighlightLayer removeAllAnimations];
                // it will be set again immediately
            }

            // if we have moved at least by REDZONEOFFSET + ORANGEZONEOFFSET then we set the timer
            if (
                (_moreChoicesTimer == nil)
                &&
                (_fullFrame.size.height - tapPointActivityAxis > (REDZONEOFFSET+ORANGEZONEOFFSET)) ){
                // if you move too much from the original position, restart the timer as you are likely
                // to trigger falsely as you start moving into the menu
                // TO CHECK - do you need the speed to be figured out?
                [self wiggle: moreItemHighlightLayer];
                _moreChoicesTimer = [NSTimer timerWithTimeInterval: SECONDLAYER_POPUP_DELAY target:self selector:@selector(toggleSecondLayer) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:self.moreChoicesTimer forMode:NSRunLoopCommonModes];
            }
        } else {
            // turn off the timer
            _secondLayerActive = NO;
            if (_moreChoicesTimer) {
                [_moreChoicesTimer invalidate];
                _moreChoicesTimer = nil;
            }
        }
    } else {
        // self.firstLayer.opacity = 0.3f;
    }
    CGFloat itemWidth = self.menuItemWidth;
    CGFloat itemTop = tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN+ELASTIC_MENU_DELTA) + (_secondLayerActive? SECONDLAYER_OFFSET: 0);
    CGFloat itemX = _menuStartXOrY;
    // NSLog(@"itemX=%f",itemX);
    // BOOL moreItem = (_maxMenuCount < _controlsCount);
    for(int i = 0 ; i<_maxMenuCount ; i++)
    {
        BOOL isMoreItem = (i==(_maxMenuCount-1));
        CALayer *currentLayer;
        CALayer *currentHighlightLayer;
        if (_hasMoreItems && isMoreItem) {
            currentLayer = _secondLayerActive? _lessLayer : _moreLayer;
            currentHighlightLayer = _secondLayerActive? _lessHighlightLayer : _moreHighlightLayer;
        } else {
            currentLayer = [self.menuItemLayersArray objectAtIndex:i];
            currentHighlightLayer = [self.menuItemHighlightedLayersArray objectAtIndex:i];
        }
        if (!_secondLayerActive) {
            if ((self.isActive == YES) && (i == activeControlIndex)) {
                currentLayer.hidden = YES;
                currentHighlightLayer.hidden = NO;
                currentHighlightLayer.opacity = 1.0;
                if (isMoreItem) {
                    // [self wiggle: currentHighlightLayer];
                }
            } else {
                // currentLayer.opacity = 0.7; // dim
                currentLayer.hidden = NO;
                currentLayer.opacity = 1.0f;
                currentHighlightLayer.hidden = YES;
            }
        } else {
            // second layer is active
            if (i == (_maxMenuCount - 1)) {
                //
                if (activeControlIndex == -1) {
                    currentLayer.hidden = YES;
                    currentHighlightLayer.hidden = NO;
                    // currentHighlightLayer.opacity = 0.6f;
                } else {
                    currentHighlightLayer.hidden = YES;
                    currentLayer.hidden = NO;
                }
            } else {
                currentLayer.opacity = 0.25f;
            }
        }
        itemX = (_secondLayerActive?(_menu2StartXOrY - _menuTotalWidthOrHeight + (self.menuItemWidth*SECONDLAYER_OVERLAP)): _menuStartXOrY) + ((self.menuItemWithMarginWidth - itemWidth) / 2) + ((itemWidth + ((self.menuItemWithMarginWidth - itemWidth))) * i  );
#ifdef NOTNOW
        if ((_stripDirection == EMDirectionHorizontalBehind) || (_stripDirection == EMDirectionVerticalBehind)) {
            [currentLayer setFrame:CGRectMake(itemX, itemTop, itemWidth, itemWidth)];
            // highlighted icon is slightly bigger
            [currentHighlightLayer setFrame:CGRectMake(itemX-4, itemTop-4, itemWidth+8, itemWidth+8)];
        } else {
            
            // we have to adjust the _lessHighlightLayer to stay on the secondlayer Y offset, so we adjust it
            [currentLayer setFrame:CGRectMake(itemX, itemTop - ((_secondLayerActive && isMoreItem)? SECONDLAYER_OFFSET: 0), itemWidth, itemWidth)];
            // highlighted icon is slightly bigger
            [currentHighlightLayer setFrame:CGRectMake(itemX-4, itemTop- 4 - ((_secondLayerActive && isMoreItem)? SECONDLAYER_OFFSET: 0), itemWidth+8, itemWidth+8)];
        }
#endif
        switch (_stripDirection) {
            case EMDirectionHorizontalBehind:
                [currentLayer setFrame:CGRectMake(itemX, itemTop, itemWidth, itemWidth)];
                // highlighted icon is slightly bigger
                [currentHighlightLayer setFrame:CGRectMake(itemX-4, itemTop-4, itemWidth+8, itemWidth+8)];
                break;

            case EMDirectionVerticalBehind:
                [currentLayer setFrame:CGRectMake(itemTop, itemX, itemWidth, itemWidth)];
                // highlighted icon is slightly bigger
                [currentHighlightLayer setFrame:CGRectMake(itemTop-4, itemX-4, itemWidth+8, itemWidth+8)];
               break;

            case EMDirectionHorizontalFront:
                // we have to adjust the _lessHighlightLayer to stay on the secondlayer Y offset, so we adjust it
                [currentLayer setFrame:CGRectMake(itemX, itemTop - ((_secondLayerActive && isMoreItem)? SECONDLAYER_OFFSET: 0), itemWidth, itemWidth)];
                // highlighted icon is slightly bigger
                [currentHighlightLayer setFrame:CGRectMake(itemX-4, itemTop- 4 - ((_secondLayerActive && isMoreItem)? SECONDLAYER_OFFSET: 0), itemWidth+8, itemWidth+8)];
                break;

            case EMDirectionVerticalFront:
                // we have to adjust the _lessHighlightLayer to stay on the secondlayer Y offset, so we adjust it
                [currentLayer setFrame:CGRectMake(itemTop - ((_secondLayerActive && isMoreItem)? SECONDLAYER_OFFSET: 0), itemX, itemWidth, itemWidth)];
                // NSLog(@"Vertical: y=%f", itemX);
                // highlighted icon is slightly bigger
                [currentHighlightLayer setFrame:CGRectMake(itemTop- 4 - ((_secondLayerActive && isMoreItem)? SECONDLAYER_OFFSET: 0), itemX-4,  itemWidth+8, itemWidth+8)];
                break;

        }
        
        
        if(isBegin)
            currentLayer.hidden = NO;
    }
    
    CGRect frame;
    if (stripHorizontal(_stripDirection)) {
    frame = CGRectMake((_secondLayerActive?(_menu2StartXOrY - _menuTotalWidthOrHeight + (self.menuItemWidth*SECONDLAYER_OVERLAP)): _menuStartXOrY),
                              tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA) + (_secondLayerActive? SECONDLAYER_OFFSET: 0),
                              _menuTotalWidthOrHeight,
                              self.menuItemHeight+ELASTIC_MENU_MARGIN*2);
    } else {
        frame = CGRectMake(
                           tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA) + (_secondLayerActive? SECONDLAYER_OFFSET: 0),
                                (_secondLayerActive?(_menu2StartXOrY - _menuTotalWidthOrHeight + (self.menuItemWidth*SECONDLAYER_OVERLAP)): _menuStartXOrY),
                                 self.menuItemHeight+ELASTIC_MENU_MARGIN*2,
                                 _menuTotalWidthOrHeight);
    }
    
    // UIBezierPath *elasticMenuOutlinePath = [UIBezierPath bezierPathWithRoundedRect: frame cornerRadius: MENUSTRIP_CORNER_RADIUS];
    UIRectCorner corners =  (_secondLayerActive) ?
    (UIRectCornerTopLeft | UIRectCornerBottomLeft) :
    (UIRectCornerAllCorners);
    UIBezierPath *elasticMenuOutlinePath = [UIBezierPath bezierPathWithRoundedRect: frame byRoundingCorners:corners cornerRadii: CGSizeMake(MENUSTRIP_CORNER_RADIUS, MENUSTRIP_CORNER_RADIUS)];
    
    
    self.firstLayer.path = elasticMenuOutlinePath.CGPath;
    
    
    if (_secondLayerActive) {
        _secondLayer.hidden = NO;
        int active2Index = (tapPointSelectionAxis - _menu2StartXOrY) / self.menuItemWithMarginWidth;
        CGFloat item2Top = tapPointActivityAxis - 1 * (self.menuItemHeight + (ELASTIC_MENU_MARGIN + ELASTIC_MENU_DELTA));
        for(int i = (_maxMenuCount - 1) ; i<_menuItemCount ; i++) {
            CALayer *currentLayer = [self.menuItemLayersArray objectAtIndex:i];
            CALayer *currentHighlightLayer = [self.menuItemHighlightedLayersArray objectAtIndex:i];
            if ((self.isActive == YES) && ((i-(_maxMenuCount - 1)) == active2Index)) {
                currentLayer.hidden = YES;
                currentHighlightLayer.hidden = NO;
                currentHighlightLayer.opacity = 1.0;
            } else {
                // currentLayer.opacity = 0.7; // dim
                currentLayer.hidden = NO;
                currentHighlightLayer.hidden = YES;
            }
            itemWidth = self.menuItemWidth;
            
            itemX = _menu2StartXOrY + ((self.menuItemWithMarginWidth - itemWidth) / 2) + ((itemWidth + ((self.menuItemWithMarginWidth - itemWidth) / 2)) * (i - _maxMenuCount + 1)  );
            
            if (stripHorizontal(_stripDirection)) {
                [currentLayer setFrame:CGRectMake(itemX, item2Top, itemWidth, itemWidth)];
                [currentHighlightLayer setFrame:CGRectMake(itemX-4, item2Top-4, itemWidth+8, itemWidth+8)];
            } else {
                [currentLayer setFrame:CGRectMake(item2Top, itemX, itemWidth, itemWidth)];
                [currentHighlightLayer setFrame:CGRectMake(item2Top-4, itemX-4, itemWidth+8, itemWidth+8)];
            }
            
        }
        
        CGRect frame2;
        UIRectCorner corners;
        if (stripHorizontal(_stripDirection)) {
            frame2 = CGRectMake(_menu2StartXOrY -40 ,
                                   tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA),
                                   _menu2TotalWidthOrHeight + 40,
                                   self.menuItemHeight+ELASTIC_MENU_MARGIN*2);
            corners =  (_secondLayerActive) ?
            (UIRectCornerTopRight | UIRectCornerBottomRight) :
            (UIRectCornerAllCorners);
        } else {
            frame2 = CGRectMake(
                                tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA), _menu2StartXOrY -40,
                                    self.menuItemHeight+ELASTIC_MENU_MARGIN*2,
                                    _menu2TotalWidthOrHeight + 40
                                );
            corners =  (_secondLayerActive) ?
            (UIRectCornerBottomLeft | UIRectCornerBottomRight) :
            (UIRectCornerAllCorners);
        }
        
        // UIBezierPath *elasticMenu2OutlinePath = [UIBezierPath bezierPathWithRoundedRect: frame2 cornerRadius: MENUSTRIP_CORNER_RADIUS];
        UIBezierPath *elasticMenu2OutlinePath = [UIBezierPath
                                                 bezierPathWithRoundedRect: frame2
                                                 byRoundingCorners:corners
                                                 cornerRadii: CGSizeMake(MENUSTRIP_CORNER_RADIUS,
                                                                         MENUSTRIP_CORNER_RADIUS)];
        
        self.secondLayer.path = elasticMenu2OutlinePath.CGPath;
        
        UIBezierPath *shimBezierPath = [UIBezierPath bezierPath];
        
        // Draw the lines.
        if (stripHorizontal(_stripDirection)) {
            [shimBezierPath moveToPoint:CGPointMake(_menu2StartXOrY - 40, /* MENUSTRIP_CORNER_RADIUS/2 +*/ tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA))];

            [shimBezierPath addLineToPoint: CGPointMake(_menu2StartXOrY  - 40, tapPointActivityAxis  - ELASTIC_MENU_DELTA)];
            [shimBezierPath addLineToPoint:CGPointMake(_menu2StartXOrY + (self.menuItemWidth*SECONDLAYER_OVERLAP), tapPointActivityAxis - (ELASTIC_MENU_DELTA) + SECONDLAYER_OFFSET)];
            [shimBezierPath addLineToPoint:CGPointMake(_menu2StartXOrY + (self.menuItemWidth*SECONDLAYER_OVERLAP), /* MENUSTRIP_CORNER_RADIUS/2  + */ tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA) + SECONDLAYER_OFFSET)];
        } else {
            //NSLog(@"1: (%f, %f)", /* MENUSTRIP_CORNER_RADIUS/2 +*/ tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA), _menu2StartXOrY - 40);
            [shimBezierPath moveToPoint:CGPointMake(/* MENUSTRIP_CORNER_RADIUS/2 +*/ tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA), _menu2StartXOrY - 40)];
            //NSLog(@"2: (%f, %f)", tapPointActivityAxis  - ELASTIC_MENU_DELTA, _menu2StartXOrY  - 40);

            [shimBezierPath addLineToPoint: CGPointMake(tapPointActivityAxis  - ELASTIC_MENU_DELTA, _menu2StartXOrY  - 40)];
            //NSLog(@"3: (%f, %f)", tapPointActivityAxis - (ELASTIC_MENU_DELTA) + SECONDLAYER_OFFSET, _menu2StartXOrY + (self.menuItemWidth*SECONDLAYER_OVERLAP));

            [shimBezierPath addLineToPoint:CGPointMake(tapPointActivityAxis - (ELASTIC_MENU_DELTA) + SECONDLAYER_OFFSET, _menu2StartXOrY + (self.menuItemWidth*SECONDLAYER_OVERLAP))];
            //NSLog(@"4: (%f, %f)", /* MENUSTRIP_CORNER_RADIUS/2  + */ tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA) + SECONDLAYER_OFFSET, _menu2StartXOrY + (self.menuItemWidth*SECONDLAYER_OVERLAP));
            [shimBezierPath addLineToPoint:CGPointMake( /* MENUSTRIP_CORNER_RADIUS/2  + */ tapPointActivityAxis - self.menuItemHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA) + SECONDLAYER_OFFSET, _menu2StartXOrY + (self.menuItemWidth*SECONDLAYER_OVERLAP))];
            
        }
        [shimBezierPath closePath];
        
        self.shimLayer.path = shimBezierPath.CGPath;
    } else {
        // make sure we hide all the second layer elements
        if (_hasMoreItems) {
            for(int i = (_maxMenuCount - 1) ; i<_menuItemCount ; i++) {
                CALayer *tlayer = [self.menuItemLayersArray objectAtIndex:i];
                tlayer.opacity = 0.7;
                tlayer.hidden = YES;
                tlayer = [self.menuItemHighlightedLayersArray objectAtIndex:i];
                tlayer.hidden = YES;
            }
        }
    }
    
    if ((!_secondLayerActive) && (self.currentIndex != activeControlIndex))
    {
        //change string of bubble TODO
        NSString *bT;
        if ((_hasMoreItems) && (activeControlIndex == (_maxMenuCount-1))) {
            bT = _moreHintName;
        } else {
            bT = [self.menuItemNamesArray objectAtIndex:activeControlIndex];
        }
        [self setBubbleText: bT];
        self.currentIndex = activeControlIndex;
    } else if (_secondLayerActive) {
        // if we are looking to
        NSString *bT;
        if (activeControlIndex<0) {
            bT = _lessHintName;
        } else {
            bT = [self.menuItemNamesArray objectAtIndex:((int) activeControlIndex + _maxMenuCount - 1)];
        }
        [self setBubbleText: bT];
        // xyz int itemIndex = ((activeControlIndex<0)) ? (_menuItemCount+1) : (int) activeControlIndex + _maxMenuCount - 1;
        // xyz [self setBubbleText: [self.menuItemNamesArray objectAtIndex:itemIndex]];
        self.currentIndex = activeControlIndex;
    }
    
    // Now set up the BubbleText to float over the selected item..
    // Extract the layer for the icon first...
    // int itemIndex;
    CALayer *activeMenuItemLayer;
    if (_secondLayerActive) {
        activeMenuItemLayer = (activeControlIndex<0) ? _lessLayer : [self.menuItemLayersArray objectAtIndex:((int) activeControlIndex + _maxMenuCount - 1)];
    } else if ((_hasMoreItems) && ((activeControlIndex==(_maxMenuCount-1))) ) {
        activeMenuItemLayer = _secondLayerActive ? _lessLayer : _moreLayer;
    } else {
        activeMenuItemLayer = [self.menuItemLayersArray objectAtIndex:(int)activeControlIndex];
    }
    
    CGFloat bubbleX, bubbleY;
    
    if (stripHorizontal(_stripDirection)) {
        bubbleX = (activeMenuItemLayer.frame.origin.x + (activeMenuItemLayer.frame.size.width/2)) - (self.bubbleLayer.frame.size.width / 2);
        
        if(bubbleX < 0)
        {
            bubbleX = 0;
        }
        else if((bubbleX + activeMenuItemLayer.frame.size.width) > self.frame.size.width)
        {
            bubbleX = self.frame.size.width - self.bubbleLayer.frame.size.width - 10;
        }
        
        bubbleY = tapPointActivityAxis - (_secondLayerActive?1:1) * (self.menuItemHeight + (ELASTIC_MENU_MARGIN*2) /* + ELASTIC_MENU_DELTA */) - self.bubbleLayer.frame.size.height - (ELASTIC_MENU_DELTA + ELASTIC_MENU_BUBBLE_GAP);
    } else {
        bubbleY = (activeMenuItemLayer.frame.origin.y + (activeMenuItemLayer.frame.size.height/2)) - (self.bubbleLayer.frame.size.height / 2);
        
        if(bubbleY < 0)
        {
            bubbleY = 0;
        }
        else if((bubbleY + activeMenuItemLayer.frame.size.height) > self.frame.size.height)
        {
            bubbleY = self.frame.size.height - self.bubbleLayer.frame.size.height - 10;
        }
        
        bubbleX = tapPointActivityAxis - (_secondLayerActive?1:1) * (self.menuItemHeight + (ELASTIC_MENU_MARGIN*2) /* + ELASTIC_MENU_DELTA */) - self.bubbleLayer.frame.size.width - (ELASTIC_MENU_DELTA + ELASTIC_MENU_BUBBLE_GAP);
    }
    
    [self.bubbleLayer setFrame:CGRectMake(bubbleX, bubbleY, self.bubbleLayer.frame.size.width, self.bubbleLayer.frame.size.height)];
    
    
    if(isBegin)
    {
        _firstLayer.hidden = NO;
        _bubbleLayer.hidden = NO;
        _isActive = NO; // ??
    }
    
    if(self.isActive == NO)
    {
        _bubbleLayer.hidden = YES;
        _firstLayer.opacity = 0.5;
        _fullLayer.opacity = BASELAYER_INACTIVE_OPACITY; // 0.05f
        _hintLayer.hidden = YES;
        _hint2Layer.hidden = YES;
        _elasticMenuPopImage.hidden = NO;
        NSString *hint = (stripHorizontal(_stripDirection)? @"Drag up to Activate menu": @"Drag to Activate menu");
        [self addMenuActionHints:hint threshold:REDZONEOFFSET showRect:NO];
    }
    else {
        _bubbleLayer.hidden = NO;
        _firstLayer.opacity = 1.0;
        _fullLayer.opacity = BASELAYER_ACTIVE_OPACITY;  // 0.2f
        
        if (_secondLayerActive) {
            self.secondLayer.hidden =  NO;
            self.shimLayer.hidden = NO;
            CGFloat boundary;
            if (stripHorizontal(_stripDirection)) {
                boundary= (_touchOrientation == EMOrientationTop) ? (_secondLayerThreshold.y - ORANGEZONEOFFSET - (_menuItemHeight + (ELASTIC_MENU_MARGIN*2) + ELASTIC_MENU_DELTA)) : (_fullFrame.size.height - _secondLayerThreshold.y - ORANGEZONEOFFSET);
            } else {
                boundary= (_touchOrientation == EMOrientationLeft) ? (_secondLayerThreshold.x - ORANGEZONEOFFSET - (_menuItemHeight + (ELASTIC_MENU_MARGIN*2) + ELASTIC_MENU_DELTA)) : (_fullFrame.size.width - _secondLayerThreshold.x - ORANGEZONEOFFSET);
                
            }
            // NSLog(@"Boundary: %f", boundary);
            [self addMenuActionHints: @"Drag here for Less Options" threshold:boundary showRect:NO];
        } else {
            [self addMenuActionHints:@"Drag here to Cancel menu" threshold:REDZONEOFFSET showRect:NO];
        }
        
        //_baseLayer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wild_oliva.png"]].CGColor;
        _elasticMenuPopImage.hidden = YES;
    }
    
    if (!_secondLayerActive) {
        self.secondLayer.hidden =  YES;
        self.shimLayer.hidden = YES;
        // _hint2Layer.hidden = YES;
    }
    
}

- (void) addMenuActionHints: (NSString *) hintText threshold: (CGFloat) boundary showRect: (BOOL) overlay
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect: [self hintRedZoneRect: (boundary)]];
    _hintLayer.path = path.CGPath;
    _hintLayer.hidden = NO;
    _hintLayer.lineWidth = 0;// UNLESS YOU figure out how to do the border "outside of the rect" leave this to 0
    _hintLayer.lineDashPattern = [NSArray arrayWithObjects: [NSNumber numberWithInt:10], [NSNumber numberWithInt:5], nil];

    CGRect textFrame = _fullFrame;
    
    if (stripHorizontal(_stripDirection)) {
        textFrame.origin.y = (_touchOrientation == EMOrientationTop) ?
                                    (boundary - 10 - 24)   // 24 for the height of the text font
                                    : (_fullFrame.size.height - boundary + 10);
    } else {
        // textFrame.origin.x +=30;
        if (_touchOrientation == EMOrientationLeft) {
            textFrame.origin.x += 10;
            
        } else {
            textFrame.origin.x = (_fullFrame.size.width - boundary + 10);
        }
        _hint2Layer.transform = CATransform3DMakeRotation( 270.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
    }
    textFrame.size.height -= textFrame.origin.y;
    _hint2Layer.frame = textFrame;
    _hint2Layer.string = hintText; // @"L E S S   O P T I O N S" "C A N C E L" etc
    _hint2Layer.hidden = NO;
    
}



#pragma mark - Reconfigure
- (void)reconfigure
{
    self.menuItemCount = (int) [self getMenuItemCount];
    
    if(_menuItemLayersArray != nil)
    {
        for(CALayer *tempLayer in _menuItemLayersArray)
        {
            [tempLayer removeFromSuperlayer];
        }
        _menuItemLayersArray = nil;
    }
    if(_menuItemHighlightedLayersArray != nil)
    {
        for(CALayer *tempLayer in _menuItemHighlightedLayersArray)
        {
            [tempLayer removeFromSuperlayer];
        }
        _menuItemHighlightedLayersArray = nil;
    }
    
    if(_menuItemNamesArray != nil)
    {
        _menuItemNamesArray = nil;
    }
    
    [self configureHint];
    [self configureView];
}


#ifdef NOTNEEDED
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        NSValue *oldCanvasSizeValue = [change objectForKey:NSKeyValueChangeOldKey];
        NSValue *newCanvasSizeValue = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (![oldCanvasSizeValue isEqual:[NSNull null]] &&
            ![newCanvasSizeValue isEqual:[NSNull null]]) {
            
            CGRect oldSize = [oldCanvasSizeValue CGRectValue];
            CGRect newSize = [newCanvasSizeValue CGRectValue];
            
        }
    }
}
#endif

#pragma mark - Touch delegate methods
- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // Check if you are within the _baseFrame
    if (_popMessageButton) {
        return _popMessageButton;
    }
    if (CGRectContainsPoint(_baseFrame, point) || _demoAnimation || _secondLayerActive || _quickSingleTap) {
        return self;
    }
    // if the user is doing something, delay the demo
    if (_demoDelay > 0.0f) {
        // recreate the timer
        if (_demoTimer != nil) {
            [_demoTimer invalidate];
        }
        _demoTimer = [NSTimer timerWithTimeInterval: _demoDelay target:self selector:@selector(doDemo) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_demoTimer forMode:NSRunLoopCommonModes];
    }

    return nil; // [super hitTest:point withEvent:event];
}
// On the first touch, we configure the view (with all the layers of menuItems - icons, bubble text, highlights, etc)
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // NSLog(@"secondlayer=%@", _secondLayerActive?@"YES":@"NO");
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuTouchesBegan:withEvent:)]) {
        [self.delegate menuTouchesBegan:touches withEvent:event];
    }
    if (_demoAnimation) {
        [self showMessage:_demoHelpMessage withTitle:@"Hello"];
        return;
    }
    if (_inAnimation) {
        [self removeAnimations: YES];
    }
    BOOL menuPopped = _secondLayerActive || _quickSingleTap;
    _quickSingleTap = NO;   //
    if (!menuPopped) {
        self.currentIndex = -1;
        [self fillFrame];
        if (_menuItemLayersArray == nil) {
            self.menuItemCount = (int)[self getMenuItemCount];
            [self configureView];
        }
        // Now adjust its horizontal location
        UITouch *touch = touches.anyObject;
        CGPoint tapPoint = [touch locationInView:self];
        if (stripHorizontal(_stripDirection)) {
            _menuStartXOrY = tapPoint.x;
            if ((_menuStartXOrY + _menuTotalWidthOrHeight + MARGIN) > _fullFrame.size.width) {
                _menuStartXOrY = _fullFrame.size.width - (_menuTotalWidthOrHeight + MARGIN);
            }
        } else {
            _menuStartXOrY = tapPoint.y;
            if ((_menuStartXOrY + _menuTotalWidthOrHeight + MARGIN) > _fullFrame.size.height) {
                _menuStartXOrY = _fullFrame.size.height - (_menuTotalWidthOrHeight + MARGIN);
            }
        }
    }
    [self menuPosition:touches withTouchBegin:!menuPopped];
    
    if ((_singleTapTimer == nil) && !menuPopped) {
        _singleTapTimer = [NSTimer timerWithTimeInterval: 0.325 target:self selector:@selector(notSingleTap) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_singleTapTimer forMode:NSRunLoopCommonModes];
        _quickSingleTap = YES;
    }

}

// We set timer after the first touch...
// If the timer fires, then it is considered as a swiping action (the user did not lift too soon)
//
- (void) notSingleTap
{
    _quickSingleTap = NO;
    _singleTapTimer = nil;
}

// This method is invoked when the Cocoa Touch framework receives a system interruption requiring cancellation of the touch event; for this, it generates a UITouch object with a phase of UITouchPhaseCancel. The interruption is something that might cause the application to be no longer active or the view to be removed from the window

// Clean up involves going back to normal
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuTouchesEnded:withEvent:)]) {
        [self.delegate menuTouchesEnded:touches withEvent:event];
    }
    [self backToNormal: NO];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuTouchesEnded:withEvent:)]) {
        [self.delegate menuTouchesEnded:touches withEvent:event];
    }

    BOOL popSecondLayer = NO;
    if(self.isActive == YES)
    {
        // if you release on the last item ..
        // Second Layer Active - The Menu will remain Visible
        //
        if (((!_secondLayerActive) && (_hasMoreItems) && (_currentIndex == (_maxMenuCount - 1)))
            || (_secondLayerActive && (_currentIndex == -1)) ){
            // NSLog(@"Not selecting - popping second layer");
            popSecondLayer = YES;
            _quickSingleTap = _secondLayerActive;  // if we are popping to the first layer, we fake a single tap
            if (_moreChoicesTimer) [_moreChoicesTimer invalidate];
            [self toggleSecondLayer];
            _hint2Layer.string = @"Touch & swipe above to continue";
        } else {
            [self didSelectMenuItem:(_secondLayerActive? (self.currentIndex+_maxMenuCount-1) :self.currentIndex)];
        }
    }
    if (!popSecondLayer) {
        // if you release the tap too soon (not realizing the behavior of the menu ..
        // The Menu will remain Visible and will be repositioned to activate..
        //
        
        if (_quickSingleTap) {
            [_singleTapTimer invalidate];
            _singleTapTimer = nil;
            _isActive = YES;    // make it active regardless of where you are...
            CGPoint fakePoint = _lastTouchPoint;
            NSString *message;
            if (stripHorizontal(_stripDirection)) {
                fakePoint.y += (((_touchOrientation== EMOrientationTop)? 3 : -1) * REDZONEOFFSET);
                message = @"Tap on the desired menu item";
            } else {
                fakePoint.x += (((_touchOrientation== EMOrientationLeft)? 2 : -1) * REDZONEOFFSET);
                message = @"Tap on the desired menu item";
            }
            [self reposition:fakePoint withTouchBegin:NO touchSpeed:0.0f stripAnimation:NO];
            _hint2Layer.string = message;
            // NSLog(@"Single Tap recognized - leaving the menu up");
        } else {
            [self backToNormal:_isActive];  // if we are active then do animated restore
        }
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self menuPosition:touches withTouchBegin:NO];
}

#pragma mark - Delegate method wrappers
-(void) didSelectMenuItem:(NSInteger)index
{
    if(self.delegate == nil)
    {
        if(self.menuItems != nil)
        {
            MoElasticMenuItem *indexedItem = [self.menuItems objectAtIndex:index];
            if(indexedItem.target != nil && indexedItem.action != nil)
            {
                [indexedItem.target performSelector:indexedItem.action withObject:indexedItem afterDelay:0];
            }
        }
    }
    else
    {
        [self.delegate didSelectMenuItem:index];
    }
}


-(NSInteger) getMenuItemCount
{
    if(self.delegate == nil)
    {
        if(self.menuItems != nil)
        {
            return [self.menuItems count];
        }
        return 0;
    }
    return [self.delegate menuItemCount];
}


-(NSString *)getMenuItemTitleForIndex:(NSInteger)index
{
    if(self.delegate == nil)
    {
        if(self.menuItems != nil)
        {
            MoElasticMenuItem *indexedItem = [self.menuItems objectAtIndex:index];
            if(indexedItem.menuTitle != nil)
            {
                return indexedItem.menuTitle;
            }
            return @"";
        }
    }
    return [self.delegate menuItemTitleForIndex:index];
}


-(UIImage *)getMenuItemImageForIndex:(NSInteger)index
{
    if(self.delegate == nil)
    {
        if(self.menuItems != nil)
        {
            MoElasticMenuItem *indexedItem = [self.menuItems objectAtIndex:index];
            if(indexedItem.menuImageName != nil)
            {
                return [UIImage imageNamed:indexedItem.menuImageName];
            }
            return indexedItem.defaultImage;
        }
    }
    return [self.delegate menuItemImageForIndex:index];
}


-(UIImage *)getMenuItemHighlightImageForIndex:(NSInteger)index
{
    if(self.delegate == nil)
    {
        if(self.menuItems != nil)
        {
            MoElasticMenuItem *indexedItem = [self.menuItems objectAtIndex:index];
            if(indexedItem.menuHighlightImageName != nil)
            {
                return [UIImage imageNamed:indexedItem.menuHighlightImageName];
            }
            if(indexedItem.menuImageName != nil)
            {
                return [UIImage imageNamed:indexedItem.menuImageName];
            }
            return indexedItem.defaultImage;
        }
    }
    return [self.delegate menuItemHighlightImageForIndex:index];
}


#pragma mark - popup
- (void) showMessage: (NSString *) messageStr withTitle: (NSString *) tbTitle
{
    
    _popMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _popMessageButton.tag = 20140412;
    
    CGRect frame = _fullFrame;
    
    [_popMessageButton setBackgroundColor: COLORFROMHEX(0xffeeeeee)];
    
    
    
    
    CGFloat width = frame.size.width - 20;
    if (width > 300) width = 300;
    
    
    // ---
    if ((messageStr == nil) || ([messageStr length] == 0)) {
        messageStr = @"No message.";
    }
    
    CGSize size = CGSizeMake(width - 72, 300);
    UIFont *titleFont = [UIFont fontWithName:@"Avenir" size: 16];
    CGRect rect = [messageStr boundingRectWithSize:size Font:titleFont];
    
    CGFloat height =  rect.size.height + 48;
    
    // CGFloat iOS7Delta = (IS_IOS7?20:0);
    _popMessageButton.frame =  CGRectMake((frame.size.width - width) / 2, (frame.size.height - height - 32)/2, width, height + 32);
    [_popMessageButton addTarget:self action:@selector(closeMessage)    forControlEvents:UIControlEventTouchUpInside];
    _popMessageButton.userInteractionEnabled = YES;
    
    
    
    // Button layers
    CALayer *layer = _popMessageButton.layer;
    
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.4f;
    layer.shadowOffset = CGSizeMake(0.0f, 6.0f);
    layer.shadowRadius = 6.0f;   // this defines the amount of the blur
    layer.cornerRadius = 6.0f;
    layer.masksToBounds = NO;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    
    layer.shadowPath = [self renderPaperCurlPath:_popMessageButton];
    
    CALayer *arealayer = [CALayer layer];
    
    
    // Add a mask
    // Frame height needs to handle the shadow at the bottom so add about 16 px
    CGRect maskFrame = [layer bounds];
    maskFrame.size.height += 24; maskFrame.origin.y = -1;
    maskFrame.size.width +=20; maskFrame.origin.x = -10;
    // layer.frame = maskFrame;
    
    arealayer.mask = [self renderNotchedMask: [_popMessageButton bounds] notchOrientation:_touchOrientation];
    arealayer.frame = [_popMessageButton bounds];
    arealayer.backgroundColor = [UIColor whiteColor].CGColor;
   [layer addSublayer:arealayer];
    
   // icon.center = CGPointMake(22, 52);
   // icon.bounds = CGRectMake(6, 20, 32, 32);
    
    
    CAShapeLayer *borderLayer = [[CAShapeLayer alloc] init];
    borderLayer.strokeColor = COLORFROMHEX(0xff999999).CGColor;
    borderLayer.path = [self renderNotchedPath: [_popMessageButton bounds] notchOrientation:_touchOrientation];
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    [layer addSublayer:borderLayer];
    
    [self addSubview: _popMessageButton];

    CGFloat top = 0;
    CGFloat bottom = 0;
    CGFloat left = 0;
    CGFloat right = 0;
    switch (_touchOrientation) {
        case EMOrientationRight:
            right = 16;
            break;
            
        case EMOrientationLeft:
            left = 16;
            break;
            
        case EMOrientationTop:
            top = 16;
            break;
            
        case EMOrientationBottom:
        default:
            bottom = 16;
            break;
            
    }
    // [button addSubview: icon];
    CALayer *iconLayer = [CALayer layer];
    iconLayer.contents = (__bridge id)([UIImage imageNamed: @"ElasticMenu-Icon.png"].CGImage);
    iconLayer.opacity = 0.8f;
    iconLayer.frame = CGRectMake(width-64-right/2, height - 32 - bottom/2, 64, 64);
    [layer addSublayer:iconLayer];

    // Text to be rendered
    UILabel *iconLabel = [[UILabel alloc] initWithFrame: CGRectMake(15+left, 5 +top, width - 72, height)];
    iconLabel.backgroundColor = [UIColor clearColor];
    iconLabel.lineBreakMode = NSLineBreakByWordWrapping;
    iconLabel.numberOfLines = 0;
    iconLabel.textColor = COLORFROMHEX(0xff0f87a1);
    
    iconLabel.text = messageStr;
    iconLabel.font = titleFont;
    [_popMessageButton addSubview: iconLabel];
    iconLabel.userInteractionEnabled = YES;
    
    // [self.overlayControls addObject: button];
    
    // Keep the overlay for about 5 seconds - if you tap before that, it should go away
    NSTimer *timer = [NSTimer timerWithTimeInterval: 15.0 target:self selector:@selector(closeMessage) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer: timer forMode:NSRunLoopCommonModes];
    
}

- (void) closeMessage
{
    if (_popMessageButton) {
        [_popMessageButton removeFromSuperview];
        _popMessageButton = nil;
    }
}


- (CGPathRef)renderPaperCurlPath:(UIView*)imgView {
	CGSize size = imgView.bounds.size;
	CGFloat curlFactor = 20.0f;
	CGFloat shadowDepth = 8.0f;
    
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(3.0f, 8.0f)];
	[path addLineToPoint:CGPointMake(size.width-3.0f, 8.0f)];
	[path addLineToPoint:CGPointMake(size.width-3.0f, size.height + shadowDepth)];
	[path addCurveToPoint:CGPointMake(3.0f, size.height + shadowDepth)
			controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
			controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    
	return path.CGPath;
}

- (CGPathRef)renderNotchedPath:(CGRect) rectFrame notchOrientation: (EMOrientationType) where
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat width = rectFrame.size.width;
    CGFloat height = rectFrame.size.height;
    
    CGFloat top = 0;
    CGFloat bottom = 0;
    CGFloat left = 0;
    CGFloat right = 0;
    switch (where) {
        case EMOrientationRight:
            right = 15;
            break;
            
        case EMOrientationLeft:
            left = 15;
            break;
            
        case EMOrientationTop:
            top = 15;
            break;
            
        case EMOrientationBottom:
        default:
            bottom = 15;
            break;
            
    }
    CGPathMoveToPoint(path, NULL, left, top);
    if (where == EMOrientationTop) {
        CGPathAddLineToPoint(path, nil, (width/2) - 10, top);
        CGPathAddLineToPoint(path, nil, width/2, 0);
        CGPathAddLineToPoint(path, nil, (width/2) + 10, top);
    }
    CGPathAddLineToPoint(path, nil, width-right, top);
    if (where == EMOrientationRight) {
        CGPathAddLineToPoint(path, nil, width-right, (height/2) - 10);
        CGPathAddLineToPoint(path, nil, width-right + 15, height/2);
        CGPathAddLineToPoint(path, nil, width-right, (height/2) + 10);
    }
    CGPathAddLineToPoint(path, nil, width-right, height-bottom);
    if (where == EMOrientationBottom) {
        CGPathAddLineToPoint(path, nil, (width/2) + 10, height-bottom);
        CGPathAddLineToPoint(path, nil, width/2, height-bottom+15);
        CGPathAddLineToPoint(path, nil, (width/2) - 10, height-bottom);
    }
    CGPathAddLineToPoint(path, nil, left, height-bottom);
    if (where == EMOrientationLeft) {
        CGPathAddLineToPoint(path, nil, left, (height/2) + 10);
        CGPathAddLineToPoint(path, nil, 0, height/2);
        CGPathAddLineToPoint(path, nil, left, (height/2) - 10);
    }
    CGPathAddLineToPoint(path, nil, left, top);
    CGPathCloseSubpath(path);
    
    return path;
    
}

- (CAShapeLayer *) renderNotchedMask: (CGRect) rectFrame notchOrientation: (EMOrientationType) where
{
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    
    mask.frame = rectFrame;
    mask.fillColor = [[UIColor blackColor] CGColor];
    mask.path = [self renderNotchedPath: rectFrame notchOrientation:where];
    
    return mask;
    
}


@end
