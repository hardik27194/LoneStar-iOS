//
//  TimeoutUIApplication.h
//  ShshDox-iOS
//
//  Created by sandeep on 11/1/14.
//  Copyright (c) 2014 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEBUG_MEMORY

#if defined(DEBUG) || defined(DEBUG_MEMORY)
#define kApplicationTimeoutInSeconds 10
#else
#define kApplicationTimeoutInSeconds 20
#endif

//the notification your AppDelegate needs to watch for in order to know that it has indeed "timed out"
#define kApplicationDidTimeoutNotification @"AppTimeOut"


@interface TimeoutUIApplication : UIApplication
{
    NSTimer     *myidleTimer;
}

-(void)resetIdleTimer;

@end
