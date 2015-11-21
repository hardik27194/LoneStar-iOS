/*
 * This file is insired from the StickyHeaderFlowLayout package.
 *
 */

#import <UIKit/UIKit.h>

@interface MoShelfPlusStickyHeaderFlowLayoutAttributes : UICollectionViewLayoutAttributes

// 0 = minimized, 1 = fully expanded, > 1 = stretched
@property (nonatomic) CGFloat progressiveness;

@end
