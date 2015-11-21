//
//  PhotoDetailViewController.m
//  Snaptica
//
//  Created by Sandeep Shah on 01/04/2015.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//
//

#import "PhotoDetailViewController.h"

#import "PhotoObject.h"

#import "AppDelegate.h"
//#import "CacheManager.h"
//#import "MarkupIO.h"
#import "UIImage+RemapColor.h"
#import "PhotoAnnotation.h"
#import "Utilities.h"
#import "Theme.h"
#import "PhotoAlbumNavigationController.h"

#define SHOWING_DESCRIPTION 0
#define SHOWING_MARKEDFILES 1
#define SHOWING_COMPASS     2

#define DESCRIPTION_BUTTON_TAG_BASE     1000

#undef SHAREBUTTON

@interface PhotoDetailViewController ()
{
    NSUInteger  showing;
    NSString    *descriptionTextInfo;
    int         currentServer;
    NSString    *geoLocationShort;
    NSString    *geoLocationFull;
    CLGeocoder  *geocoder;
    NSDictionary     *placemarkDict;
    NSString    *photoTags;
}


@end

@implementation PhotoDetailViewController

- (void) setup
{
#if 0
    UIButton *leftButton = [[UIButton alloc] initWithFrame:(CGRect){0,0,22,22}];
    [leftButton setImage:[UIImage RemapColor:[Theme mainColor] maskImage:[UIImage imageNamed:@"back.png"]] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(menuBackAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];

    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -12;// it was -6 in iOS 6
    
    // self.navigationItem.leftBarButtonItem = settingsButtonItem;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, leftButtonItem];
#endif

#ifdef SHAREBUTTON
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(menuShareAction)];
    
    self.navigationItem.rightBarButtonItem = shareButton;
#endif
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[ADVThemeManager customizeView:self.view];
    
    currentServer = [[SettingsManager instance] currentServer];

    self.title = self.root;
    
    [self setup];
    
    _coverImageV.image = _item.imageDownloaded ? _item.image : [UIImage imageNamed:_item.imageName];
    
    NSDateFormatter *dfmt = [[NSDateFormatter alloc] init];
    dfmt.dateFormat = @"MMMM yyyy";
    _dateLabel.text = [dfmt stringFromDate:_item.date];
    
    [self setButtonTitles];
    [_cachingButton addTarget:self action:@selector(cachingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_clearCacheButton addTarget:self action:@selector(clearCacheButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self showDescription:SHOWING_DESCRIPTION];
//    [_cacheDescriptionButton addTarget:self action:@selector(descriptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_markedFilesButton addTarget:self action:@selector(descriptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_locationButton addTarget:self action:@selector(locationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}


- (void) showDescription: (NSUInteger) what
{
    showing = what;
    
    switch (what) {
        case SHOWING_DESCRIPTION:
        {
            _descriptionTitle.text = @"INFO";
            _descriptionText.text = descriptionTextInfo;
            _markedFilesButton.userInteractionEnabled = NO;
            _locationButton.userInteractionEnabled = YES;
            _mapView.hidden = YES;
            _descriptionText.hidden = NO;
            
            [_markedFilesButton setImage:[UIImage imageNamed:@"menu-markedfiles-solid-72.png"] forState:UIControlStateHighlighted];
            [_markedFilesButton setImage:[UIImage imageNamed:@"menu-markedfiles-72.png"] forState:UIControlStateNormal];
            
            [_locationButton setImage:[UIImage imageNamed:@"menu-compass-solid-72.png"] forState:UIControlStateHighlighted];
            [_locationButton setImage:[UIImage imageNamed:@"menu-compass-72.png"] forState:UIControlStateNormal];
            _noLocationLabel.hidden = YES;
            
            break;
        }

#ifdef NOTNOW
        case SHOWING_MARKEDFILES:
        {
            _descriptionTitle.text = @"MARKED FILES";
            [self markedFileInCurrentDirectory];
            [_markedFilesButton setImage:[UIImage imageNamed:@"menu-markedfiles-solid-72.png"] forState:UIControlStateNormal];
            [_markedFilesButton setImage:[UIImage imageNamed:@"menu-markedfiles-72.png"] forState:UIControlStateHighlighted];
            _cacheDescriptionButton.userInteractionEnabled = YES;
            _markedFilesButton.userInteractionEnabled = NO;
            _locationButton.userInteractionEnabled = YES;
            _mapView.hidden = YES;
            [_cacheDescriptionButton setImage:[UIImage imageNamed:@"menu-cache-solid-72.png"] forState:UIControlStateHighlighted];
            [_cacheDescriptionButton setImage:[UIImage imageNamed:@"menu-cache-72.png"] forState:UIControlStateNormal];
            [_locationButton setImage:[UIImage imageNamed:@"menu-compass-solid-72.png"] forState:UIControlStateHighlighted];
            [_locationButton setImage:[UIImage imageNamed:@"menu-compass-72.png"] forState:UIControlStateNormal];
            break;
        }
#endif
            
        case SHOWING_COMPASS:
        {
            _descriptionTitle.text = @"LOCATION";
            _descriptionText.hidden = YES;
           [_locationButton setImage:[UIImage imageNamed:@"menu-compass-solid-72.png"] forState:UIControlStateNormal];
            [_locationButton setImage:[UIImage imageNamed:@"menu-compass-72.png"] forState:UIControlStateHighlighted];
            _markedFilesButton.userInteractionEnabled = YES;
            _locationButton.userInteractionEnabled = NO;
            _mapView.hidden = NO;
            _mapView.delegate = self;
            _noLocationLabel.hidden = ![self isMapLocationZero:_asset.location.coordinate];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_asset.location.coordinate, 5000, 3000);
            
            [_mapView setRegion:region];
            if (geoLocationShort) {
                PhotoAnnotation *annotation = [[PhotoAnnotation alloc] init];
                annotation.coordinate = _asset.location.coordinate;
                annotation.title = geoLocationShort;
//                annotation.subtitle = geoLocationFull;
                
                // Add a More Info button to the annotation's view.
                MKPinAnnotationView* view = (MKPinAnnotationView*)[_mapView viewForAnnotation:annotation];
                if (view && (view.rightCalloutAccessoryView == nil))
                {
                    view.canShowCallout = YES;
                    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                }
                
                [_mapView addAnnotation:annotation];
//                [_mapView showAnnotations:@[annotation] animated:YES];
             }
            
            [_markedFilesButton setImage:[UIImage imageNamed:@"menu-markedfiles-solid-72.png"] forState:UIControlStateHighlighted];
            [_markedFilesButton setImage:[UIImage imageNamed:@"menu-markedfiles-72.png"] forState:UIControlStateNormal];
            break;
        }

        default:
            break;
    }
    
}

- (NSString *) cacheInfo: (NSDictionary *) dict
{
    NSString *description = @"";
    
    NSUInteger count = [[dict objectForKey:@"count"] integerValue];
    NSUInteger size = [[dict objectForKey:@"size"] integerValue];
    NSUInteger totalcount = [[dict objectForKey:@"totalcount"] integerValue];
    NSUInteger totalsize = [[dict objectForKey:@"totalsize"] integerValue];
    
    
    NSString *unit, *totalunit;
    if (size > (1024*1024*1024)) { unit = @" GB"; size /= (1024*1024*1024); }
    else if (size > (1024*1024)) { unit = @" MB"; size /= (1024*1024); }
    else if (size > 1024) { unit = @" KB"; size /= 1024; }
    else { unit = @""; }
    
    if (totalsize > (1024*1024*1024)) { totalunit = @" GB"; totalsize /= (1024*1024*1024); }
    else if (totalsize > (1024*1024)) { totalunit = @" MB"; totalsize /= (1024*1024); }
    else if (totalsize > 1024) { totalunit = @" KB"; totalsize /= 1024; }
    else { totalunit = @""; }
    
    description = [NSString stringWithFormat:@"Number of Cached Entries: %ld\nCache Size: %ld %@\n\nTotal Cached Entries: %ld\nTotal Cache Size: %ld %@", (unsigned long)count, (unsigned long)size, unit, (unsigned long)totalcount, (unsigned long)totalsize, totalunit ];
    return description;
}

- (void) menuBackAction
{
        [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) setButtonTitles
{
    {
        {
            //            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
//            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:nil];
            CLLocation *location = _asset.location;
            CLLocationDistance alt =  location.altitude;
            if (placemarkDict) {
                NSString *areasofinterest = [placemarkDict objectForKey:@"areaofinterest"];
                NSString *locality = [placemarkDict objectForKey:@"city"];
                NSString *administrativeArea = [placemarkDict objectForKey:@"state"];
                __unused NSString *country = [placemarkDict objectForKey:@"country"];
                __unused NSString *thoroughfare = [placemarkDict objectForKey:@"street"];
                __unused NSString *subThoroughfare = [placemarkDict objectForKey:@"streetno"];
                NSString *ISOcountryCode = [placemarkDict objectForKey:@"countrycode"];
                NSDictionary *addressDictionary = [placemarkDict objectForKey:@"addressdictionary"];
                
                
                
                
                
                geoLocationShort = [NSString stringWithFormat:@"%@, %@ [%@]", locality?locality:@"", administrativeArea?administrativeArea:@"", ISOcountryCode? ISOcountryCode:@""];
                NSDictionary *dict = addressDictionary;
                NSString *addr = @"";
                for (NSString *line in [dict objectForKey: @"FormattedAddressLines"]) {
                    addr = [NSString stringWithFormat:@"%@\n%@", addr, line];
                }
                if ([addr length] > 0) {
                    geoLocationFull = [NSString stringWithFormat:@"%@\nLocation Address:\n%@", areasofinterest, addr];
                } else {
                    geoLocationFull = [NSString stringWithFormat:@"%@\nLocation Address:\n%@\n%@, %@ %@ [%@]\n",
                                       areasofinterest ? areasofinterest : @"",
                                       [dict objectForKey:@"Street"], [dict objectForKey:@"City"], [dict objectForKey:@"State"], [dict objectForKey:@"ZIP"], [dict objectForKey:@"CountryCode"] ];
                    
                }
                
#if 0
                
                // Create a Annotation object if not passed
                annotation.placemark = [placemarks objectAtIndex:0];
                
                // Add a More Info button to the annotation's view.
                MKPinAnnotationView* view = (MKPinAnnotationView*)[_mapView viewForAnnotation:annotation];
                if (view && (view.rightCalloutAccessoryView == nil))
                {
                    view.canShowCallout = YES;
                    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                }
#endif
            } else if (!placemarkDict && ![self isMapLocationZero:location.coordinate]) {
                [self geocodeLocation:location];
            }
            
            if (!photoTags) {
                NSArray *tagsArray = [CacheManager tagsForPhoto:self.asset];
                if (tagsArray) {
                    NSString *tagsString = @"Tags: ";
                    NSString *sep = @"";
                    for (NSString *tag in tagsArray) {
                        tagsString = [NSString stringWithFormat:@"%@%@#%@", tagsString, sep, tag];
                        sep = @", ";
                    }
                    photoTags = tagsString;
                }
                
            }
            
            descriptionTextInfo = [NSString stringWithFormat:@"Resolution: %ldx%ld [%@]\nFavorite: %@\nHidden: %@\nLocation: [%f:%f]\nAltitude: %2.f meters\n%@\n%@",
                                   (unsigned long)_asset.pixelWidth, (unsigned long) _asset.pixelHeight,
                                   (_asset.mediaType == PHAssetMediaTypeImage) ? @"Photo" : @"Video",
                                   _asset.isFavorite? @"YES" : @"NO",
                                   _asset.isHidden ? @"YES" : @"NO",
                                   location.coordinate.latitude, location.coordinate.longitude,
                                   alt,
                                   geoLocationFull? geoLocationFull : @"",
                                   photoTags? photoTags : @""
                                   ];
            
            if (showing == SHOWING_DESCRIPTION) {
                _descriptionText.text = descriptionTextInfo;
            }
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
            dateFormatter.dateStyle = NSDateFormatterMediumStyle;
            
            //                                          NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
            
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:usLocale];
            
            
            _dateLabel.text = [dateFormatter stringFromDate: _asset.creationDate];
            _altLabel.text = (geoLocationShort? geoLocationShort :[dateFormatter stringFromDate: _asset.modificationDate]);
        }
        _clearCacheButton.hidden = YES;
        _cachingButton.hidden = YES;
    }
#if 0
    else {
        CacheManager *cm = [AppDelegate cacheManager];
        
        PhotoObject *item = [cm findFolderBeingCachedByName:self.title];
        
        NSString *label = (item!=nil)? @"Stop Caching" : @"Start Caching";
        
        [_cachingButton setTitle:label forState:UIControlStateNormal];
        
        NSString *str;
        NSDictionary *cacheDict = [cm infoDirectory:self.root];
        BOOL count = ([[cacheDict objectForKey:@"count"] integerValue] > 0);
        if (count) {
            _clearCacheButton.alpha = 1.0f;
            str = @"Clear Cache";
            [_clearCacheButton setTitleColor:[Theme redColor] forState: UIControlStateNormal];
            [_clearCacheButton setBackgroundImage:[UIImage RemapColor:[Theme redColor] maskImage:[UIImage imageNamed:@"button-preview.png"]]  forState: UIControlStateNormal];
        } else {
            _clearCacheButton.alpha = 0.5;
            str = @"Nothing Cached";
            [_clearCacheButton setTitleColor:[UIColor lightGrayColor] forState: UIControlStateNormal];
            [_clearCacheButton setBackgroundImage: [UIImage imageNamed:@"button-preview.png"]  forState: UIControlStateNormal];
        }
        
        [_clearCacheButton setTitle:str forState:UIControlStateNormal];
        descriptionTextInfo = [self cacheInfo:cacheDict]; //  _item.description;
    }
#endif
    
}

- (BOOL) isMapLocationZero: (CLLocationCoordinate2D) location
{
    return((location.latitude == 0.0) && (location.longitude == 0.0));
}

- (void)geocodeLocation:(CLLocation*)location
{
#if 1
//    CacheManager *cm = [AppDelegate cacheManager];
//    if (!placemarkDict) {
//        placemarkDict = [cm locationPlacemarks:location.coordinate];
//    }
    if (placemarkDict) {
        [self setButtonTitles];
    } else
        
        if (!geocoder) {
        geocoder = [[CLGeocoder alloc] init];
        
        [geocoder reverseGeocodeLocation:location completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if (error != nil) {
                 geocoder = nil;
             } else {
                 placemarkDict = [self mapToPlacemarkDict:placemarks];
//                 [cm setLocationPlacemark: placemarkDict forLocation:location.coordinate];
                 [self setButtonTitles];
             }
         }
         ];
    }
#endif
    
}

#pragma mark - MKMapViewDelegate methods
#if 1
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
//    if ([annotation isKindOfClass:[MyCustomAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[mapView
                                                                 dequeueReusableAnnotationViewWithIdentifier:@"Photo"];
        
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"Photo"];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = YES;
            
            // If appropriate, customize the callout by adding accessory views (code not shown).
            pinView.canShowCallout = YES;
            
            UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = disclosureButton;
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
    }
    
    return nil;
}
// user tapped the call out accessory 'i' button
- (void)mapView:(MKMapView *)aMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
#if 0
    PhotoAnnotation *annotation = (PhotoAnnotation *)view.annotation;
    NSMutableArray *photosToShow = [NSMutableArray arrayWithObject:annotation];
    [photosToShow addObjectsFromArray:annotation.containedAnnotations];
    
    PhotosViewController *viewController = [[PhotosViewController alloc] init];
    viewController.edgesForExtendedLayout = UIRectEdgeNone;
    viewController.photosToShow = photosToShow;
    
    [self.navigationController pushViewController:viewController animated:YES];
#endif
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[PhotoAnnotation class]])
    {
        PhotoAnnotation *annotation = (PhotoAnnotation *)view.annotation;
        [annotation updateSubtitleIfNeeded];
    }
}

#endif


#pragma mark - Caching
- (void)cachingButtonPressed:(id) sender
{
#if 0
    // [self tappedOnItemAtRow: ((UIButton *)sender).tag];
    CacheManager *cm = [AppDelegate cacheManager];
    PhotoObject *item = [cm findFolderBeingCachedByName:self.title];
    if (item != nil) {
        // Stop caching, so remove from the list
        [cm removeFolderBeingCachedByName:self.title];
    } else {        // Start caching
        [cm addFolderBeingCached:self.item.title forName:self.title];
    }
    [self setButtonTitles];
#endif
    
}

- (void) clearCacheButtonPressed: (id) sender
{
#if 0
    CacheManager *cm = [[AppDelegate sharedDelegate] cacheManager];
    [cm purgeDirectory:self.root];
//    _descriptionText.text = [cm infoDirectory:self.root]; //  _item.description;
    [self setButtonTitles];
    if (showing == SHOWING_DESCRIPTION) {
        _descriptionText.text = descriptionTextInfo;
    }
#endif
    
}

- (void) descriptionButtonPressed: (id) sender
{
    [self showDescription:SHOWING_DESCRIPTION];
}

#if 0

- (void) markedfilesButtonPressed: (id) sender
{
    [self showDescription:SHOWING_MARKEDFILES];
    
}
#endif

- (void) locationButtonPressed: (id) sender
{
    [self showDescription:SHOWING_COMPASS];
    
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self  dismissViewControllerAnimated:YES completion: ^{
        if ([_delegate respondsToSelector:@selector(dismissedPresentedController:)]) {
            [_delegate dismissedPresentedController:self];
        }
    }];
//    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Marked Files
-(NSUInteger) countCharacters: (NSString *) component  {
    NSRange r;
    NSString *s = [component copy];
    NSUInteger count = 0;
    while ((r = [s rangeOfString:@"[\n]" options:NSRegularExpressionSearch]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@"#"];
        count++;
    }
    return count;
}

#pragma mark - Marked Files Management
- (void) markedFileInCurrentDirectory
{
#if 0
    NSString *file = [NSString stringWithFormat: @"%@:%@", self.root?self.root:@"", MARKED_FILENAME];
    NSString *server = [AppDelegate currentHostAddress];
    
    NSString *nameUrlString = [NSString stringWithFormat: @"%@%@/%@/file/file=%@", server,
                               kCompany, kProduct,
                               [file stringByReplacingOccurrencesOfString:@"/" withString:@":"]];
    
    NSURL *url = [NSURL URLWithString:UrlSafeString(nameUrlString)];
    CacheManager *cm = [AppDelegate sharedDelegate].cacheManager;
    [cm downloadFileWithURL:url
                   withPath:file
            completionBlock:^(BOOL succeeded, NSData *fileData, NSString *errorMessage) {
                if (succeeded) {
                    // TODO - if the lines could be read from the NSData - do so (to avoid reading the file again)
                    NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
                    _descriptionText.text = [NSString stringWithFormat:@"# of Marked Files: %ld\n\n%@",
                                             [self countCharacters:fileString],
                                             fileString];

                } else {
                    _descriptionText.text = errorMessage ;
                }
            }];
#endif
}

- (NSDictionary *) mapToPlacemarkDict: (NSArray *) placemarks
{
    NSMutableDictionary *placemrkDict = [[NSMutableDictionary alloc] init];
    if (placemarks && ([placemarks count] > 0)) {
        CLPlacemark *placemrk = placemarks[0]; // just use the first item, ignore the rest
                                                // It is not clear what elements are available - compile the list accordingly...
        if (placemrk.locality) [placemrkDict setObject:placemrk.locality forKey: @"city"];
        if (placemrk.administrativeArea) [placemrkDict setObject:placemrk.administrativeArea forKey: @"state"];
        if (placemrk.country) [placemrkDict setObject:placemrk.country forKey: @"country"];
        if (placemrk.thoroughfare) [placemrkDict setObject:placemrk.thoroughfare forKey: @"street"];
        if (placemrk.subThoroughfare) [placemrkDict setObject:placemrk.subThoroughfare forKey: @"streetno"];
        if (placemrk.ISOcountryCode) [placemrkDict setObject:placemrk.ISOcountryCode forKey: @"countrycode"];
        if (placemrk.addressDictionary) [placemrkDict setObject:placemrk.addressDictionary forKey: @"addressdictionary"];
        if (placemrk.areasOfInterest) [placemrkDict setObject:placemrk.areasOfInterest forKey: @"areaofinterest"];
        // ZIP code?
    }
    return placemrkDict;
}


@end
