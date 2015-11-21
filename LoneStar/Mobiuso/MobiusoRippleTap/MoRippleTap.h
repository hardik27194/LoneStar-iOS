//
//  MoRippleTap.h
//  MoRippleTap
//
//  Created by Sandeep on 06/06/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//  Inspired by Balram Tiwari's code
//

#import <UIKit/UIKit.h>

typedef void (^completion)(BOOL success);

@interface MoRippleTap : UIButton {
@private
    UIImageView *imageView;
    UILabel *title;
    UITapGestureRecognizer *gesture;
    UILongPressGestureRecognizer *longTapGestureRecognizer;
    
    SEL methodName;
    SEL longpressMethodName;
    
    id delegate;
    NSArray *rippleColors;
    CALayer *borderLayer;
    NSTimer *timer;
}

@property (nonatomic, retain) UIColor *rippleColor;
@property (nonatomic, assign) CGFloat rippleWidth;
@property (nonatomic, assign) CGFloat rippleRadius;
@property (nonatomic, assign) CGFloat rippleDuration;
@property (nonatomic, assign) BOOL    rippleOn;

@property (nonatomic, copy) completion block;

-(id) initWithFrame:(CGRect)frame andImage:(UIImage *)image andTarget:(SEL)action andBorder:(BOOL) border delegate:(id)sender;

-(id) initWithFrame:(CGRect)frame andImage:(UIImage *)image andBorder:(BOOL) border onCompletion:(completion)completionBlock;

-(void) setImage:(UIImage *)image;

-(void) setLongPressAction: (SEL) selector;

-(void) handle: (SEL) methodToCall;

- (id) startAnimation: (CGFloat) duration withRippleCount: (CGFloat) count;

- (void) stopAnimation: (id) reference;

@end
