//
//  MoArcMenu.m
//  MoArcMenu
//
//  Created by sandeep on 01/10/13.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//  Updated 2015/09/21
//

#import "MoArcMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Glow.h"
#import "AppDelegate.h"
#import "Constants.h"

static CGFloat const kMoArcMenuDefaultNearRadius = 80.0f;
static CGFloat const kMoArcMenuDefaultEndRadius = 90.0f;
static CGFloat const kMoArcMenuDefaultFarRadius = 110.0f;
static CGFloat const kMoArcMenuDefaultStartPointX = 160.0;
static CGFloat const kMoArcMenuDefaultStartPointY = 240.0;
static CGFloat const kMoArcMenuDefaultTimeOffset = 0.036f;
static CGFloat const kMoArcMenuDefaultRotateAngle = 0.0;
static CGFloat const kMoArcMenuDefaultMenuWholeAngle = M_PI * 2;
static CGFloat const kMoArcMenuDefaultExpandRotation = M_PI;
static CGFloat const kMoArcMenuDefaultCloseRotation = M_PI * 2;


static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);    
}

@interface MoArcMenu ()
{
    NSArray *_menusArray;
    int _flag;
    NSTimer *_timer;
    MoArcMenuItem *_addButton;
    UIView *glowView;
    
    //id<MoArcMenuDelegate> _delegate;
    BOOL _isAnimating;
    
    CGFloat centerButtonDiameter;
}

- (void)_expand;
- (void)_close;
- (void)_setMenu;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;
@end


@implementation MoArcMenu

@synthesize nearRadius, endRadius, farRadius, timeOffset, rotateAngle, menuWholeAngle, startPoint, expandRotation, closeRotation, shim, blur, anchorColor, selectedIndex;
@synthesize expanding = _expanding;
@synthesize delegate = _delegate;
@synthesize menusArray = _menusArray;
@synthesize repeatCount;
@synthesize useSelectedMenuItemAsAnchor;
@synthesize gravity;
@synthesize menuHint;
@synthesize underlyingView = _underlyingView;

#pragma mark - initialization & cleaning up

- (id) initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray
            position: (ArcMenuPosition) position
              anchor: (UIImage *) anchorImage
   anchorHighlighted: (UIImage *) anchorHighlightedImage
animationRepeatCount: (CGFloat) count
     anchorAnimation: (BOOL) shouldAnimate
 selectedMenuItemAsAnchor: (BOOL) anchorType
centerButtonDiameter: (CGFloat) buttonDiameter
{
    self = [super initWithFrame:frame];
    if (self) {
        centerButtonDiameter = buttonDiameter;
        self.backgroundColor = [UIColor clearColor];
		CGFloat mult = (IS_IPAD? 1.5 : 1);
		self.nearRadius = kMoArcMenuDefaultNearRadius * mult;
		self.endRadius = kMoArcMenuDefaultEndRadius * mult;
		self.farRadius = kMoArcMenuDefaultFarRadius * mult;
        self.userInteractionEnabled = YES;
        
		self.timeOffset = kMoArcMenuDefaultTimeOffset;
		self.rotateAngle = kMoArcMenuDefaultRotateAngle;
		self.menuWholeAngle = kMoArcMenuDefaultMenuWholeAngle;
		self.startPoint = CGPointMake(kMoArcMenuDefaultStartPointX, kMoArcMenuDefaultStartPointY);
        self.expandRotation = kMoArcMenuDefaultExpandRotation;
        self.closeRotation = kMoArcMenuDefaultCloseRotation;
        
        self.menusArray = aMenusArray;
        self.useSelectedMenuItemAsAnchor = anchorType;
        
        shim = [[MoArcBackground alloc] initWithFrame:frame];
        shim.endRadius = self.endRadius;
        shim.startPoint = self.startPoint;
        //DLog(@"startPoint is at (%f, %f)", self.startPoint.x, self.startPoint.y);
        shim.repeatCount = count;
        [shim setBackgroundColor: [UIColor clearColor]];//[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.4f]];
        
        blur = nil;
        
        // add the "Add" Button.
        
        
        UIImage *baseImage = [UIImage imageNamed:@"bg-transparent.png"]; // bg-addbutton.png
        _addButton = [[MoArcMenuItem alloc] initWithImage: baseImage
                                       highlightedImage: [UIImage imageNamed:@"bg-transparent.png"]
                                             ContentImage:(anchorImage!=nil)? anchorImage : [UIImage imageNamed: @"icon-plus.png"]
                                highlightedContentImage: (anchorHighlightedImage!=nil)? anchorHighlightedImage : [UIImage imageNamed: @"icon-plus-highlighted.png"]
                                    anchorColor: [UIColor grayColor]
                                           diameter: centerButtonDiameter];

        _addButton.delegate = self;
        _addButton.alpha = 1.0f;
        _addButton.center = self.startPoint;


        // If anchor should animate, then add the following
        if (shouldAnimate) {
            self.repeatCount = count;
        }

        [self addSubview:_addButton];

        int WA = kMoArcMenuDefaultMenuWholeAngle;
        int RA = kMoArcMenuDefaultRotateAngle;
        
        switch (position) {
            case ArcMenuSpanLowerRight:
                WA = 90; RA = 90;
                gravity.x = +1; gravity.y = +1;
                break;
                
            case ArcMenuSpanUpperLeft:
                WA = 90; RA = -90;
                gravity.x = -1; gravity.y = -1;
                break;
                
            case ArcMenuSpanUpperRight:
                WA = -90; RA = 90;
                gravity.x = +1; gravity.y = -1;
                break;
                
            case ArcMenuSpanLowerLeft:
                WA = -90; RA =-90;
                gravity.x = -1; gravity.y = +1;
               break;
                
            case ArcMenuSpanRightSemiCircle:
                WA = 180; RA = 0;   // check RA
                gravity.x = +1; gravity.y = 0;
                break;
                
            case ArcMenuSpanLeftSemiCircle:
                WA = -180; RA = 0; // check RA
                gravity.x = -1; gravity.y = 0;
                break;
                
            case ArcMenuSpanTopSemiCircle:
                WA = 180; RA = -91; // check RA
                gravity.x = 0; gravity.y = -1;
                break;

            case ArcMenuSpanBottomSemiCircle:
                WA = 180; RA = 90; // check RA
                gravity.x = 0; gravity.y = +1;
                break;

            case ArcMenuSpanTopThreeFourthCircle:
                WA = 270; RA = -135; // check RA
                gravity.x = 0; gravity.y = -1;
                break;
                
            case ArcMenuSpanBottomThreeFourthCircle:
                WA = 270; RA = 45; // check RA
                gravity.x = 0; gravity.y = -1;
                break;

            default:
                break;
        }
    
        self.menuWholeAngle = DEGREES_TO_RADIANS(WA); // M_PI / 180 * WA;
        self.rotateAngle    = DEGREES_TO_RADIANS(RA); // M_PI / 180 * RA;

        // Check if we need to adjust the default endpoint based on the
        // count and size of each menu button (approx - assumes square aspect ratio
        CGFloat len = 0;
        for (MoArcMenuItem *item in aMenusArray) {
            len += item.buttonDiameter; // [[item contentImageView] frame].size.width;
        }
        len += ([aMenusArray count] - 1) * 5;  // gap of at least 10 pixels
        // Check the length of the arc desired
        // =2*side length*sin((angle*pi)/360)
        // DLog(@"span : %f (%f)", endRadius * menuWholeAngle, endRadius);
        CGFloat angle = (menuWholeAngle < 0) ? (-menuWholeAngle) : menuWholeAngle;
        if (len >  endRadius * angle) {
            // adjust the endRadius
            endRadius = len / angle;    // round?
            CGFloat minDimension = MIN(frame.size.height, frame.size.width) - 36;
            if (endRadius > minDimension) {
                endRadius = minDimension;
            }
            farRadius = endRadius + 10;
            shim.endRadius = endRadius;
            // DLog(@"changed : end %f (far %f)", endRadius, farRadius);
        }
        
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray
            position: (ArcMenuPosition) position
              anchor: (UIImage *) anchorImage
   anchorHighlighted: (UIImage *) anchorHighlightedImage
animationRepeatCount: (CGFloat) count
     anchorAnimation: (BOOL) shouldAnimate
selectedMenuItemAsAnchor: (BOOL) anchorType
centerButtonDiameter: (CGFloat) diameter
        withBlurView: (UIView *) view
{
    self = [self initWithFrame:frame menus:aMenusArray position:position anchor:anchorImage anchorHighlighted:anchorHighlightedImage animationRepeatCount:count anchorAnimation:shouldAnimate selectedMenuItemAsAnchor:anchorType centerButtonDiameter:diameter];
    if (self) {
        _underlyingView = view;
        // if dynamic, we may want to handle it on the fly
        // [self setBlurWithView:view];
        // [self performSelector:@selector(doblur) withObject:self afterDelay:0.5f];
    }
    return self;
    
}

#pragma mark - Blur activities
- (void) setBlurView: (UIView *) view
{
    _underlyingView = view;
    if (self.isExpanding) { // it is expanded, we change the blurview
        [self animateMenuClose];
//        [blur removeFromSuperview];
//        [self setBlurWithView:view];
    }
}

- (void) setBlurWithView: (UIView *) view
{
    // Blur Effect
    if (IS_IOS8) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [bluredEffectView setFrame:view.bounds];
        
        
        // Vibrancy Effect
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        // vibrancyEffectView.backgroundColor = COLORFROMHEX(0xff990000);
        [vibrancyEffectView setFrame:bluredEffectView.bounds];
        // Add Vibrancy View to Blur View
        [bluredEffectView addSubview:vibrancyEffectView];
        // Add Label to Vibrancy View
        blur = bluredEffectView;
    } else {
        UIImage *screenshot = [view screenshot];
        UIColor *tintColor = [UIColor colorWithWhite:0.0 alpha:0.15];    // COLORFROMHEX(0x10d71341); //
        screenshot =  [screenshot applyBlurWithRadius:8 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
        // screenshot = [screenshot applyLightBluredAtFrame:view.frame];
        
        CGRect frm = [view bounds];
        DLog(@"Blurring Frame %f, %f, %f, %f", frm.origin.x, frm.origin.y, frm.size.width, frm.size.height);
        UIImageView *blurImageView = [[UIImageView alloc] initWithFrame:frm];
        blurImageView.image = screenshot;
        blurImageView.alpha = 0.0f;
        blur = blurImageView;
        // blur.tintColor = [UIColor clearColor]; // COLORFROMHEX(0xffd71341); // [Theme signatureColor];
        
    }

}

- (void) blurOn
{
    [blur removeFromSuperview];
    [self insertSubview:blur belowSubview:shim];
    [UIView animateWithDuration:0.4 animations:^{
        blur.alpha = 1.0f;
    }];

}

- (void) blurOff
{
    [UIView animateWithDuration:0.4 animations:^{
        blur.alpha = 0.0f;
    }];
    [blur removeFromSuperview];
}

- (MoArcMenuItem *) tapButton;
{
    return _addButton;
}


#pragma mark - Animation etc
- (void) animateAnchor
{
    glowView = [[UIImageView alloc] initWithImage:_addButton.image];
    glowView.center = _addButton.center;
    glowView.tag = GLOWVIEW_TAG;
    // DLog(@"_addButton is at (%f, %f)", _addButton.center.x, _addButton.center.y);
    UIImage *image = [UIImage imageNamed:@"GlowEffect-Orange.png"];
    CALayer *layer = glowView.layer;
    layer.contents = (id)image.CGImage;
    // UIImage *baseImage = _addButton.image;
//    CGSize size = [[_addButton contentImageView] bounds].size;
    layer.bounds = glowView.bounds = CGRectMake(0, 0, centerButtonDiameter, centerButtonDiameter);; // CGRectMake(0, 0, size.width, size.height);
    // DLog(@"baseimage is at (%f, %f)", baseImage.size.width, baseImage.size.height);
    layer.position = CGPointMake(_addButton.center.x, _addButton.center.y); // CGPointMake(160, 200);
    layer.opacity = 0.7;
    
    // grow from its original value
    layer.transform = CATransform3DMakeScale(2, 2, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.autoreverses = YES;
    animation.duration = 1.9;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = repeatCount; // HUGE_VALF;  // Count for animation
//    temp [layer addAnimation:animation forKey:@"pulseAnimation"];
    
    [self insertSubview:glowView belowSubview:_addButton];  //

}

- (void) animateDemo
{
    self.expanding = !self.isExpanding;
    // Do any other action - like showing the finger tap
    [MobiusoToast toast: (self.isExpanding?
                          @"Tap on the button to expand menu":
                          @"Tap again to collapse")];

    
}

- (void) animateMenuOpen
{
    if (!self.isExpanding)
        [self  MoArcMenuItemTouchesBegan: _addButton];
}

- (void) animateMenuClose
{
    if (self.isExpanding)
        [self  MoArcMenuItemTouchesBegan: _addButton];
}

#pragma mark - getters & setters

- (void)setStartPoint:(CGPoint)aPoint
{
    startPoint = aPoint;
    _addButton.center = aPoint;
    // UIView *glow = [self viewWithTag:GLOWVIEW_TAG];
    glowView.center = aPoint;
    // change the layer position as well
    glowView.layer.position = aPoint;
   // for (UIView *view in [_addButton subviews]) {
   //     if (view isKindOfClass:[ ]) {
   //
   //     }
   // }
    shim.startPoint = aPoint;
    shim.anchorColor = self.anchorColor;
    
}

#pragma mark - images

- (void)setImage:(UIImage *)image {
	_addButton.image = image;
}

- (UIImage*)image {
	return _addButton.image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
	_addButton.highlightedImage = highlightedImage;
}

- (UIImage*)highlightedImage {
	return _addButton.highlightedImage;
}


- (void)setContentImage:(UIImage *)contentImage {
	_addButton.contentImageView.image = contentImage;
}

- (UIImage*)contentImage {
	return _addButton.contentImageView.image;
}

- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
	_addButton.contentImageView.highlightedImage = highlightedContentImage;
}

- (UIImage*)highlightedContentImage {
	return _addButton.contentImageView.highlightedImage;
}


                               
#pragma mark - UIView's methods
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // if the menu is animating, prevent touches
    if (_isAnimating) 
    {
        return NO;
    }
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (YES == _expanding) 
    {
        return YES;
    }
    else
    {
        return CGRectContainsPoint(_addButton.frame, point);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [MP_APP_DELEGATE setMenuTouchedOnce:YES];
    self.expanding = !self.isExpanding;
}

#pragma mark - MoArcMenuItem delegates
- (void)MoArcMenuItemTouchesBegan:(MoArcMenuItem *)item
{
//    [MP_APP_DELEGATE setMenuTouchedOnce:YES];
    if (item == _addButton)
    {
        if (!self.isExpanding) {
            [self setBlurWithView:_underlyingView]; // dynamic
            if ([_delegate respondsToSelector:@selector(MoArcMenuFired:)]) {
                [_delegate MoArcMenuFired:self];
            }
        } else {
#if 0
            // This is the CLOSE - we need to move the dismissed call later when the last item is shrunk

            if ([_delegate respondsToSelector:@selector(MoArcMenuDismissed:)]) {
                [_delegate MoArcMenuDismissed:self];
            }
#endif
        }
        self.expanding = !self.isExpanding;
    } else     if (item.hint) {
        self.menuHint = [[MobiusoToast alloc] initWithDuration: 2.5f andText:item.hint];
        
        [self.menuHint displayInView:[self superview] atCenter:CGPointMake(item.endPoint.x + gravity.x * 48, item.endPoint.y + gravity.y * 48)];
    }
}
- (void)MoArcMenuItemTouchesEnd:(MoArcMenuItem *)item
{
    // exclude the "add" button
    if (item == _addButton) 
    {
        return;
    }
    
    // blowup the selected menu button - We want to wait until the blow up is done
    [CATransaction begin];
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    [CATransaction setCompletionBlock:^{
        if ([_delegate respondsToSelector:@selector(MoArcMenu:didSelectIndex:)])
        {
            [_delegate MoArcMenu:self didSelectIndex:item.tag - 1000];
        }
        if (self.menuHint) {
            [self.menuHint removeFromSuperview];
            self.menuHint = nil;
        }
        [shim removeFromSuperview];
        [self blurOff];
    }];
    [item.layer addAnimation:blowup forKey:@"blowup"];
    // item.center = item.startPoint;

    blowup.delegate = self;
    selectedIndex = (int)item.tag - 1000;
    if (self.menuHint != nil) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.duration = 0.5f;
        opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
        
        CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
        animationgroup.animations = [NSArray arrayWithObjects: /*positionAnimation, scaleAnimation, */ opacityAnimation, /*rotateAnimation,*/ nil];
        animationgroup.duration = 0.5f;
        animationgroup.fillMode = kCAFillModeForwards;
        animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [self.menuHint.layer addAnimation:animationgroup forKey:@"CloseMenuHint"];
        
        // self.menuHint.center = CGPointMake(item.endPoint.x, item.endPoint.y);
    }

    [CATransaction commit];
    
    // shrink other menu buttons
    for (int i = 0; i < [_menusArray count]; i ++)
    {
        MoArcMenuItem *otherItem = [_menusArray objectAtIndex:i];
        CAAnimationGroup *shrinkAnimation = [self _shrinkAnimationAtPoint:otherItem.center];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.duration = 0.5f;
        opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];

        CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
        animationgroup.animations = [NSArray arrayWithObjects:  shrinkAnimation, /* opacityAnimation, rotateAnimation,*/ nil];
        animationgroup.duration = 0.5f;
        animationgroup.fillMode = kCAFillModeForwards;
        animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animationgroup.delegate = self;
        [animationgroup setValue:@"Close" forKey:@"name"];
        
        if (otherItem.tag == item.tag) {
            continue;
        }
        [otherItem.layer addAnimation:animationgroup forKey:@"shrink"];

        // otherItem.center = otherItem.startPoint;
        // otherItem.layer.opacity = 0.0f;
    }
    _expanding = NO;
    
    // rotate "anchor" button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    float scale = self.isExpanding ? 0.5 : 1.0;
    CGFloat duration = self.isExpanding ? 0.3 : 1.0;
    BOOL highlight = self.isExpanding;
    [UIView animateWithDuration:duration animations:^{
        CGAffineTransform t = CGAffineTransformMakeRotation(angle);
        _addButton.transform = CGAffineTransformScale(t, scale, scale); // (_addButton.transform, 0.7, 0.7);
        _addButton.highlighted = highlight;
    }];
    
#ifdef DOTHISAFTERBLOWUP
    if ([_delegate respondsToSelector:@selector(MoArcMenu:didSelectIndex:)])
    {
        [_delegate MoArcMenu:self didSelectIndex:item.tag - 1000];
    }
#endif
    
    CAAnimationGroup *shrinkToo = [self _shrinkAnimationAtPoint:shim.startPoint];
    [shim.layer addAnimation:shrinkToo forKey:@"shrinkToo"];
    
    
}

#pragma mark Select action to the delegate
- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)finished
{
    if([[anim valueForKey:@"name"] isEqual:@"Close"] && finished) {
        // DLog(@"Finished Animation");
        for (int i = 0; i < [_menusArray count]; i ++)
        {
            MoArcMenuItem *otherItem = [_menusArray objectAtIndex:i];
            // check if we have already added the fadeout animation or not
            if ([otherItem.layer animationForKey:@"fadeout"] == nil) {
                CAAnimationGroup *shrinkAnimation = [self _shrinkAnimationAtPoint:otherItem.center];
                CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                opacityAnimation.duration = 0.3f;
                opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
                opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
                
                CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
                animationgroup.animations = [NSArray arrayWithObjects:  shrinkAnimation, /* opacityAnimation, rotateAnimation,*/ nil];
                animationgroup.duration = 0.3f;
                animationgroup.fillMode = kCAFillModeForwards;
                animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                
                [otherItem.layer addAnimation:animationgroup forKey:@"fadeout"];
                
                otherItem.center = otherItem.startPoint;
                otherItem.layer.opacity = 0.0f;
            }
        }
    }
#ifdef NOTNEEDED
    if ([_delegate respondsToSelector:@selector(MoArcMenu:didSelectIndex:)])
    {
        [_delegate MoArcMenu:self didSelectIndex: selectedIndex];
    }
#endif
}

#pragma mark - instant methods
- (void)setMenusArray:(NSArray *)aMenusArray
{	
    if (aMenusArray == _menusArray)
    {
        return;
    }
    //[_menusArray release];
    _menusArray = [aMenusArray copy];
    
    
    // clean subviews
    for (UIView *v in self.subviews) 
    {
        if (v.tag >= 1000) 
        {
            [v removeFromSuperview];
        }
    }
}

#define SINF sinf
#define COSF cosf

- (void)_setMenu {
	int count = (int)[_menusArray count];
    int gaps = count - 1;
    for (int i = 0; i < count; i ++)
    {
        MoArcMenuItem *item = [_menusArray objectAtIndex:i];
        item.tag = 1000 + i;
        item.startPoint = startPoint;
        CGPoint endPoint = CGPointMake(startPoint.x + endRadius * SINF(i * menuWholeAngle / gaps), startPoint.y - endRadius * COSF(i * menuWholeAngle / (gaps)));
        item.endPoint = RotateCGPointAroundCenter(endPoint, startPoint, rotateAngle);
        CGPoint nearPoint = CGPointMake(startPoint.x + nearRadius * SINF(i * menuWholeAngle / gaps), startPoint.y - nearRadius * COSF(i * menuWholeAngle / gaps));
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, startPoint, rotateAngle);
        CGPoint farPoint = CGPointMake(startPoint.x + farRadius * SINF(i * menuWholeAngle / gaps), startPoint.y - farRadius * COSF(i * menuWholeAngle / gaps));
        item.farPoint = RotateCGPointAroundCenter(farPoint, startPoint, rotateAngle);  
        item.center = item.startPoint;
        item.delegate = self;
		[self insertSubview:item belowSubview:_addButton];
    }
    shim.anchorColor = self.anchorColor;
    // start the loadView after some time
    [shim loadView: rotateAngle spanAngle:menuWholeAngle ];
    // shim.alpha = 0.0;
    [shim removeFromSuperview]; // don't repeat it
    [self insertSubview:shim belowSubview:[_menusArray objectAtIndex:0]];
    [self blurOn];
}

- (BOOL)isExpanding
{
    return _expanding;
}

- (void)setExpanding:(BOOL)expanding
{
	if (expanding) {
		[self _setMenu];
	}
	
    _expanding = expanding;    
    
    // rotate add button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    float scale = self.isExpanding ? 0.5 : 1.0;
    CGFloat duration = self.isExpanding ? 0.3 : 1.0;
    BOOL highlight = self.isExpanding;

    [UIView animateWithDuration:duration
                     animations:^{
                         CGAffineTransform t = CGAffineTransformMakeRotation(angle);
                         _addButton.transform = CGAffineTransformScale(t, scale, scale); // (_addButton.transform, 0.7, 0.7);
                         _addButton.highlighted = highlight;
    }];
    
    // expand or close animation
    if (!_timer) 
    {
        _flag = self.isExpanding ? 0 : ((int)[_menusArray count] - 1);
        SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);

        // Adding timer to runloop to make sure UI event won't block the timer from firing
        _timer = [NSTimer timerWithTimeInterval:timeOffset target:self selector:selector userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        _isAnimating = YES;
    }
}
#pragma mark - private methods
- (void)_expand
{
	
    if (_flag == [_menusArray count])
    {
        _isAnimating = NO;
        [_timer invalidate];
        // [_timer release];
        _timer = nil;
        [self setNeedsDisplay];
        return;
    }
    
    int tag = 1000 + _flag;
    MoArcMenuItem *item = (MoArcMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:expandRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.3], 
                                [NSNumber numberWithFloat:.4], nil]; 

    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue  = [NSNumber numberWithFloat:0.0f];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:1.0f];

    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 1.5f;  // sandeep
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y); 
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    positionAnimation.path = path;
    CGPathRelease(path);

    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    item.center = item.endPoint;
    item.layer.opacity = 1.0f;
    
    _flag ++;
    
}

- (void)_close
{
    if (_flag == -1)
    {
        // We want to shrink this and then later make it vanish
        [CATransaction begin];
        CAAnimationGroup *shrinkToo = [self _shrinkAnimationAtPoint:shim.startPoint];
        [shim.layer addAnimation:shrinkToo forKey:@"shrinkToo"];
        [CATransaction setCompletionBlock:^{
            [shim removeFromSuperview];
            [self blurOff];
        }];
        [CATransaction commit];
       _isAnimating = NO;
        [_timer invalidate];
        // [_timer release];
        _timer = nil;
        
        // This is the CLOSE - we need to move the dismissed here
        if ([_delegate respondsToSelector:@selector(MoArcMenuDismissed:)]) {
            [_delegate MoArcMenuDismissed:self];
        }

        return;
    }
    
    int tag = 1000 + _flag;
     MoArcMenuItem *item = (MoArcMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:closeRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.0], 
                                [NSNumber numberWithFloat:.4],
                                [NSNumber numberWithFloat:.5], nil]; 
        
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = 0.5f;
    opacityAnimation.beginTime = 0.5f;
    opacityAnimation.fromValue  = [NSNumber numberWithFloat:1.0f];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, opacityAnimation, nil];
    animationgroup.duration = 1.0f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    [animationgroup setValue:@"Close" forKey:@"name"];

    [item.layer addAnimation:animationgroup forKey:@"Close"];
    item.center = item.startPoint;
    //item.layer.opacity = 0.0f;
    _flag --;
}

- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], [NSNumber numberWithFloat:.6],[NSNumber numberWithFloat:.8],nil];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.6f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, /*opacityAnimation,*/ nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.autoreverses = TRUE;

    return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}


@end
