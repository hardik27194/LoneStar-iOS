//
//  MoLocationManager.h
//  SnapticaToo
//
//  Created by sandeep on 2/6/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobiusoToast.h"

@import CoreLocation;

@interface MoLocationManager : NSObject <CLLocationManagerDelegate>

+ (CLLocation *) location;
+ (MoLocationManager *) instance;
+ (void) startTrackingLocation;
+ (void) stopTrackingLocation;

@end
