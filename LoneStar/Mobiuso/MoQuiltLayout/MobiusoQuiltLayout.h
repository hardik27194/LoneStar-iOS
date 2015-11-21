//
//  MobiusoQuiltLayout.h
//  
//  Based on RFQuiltLayout - Sandeep Shah on 6/7/15.
//  Copyright (c) Sandeep Shah 2015. All rights reserved.
//
//

//

#import <UIKit/UIKit.h>

#define STICKY_HEADER   1

extern NSString *const GridLayoutHeaderStickyHeader;


@protocol MobiusoQuiltLayoutDelegate <UICollectionViewDelegate>
@optional
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath; // defaults to 1x1
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetsForItemAtIndexPath:(NSIndexPath *)indexPath; // defaults to uiedgeinsetszero
@end

@interface MobiusoQuiltLayout : UICollectionViewLayout



@property (nonatomic, weak) IBOutlet NSObject<MobiusoQuiltLayoutDelegate>* delegate;

@property (nonatomic, assign) CGSize blockPixels; // defaults to 100x100
@property (nonatomic, assign) UICollectionViewScrollDirection direction; // defaults to vertical

// only use this if you don't have more than 1000ish items.
// this will give you the correct size from the start and
// improve scrolling speed, at the cost of time at the beginning
@property (nonatomic) BOOL prelayoutEverything;

// Sticky Header
#ifdef STICKY_HEADER
@property (nonatomic) CGSize parallaxHeaderReferenceSize;
@property (nonatomic) CGSize parallaxHeaderMinimumReferenceSize;
@property (nonatomic) BOOL parallaxHeaderAlwaysOnTop;
@property (nonatomic) BOOL disableStickyHeaders;
#endif

@end
