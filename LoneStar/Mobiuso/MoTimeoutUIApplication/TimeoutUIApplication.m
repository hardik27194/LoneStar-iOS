//
//  TimeoutUIApplication.m
//  ShshDox-iOS
//
//  Created by sandeep on 11/1/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import "TimeoutUIApplication.h"
#import "AppDelegate.h"

@implementation TimeoutUIApplication

static dispatch_once_t onceToken;

//here we are listening for any touch. If the screen receives touch, the timer is reset
-(void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    
    if (!myidleTimer)
    {
        [self resetIdleTimer];
    }
    
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0)
    {
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan)
        {
            [self resetIdleTimer];
        }
        
    }
}
//as labeled...reset the timer
-(void)resetIdleTimer
{
    // Let there be a reference established
    dispatch_once(&onceToken, ^{
        [AppDelegate sharedDelegate].timeoutUIApplication = self;
    });
    
    
    if (myidleTimer)
    {
        [myidleTimer invalidate];
    }
    //convert the wait period into minutes rather than seconds
    int timeout = kApplicationTimeoutInSeconds;
    myidleTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:NO];
    
}
//if the timer reaches the limit as defined in kApplicationTimeoutInMinutes, post this notification
-(void)idleTimerExceeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidTimeoutNotification object:nil];
    // DLog(@"Sent idle notification");
}


@end
