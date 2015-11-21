//
//  MoSpringAnimation
//  MobiusoActionView
//
//  Created by sandeep on 12/20/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import "MoSpringAnimation.h"
#import "MoGeometryExtras.h"

#undef DEBUG

@interface MoSpringAnimation ()

@property (nonatomic) CGPoint velocity;
@property (nonatomic) CGPoint targetPoint;
@property (nonatomic) UIView *view;

@end


@implementation MoSpringAnimation

- (instancetype)initWithView:(UIView *)view delegate: (id) delegate  target:(CGPoint)target velocity:(CGPoint)velocity
{
    self = [super init];
    if (self) {
        self.view = view;
        self.targetPoint = target;
        self.velocity = velocity;
        self.delegate = delegate;
        self.dampened = NO;
    }
    return self;
}

+ (instancetype)animationWithView:(UIView *)view delegate: (id) delegate target:(CGPoint)target velocity:(CGPoint)velocity
{
    return [[self alloc] initWithView:view delegate: (id) delegate  target:target velocity:velocity];
}

- (void)animationTick:(CFTimeInterval)dt finished:(BOOL *)finished
{
    static const float frictionConstant = 20;
    static const float springConstant = 300;
    CGFloat time = (CGFloat) dt;

    
    
    // friction force = velocity * friction constant
    CGPoint frictionForce = CGPointMultiply(self.velocity, frictionConstant);
    
    // spring force = (target point - current position) * spring constant
    CGPoint springForce = CGPointMultiply(CGPointSubtract(self.targetPoint, self.view.center), springConstant);
    
    // force = spring force - friction force
    CGPoint force = CGPointSubtract(springForce, frictionForce);
    // velocity = current velocity + force * time / mass
    
    self.velocity = CGPointAdd(self.velocity, CGPointMultiply(force, time));
    
    
    // position = current position + velocity * time
    self.view.center = CGPointAdd(self.view.center, CGPointMultiply(self.velocity, time));
    
    CGFloat speed = CGPointLength(self.velocity);
    CGFloat distanceToGoal = CGPointLength(CGPointSubtract(self.targetPoint, self.view.center));

    if ([self.delegate respondsToSelector:@selector(drawPane:)]) {
        [self.delegate performSelectorOnMainThread:@selector(drawPane:) withObject:[NSNumber numberWithFloat:distanceToGoal] waitUntilDone:NO];
        // DLog(@"---->>>>>>Calling drawPane<<<----------");
    }
    

    // DLog(@"center Y=%3.1f, Y velocity=%3.1f, speed=%3.1f, distanceToGoal=%3.1f", self.view.center.y, self.velocity.y, speed, distanceToGoal);

    // The first time you slow down - give a chance to the delegate to handle it for any finishing touches
    if (!self.dampened && (speed < 50)) {
        self.dampened = YES;
        if ([self.delegate respondsToSelector:@selector(viewWillCompleteAnimation)]) {
            [self.delegate performSelectorOnMainThread:@selector(viewWillCompleteAnimation) withObject:nil waitUntilDone:NO];
            // DLog(@"---->>>>>>Calling viewWillCompleteAnimation<<<----------");
        }
    }
    if (speed < 0.05 && distanceToGoal < 1) {
        self.view.center = self.targetPoint;
        *finished = YES;
        // let the delegate know that we are (almost) done...
        if ([self.delegate respondsToSelector:@selector(viewDidCompleteAnimation)]) {
            [self.delegate performSelectorOnMainThread:@selector(viewDidCompleteAnimation) withObject:nil waitUntilDone:NO];
        }
    }
}

@end
