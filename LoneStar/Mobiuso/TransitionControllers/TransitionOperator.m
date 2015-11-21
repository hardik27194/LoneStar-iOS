//
//  TransitionOperator.m
//  SnapticaToo
//
//  Created by sandeep on 12/31/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import "TransitionOperator.h"

@implementation TransitionOperator

#pragma mark - Delegate Methods

- (id) init
{
    if (self = [super init]) {
        _isPresenting = YES;
        _presentationDuration = 0.5;
        _dismissalDuration = 0.65;
        
    }
    return self;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (_isPresenting) {
        [self presentNavigation: transitionContext];
    } else {
        [self dismissNavigation: transitionContext];
    }
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _isPresenting ? _presentationDuration : _dismissalDuration;
    // return 0.5;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    _isPresenting = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    _isPresenting = NO;
    return self;
    
}

#pragma mark - Main methods
- (void)presentNavigation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *container = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *fromView = fromViewController.view;

    UIViewController <HandleTapGestureDelegate> *toViewController = (UIViewController <HandleTapGestureDelegate> *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *toView = toViewController.view;
    
    CGSize size = toView.frame.size;
    CGAffineTransform offsetTransform = CGAffineTransformMakeTranslation(size.width * .70, 0);
    
    offsetTransform = CGAffineTransformScale(offsetTransform, 0.6, 0.6);
    
    snapshot = [fromView snapshotViewAfterScreenUpdates:YES];
    [container addSubview:toView];
    [container addSubview:snapshot];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:toViewController action:@selector(handleTap:)];
    
    [snapshot addGestureRecognizer:gesture];

    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        snapshot.transform = offsetTransform;
        
    } completion:^(BOOL finished) {[transitionContext completeTransition:YES];} ];
    
}

- (void)dismissNavigation:(id<UIViewControllerContextTransitioning>)transitionContext
{
#ifdef NOTUSED
    UIView *container = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *fromView = fromViewController.view;
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *toView = toViewController.view;
#endif
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        snapshot.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        [snapshot removeFromSuperview];
    } ];
    
    
}

@end
