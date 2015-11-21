//
//  MoSwiftUtilities.h
//  FAVbox
//
//  Created by sandeep on 9/22/15.
//  Copyright © 2015 Mobiuso. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const *key1;

@interface MoSwiftUtilities : NSObject

// Attach an object to the specified Object, which can be retrieved later.
+ (NSObject *) getAssociatedObject: (id) selfObject ForKey: (NSString const *) keyRef;

// Attach a view to this one, which we'll use as the glowing view.


// Retrieve an attached object for a given key of the referenced object
+ (void) setAssociatedObject:(id) selfObject setValue: (id) value  forKey: (void *) keyRef;
@end
