//
//  MoImageInfo.h
//
//
//

@import Foundation;
@import Photos;

@interface MoImageInfo : NSObject

@property (strong, nonatomic) UIImage *image; // If nil, be sure to set either imageURL or canonicalImageURL.
@property (strong, nonatomic) UIImage *placeholderImage; // Use this if all you have is a thumbnail and an imageURL.
@property (copy, nonatomic) NSURL *imageURL;
@property (copy, nonatomic) NSURL *canonicalImageURL; // since `imageURL` might be a filesystem URL from the local cache.
@property (copy, nonatomic) NSString *altText;
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) CGRect referenceRect;
@property (strong, nonatomic) UIView *referenceView;
@property (assign, nonatomic) UIViewContentMode referenceContentMode;
@property (assign, nonatomic) CGFloat referenceCornerRadius;
@property (copy, nonatomic) NSMutableDictionary *userInfo;

@property (retain, nonatomic) PHAsset *imageAsset;
@property (retain, nonatomic) PHAssetCollection  *imageAssetCollection;
@property (assign, nonatomic) NSInteger imageMarkerIndex;  // for reference in callback

- (NSString *)displayableTitleAltTextSummary;
- (NSString *)combinedTitleAndAltText;
- (CGPoint)referenceRectCenter;

@end
