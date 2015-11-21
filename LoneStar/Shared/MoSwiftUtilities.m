//
//  MoSwiftUtilities.m
//  FAVbox
//
//  Created by sandeep on 9/22/15.
//  Copyright © 2015 Mobiuso. All rights reserved.
//

#import "MoSwiftUtilities.h"
#import <objc/runtime.h>

NSString const *key1 = @"FirstConstant";
NSString *const MySecondConstant = @"SecondConstant";

@implementation MoSwiftUtilities

// Used to identify the associating glowing view
// static char* GLOWVIEW_KEY = "GLOWVIEW";

static NSMutableDictionary *keyDictionary = nil;

// Get the glowing view attached to this one.
+ (NSObject *) getAssociatedObject: (id) selfObject ForKey: (NSString const *) keyRef
{
    return objc_getAssociatedObject(selfObject, (__bridge const void *)(keyRef));
}

// Attach a view to this one, which we'll use as the glowing view.
+ (void) setAssociatedObject:(id) selfObject setValue: (id) value  forKey: (void *) keyRef

{
//    id object, void *key, id value
    objc_setAssociatedObject(selfObject, keyRef, value, OBJC_ASSOCIATION_RETAIN);
}

@end
