//
//  MobiusoDIalogPopup.m
//  ShshDox
//
//  Created by sandeep on 7/13/14.
//  Copyright (c) 2014 Dropbox, Inc. All rights reserved.
//  Updated by Sandeep on 10/16/15 to add cleanup call
//

#import "MobiusoBubblePopup.h"
#import "Utilities.h"
#import "Theme.h"
#import "NSString+StringSizeWithFont.h"
#import "UIImage+RemapColor.h"

#define MB_TITLE_HEIGHT    32
#define MB_SUBTITLE_HEIGHT 16
#define GAP             16
#define OFFSET_FULL     (MB_TITLE_HEIGHT+MB_SUBTITLE_HEIGHT+16)
#define OFFSET_TITLE    (MB_TITLE_HEIGHT+8)

@interface MobiusoBubblePopup ()

@property (nonatomic, retain) UIButton      *popMessageButton;

@end

@implementation MobiusoBubblePopup


- (id)initWithFrame:(CGRect)frame withOrientation: (MBOrientationType) type andDuration: (CGFloat) duration
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        _touchOrientation = type;
        _duration = duration;
        // if the called does not want to time out, then set the duration to be 0
        if (duration > 0) {
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(messageTapped:)];
            [self addGestureRecognizer:gesture];
        }
        
    }
    return self;
    
}

#pragma mark - popup with just the title
- (void) showMessage: (NSString *) messageStr withTitle: (NSString *) title
{
    [self showMessage:messageStr withTitle:title andSubtitle:nil andIcon:nil];
}

#pragma mark popup with subtitle
- (void) showMessage: (NSString *) messageStr withTitle: (NSString *) title andSubtitle: (NSString *)subTitle
{
    [self showMessage:messageStr withTitle:title andSubtitle:subTitle andIcon:nil];
}

- (void) showMessage: (NSString *) messageStr withTitle: (NSString *) title andSubtitle: (NSString *)subTitle andIcon: (UIImage *) icon
{
    self.backgroundColor = COLORFROMHEX(0x40000000);
    _popMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _popMessageButton.tag = 20140412;
   //  [_popMessageButton addTarget:self action:@selector(messageTapped:) forControlEvents: UIControlEventTouchUpInside];
    
    CGRect frame = [Utilities applicationFrame];
    
    [_popMessageButton setBackgroundColor: COLORFROMHEX(0xffeeeeee)];
    
    
    
    
    CGFloat width = frame.size.width - 20;
    // if (width > 300) width = 300;
    
    
    // ---
    if ((messageStr == nil) || ([messageStr length] == 0)) {
        messageStr = @"No message.";
    }
    
    CGSize size = CGSizeMake(width - 72, 500);
    UIFont *messageFont = [UIFont fontWithName:@"Avenir" size: 16];
    UIFont *titleFont = [UIFont fontWithName:@"Avenir" size: 20];
    UIFont *subtitleFont = [UIFont fontWithName:@"Avenir" size: 12];
    CGRect rect = [messageStr boundingRectWithSize:size Font:messageFont];
    
    CGFloat offset = (subTitle ? OFFSET_FULL : OFFSET_TITLE);
    CGFloat height =  rect.size.height + offset + 32;
    
    // CGFloat iOS7Delta = (IS_IOS7?20:0);
    CGFloat bubbleTop = (frame.size.height - height - 32)/2; // if center
    CGFloat top = 0;
    CGFloat bottom = 0;
    CGFloat left = 0;
    CGFloat right = 0;
    switch (_touchOrientation) {
        case MBOrientationRight:
            right = 16;
            break;
            
        case MBOrientationLeft:
            left = 16;
            break;
            
        case MBOrientationTop:
        case MBOrientationNorthWest:
        case MBOrientationNorthEast:
            bubbleTop = 84;
            top = 16;
            break;
            
        case MBOrientationBottom:
        case MBOrientationSouthWest:
        case MBOrientationSouthEast:
        default:
            bubbleTop = frame.size.height - height - 84;
            bottom = 16;
            break;
            
    }
    _popMessageButton.frame =  CGRectMake((frame.size.width - width) / 2, bubbleTop, width, height + 32);
    [_popMessageButton addTarget:self action:@selector(messageTapped:)    forControlEvents:UIControlEventTouchUpInside];
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
    
    // [button addSubview: icon];
    CALayer *iconLayer = [CALayer layer];
    iconLayer.contents = (__bridge id)([UIImage RemapColor:[Theme mainColor] maskImage:icon?icon:[UIImage imageNamed: @"Icon-Mask-1024.png"]].CGImage);
    iconLayer.opacity = 0.8f;
    iconLayer.frame = CGRectMake(width-64-right/2, 16 /* height - 32 - bottom/2 */, 64, 64);
    [layer addSublayer:iconLayer];
    
    // Text to be rendered
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(15+left, offset - 24 + top, width - 72, height)];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.numberOfLines = 0;
    messageLabel.textColor = COLORFROMHEX(0xff0f87a1);
    
    messageLabel.text = messageStr;
    messageLabel.font = messageFont;
    [_popMessageButton addSubview: messageLabel];
    messageLabel.userInteractionEnabled = YES;

    // Title to be rendered
    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(15+left, top+10, width - 72, MB_TITLE_HEIGHT)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [Theme redColor];
    
    titleLabel.text = title;
    titleLabel.font = titleFont;
    [_popMessageButton addSubview: titleLabel];

    // Subtitle to be rendered
    if (subTitle) {
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame: CGRectMake(15+left, top+6+MB_TITLE_HEIGHT, width - 72, MB_SUBTITLE_HEIGHT)];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subtitleLabel.numberOfLines = 0;
        subtitleLabel.textColor = [Theme neutralColor];
        
        subtitleLabel.text = subTitle;
        subtitleLabel.font = subtitleFont;
        [_popMessageButton addSubview: subtitleLabel];
    }
    
    // Keep the overlay for about 15 seconds - if you tap before that, it should go away
    if (_duration > 0) {
        NSTimer *timer = [NSTimer timerWithTimeInterval: _duration target:self selector:@selector(messageTimedout:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer: timer forMode:NSRunLoopCommonModes];
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

- (CGPathRef)renderNotchedPath:(CGRect) rectFrame notchOrientation: (MBOrientationType) where
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat width = rectFrame.size.width;
    CGFloat height = rectFrame.size.height;
    
    CGFloat top = 0;
    CGFloat bottom = 0;
    CGFloat left = 0;
    CGFloat right = 0;
    switch (where) {
        case MBOrientationRight:
            right = 15;
            break;
            
        case MBOrientationLeft:
            left = 15;
            break;
            
        case MBOrientationTop:
            top = 15;
            break;
            
        case MBOrientationBottom:
        default:
            bottom = 15;
            break;
            
    }
    CGPathMoveToPoint(path, NULL, left, top);
    if (where == MBOrientationTop) {
        CGPathAddLineToPoint(path, nil, (width/2) - 10, top);
        CGPathAddLineToPoint(path, nil, width/2, 0);
        CGPathAddLineToPoint(path, nil, (width/2) + 10, top);
    } else if (where == MBOrientationNorthWest) {
        CGPathAddLineToPoint(path, nil, (width*.2), top);
        CGPathAddLineToPoint(path, nil, width*.2, 0);
        CGPathAddLineToPoint(path, nil, (width*.2) + 15, top);
    } else if (where == MBOrientationNorthEast) {
        CGPathAddLineToPoint(path, nil, (width*.8) - 15, top);
        CGPathAddLineToPoint(path, nil, width*.8, 0);
        CGPathAddLineToPoint(path, nil, (width*.8), top);
    }
    CGPathAddLineToPoint(path, nil, width-right, top);
    if (where == MBOrientationRight) {
        CGPathAddLineToPoint(path, nil, width-right, (height/2) - 10);
        CGPathAddLineToPoint(path, nil, width-right + 15, height/2);
        CGPathAddLineToPoint(path, nil, width-right, (height/2) + 10);
    }
    CGPathAddLineToPoint(path, nil, width-right, height-bottom);
    if (where == MBOrientationBottom) {
        CGPathAddLineToPoint(path, nil, (width/2) + 10, height-bottom);
        CGPathAddLineToPoint(path, nil, width/2, height-bottom+15);
        CGPathAddLineToPoint(path, nil, (width/2) - 10, height-bottom);
    } else if (where == MBOrientationSouthWest) {
        CGPathAddLineToPoint(path, nil, (width*.2) + 15, height-bottom);
        CGPathAddLineToPoint(path, nil, width*.2, height-bottom+15);
        CGPathAddLineToPoint(path, nil, (width*.2), height-bottom);
    } else if (where == MBOrientationSouthEast) {
        CGPathAddLineToPoint(path, nil, (width*.8), height-bottom);
        CGPathAddLineToPoint(path, nil, width*.8, height-bottom+15);
        CGPathAddLineToPoint(path, nil, (width*.8) - 15, height-bottom);
    }
    CGPathAddLineToPoint(path, nil, left, height-bottom);
    if (where == MBOrientationLeft) {
        CGPathAddLineToPoint(path, nil, left, (height/2) + 10);
        CGPathAddLineToPoint(path, nil, 0, height/2);
        CGPathAddLineToPoint(path, nil, left, (height/2) - 10);
    }
    CGPathAddLineToPoint(path, nil, left, top);
    CGPathCloseSubpath(path);
    
    return path;
    
}

#pragma mark - Button actions
- (void) messageTapped : (id) sender
{
    if ([sender class] != [UITapGestureRecognizer class]) {
        DLog(@"Class is not correct : %@", [sender class]);
        return;
    }
    UIGestureRecognizer *r = (UIGestureRecognizer *) sender;
    CGPoint point = [r locationInView:self];
    CGRect touchRect = CGRectInset(_popMessageButton.frame, -10, -10);
    if ((CGRectContainsPoint(touchRect, point)) &&
        ([self.delegate respondsToSelector:@selector(didTapBubblePopup)])) {
        [self.delegate didTapBubblePopup];
    } else {
        [self close];
    }
    
}

- (void) messageTimedout : (id) sender
{
    [self close];
}

- (void) close
{
    if ([self.delegate respondsToSelector:@selector(willCloseBubblePopup)]) {
        [self.delegate willCloseBubblePopup];
    }
    [self removeFromSuperview];
    
}

- (CAShapeLayer *) renderNotchedMask: (CGRect) rectFrame notchOrientation: (MBOrientationType) where
{
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    
    mask.frame = rectFrame;
    mask.fillColor = [[UIColor blackColor] CGColor];
    mask.path = [self renderNotchedPath: rectFrame notchOrientation:where];
    
    return mask;
    
}

#ifdef DOHITTEST
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect touchRect = CGRectInset(_popMessageButton.frame, -10, -10);
    if (CGRectContainsPoint(touchRect, point)) {
        return self;
    }
    return nil;
#ifdef NOTNOW
    UIView *hitTestView = [_popMessageButton hitTest:point withEvent:event];
    if (hitTestView == self) {
        hitTestView = nil;
    }
    return hitTestView;
#endif
    
}
#endif

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
