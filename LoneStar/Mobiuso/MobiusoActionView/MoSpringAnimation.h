//
//  MoSpringAnimation
//  MobiusoActionView
//
//  Created by sandeep on 12/20/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animator.h"

@protocol MoSpringAnimationDelegate <NSObject>

@optional
- (void) drawPane: (NSNumber *) speed;
- (void) viewWillCompleteAnimation;
- (void) viewDidCompleteAnimation;

@end

@interface MoSpringAnimation : NSObject <Animation>

@property (nonatomic, readonly) CGPoint velocity;
@property (nonatomic, retain) NSObject<MoSpringAnimationDelegate> *delegate;
@property (nonatomic, assign) CFTimeInterval firstTimestamp;
@property (nonatomic, assign) BOOL dampened;

+ (instancetype)animationWithView:(UIView *)view delegate: (NSObject <MoSpringAnimationDelegate>*) delegate target:(CGPoint)target velocity:(CGPoint)velocity;

@end
