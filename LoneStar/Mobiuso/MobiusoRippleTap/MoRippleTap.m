//
//  MoRippleTap.m
//  MoRippleTap
//
//  Created by Sandeep on 06/06/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MoRippleTap.h"


@implementation MoRippleTap

@synthesize rippleColor = _rippleColor;
@synthesize rippleOn = _rippleOn;
// @synthesize circular = _circular;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)commonInitWithImage:(UIImage *)image andFrame:(CGRect) frame andBorder:(BOOL) border
{
    
    imageView = [[UIImageView alloc]initWithImage:image];
    imageView.frame = CGRectMake(0, 0, frame.size.width-4, frame.size.height-4);
    imageView.layer.borderColor = [UIColor clearColor].CGColor;
    imageView.layer.borderWidth = 3;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = imageView.frame.size.height/2;
    [self addSubview:imageView];
    
    imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    
    gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:gesture];
    
    // _circular = border;
    _rippleWidth = 0;
    _rippleRadius = 0;
    _rippleDuration = 0;
    
    borderLayer = [CALayer layer];
    borderLayer.frame = self.bounds;
    borderLayer.cornerRadius = self.layer.cornerRadius = self.frame.size.height/2;
    if (border) {
        borderLayer.borderWidth = 4;
        borderLayer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.9].CGColor;
        borderLayer.opacity = 0.5f;
    } else {
        borderLayer.borderColor = [UIColor clearColor].CGColor;
    }
    
    [self.layer addSublayer:borderLayer];
}

-(id) initWithFrame:(CGRect)frame
           andImage:(UIImage *)image
          andTarget:(SEL)action
          andBorder:(BOOL) border
           delegate:(id)sender
{
    self = [super initWithFrame:frame];
    
    if(self){
        [self commonInitWithImage:image andFrame:frame andBorder: border];
        methodName = action;
        delegate = sender;
    }
    
    return self;
}

-(id) initWithFrame:(CGRect) frame
           andImage:(UIImage *) image
          andBorder:(BOOL) border
       onCompletion:(completion) completionBlock
{
    self = [super initWithFrame:frame];
    
    if(self){
        
        [self commonInitWithImage:image andFrame:frame andBorder: border];
        self.block = completionBlock;
    }
    
    return self;
}

- (void) setRippleColor:(UIColor *)rippleColor
{
    _rippleColor = rippleColor;
    
    borderLayer.borderColor = rippleColor.CGColor;
    
}

- (void) setImage: (UIImage *) image
{
    imageView.image = image;
}

- (void) setLongPressAction: (SEL) selector
{
#ifdef NOTNOW
    // init gesture for Selection of multiple items
    longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    longTapGestureRecognizer.minimumPressDuration = 0.75;
    [self addGestureRecognizer:longTapGestureRecognizer];
#endif
    longpressMethodName = selector;
    
}

#pragma mark -
#pragma mark Life Cycle and Events
-(void) viewWillAppear
{
}

-(void)handleTap: (UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        if (timer) { [timer invalidate]; timer = nil; }
        [self handle: methodName];
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        DLog(@"Began touch");
    }
}

-(void)handleDoubleTap: (UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self handle: longpressMethodName];
    }
}

- (void) handleDoubleTapTimer: (NSTimer *) timer
{
    DLog(@"Ended Long touch");
    [self handle: longpressMethodName];
}

-(void)handle: (SEL) methodToCall
{
    CGFloat duration = (_rippleDuration > 0.1) ? _rippleDuration : 0.5;
    
    if (_rippleOn) {
        [self startAnimation:duration withRippleCount:0];
    }

    /* 
     Reference to use the following for the animation of the ripple...
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
*/
    [UIView animateWithDuration:0.1 animations:^{
        imageView.alpha = 0.4;
        self.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.9].CGColor;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            imageView.alpha = 1;
            self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.9].CGColor;
        }completion:^(BOOL finished) {
            if([delegate respondsToSelector:methodToCall]){
                [delegate performSelectorOnMainThread: methodToCall withObject:self waitUntilDone:NO];
            }
            
            if(_block) {
                BOOL success= YES;
                _block(success);
            }
        }];
        
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
#ifdef RIPPLE_DEBUG
    DLog(@"touches began");
#endif
    if (longpressMethodName) {
        timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(handleDoubleTapTimer:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer: timer forMode:NSRunLoopCommonModes];
    }
}

- (id) startAnimation:(CGFloat)duration withRippleCount:(CGFloat)count
{
    UIColor *stroke = _rippleColor ? _rippleColor : [UIColor colorWithWhite:0.8 alpha:0.8];
    
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.layer.cornerRadius];
    
    // accounts for left/right offset and contentOffset of scroll view
    //CGPoint shapePosition = [self convertPoint:self.center fromView:[UIApplication sharedApplication].keyWindow];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    // NSLog(@"position: %f, %f, center: %f, %f", shapePosition.x, shapePosition.y, centerPoint.x, centerPoint.y);
    
    // Circle may not be circle - depending upon the cornerRadius it could be a rounded rectangle
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = path.CGPath;
    circle.position = centerPoint;
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.opacity = 0;
    circle.strokeColor = stroke.CGColor;
    circle.lineWidth = (_rippleWidth > 0.1)? _rippleWidth : 3;
    
    [self.layer addSublayer:circle];
    
    CGFloat scale = (_rippleRadius > 0.1) ? _rippleRadius : 2.5;
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = duration;
    animation.delegate = self;
    animation.repeatCount = count;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circle addAnimation:animation forKey:nil];
    
    return circle;
}

- (void) stopAnimation:(id)reference
{
    [reference removeAllAnimations];
}

#ifdef DEBUG
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
//    DLog(@"RippleTap Animation finished");
}
#endif


@end
