//
//  MoArcBackground.m
//  
//
//  Created by sandeep on 1/13/13.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//

#import "MoArcBackground.h"
#import "QuartzCore/QuartzCore.h"
#import "QuartzCore/CAAnimation.h"
#import "Constants.h"
#import "Theme.h"

#define TRACK_WIDTH 1.0f
#define TRACK_DOTTED_INSIDE 1   // selected area
#define TRACK_DOTTED_OUTSIDE 0
#define TRACK_SHADOW 0

#define TRACK_COLOR COLOR


@implementation MoArcBackground

@synthesize endRadius, startPoint, anchorColor, aPath, bPath, repeatCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.repeatCount = 3;
    }
    return self;
}

// Load the view with the start angle and span in clockWise direction
- (void) loadView: (CGFloat) start spanAngle: (CGFloat) span 
{
    // Remove sublayers before:
    if (self.layer != nil) {
        NSArray *layers = [self.layer sublayers];
        for (int i=0; i < [layers count]; i++) {
            CALayer *l = [layers objectAtIndex: i];
            [l removeFromSuperlayer];
        }
    }
    
    //CGRect circularRect = CGRectMake(startPoint.x - endRadius, startPoint.y - endRadius, endRadius*2, endRadius*2);
//    circularPath = [UIBezierPath bezierPathWithOvalInRect: circularRect];
    // red
    UIBezierPath* cw = [UIBezierPath bezierPathWithArcCenter: startPoint
                                                                radius: self.endRadius
                                                     startAngle: DEGREES_TO_RADIANS(90)
                                                       endAngle: DEGREES_TO_RADIANS(89)
                                                      clockwise: YES];
    // orange
    UIBezierPath* ccwPath = [UIBezierPath bezierPathWithArcCenter: startPoint
                                                                radius: self.endRadius
                                                            startAngle: DEGREES_TO_RADIANS(90)
                                                              endAngle: DEGREES_TO_RADIANS(91)
                                                             clockwise: NO];
	CALayer *glow1 = [CALayer layer];
	glow1.bounds = CGRectMake(0, 0, TRACK_WIDTH+40, TRACK_WIDTH+40);  //
	glow1.position = CGPointMake(startPoint.x, startPoint.y - endRadius);
	glow1.contents = (id)([UIImage imageNamed:@"GlowEffect-Red"].CGImage); // GlowEffect.png Sandeep
    
    glow1.opacity = 0.4f;
	[self.layer addSublayer:glow1];
    
    
	CALayer *glow2 = [CALayer layer];
	glow2.bounds = CGRectMake(0, 0, TRACK_WIDTH+40, TRACK_WIDTH+40);  //
	glow2.position = CGPointMake(startPoint.x + endRadius, startPoint.y);
	glow2.contents = (id)([UIImage imageNamed:@"GlowEffect-Blue"].CGImage); // GlowEffect.png Sandeep
    
    glow2.opacity = 0.4f;
	[self.layer addSublayer:glow2];
	
	CAKeyframeAnimation *anim1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	anim1.path = ccwPath.CGPath; 
	anim1.rotationMode = kCAAnimationRotateAuto;
	anim1.repeatCount = self.repeatCount; // HUGE_VALF;
	anim1.duration = 2.0;
    

	CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	anim2.path = cw.CGPath;
	anim2.rotationMode = kCAAnimationRotateAuto;
	anim2.repeatCount = self.repeatCount; // HUGE_VALF;
	anim2.duration = 2.0;


	[glow1 addAnimation:anim1 forKey:@"race"];
    [glow2 addAnimation:anim2 forKey:@"race"];
    
    CABasicAnimation* fade =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    fade.removedOnCompletion = FALSE;
    fade.fillMode = kCAFillModeForwards;
    fade.duration = 2.0;
    fade.beginTime = 0;
    fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [fade setToValue: [NSNumber numberWithFloat: 0.0]];
    [glow1 addAnimation:fade forKey:@"opacity"];
    [glow2 addAnimation:fade forKey:@"opacity"];

    
    
    // For inside track - colored
    // Due to a bug in calculating points in ArcMenu, we are off by 90.  Calculate that here
    // Bug hack
    start -= DEGREES_TO_RADIANS(90);
    aPath = [UIBezierPath bezierPathWithArcCenter: startPoint // CGPointMake(15, 2)
                                                         radius: self.endRadius
                                                     startAngle: (start)    // was DEGREES_TO_RADIANS
                                                       endAngle: (start+(span))
                                        clockwise: (span>0)?YES:NO];
    
    // For outside track - colored
    bPath = [UIBezierPath bezierPathWithArcCenter: startPoint // CGPointMake(15, 2)
                                           radius: self.endRadius
                                       startAngle: (start)
                                         endAngle: (start+(span))
                                        clockwise: (span>0)?NO:YES];
	CAShapeLayer *insideTrack = [CAShapeLayer layer];
    // insideTrack.delegate = self;
	insideTrack.path = aPath.CGPath;
	insideTrack.strokeColor = COLORFROMHEX(0xfffc7a58).CGColor ; // self.anchorColor.CGColor;
	insideTrack.fillColor = [UIColor clearColor].CGColor;
	insideTrack.lineWidth = TRACK_WIDTH;
#if TRACK_DOTTED_INSIDE
    insideTrack.lineDashPattern = [NSArray arrayWithObjects: [NSNumber numberWithInt:2], [NSNumber numberWithInt:4], nil];
#endif
    insideTrack.opacity = 0.0f;
#if TRACK_SHADOW
    insideTrack.shadowColor = [UIColor blackColor].CGColor;
    insideTrack.shadowOffset = CGSizeMake(0, 1);
    insideTrack.shadowOpacity = 0.7f;
    insideTrack.shadowRadius = 1.0f;
#endif
	[self.layer addSublayer:insideTrack];
    // [insideTrack setNeedsDisplay];
    CAShapeLayer *outsideTrack = [CAShapeLayer layer];
	outsideTrack.path = bPath.CGPath;
	outsideTrack.strokeColor = COLORFROMHEX(0xffd22c5d).CGColor; // [UIColor blackColor].CGColor;
	outsideTrack.fillColor = [UIColor clearColor].CGColor;
	outsideTrack.lineWidth = TRACK_WIDTH;
#if TRACK_DOTTED_OUTSIDE
    outsideTrack.lineDashPattern = [NSArray arrayWithObjects: [NSNumber numberWithInt:2], [NSNumber numberWithInt:4], nil];
#endif
    outsideTrack.opacity = 0.0f;
#if TRACK_SHADOW
    outsideTrack.shadowColor = [UIColor blackColor].CGColor;
    outsideTrack.shadowOffset = CGSizeMake(0, 1);
    outsideTrack.shadowOpacity = 0.7f;
    outsideTrack.shadowRadius = 1.0f;
#endif
	[self.layer addSublayer:outsideTrack];


    CABasicAnimation* transition =  [CABasicAnimation animationWithKeyPath: @"opacity"];
    transition.removedOnCompletion = FALSE;
    transition.fillMode = kCAFillModeForwards;
    transition.duration = 2.0;
    transition.beginTime = 0;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [transition setToValue: [NSNumber numberWithFloat: 0.6]];
    
    [insideTrack addAnimation:transition forKey:@"opacity"];
    [outsideTrack addAnimation:transition forKey:@"opacity"];

}

#ifdef NOTNOW
// If custom drawn
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    
    CGColorRef bgColor = [UIColor colorWithHue:0.6 saturation:1.0 brightness:1.0 alpha:1.0].CGColor;
    CGContextSetFillColorWithColor(context, bgColor);
    CGContextFillRect(context, layer.bounds);
    
    CGContextFillRect(context, layer.bounds);
    CGContextRestoreGState(context);
}
#endif

@end
