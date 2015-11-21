//
//  MoLocationViewController.h
//  
//
//  Created by Sandeep on 8/05/13.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapPoint.h"
//#import "MPConfiguration.h"
#import "Constants.h"


@protocol MoLocationViewControllerDelegate;


@interface MoLocationViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
{
    CLLocationManager *locationManager;
    
    CLLocationCoordinate2D currentCentre;
    int currenDist;
    BOOL firstLaunch;
    id <MoLocationViewControllerDelegate> delegate;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) UITextField *messageTextField;
@property (nonatomic, retain) UIButton *sendButton;
@property (nonatomic, retain) UIButton *attachButton;
@property (nonatomic, retain) UIView *chatBoxView;
@property (nonatomic, assign) CLLocationCoordinate2D selectedPoint;
@property (nonatomic, retain) NSString *selectedAddress;
@property (nonatomic, assign) BOOL pointDefined;
@property (nonatomic, assign) BOOL readOnly;    // show a location and the pin
@property (nonatomic, retain) id <MoLocationViewControllerDelegate> delegate;
@property (nonatomic, assign) CLLocationCoordinate2D pinLocation;

- (IBAction) bottomBarButtonPress:(id)sender;
- (id) initWithTitle: (NSString *) titleStr readOnly: (BOOL) flag pinLatitude: (NSString *) lat pinLongitude: (NSString *) lng pinAddress: (NSString *) addr;

@end

// Location View & Selection
@protocol MoLocationViewControllerDelegate <NSObject>

- (void) selectedLocation: (CLLocationCoordinate2D) loc withAddress: (NSString *)addr;

@optional
- (void) locationViewControllerWillDismiss:(MoLocationViewController *)vc animated:(BOOL)animated;

@end