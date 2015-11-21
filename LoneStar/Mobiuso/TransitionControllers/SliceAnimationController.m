//
//  SliceAnimationController.m
//  Notes
//
//  Created by Tope Abayomi on 26/07/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "SliceAnimationController.h"

@interface SliceAnimationController ()

double radianFromDegree(float degrees);

@end




@implementation SliceAnimationController


-(id)init{
    self = [super init];
    
    if(self){
        
        self.presentationDuration = 6.0;
        self.dismissalDuration = 6.0;
    }
    
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    return self.isPresenting ? self.presentationDuration : self.dismissalDuration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    if(self.isPresenting){
        [self executePresentationAnimation:transitionContext];
    }
    else{
        
        [self executeDismissalAnimation:transitionContext];
    }
    
}

-(void)executePresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView* inView = [transitionContext containerView];
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect oldFrame = fromViewController.view.layer.frame;
    [fromViewController.view.layer setAnchorPoint:CGPointMake(0.0,0.5f)];
    [fromViewController.view.layer setFrame:oldFrame];
    
    
    [inView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    
    fromViewController.view.layer.transform = [self fromTransformStart];
    toViewController.view.layer.transform = [self toTransformStart];

    
    [UIView animateWithDuration:self.presentationDuration delay:0.0f options:0 animations:^{
        
        toViewController.view.layer.transform = [self toTransformEnd];

    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
    [UIView animateWithDuration:0.8*self.presentationDuration delay:0.2*self.presentationDuration options:0 animations:^{
        
        fromViewController.view.layer.transform = [self fromTransformEnd];
        
    } completion:^(BOOL finished) {
    
    }];
}

-(void)executeDismissalAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView* inView = [transitionContext containerView];
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [inView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    
    fromViewController.view.layer.transform = [self fromTransformEnd];
    toViewController.view.layer.transform = [self toTransformEnd];
    
    [UIView animateWithDuration:0.8f*self.dismissalDuration delay:0.2f*self.dismissalDuration options:UIViewAnimationOptionCurveLinear animations:^{
        
        toViewController.view.layer.transform = [self toTransformStart];
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:self.dismissalDuration delay:0.0f options:0 animations:^{

        fromViewController.view.layer.transform = [self fromTransformStart];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}


-(CATransform3D)fromTransformStart{
    
    CATransform3D fromTransform = CATransform3DIdentity;
    fromTransform.m34 = 1.0/ -500;
    fromTransform = CATransform3DTranslate(fromTransform, 0.0f, 0.0f,  0.0f);
    
    return fromTransform;
}

-(CATransform3D)toTransformStart{
    
    CATransform3D toTransform = CATransform3DIdentity;
    toTransform.m34 = 1.0/ -500;
    // Rotate 5 degrees within the axis of z axis
    toTransform = CATransform3DRotate(toTransform, radianFromDegree(5.0f), 0.0f,0.0f, 1.0f);
    // Reposition toward to the left where it initialized
    toTransform = CATransform3DTranslate(toTransform, 320.0f, -40.0f,  150.0f);
    // Rotate it -45 degrees within the y axis
    toTransform = CATransform3DRotate(toTransform, radianFromDegree(-45), 0.0f,1.0f, 0.0f);
    // Rotate it 10 degrees within thee x axis
    toTransform = CATransform3DRotate(toTransform, radianFromDegree(10), 1.0f,0.0f, 0.0f);
    
    return toTransform;
}

-(CATransform3D)fromTransformEnd{
    
    CATransform3D fromTransformFinal = CATransform3DIdentity;
    fromTransformFinal.m34 = 1.0/ -500;
    fromTransformFinal = CATransform3DRotate(fromTransformFinal, radianFromDegree(80), 0.0f,1.0f, 0.0f);
    fromTransformFinal = CATransform3DTranslate(fromTransformFinal, 0.0f, 0.0f,  -30.0f);
    fromTransformFinal = CATransform3DTranslate(fromTransformFinal,170.0f, 0.0f,  0.0f);
    
    return fromTransformFinal;
    
}

-(CATransform3D)toTransformEnd{
    
    CATransform3D toTransformFinal = CATransform3DIdentity;
    toTransformFinal.m34 = 1.0/ -500;
    // Rotate to 0 degrees within z axis
    toTransformFinal = CATransform3DRotate(toTransformFinal, radianFromDegree(0), 0.0f,0.0f, 1.0f);
    // Bring back to the final position
    toTransformFinal = CATransform3DTranslate(toTransformFinal, 0.0f, 0.0f,  0.0f);
    // Rotate 0 degrees within y axis
    toTransformFinal = CATransform3DRotate(toTransformFinal, radianFromDegree(0), 0.0f,1.0f, 0.0f);
    // Rotate 0 degrees within  x axis
    toTransformFinal = CATransform3DRotate(toTransformFinal, radianFromDegree(0), 1.0f,0.0f, 0.0f);
    
    return toTransformFinal;
}

double radianFromDegree(float degrees) {
    return (degrees / 180) * M_PI;
}

@end
