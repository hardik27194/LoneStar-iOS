//
//  PhotoAlbumNavigationViewController.h
//
//
//

#import <UIKit/UIKit.h>
#import "MobiusoQuiltLayout.h"
// #import "MoLocationViewController.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLRegion.h>
#import <CoreLocation/CLVisit.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import "MobiusoBubblePopup.h"
#import "MoArcMenu.h"
#import "MoGradientProgressView.h"
#import "MobiusoActionView.h"
#import "MoElasticMenu.h"
#import "UIImage+RemapColor.h"
#import "UIImage+ImageEffects.h"
#import "MoShelfPlusStickyHeader.h"
#import "MoImageViewController.h"
#import "MoProgressView.h"
#import "PhotoDetailViewController.h"
#import "MoPopupListToo.h"
#import "ImageEditor.h"

// #import "AssetsDataIsInaccessibleViewController.h"
//#import "AssetsList.h"
//#import "FavoriteAssets.h"

//#import "MapViewController.h"

typedef NS_ENUM(NSInteger, NavActionView) {
    ServerActionView = 0,
    DateActionView,
    AddressActionView,
    StringActionView,
    TagActionView,
    DeleteActionView
};

typedef NS_ENUM(NSInteger, NavSortField) {
    NavSortFieldCreationDate = 0,
    NavSortFieldModificationDate,
    NavSortFieldFileName,
    NavSortFieldPrimaryTag
};

typedef NS_ENUM(NSInteger, NavSortType) {
    NavSortTypeAscending = 0,
    NavSortTypeDescending
};

typedef NS_ENUM(NSInteger, NavSearchType) {
    NavSearchTypeNone = 0,
    NavSearchTypeByDate = (1UL  << 1),  // date (or parts thereof supplied)
    NavSearchTypeByMap  = (1UL  << 2),  // map as a region
    NavSearchTypeByAddress  = (1UL  << 3),  // typed address
    NavSearchTypeByString  = (1UL  << 4),   // any string with specialized meaning (resolution, etc)
};

typedef NS_ENUM(NSInteger, NavSearchOperator) {
    NavSearchOperatorEquals = 0,
    NavSearchOperatorGreaterThan,
    NavSearchOperatorLessThan
};

#if 0
// For Cache Stuff
typedef NS_ENUM(NSInteger, FileSystemZone) {
    FileSystemZoneCache = 0,
    FileSystemZoneStash,
    FileSystemZoneGroupCommon
};
#endif

#define PHOTO_ROLL_SERVER_INDEX     0

// If you want to do Panning for selection then define the following, else undef it.
#undef DO_PAN_SELECTION // This conflicts with the ElasticMenu - disable it

@class  PhotoAlbumNavigationController;

@protocol PhotoAlbumViewControllerDelegate <NSObject>

- (void) photoAlbumViewController: (PhotoAlbumNavigationController *) controller didFinishPickingMedia: (PHAsset *) photoAsset inAssetCollection: (PHAssetCollection *) assetCollection withContextArray: (PHFetchResult *)fetchResults andMarker: (NSUInteger) indexMarker;

@end

@interface PhotoAlbumNavigationController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate,UIViewControllerTransitioningDelegate, MobiusoQuiltLayoutDelegate, MobiusoBubblePopupDelegate, MobiusoActionViewDelegate,
    MoImageViewControllerDismissalDelegate, PhotoDetailViewControllerDelegate, MoPopupListTooViewDataSource, MoPopupListTooViewDelegate,
#ifdef DOARCMENU
    MoArcMenuDelegate,
#endif
#ifdef IMAGEEDITOR_HANDOFF_TO_HOMEVIEW
    ImageEditorDelegate,

#endif

    MoElasticMenuDelegate, MoShelfPlusStickyHeaderDelegate, UISearchBarDelegate
>
{
    
    ALAssetsLibrary                     *assetsLibrary;
    NSMutableArray                      *groups;
    // FavoriteAssets *favoriteAssets;
#if 0
    IBOutlet MoGradientProgressView     *progressView;
#else
    MoProgressView                      *progressView;
#endif

    UILongPressGestureRecognizer *longTapGestureRecognizer;
#ifdef DO_PAN_SELECTION
    UIPanGestureRecognizer              *panGestureRecognizer;
#endif
    
}

// @property (nonatomic, retain) AssetsList *assetsList;

@property (nonatomic, retain) NSString *root;
@property (nonatomic, retain) NSString *stickyTitle;
@property  (nonatomic, retain) UIImage *background;

@property  (nonatomic, retain) id <PhotoAlbumViewControllerDelegate> delegate;


@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) PHFetchResult *assetsFetchResults;
@property (nonatomic, retain) PHAssetCollection *assetCollection;
@property  (nonatomic, retain) NSString *helpInformation;
@property  (nonatomic, retain) MoShelfPlusStickyHeader             *stickyHeaderCell;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;                     // called when keyboard search button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;                     // called when cancel button pressed

- (void) refresh;


#if 0
// Cache and Tagging
+ (BOOL) setTagsForPhoto: (PHAsset *) photoAsset withTags: (NSArray *) tags;
+ (NSArray *) tagsForPhoto: (PHAsset *) photoAsset;
#endif

@end
