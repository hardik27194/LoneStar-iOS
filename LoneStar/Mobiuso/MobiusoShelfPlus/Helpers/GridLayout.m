//
//  GridLayout.m
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "GridLayout.h"
#import "ShelfView.h"
#import "ModuleTypeHeader.h"
#import "ModuleLayoutAttributes.h"
#import "MoShelfPlusStickyHeaderFlowLayoutAttributes.h"
#import "MoShelfPlusStickyHeader.h"

#ifdef DEBUG
@interface GridLayout (Debug)

- (void)debugLayoutAttributes:(NSArray *)layoutAttributes;

@end
#endif

@interface GridLayout()

@property (nonatomic, strong) NSDictionary *shelfRects;

@end

NSString *const GridLayoutHeaderStickyHeader = @"MoStickyHeaderStickyHeader";

@implementation GridLayout

- (id)init
{
    self = [super init];
    if (self)
    {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = (CGSize){170, 197};
        self.sectionInset = UIEdgeInsetsMake(4, 10, 14, 10);//UIEdgeInsetsMake(54, 60, 64, 60);
        self.headerReferenceSize = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad? (CGSize){50, 50} : (CGSize){43, 43}; // 100
        self.footerReferenceSize = (CGSize){44, 44}; // 88
        self.minimumInteritemSpacing = 10; // 40;
        self.minimumLineSpacing = 10;//40;
        
        [self registerClass:[ShelfView class] forDecorationViewOfKind:[ShelfView kind]];
    }
    return self;
}


#if STICKY_HEADER // Sticky Header
#pragma mark Overrides

+ (Class)layoutAttributesClass {
    return [MoShelfPlusStickyHeaderFlowLayoutAttributes class];
}

- (void)setParallaxHeaderReferenceSize:(CGSize)parallaxHeaderReferenceSize {
    _parallaxHeaderReferenceSize = parallaxHeaderReferenceSize;
    // Make sure we update the layout
    [self invalidateLayout];
}

- (CGSize)collectionViewContentSize {
    // If not part of view hierarchy then return CGSizeZero (as in docs).
    // Call [super collectionViewContentSize] can cause EXC_BAD_ACCESS when collectionView has no superview.
    if (!self.collectionView.superview) {
        return CGSizeZero;
    }
    CGSize size = [super collectionViewContentSize];
    size.height += self.parallaxHeaderReferenceSize.height;
    return size;
}

#else
// Original
+ (Class)layoutAttributesClass
{
    return [ModuleLayoutAttributes class];
}

#endif

// Do all the calculations for determining where shelves go here
- (void)prepareLayout
{
    // call super so flow layout can do all the math for cells, headers, and footers
    [super prepareLayout];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical)
    {
        // Calculate where shelves go in a vertical layout
        NSUInteger sectionCount = [self.collectionView numberOfSections];
        
        CGFloat y = 0;
        CGFloat availableWidth = self.collectionViewContentSize.width - (self.sectionInset.left + self.sectionInset.right);
        int itemsAcross = floorf((availableWidth + self.minimumInteritemSpacing) / (self.itemSize.width + self.minimumInteritemSpacing));
        
        for (int section = 0; section < sectionCount; section++)
        {
            y += self.headerReferenceSize.height;
            y += self.sectionInset.top;
            
            NSUInteger itemCount = [self.collectionView numberOfItemsInSection:section];
            int rows = ceilf(itemCount/(float)itemsAcross);
            for (int row = 0; row < rows; row++)
            {
                y += self.itemSize.height;
                dictionary[[NSIndexPath indexPathForItem:row inSection:section]] = [NSValue valueWithCGRect:CGRectMake(0, y - 32, self.collectionViewContentSize.width, 37)];
                
                if (row < rows - 1)
                    y += self.minimumLineSpacing;
            }
            
            y += self.sectionInset.bottom;
            y += self.footerReferenceSize.height;
        }
    }
    else
    {
        // Calculate where shelves go in a horizontal layout
        CGFloat y = self.sectionInset.top;
        CGFloat availableHeight = self.collectionViewContentSize.height - (self.sectionInset.top + self.sectionInset.bottom);
        int itemsAcross = floorf((availableHeight + self.minimumInteritemSpacing) / (self.itemSize.height + self.minimumInteritemSpacing));
        CGFloat interval = ((availableHeight - self.itemSize.height) / (itemsAcross <= 1? 1 : itemsAcross - 1)) - self.itemSize.height;
        for (int row = 0; row < itemsAcross; row++)
        {
            y += self.itemSize.height;
            dictionary[[NSIndexPath indexPathForItem:row inSection:0]] = [NSValue valueWithCGRect:CGRectMake(0, roundf(y - 32), self.collectionViewContentSize.width, 37)];
            
            y += interval;
        }
    }
    
    self.shelfRects = [NSDictionary dictionaryWithDictionary:dictionary];
}

// Return attributes of all items (cells, supplementary views, decoration views) that appear within this rect
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
#if STICKY_HEADER // Sticky Header
      // The rect should compensate the header size
    CGRect adjustedRect = rect;
    adjustedRect.origin.y -= self.parallaxHeaderReferenceSize.height;
    
    NSArray *array = [super layoutAttributesForElementsInRect:adjustedRect];

#else
    // Original
    // call super so flow layout can return default attributes for all cells, headers, and footers
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
#endif
    
    // tweak the attributes slightly
    for (UICollectionViewLayoutAttributes *attributes in array)
    {

#if STICKY_HEADER // Sticky Header
        CGRect frame = attributes.frame;
        frame.origin.y += self.parallaxHeaderReferenceSize.height;
        attributes.frame = frame;
#endif
        attributes.zIndex = 1;
        //if (attributes.representedElementCategory != UICollectionElementCategoryCell)
        /*if (attributes.representedElementCategory != UICollectionElementCategorySupplementaryView || [attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
            attributes.alpha = 0.5;
        else if (attributes.indexPath.row > 0 || attributes.indexPath.section > 0)
            attributes.alpha = 0.5; // for single cell closeup*/
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal && attributes.representedElementCategory == UICollectionElementCategorySupplementaryView)
        {
            // make label vertical if scrolling is horizontal
            attributes.transform3D = CATransform3DMakeRotation(-90 * M_PI / 180, 0, 0, 1);
            attributes.size = CGSizeMake(attributes.size.height, attributes.size.width);            
        }
        
        if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView && [attributes isKindOfClass:[ModuleLayoutAttributes class]])
        {
            ModuleLayoutAttributes *conferenceAttributes = (ModuleLayoutAttributes *)attributes;
            conferenceAttributes.headerTextAlignment = NSTextAlignmentLeft;
        }
    }
    
    // Add our decoration views (shelves)
    NSMutableArray *newArray = [array mutableCopy];
    
    [self.shelfRects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (CGRectIntersectsRect([obj CGRectValue], rect))
        {
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[ShelfView kind] withIndexPath:key];
            attributes.frame = [obj CGRectValue];
            
            attributes.zIndex = 0;
            //attributes.alpha = 0.5; // screenshots
            [newArray addObject:attributes];
        }
    }];

    // Parallax
#if STICKY_HEADER
    BOOL visibleParallexHeader = (self.parallaxHeaderAlwaysOnTop == YES);
    if (visibleParallexHeader && (self.scrollDirection == UICollectionViewScrollDirectionVertical) && ! CGSizeEqualToSize(CGSizeZero, self.parallaxHeaderReferenceSize)) {
        MoShelfPlusStickyHeaderFlowLayoutAttributes *currentAttribute = [MoShelfPlusStickyHeaderFlowLayoutAttributes layoutAttributesForSupplementaryViewOfKind:GridLayoutHeaderStickyHeader withIndexPath:[NSIndexPath indexPathWithIndex:0]];
        CGRect frame = currentAttribute.frame;
        frame.size.width = self.parallaxHeaderReferenceSize.width;
        frame.size.height = self.parallaxHeaderReferenceSize.height;
        
        CGRect bounds = self.collectionView.bounds;
        CGFloat maxY = CGRectGetMaxY(frame);
        
        // make sure the frame won't be negative values
        CGFloat y = MIN(maxY - self.parallaxHeaderMinimumReferenceSize.height, bounds.origin.y + self.collectionView.contentInset.top);
        CGFloat height = MAX(0, -y + maxY);
        
        
        CGFloat maxHeight = self.parallaxHeaderReferenceSize.height;
        CGFloat minHeight = self.parallaxHeaderMinimumReferenceSize.height;
        CGFloat progressiveness = (height - minHeight)/(maxHeight - minHeight);
        currentAttribute.progressiveness = progressiveness;
        
        // if zIndex < 0 would prevents tap from recognized right under navigation bar
        currentAttribute.zIndex = 0;
        
        
        // When parallaxHeaderAlwaysOnTop is enabled, we will check when we should update the y position
        if (self.parallaxHeaderAlwaysOnTop && height <= self.parallaxHeaderMinimumReferenceSize.height) {
            CGFloat insetTop = self.collectionView.contentInset.top;
            // Always stick to top but under the nav bar
            y = self.collectionView.contentOffset.y + insetTop;
            currentAttribute.zIndex = 2000;
        }
        
        currentAttribute.frame = (CGRect){
            frame.origin.x,
            y,
            frame.size.width,
            height,
        };
        
        
        [newArray addObject:currentAttribute];
    }

#endif
    
    
    
    array = [NSArray arrayWithArray:newArray];
    
#ifdef DEBUG
//    [self debugLayoutAttributes:array];
#endif
    
    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

// Layout attributes for a specific cell
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    attributes.zIndex = 1;
#if STICKY_HEADER // Sticky Header
    CGRect frame = attributes.frame;
    frame.origin.y += self.parallaxHeaderReferenceSize.height;
    attributes.frame = frame;
#endif
    return attributes;
}

// layout attributes for a specific header or footer
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:[SmallModuleTypeHeader kind]])
        return nil;
    
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
#if STICKY_HEADER // Sticky Header
    if (!attributes && [kind isEqualToString:GridLayoutHeaderStickyHeader]) {
        attributes = [MoShelfPlusStickyHeaderFlowLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    } 
#endif
    {

        attributes.zIndex = 1;
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
        {
            // make label vertical if scrolling is horizontal
            attributes.transform3D = CATransform3DMakeRotation(-90 * M_PI / 180, 0, 0, 1);
            attributes.size = CGSizeMake(attributes.size.height, attributes.size.width);
        }
        
        if ([attributes isKindOfClass:[ModuleLayoutAttributes class]])
        {
            ModuleLayoutAttributes *conferenceAttributes = (ModuleLayoutAttributes *)attributes;
            conferenceAttributes.headerTextAlignment = NSTextAlignmentLeft;
        }
    }
    
   return attributes;
}

// layout attributes for a specific decoration view
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    id shelfRect = self.shelfRects[indexPath];
    if (!shelfRect)
        return nil; // no shelf at this index (this is probably an error)
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[ShelfView kind] withIndexPath:indexPath];
    attributes.frame = [shelfRect CGRectValue];
    attributes.zIndex = 0; // shelves go behind other views
    
    return attributes;
}

@end

#pragma mark - Debugging

@implementation MoShelfPlusStickyHeaderFlowLayoutAttributes (Debug)

- (NSString *)description {
    NSString *indexPathString = [NSString stringWithFormat:@"{%ld, %ld}", (long)self.indexPath.section, (long)self.indexPath.item];
    
    NSString *desc = [NSString stringWithFormat:@"<GridLayout: %p> indexPath: %@ zIndex: %ld valid: %@ kind: %@", self, indexPathString, (long)self.zIndex, [self isValid] ? @"YES" : @"NO", self.representedElementKind ?: @"cell"];
    
    return desc;
}

- (BOOL)isValid {
    switch (self.representedElementCategory) {
        case UICollectionElementCategoryCell:
            if (self.zIndex != 1) {
                return NO;
            }
            return YES;
        case UICollectionElementCategorySupplementaryView:
            if ([self.representedElementKind isEqualToString:GridLayoutHeaderStickyHeader]) {
                return YES;
            } else if (self.zIndex < 1024) {
                return NO;
            }
            return YES;
        default:
            return YES;
    }
}

@end



@implementation GridLayout (Debug)

- (void)debugLayoutAttributes:(NSArray *)layoutAttributes {
    __block BOOL hasInvalid = NO;
    [layoutAttributes enumerateObjectsUsingBlock:^(MoShelfPlusStickyHeaderFlowLayoutAttributes *attr, NSUInteger idx, BOOL *stop) {
        hasInvalid = ![attr isValid];
        if (hasInvalid) {
            *stop = YES;
        }
    }];
    
    if (hasInvalid) {
        DLog(@"MoStickyHeaderFlowLayout: %@", layoutAttributes);
    }
}
@end