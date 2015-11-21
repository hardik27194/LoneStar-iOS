    //
//  MoElasticViewNew.m
//  WaveToolBar
//
//  Based on Harvindar WaveToolbar (WaveCustomView) design - modified by Sandeep Dec 2013.
//  Copyright 2012-2014 Mobiuso. All rights reserved.
//
/*!
 
 @class WaveCustomView
 
 @discussion
 
 
 TODO:
 
 @history
 
 Initial version.
 
 */

#import "MoElasticViewNew.h"
#ifdef NOTNOW
#import "MixpanelWrapper.h"
#endif
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@interface MoElasticViewNew()
-(void)backtonormal;
-(void)configureView;
-(void)reposition:(BOOL)isbegin ontouch:(NSSet *)touches;
-(void)setBubbleText:(NSString *)tempString;
@end

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


@implementation MoElasticViewNew

@synthesize touchBeginCordinates = _touchBeginCordinates;
@synthesize controlsCount = _controlsCount;
@synthesize controlsFrameArray = _controlsFrameArray;
@synthesize controlsHighlightFrameArray = _controlsHighlightFrameArray;
@synthesize controlsNameArray = _controlsNameArray;
@synthesize controlBackWidth = _controlBackWidth;
@synthesize maxWidth = _maxWidth;
@synthesize maxHeight = _maxHeight;
@synthesize delegate = _delegate;
@synthesize currentIndex = _currentIndex;
@synthesize bubbleLayer = _bubbleLayer;
@synthesize bubbleTextLayer = _bubbleTextLayer;
@synthesize isActive = _isActive;

@synthesize firstLayer = _firstLayer;
@synthesize font = _font;
@synthesize baseLayer = _baseLayer;
@synthesize baseFrame = _baseFrame;
@synthesize elasticMenuPopImage = _elasticMenuPopImage;
@synthesize menuItems = _menuItems;

@synthesize menuExpended = _menuExpended;



- (id)initWithFrame:(CGRect)frame withDelegate:(id <MoElasticMenuDelegateNew>)del
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.controlsCount = [self.delegate menuItemCount];
        self.isActive = NO;
        self.delegate = del;
        
        self.baseFrame = frame;
        self.baseLayer = [CALayer layer];
        self.baseLayer.backgroundColor = [UIColor blackColor].CGColor;
        self.baseLayer.opacity = 1.0;
        [self.layer addSublayer:self.baseLayer];
        
        self.firstLayer = [CAShapeLayer layer];
        self.font = [UIFont fontWithName:@"Ropa Sans" size: FONTSIZE];
        
        self.bubbleLayer = [CALayer layer];
        self.bubbleLayer.backgroundColor = COLORFROMHEX(0x80d71341).CGColor; // [UIColor colorWithWhite:0 alpha:0.7].CGColor;
        [self.bubbleLayer setCornerRadius:5];
        [self.bubbleLayer setHidden:YES];
        self.bubbleLayer.speed = 4;
        self.bubbleTextLayer = [CATextLayer layer];
        self.bubbleTextLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.bubbleTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
        self.bubbleTextLayer.font = (__bridge CFTypeRef)(self.font.fontName);
        self.bubbleTextLayer.fontSize = FONTSIZE;
        self.bubbleTextLayer.zPosition = 0;
        
        [self.bubbleLayer addSublayer:self.bubbleTextLayer];
        [self.layer addSublayer:self.bubbleLayer];
        
        //00c3ff
        
        //[self.firstLayer setLineWidth:3];
        
        
        self.firstLayer.strokeColor = COLORFROMHEX(0x50ffffff).CGColor;
        self.firstLayer.fillColor = COLORFROMHEX(0x05ffffff).CGColor;
        self.firstLayer.opacity = 1.0;
        
        self.firstLayer.shadowOffset = CGSizeMake(0, 8);
        self.firstLayer.shadowRadius = 16;
        self.firstLayer.shadowColor = [UIColor blackColor].CGColor;
        self.firstLayer.shadowOpacity = 0.15;
        
        // [UIColor colorWithWhite:0.0f alpha:0.4f].CGColor; // COLORFROMHEX(0x60ed145b).CGColor;
        [self.layer addSublayer:self.firstLayer];
        
        self.controlsCount = [self getMenuItemCount];
        [self configureView];
        [self configureHint];
        
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withMenuItems:(NSArray *)menuItemsArray
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.controlsCount = [self.delegate menuItemCount];
        self.isActive = NO;
        self.delegate = nil;
        self.menuItems = menuItemsArray;
        
        self.baseFrame = frame;
        self.baseLayer = [CALayer layer];
        self.baseLayer.backgroundColor = [UIColor blackColor].CGColor;
        self.baseLayer.opacity = 1.0;
        [self.layer addSublayer:self.baseLayer];
        
        self.firstLayer = [CAShapeLayer layer];
        self.font = [UIFont fontWithName:@"Ropa Sans" size: FONTSIZE];
        
        self.bubbleLayer = [CALayer layer];
        self.bubbleLayer.backgroundColor = COLORFROMHEX(0x80d71341).CGColor; // [UIColor colorWithWhite:0 alpha:0.7].CGColor;
        [self.bubbleLayer setCornerRadius:5];
        [self.bubbleLayer setHidden:YES];
        self.bubbleLayer.speed = 4;
        self.bubbleTextLayer = [CATextLayer layer];
        self.bubbleTextLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.bubbleTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
        self.bubbleTextLayer.font = (__bridge CFTypeRef)(self.font.fontName);
        self.bubbleTextLayer.fontSize = FONTSIZE;
        self.bubbleTextLayer.zPosition = 0;
        
        [self.bubbleLayer addSublayer:self.bubbleTextLayer];
        [self.layer addSublayer:self.bubbleLayer];
        
        //00c3ff
        
        //[self.firstLayer setLineWidth:3];
        
        
        self.firstLayer.strokeColor = COLORFROMHEX(0x50ffffff).CGColor;
        self.firstLayer.fillColor = COLORFROMHEX(0x05ffffff).CGColor;
        self.firstLayer.opacity = 1.0;
        
        self.firstLayer.shadowOffset = CGSizeMake(0, 8);
        self.firstLayer.shadowRadius = 16;
        self.firstLayer.shadowColor = [UIColor blackColor].CGColor;
        self.firstLayer.shadowOpacity = 0.15;
        
        // [UIColor colorWithWhite:0.0f alpha:0.4f].CGColor; // COLORFROMHEX(0x60ed145b).CGColor;
        [self.layer addSublayer:self.firstLayer];
        
        self.controlsCount = [self getMenuItemCount];
        [self configureView];
        [self configureHint];
        
        
    }
    return self;

}



- (void)reconfigure
{
    self.menuExpended = NO;
    self.controlsCount = [self getMenuItemCount];
    if(self.controlsFrameArray != nil)
    {
        for(CALayer *tempLayer in self.controlsFrameArray)
        {
            [tempLayer removeFromSuperlayer];
        }
        self.controlsFrameArray = nil;
    }
    if(self.controlsHighlightFrameArray != nil)
    {
        for(CALayer *tempLayer in self.controlsHighlightFrameArray)
        {
            [tempLayer removeFromSuperlayer];
        }
        self.controlsHighlightFrameArray = nil;
    }

    if(self.controlsNameArray != nil)
    {
        self.controlsNameArray = nil;
    }

    [self configureView];
    [self configureHint];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)setBubbleText:(NSString *)tempString
{
    self.bubbleTextLayer.string = tempString;
    UIFont *tempFont = self.font; // [UIFont systemFontOfSize:14];
    CGSize tempSize = [tempString sizeWithFont:tempFont];
    self.bubbleTextLayer.frame = CGRectMake(3, 2,tempSize.width, tempSize.height);
    self.bubbleLayer.frame = CGRectMake(0, 0, tempSize.width + 6, tempSize.height + 4);
}

-(void)configureView
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempHighlightArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempNameArray = [[NSMutableArray alloc] init];
    UIImage *tempImage, *tempHighlightImage;
    NSString *tempName;
    self.menuExpended = NO;
    for(int i = 0;i<self.controlsCount;i++)
    {
        CALayer *tempLayer = [[CALayer alloc]init];
        tempLayer.opacity = 0.7;
        tempLayer.frame = CGRectMake(0, 0, 10, 10);
        tempLayer.backgroundColor = [UIColor clearColor].CGColor;   // was black
        [tempLayer setCornerRadius:5];
        [tempLayer setBorderColor:[UIColor clearColor].CGColor]; // was white
        // [tempLayer setBorderWidth:1];
        tempLayer.hidden = YES;
        tempLayer.speed = 4;
        
        tempImage = [self getMenuItemImageForIndex:i];
        tempLayer.contents = (id)tempImage.CGImage;
        [tempArray addObject:tempLayer];
        
        CALayer *tempHighlightLayer = [[CALayer alloc]init];
        tempHighlightLayer.opacity = 1.0;
        tempHighlightLayer.frame = CGRectMake(0, 0, 10, 10);
        tempHighlightLayer.backgroundColor = [UIColor clearColor].CGColor;   // was black
        [tempHighlightLayer setCornerRadius:5];
        [tempHighlightLayer setBorderColor:[UIColor clearColor].CGColor]; // was white
        // [tempLayer setBorderWidth:1];
        tempHighlightLayer.hidden = YES;
        tempHighlightLayer.speed = 4;
        tempHighlightImage = [self getMenuItemHighlightImageForIndex:i];
        tempHighlightLayer.contents = (id)tempHighlightImage.CGImage;
        
        tempName = [self getMenuItemTitleForIndex:i];
        
        [tempHighlightArray addObject:tempHighlightLayer];
        
        [tempNameArray addObject:tempName];
        
        //[self.firstLayer addSublayer:tempLayer];
        [self.layer addSublayer:tempLayer];
        [self.layer addSublayer:tempHighlightLayer];
    }
    self.controlsFrameArray = tempArray;
    self.controlsHighlightFrameArray = tempHighlightArray;
    self.controlsNameArray = tempNameArray;
}



- (void) configureHint
{
    if(_elasticMenuPopImage != nil)
    {
        [_elasticMenuPopImage removeFromSuperview];
    }
    _elasticMenuPopImage = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 64, 64)];
    _elasticMenuPopImage.alpha = 0.7f;
    _elasticMenuPopImage.image = [UIImage imageNamed:@"Finger-drag-icon.png"];
    _elasticMenuPopImage.userInteractionEnabled = YES;
    
    [_elasticMenuPopImage setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleLeftMargin)];
    [self addSubview:_elasticMenuPopImage];
    
}
-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self backtonormal];
}


-(void)backtonormal
{
    // CGRect superRect = self.superview.frame;
    
    self.menuExpended = NO;
    _elasticMenuPopImage.hidden = NO;
    self.baseLayer.opacity = 0.0f;
    
    // self.baseLayer.backgroundColor = [UIColor blueColor].CGColor;
    /* Start Fix for Issue - 0000017*/
    
    self.frame = self.baseFrame; //CGRectMake(superRect.size.width - 64,superRect.size.height - 64, 64, 64);
    // 234 self.backgroundColor = [UIColor clearColor];
    /* End Fix for Issue - 0000017*/
    for(int i =0 ; i< self.controlsFrameArray.count;i++)
    {
        CALayer *tlayer = [self.controlsFrameArray objectAtIndex:i];
        tlayer.opacity = 0.7;
        tlayer.hidden = YES;
        tlayer = [self.controlsHighlightFrameArray objectAtIndex:i];
        tlayer.hidden = YES;
    }
    self.firstLayer.hidden = YES;
    self.bubbleLayer.hidden = YES;
}

#define MAXTOTALWIDTH 360

// sandeep 123 - TODO - lot of calcs can be done 1 time (unlike in bezier for wavebar menu) - so it can be simplied
// on every touch event - move to init routines
-(void)reposition:(BOOL)isbegin ontouch:(NSSet *)touches
{
    
    self.frame = self.superview.bounds;
    self.clipsToBounds = NO;
    self.baseLayer.frame = self.superview.bounds;
    
    
    CGFloat totalwidth = self.frame.size.width - (MARGIN*2);
    CGFloat startX = MARGIN;
    // If we maximize, we are putting the control on the right edge.. May want to rethink based on the initial touch X - TODO
    if (totalwidth > MAXTOTALWIDTH) {
        totalwidth = MAXTOTALWIDTH;
        startX = self.frame.size.width - MAXTOTALWIDTH - MARGIN;
    }
    self.controlBackWidth = totalwidth / self.controlsCount;
    self.maxWidth = MAXCONTROLWIDTH;
    self.maxHeight = MAXCONTROLHEIGHT;
    if(self.controlBackWidth < MAXCONTROLWIDTH)
    {
        self.maxWidth = self.maxWidth - 12;
        self.maxHeight = self.maxHeight - 12;
    }
    
    UITouch *touch = touches.anyObject;
    CGPoint tapPoint = [touch locationInView:self];
    
    
    if(self.frame.size.height - tapPoint.y < 60)
    {
        self.isActive = NO;
    }
    else {
        self.isActive = YES;
    }
    
    
    NSInteger activeControlIndex = (tapPoint.x - startX) / self.controlBackWidth;
    
    
    if(activeControlIndex < 0)
    {
        activeControlIndex = 0;
    }
    else if(activeControlIndex >= self.controlsFrameArray.count)
    {
        activeControlIndex = self.controlsFrameArray.count - 1;
    }
#define ELASTIC_MENU_MARGIN 10
#define ELASTIC_MENU_DELTA  5
    
    CGFloat currentControlWidth = self.maxWidth;
    CGFloat currentControlHeight = self.maxHeight;
    CGFloat currentControlYPosition = tapPoint.y - self.maxHeight - (ELASTIC_MENU_MARGIN+ELASTIC_MENU_DELTA);
    CGFloat currentControlXPosition = startX;
    CGFloat tempFloat = 0;
    
    for(int i = 0 ; i<self.controlsCount ; i++)
    {
        CALayer *currentLayer = [self.controlsFrameArray objectAtIndex:i];
        CALayer *currentHighlightLayer = [self.controlsHighlightFrameArray objectAtIndex:i];
        if ((self.isActive == YES) && (i == activeControlIndex))
        {
            currentLayer.hidden = YES;
            currentHighlightLayer.hidden = NO;
            currentHighlightLayer.opacity = 1.0;
        } else {
            // currentLayer.opacity = 0.7; // dim
            currentLayer.hidden = NO;
            currentHighlightLayer.hidden = YES;
        }
        tempFloat = (self.controlBackWidth * i ) + (self.controlBackWidth / 2) - tapPoint.x;
        if(tempFloat > 0)
        {
            tempFloat = tempFloat * -1;
        }
        currentControlWidth = self.maxWidth; // sandeep 123 + (tempFloat / 10);
        currentControlXPosition = startX + (self.controlBackWidth * i ) + ((self.controlBackWidth - currentControlWidth) / 2);
        // sandeep 123 currentControlYPosition = (tapPoint.y - 100) + (tempFloat / -3);
        [currentLayer setFrame:CGRectMake(currentControlXPosition, currentControlYPosition, currentControlWidth, currentControlWidth)];
        [currentHighlightLayer setFrame:CGRectMake(currentControlXPosition-4, currentControlYPosition-4, currentControlWidth+8, currentControlWidth+8)];
        if(isbegin)
            currentLayer.hidden = NO;
    }
    CALayer *currentLayer1 = [self.controlsFrameArray objectAtIndex:0];
    CALayer *currentLayer2 = [self.controlsFrameArray objectAtIndex:activeControlIndex];
    CGRect frame = CGRectMake(startX, tapPoint.y - self.maxHeight - (ELASTIC_MENU_MARGIN*2+ELASTIC_MENU_DELTA), totalwidth, self.maxHeight+ELASTIC_MENU_MARGIN*2);
    UIBezierPath *tempPath = [UIBezierPath bezierPathWithRoundedRect: frame cornerRadius: 6.0f/*MAXCONTROLHEIGHT/2.0*/];
    
    
    self.firstLayer.path = tempPath.CGPath;
    
    if(self.currentIndex != activeControlIndex)
    {
        [self setBubbleText:[self.controlsNameArray objectAtIndex:activeControlIndex]];
        self.currentIndex = activeControlIndex;
    }
    
    currentControlXPosition = (currentLayer2.frame.origin.x + (currentLayer2.frame.size.width/2)) - (self.bubbleLayer.frame.size.width / 2);
    
    if(currentControlXPosition < 0)
    {
        currentControlXPosition = 0;
    }
    else if((currentControlXPosition + currentLayer2.frame.size.width) > self.frame.size.width)
    {
        currentControlXPosition = self.frame.size.width - self.bubbleLayer.frame.size.width - 10;
    }
    
    [self.bubbleLayer setFrame:CGRectMake(currentControlXPosition, tapPoint.y - (self.maxHeight + (ELASTIC_MENU_MARGIN+ELASTIC_MENU_DELTA)*2 + self.bubbleLayer.frame.size.height), self.bubbleLayer.frame.size.width, self.bubbleLayer.frame.size.height)];
    
    
    if(isbegin)
    {
        self.firstLayer.hidden = NO;
        self.bubbleLayer.hidden = NO;
        self.isActive = NO;
    }
    
    if(self.isActive == NO)
    {
        self.bubbleLayer.hidden = YES;
        self.firstLayer.opacity = 0.5;
        self.baseLayer.opacity = 0.05f;
        _elasticMenuPopImage.hidden = NO;
    }
    else {
        self.bubbleLayer.hidden = NO;
        self.firstLayer.opacity = 1.0;
        self.baseLayer.opacity = 0.2f;
        _elasticMenuPopImage.hidden = YES;
    }
    if([self.bubbleTextLayer.string compare:@"" options:NSCaseInsensitiveSearch] == 0)
    {
        self.bubbleLayer.hidden = YES;
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.delegate == nil)
    {
        if(self.menuItems == nil || [self.menuItems count] == 0)
        {
            return;
        }
    }
    if(self.menuExpended == YES)
    {
        [self backtonormal];
        return;
    }
    self.menuExpended = YES;
    self.baseFrame = self.frame;
    self.currentIndex = -1;
    [self reposition:YES ontouch:touches];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.delegate == nil)
    {
        if(self.menuItems == nil || [self.menuItems count] == 0)
        {
            return;
        }
    }

    [self backtonormal];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.delegate == nil)
    {
        if(self.menuItems == nil || [self.menuItems count] == 0)
        {
            return;
        }
    }

    if(self.menuExpended == NO)
    {
        return;
    }
    
    if(self.isActive == YES)
    {
        [self didSelectMenuItem:self.currentIndex];
    }
    [UIView animateWithDuration:0.5  delay:0.5 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         //_elasticMenuPopImage.hidden = NO;
                         [self backtonormal];
                     } completion:^(BOOL finished){}];
    // [self backtonormal];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.delegate == nil)
    {
        if(self.menuItems == nil || [self.menuItems count] == 0)
        {
            return;
        }
    }

    if(self.menuExpended == NO)
    {
        return;
    }
    
    [self reposition:NO ontouch:touches];
}


-(void)didSelectMenuItem:(NSInteger)index
{
    if(self.delegate == nil)
    {
        if(self.menuItems != nil)
        {
            MoElasticMenuItem *indexedItem = [self.menuItems objectAtIndex:index];
            if(indexedItem.target != nil && indexedItem.action != nil)
            {
                [indexedItem.target performSelector:indexedItem.action withObject:indexedItem afterDelay:0];
                
                
                NSString *menuItemTitle = @"notDefined";
                if(indexedItem.menuTitle != nil)
                {
                    menuItemTitle = indexedItem.menuTitle;
                }
                
                NSDictionary *mixPanelEventProperty = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       menuItemTitle,@"menuOption",nil];
                

            }
        }
    }
    else
    {
        [self.delegate didSelectMenuItem:index];
        
        NSString *menuItemTitle = [self getMenuItemTitleForIndex:index];
        if(menuItemTitle == nil)
        {
            menuItemTitle = @"notDefined";
        }
        
        NSDictionary *mixPanelEventProperty = [NSDictionary dictionaryWithObjectsAndKeys:
                                               menuItemTitle,@"menuOption",nil];
        
        
    }
}


-(NSInteger)getMenuItemCount
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


@end
