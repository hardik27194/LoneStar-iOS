//
//  MoLocationViewController.m
//
//
//  Created by Sandeep on 8/05/13.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//

#import "MoLocationViewController.h"
#import "Strings.h"


@implementation MoLocationViewController

@synthesize mapView;
@synthesize messageTextField;
@synthesize chatBoxView;
@synthesize sendButton;
@synthesize pointDefined;
@synthesize selectedPoint;
@synthesize selectedAddress;
@synthesize delegate;
@synthesize readOnly;
@synthesize pinLocation;

#pragma mark - Initialization
- (id) initWithTitle: (NSString *) titleStr readOnly: (BOOL) flag pinLatitude: (NSString *) lat pinLongitude: (NSString *) lng pinAddress: (NSString *) addr
{
    self = [super initWithNibName:@"MoLocationViewController" bundle:nil];
    self.readOnly = flag;
    self.title = titleStr;
    if ((lat != nil) && (lng != nil)) {
        pinLocation.latitude =  [lat doubleValue];
        pinLocation.longitude = [lng doubleValue];
    }
    selectedAddress = addr;
    return self;
}


#pragma mark - View Cycle
- (void) loadView {
    [super loadView];
    
    // self.mapView = [[MKMapView alloc] init];
    // self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
#ifdef NOTNOW
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 40.7310;
    zoomLocation.longitude= -73.9977;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 10000, 10000);
    [self.mapView setRegion:viewRegion animated:NO];
#endif
    
    pointDefined = self.readOnly;
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithTitle:(readOnly?@"Done": @"Use") style:UIBarButtonItemStyleDone target:self action:@selector(toolBarButtonPress:)];
    self.navigationItem.rightBarButtonItem = actionButton;
    
    self.view.backgroundColor = COLORFROMHEX(0xffddddddd); //[UIColor lightGrayColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    // [self.navigationController setNavigationBarHidden:NO]; // sandeep
 
    // self.mapView.frame = CGRectMake(0, 50, 240, 320);
  
    //[self.view addSubview: self.mapView];
    

    //Make this controller the delegate for the map view.
    self.mapView.delegate = self;
    
    // Ensure that we can view our own location in the map view.
    [self.mapView setShowsUserLocation:YES];
    
    //Instantiate a location object.
    locationManager = [[CLLocationManager alloc] init];
    
    //Make this controller the delegate for the location manager.
    [locationManager setDelegate:self];
    
    //Set some paramater for the location object.
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    //Set the first launch instance variable to allow the map to zoom on the user location when first launched.
    firstLaunch=YES;

    if (readOnly) {
        // Add a point to the map
        // Place this annotation now
        MapPoint *placeObject = [[MapPoint alloc] initWithName: @"Tracking Point" address: selectedAddress coordinate: pinLocation];
        
        
        [self.mapView addAnnotation:placeObject];
        [self.mapView selectAnnotation:placeObject animated:YES];

    }
    // User touch to be initiated
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
}

-(void) queryGooglePlaces: (NSString *) googleType
{
    
    
    // Build the url string we are going to sent to Google. NOTE: The kGOOGLE_API_KEY is a constant which should contain your own API key that you can obtain from Google. See this link for more info:
    // https://developers.google.com/maps/documentation/places/#Authentication
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", currentCentre.latitude, currentCentre.longitude, [NSString stringWithFormat:@"%i", currenDist], googleType, kGOOGLE_API_KEY];
    
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:responseData 
                          
                          options:kNilOptions 
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"]; 
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
    
    //Plot the data in the places array onto the map with the plotPostions method.
    [self plotPositions:places];
    
    
}

-(void) queryAddress: (CLLocationCoordinate2D) location
{
    // Build the url string we are going to sent to Google. NOTE: The kGOOGLE_API_KEY is a constant which should contain your own API key that you can obtain from Google. See this link for more info:
    // https://developers.google.com/maps/documentation/places/#Authentication
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", location.latitude, location.longitude];
    
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedAddress:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedAddress:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
    
    // we are looking for formatted address
    //Retrieve the NSDictionary object in each index of the array.
    NSString *fmtaddr;
    if ([places count] > 0) {
        NSDictionary* place = [places objectAtIndex:0]; // the first item is precise
        
        //There is a specific NSDictionary object that gives us location info.
        fmtaddr = [place objectForKey:@"formatted_address"];
    } else {
        fmtaddr = @"[no address]";
    }
    
    
    //Plot the data in the places array onto the map with the plotPostions method.
    // [self plotPositions:places];
    //Create a new annotiation.
    // Place this annotation now
    MapPoint *placeObject = [[MapPoint alloc] initWithName: @"Meeting Point" address: fmtaddr coordinate: selectedPoint];
    
    selectedAddress = fmtaddr;
    
    [self.mapView addAnnotation:placeObject];
    [self.mapView selectAnnotation:placeObject animated:YES];
}

- (void) removeAnnotations
{
    //Remove any existing custom annotations but not the user location blue dot.
    for (id<MKAnnotation> annotation in mapView.annotations)
    {
        if ([annotation isKindOfClass:[MapPoint class]])
        {
            [mapView removeAnnotation:annotation];
        }
    }

}

- (void)plotPositions:(NSArray *)data
{
    //Remove any existing custom annotations but not the user location blue dot.
    [self removeAnnotations];
    
    
    //Loop through the array of places returned from the Google API.
    for (int i=0; i<[data count]; i++)
    {
        
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary* place = [data objectAtIndex:i];
        
        //There is a specific NSDictionary object that gives us location info.
        NSDictionary *geo = [place objectForKey:@"geometry"];
        
        
        //Get our name and address info for adding to a pin.
        NSString *name=[place objectForKey:@"name"];
        NSString *vicinity=[place objectForKey:@"vicinity"];
        
        //Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        
        //Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        //Create a new annotiation.
        MapPoint *placeObject = [[MapPoint alloc] initWithName:name address:vicinity coordinate:placeCoord];
        
        
        [mapView addAnnotation:placeObject];
    }
}

-(void)keyboardWillHideOrShow:(NSNotification *)note
{
#ifdef NOTNOW
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect keyboardFrameForTextField = [self.chatBoxView.superview convertRect:keyboardFrame fromView:nil];
    CGRect newTextFieldFrame = self.chatBoxView.frame;
    
    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
    
    CGRect newTableViewFrame = CGRectMake(0, 0, self.chatHistoryTextView.frame.size.width, keyboardFrameForTableView.origin.y-newTextFieldFrame.size.height);
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.chatBoxView.frame = newTextFieldFrame;
    } completion:nil];
#endif
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [textField resignFirstResponder];
    } else {
        [self sendButtonPressed:nil];
    }
    return YES;
}

- (void)sendButtonPressed:(id)sender {
    // [buddy sendMessage:messageTextField.text secure:secure];
    //[button.title lowercaseString]
    [self queryGooglePlaces: [messageTextField.text lowercaseString]];
}


#define kSendButtonWidth 60

- (IBAction)bottomBarButtonPress:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 102:
            DLog(@"Cafe pressed");
            [self queryGooglePlaces: @"cafe"];
            return;
        case 100:
            DLog(@"Find pressed");
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideOrShow:) name:UIKeyboardWillHideNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideOrShow:) name:UIKeyboardWillShowNotification object:nil];
            
            CGRect frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height-(IS_IPAD?50:44));
            CGRect searchBoxFrame = CGRectMake(0,0, frame.size.width, (IS_IPAD?50:40));
            self.chatBoxView = [[UIView alloc] initWithFrame:searchBoxFrame];
            self.chatBoxView.backgroundColor = COLORFROMHEX(0xffd0d0d0);
            // self.chatBoxView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            
            self.messageTextField = [[UITextField alloc] init];
            messageTextField.borderStyle =  UITextBorderStyleRoundedRect; //UITextBorderStyleLine; //
            messageTextField.font = [UIFont fontWithName:@"Avenir" size:14];
            messageTextField.delegate = self;
            self.messageTextField.frame = CGRectMake(4, 3,
                                                     frame.size.width-kSendButtonWidth-8,
                                                     self.chatBoxView.frame.size.height-6);
            messageTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            
            
            
            self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [sendButton setTitle:@"Find" forState:UIControlStateNormal];
            [sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            self.sendButton.frame = CGRectMake(self.messageTextField.frame.size.width+8, 2, kSendButtonWidth , self.chatBoxView.frame.size.height-8);
            sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self.view addSubview:chatBoxView];
            [self.chatBoxView addSubview:messageTextField];
            [self.chatBoxView addSubview:sendButton];
            return;
        case 101:
            DLog(@"My Location");
            // set the point here...
            selectedPoint = mapView.userLocation.location.coordinate;
            [self queryAddress: selectedPoint];
#ifdef NOTNOW
            if (delegate && [delegate respondsToSelector:@selector(selectedLocation:)]) {
                [delegate selectedLocation: [[locationManager location] coordinate] withAddress:selectedAddress];
            }
#endif
            break;
            
        default:
            break;
    }
    
}

- (IBAction)toolBarButtonPress:(id)sender {
    // UIBarButtonItem *button = (UIBarButtonItem *)sender;
    if (!readOnly) {
        if (!pointDefined) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location" message:LOCATION_SET_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        } else {
            if (delegate && [delegate respondsToSelector:@selector(selectedLocation:withAddress:)]) {
                [delegate selectedLocation: selectedPoint withAddress: selectedAddress];
            }
            
        }
    }
    UINavigationController *nav = [self navigationController];
    
    [nav popViewControllerAnimated:YES];
    
    
    
    
#ifdef NOTNOW
    NSString *buttonTitle = @"Cafe"; //[button.title lowercaseString];
    
    //Use this title text to build the URL query and get the data from Google. Change the radius value to increase the size of the search area in meters. The max is 50,000.
    [self queryGooglePlaces:buttonTitle];
#endif
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - MKMapViewDelegate methods.
    
    
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{    
    
    //Zoom back to the user location after adding a new set of annotations.
    
    //Get the center point of the visible map.
    CLLocationCoordinate2D centre = [mv centerCoordinate];
    
    MKCoordinateRegion region;
    
    //If this is the first launch of the app then set the center point of the map to the user's location.
    if (firstLaunch) {
        // if readOnly is set then there will be pin set up.
        region = MKCoordinateRegionMakeWithDistance(readOnly?
                                                    pinLocation:
                                                    locationManager.location.coordinate,
                                                    8000,8000);
        firstLaunch=NO;
    }else {
        //Set the center point to the visible region of the map and change the radius to match the search radius passed to the Google query string.
        region = MKCoordinateRegionMakeWithDistance(centre,currenDist,currenDist);
    }
    
    //Set the visible region of the map.
    [mv setRegion:region animated:YES];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    //Define our reuse indentifier.
    static NSString *identifier = @"MapPoint";   
    
    
    if ([annotation isKindOfClass:[MapPoint class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        
        return annotationView;
    }
    
    return nil;    
}
    
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    //Get the east and west points on the map so we calculate the distance (zoom level) of the current map view.
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    //Set our current distance instance variable.
    currenDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    //Set our current centre point on the map instance variable.
    currentCentre = self.mapView.centerCoordinate;
}    


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    id <MKAnnotation> anot = [view annotation];
    DLog(@"Tapped: %f, %f (Title: %@, %@)", [anot coordinate].latitude, [anot coordinate].longitude, [anot title], [anot subtitle]);
    selectedPoint = [anot coordinate];
    pointDefined = TRUE;
}
#pragma mark - Gesture Recognizer
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    [self removeAnnotations];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    selectedPoint =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    
    [self queryAddress:selectedPoint];
    
    //MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    //annot.coordinate = touchMapCoordinate;
    //[self.mapView addAnnotation:annot];
}

@end
