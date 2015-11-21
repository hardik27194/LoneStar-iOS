//
//  PhotoDetailViewController.h
//  Snaptica
//
//  Created by Sandeep Shah on 01/04/2015.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
//#import "MobiusoResourceView.h"
#import "PhotoAnnotation.h"

@class PhotoObject;

@import Photos;
@import CoreLocation;
@import MapKit;

@class PhotoDetailViewController;

@protocol PhotoDetailViewControllerDelegate <NSObject>

@optional
// Dismissing the view Controller
- (void) dismissedPresentedController:(PhotoDetailViewController *) viewController;

@end

@interface PhotoDetailViewController : UIViewController <MKMapViewDelegate>
{
}

@property (nonatomic, strong) PhotoObject *item;

@property (nonatomic, strong) NSString  *root;

@property (nonatomic, strong) NSString  *markedFilesText;

@property (nonatomic, strong) NSDictionary  *dirInfo;

@property (strong, nonatomic) IBOutlet UIImageView *coverImageV;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) IBOutlet UILabel *altLabel;

@property (strong, nonatomic) IBOutlet UIButton *cachingButton;

@property (strong, nonatomic) IBOutlet UIButton *clearCacheButton;

@property (strong, nonatomic) IBOutlet UITextView *descriptionText;

@property (strong, nonatomic) IBOutlet UILabel *descriptionTitle;

@property (strong, nonatomic) IBOutlet UIButton *cacheDescriptionButton;

@property (strong, nonatomic) IBOutlet UIButton *locationButton;

@property (strong, nonatomic) IBOutlet UIButton *markedFilesButton;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UILabel *noLocationLabel;


@property (nonatomic, retain) UIViewController <PhotoDetailViewControllerDelegate> *delegate;

// AAPL
@property (strong) PHAsset *asset;
@property (strong) PHAssetCollection *assetCollection;



@end
