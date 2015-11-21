//
//  TransitionOperator.h
//  SnapticaToo
//
//  Created by sandeep on 12/31/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADVAnimationController.h"

@protocol HandleTapGestureDelegate <NSObject>

- (void) handleTap: (id) sender;

@end

@interface TransitionOperator : NSObject <UIViewControllerTransitioningDelegate, ADVAnimationController>
{
    UIView *snapshot;
}

@property (nonatomic, assign)     BOOL    isPresenting;
@property (nonatomic, assign) NSTimeInterval presentationDuration;
@property (nonatomic, assign) NSTimeInterval dismissalDuration;

@end
