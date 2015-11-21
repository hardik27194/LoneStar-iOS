//
//  Animator
//  MobiusoActionView
//
//  Created by sandeep on 12/20/14.
//  Copyright (c) 2014 Sandeep. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol Animation <NSObject>
- (void)animationTick:(CFTimeInterval)dt finished:(BOOL *)finished;
@end

@interface Animator : NSObject

+ (instancetype)animatorWithScreen:(UIScreen *)screen;

- (void)addAnimation:(id<Animation>)animatable;
- (void)removeAnimation:(id<Animation>)animatable;

@end

@interface UIView (AnimatorAdditions)

- (Animator *)animator;

@end
