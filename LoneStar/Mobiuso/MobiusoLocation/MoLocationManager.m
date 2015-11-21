//
//  MoLocationManager.m
//  SnapticaToo
//
//  Created by sandeep on 2/6/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "MoLocationManager.h"
#import "Configs.h"

@interface MoLocationManager ()
@property (nonatomic, retain) CLLocationManager             *locationManager;
@property (nonatomic, assign) BOOL                          timeToUpdateLocation;
@property (nonatomic, retain) NSTimer                       *locationUpdateTimer;

@end

static CLLocation           *currentLocation;
static MoLocationManager    *moLocationManager;

@implementation MoLocationManager

+ (CLLocation *) location
{
    @synchronized(self) {
        // any activity to be done?
    }
    
    return currentLocation;
}

+ (MoLocationManager *) instance
{
    @synchronized(self) {
        if (moLocationManager == nil) {
            // Is there anything being done?
            moLocationManager = [[MoLocationManager alloc] init];
            moLocationManager.locationManager = [[CLLocationManager alloc] init];
            moLocationManager.locationManager.delegate = moLocationManager;
            // Set a movement threshold for new events.
            moLocationManager.locationManager.distanceFilter = 10; // meters (every KM or so)
            moLocationManager.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
#ifdef LOCATION_REQUEST_INUSE_AUTH
            if ([moLocationManager.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [moLocationManager.locationManager requestWhenInUseAuthorization];
            }
#endif
#ifdef LOCATION_REQUEST_ALWAYS_AUTH
            if ([moLocationManager.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [moLocationManager.locationManager requestAlwaysAuthorization];
            }
#endif
            currentLocation = nil;

        }
    }
    
    return moLocationManager;
}

#pragma mark - Location tracking
+ (void) startTrackingLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        MoLocationManager *lm = [MoLocationManager instance];
        if (lm) {
            [lm.locationManager startUpdatingLocation];
            lm.timeToUpdateLocation = YES;
        }
    }
    
}

+ (void) stopTrackingLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        MoLocationManager *lm = [MoLocationManager instance];
        if (lm) [lm.locationManager stopUpdatingLocation];
    }
}

- (void) updateLocation
{
    
    // [[MPBuzzAccount sharedInstance] updateLocation: _currentLocation];
    
}

#undef DEBUG_LOCATION

// Deprecated
#ifdef USE_DEPRECATED
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
    
    if (_timeToUpdateLocation) {
        // Tell the server our location
        _timeToUpdateLocation = NO;
        // [[MPBuzzAccount sharedInstance] updateLocation: _currentLocation];
        if (!_locationUpdateTimer) {
            _locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(locationTimeout) userInfo:nil repeats:YES];
        }
        
    }
    
#ifdef DEBUG_LOCATION
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    NSString *lat = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                     degrees, minutes, seconds];
    // latLabel.text = lat;
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    NSString *longt = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                       degrees, minutes, seconds];
    // longLabel.text = longt;
    DLog(@"Updated location: %@", [NSString stringWithFormat: @"%@, %@", lat, longt]);
    
//    MobiusoToast *menuHint = [[MobiusoToast alloc] initWithDuration: 2.5f andText:[NSString stringWithFormat: @"%@, %@", lat, longt]];
//    [menuHint displayInView:[self.window.rootViewController view] atCenter:CGPointMake(160, 30)];
#endif
    
}
#endif

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    NSUInteger count = [locations count];
    if (count < 1) {
        return;
    }
    currentLocation = locations[count - 1];

#ifdef DEBUG_LOCATION
    CLLocation *newLocation = locations[count - 1];
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    NSString *lat = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                     degrees, minutes, seconds];
    // latLabel.text = lat;
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    NSString *longt = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                       degrees, minutes, seconds];
    // longLabel.text = longt;
    DLog(@"Updated location: %@", [NSString stringWithFormat: @"%@, %@", lat, longt]);
    
    //    MobiusoToast *menuHint = [[MobiusoToast alloc] initWithDuration: 2.5f andText:[NSString stringWithFormat: @"%@, %@", lat, longt]];
    //    [menuHint displayInView:[self.window.rootViewController view] atCenter:CGPointMake(160, 30)];
#endif
    
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
#ifdef DEBUG_LOCATION
    DLog(@"Failed to get location: Error=%@", [error description]);
#endif
    
}


- (void)locationManagerDidPauseLocationUpdates: (CLLocationManager *)manager
{
#ifdef DEBUG_LOCATION
    DLog(@"Did Pause Location Updates");
#endif
    
}


- (void)locationManagerDidResumeLocationUpdates: (CLLocationManager *)manager
{
#ifdef DEBUG_LOCATION
    DLog(@"Did Resume Location Updates");
#endif
    
}

#pragma mark - actions to be taken when requested with timeToUpdateLocation flag
- (void) locationTimeout
{
    _timeToUpdateLocation = YES;
    DLog(@"Time to update Location to the rest");
//    [[MPBuzzAccount sharedInstance] updateLocation: _currentLocation];
}


@end
