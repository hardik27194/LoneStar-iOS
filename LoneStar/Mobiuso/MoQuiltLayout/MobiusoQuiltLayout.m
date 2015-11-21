//
//  RFQuiltLayout.h
//
//  Based on RFQuiltLayout - Sandeep Shah on 6/7/15.
//  Copyright (c) Sandeep Shah 2015. All rights reserved.
//

#import "MobiusoQuiltLayout.h"
#import "MoShelfPlusStickyHeaderFlowLayoutAttributes.h"
#import "MoShelfPlusStickyHeader.h"

#ifdef DEBUG
@interface MobiusoQuiltLayout (Debug)

- (void)debugLayoutAttributes:(NSArray *)layoutAttributes;

@end
#endif


@interface MobiusoQuiltLayout ()
@property(nonatomic) CGPoint firstOpenSpace;
@property(nonatomic) CGPoint furthestBlockPoint;

// this will be a 2x2 dictionary storing nsindexpaths
// which indicate the available/filled spaces in our quilt
@property(nonatomic) NSMutableDictionary* indexPathByPosition;

// indexed by "section, row" this will serve as the rapid
// lookup of block position by indexpath.
@property(nonatomic) NSMutableDictionary* positionByIndexPath;

@property(nonatomic, assign) BOOL hasPositionsCached;

// previous layout cache.  this is to prevent choppiness
// when we scroll to the bottom of the screen - uicollectionview
// will repeatedly call layoutattributesforelementinrect on
// each scroll event.  pow!
@property(nonatomic) NSArray* previousLayoutAttributes;
@property(nonatomic) CGRect previousLayoutRect;

// remember the last indexpath placed, as to not
// relayout the same indexpaths while scrolling
@property(nonatomic) NSIndexPath* lastIndexPathPlaced;
@end


@implementation MobiusoQuiltLayout

- (id)init {
    if((self = [super init]))
        [self initialize];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder]))
        [self initialize];
    
    return self;
}

- (void) initialize {
    // defaults
    self.direction = UICollectionViewScrollDirectionVertical;
    self.blockPixels = CGSizeMake(100.f, 100.f);
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

- (CGSize) collectionViewContentSize {
    
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    CGRect contentRect = UIEdgeInsetsInsetRect(self.collectionView.frame, self.collectionView.contentInset);
    if (isVert) {
        return CGSizeMake(CGRectGetWidth(contentRect),
                          self.parallaxHeaderReferenceSize.height + (self.furthestBlockPoint.y+1) * self.blockPixels.height);
    } else {
        return CGSizeMake((self.furthestBlockPoint.x+1) * self.blockPixels.width, CGRectGetHeight(contentRect));
    }

}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (!self.delegate) return @[];
    
    // see the comment on these properties
    if(CGRectEqualToRect(rect, self.previousLayoutRect)) {
        return self.previousLayoutAttributes;
    }
    self.previousLayoutRect = rect;
    
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    // The rect should compensate the header size
    CGRect adjustedRect = rect;
    adjustedRect.origin.y -= self.parallaxHeaderReferenceSize.height;

    int unrestrictedDimensionStart = isVert? adjustedRect.origin.y / self.blockPixels.height : adjustedRect.origin.x / self.blockPixels.width;
    int unrestrictedDimensionLength = (isVert? adjustedRect.size.height / self.blockPixels.height : adjustedRect.size.width / self.blockPixels.width) + 1;
    int unrestrictedDimensionEnd = unrestrictedDimensionStart + unrestrictedDimensionLength;
    
    [self fillInBlocksToUnrestrictedRow:self.prelayoutEverything? INT_MAX : unrestrictedDimensionEnd];
    
    // find the indexPaths between those rows
    NSMutableSet* attributes = [NSMutableSet set];
    [self traverseTilesBetweenUnrestrictedDimension:unrestrictedDimensionStart and:unrestrictedDimensionEnd iterator:^(CGPoint point) {
        NSIndexPath* indexPath = [self indexPathForPosition:point];
        
        if(indexPath) [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        return YES;
    }];

    // Sticky Header attribute to be inserted
    BOOL visibleParallexHeader = (self.parallaxHeaderAlwaysOnTop == YES);
    if (visibleParallexHeader && (self.direction == UICollectionViewScrollDirectionVertical) && ! CGSizeEqualToSize(CGSizeZero, self.parallaxHeaderReferenceSize)) {
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
        
        
        [attributes addObject:currentAttribute];
    }
    
    return (self.previousLayoutAttributes = [attributes allObjects]);
}



- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if([self.delegate respondsToSelector:@selector(collectionView:layout:insetsForItemAtIndexPath:)])
        insets = [[self delegate] collectionView:[self collectionView] layout:self insetsForItemAtIndexPath:indexPath];
    
    
    CGRect frame = [self frameForIndexPath:indexPath];
    
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
#if STICKY_HEADER // Sticky Header
    frame.origin.y += self.parallaxHeaderReferenceSize.height;
#endif

    
    attributes.frame = UIEdgeInsetsInsetRect(frame, insets);
    return attributes;
}

// layout attributes for a specific header or footer
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];

    if (!attributes && [kind isEqualToString:GridLayoutHeaderStickyHeader]) {
        attributes = [MoShelfPlusStickyHeaderFlowLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
        
        attributes.zIndex = 1;

    }
    
    return attributes;
}

#else

// Original

- (CGSize)collectionViewContentSize {
    
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    CGRect contentRect = UIEdgeInsetsInsetRect(self.collectionView.frame, self.collectionView.contentInset);
    if (isVert) {
        return CGSizeMake(CGRectGetWidth(contentRect), (self.furthestBlockPoint.y+1) * self.blockPixels.height);
    } else {
        return CGSizeMake((self.furthestBlockPoint.x+1) * self.blockPixels.width, CGRectGetHeight(contentRect));
    }
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (!self.delegate) return @[];
    
    // see the comment on these properties
    if(CGRectEqualToRect(rect, self.previousLayoutRect)) {
        return self.previousLayoutAttributes;
    }
    self.previousLayoutRect = rect;
    
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    int unrestrictedDimensionStart = isVert? rect.origin.y / self.blockPixels.height : rect.origin.x / self.blockPixels.width;
    int unrestrictedDimensionLength = (isVert? rect.size.height / self.blockPixels.height : rect.size.width / self.blockPixels.width) + 1;
    int unrestrictedDimensionEnd = unrestrictedDimensionStart + unrestrictedDimensionLength;
    
    [self fillInBlocksToUnrestrictedRow:self.prelayoutEverything? INT_MAX : unrestrictedDimensionEnd];
    
    // find the indexPaths between those rows
    NSMutableSet* attributes = [NSMutableSet set];
    [self traverseTilesBetweenUnrestrictedDimension:unrestrictedDimensionStart and:unrestrictedDimensionEnd iterator:^(CGPoint point) {
        NSIndexPath* indexPath = [self indexPathForPosition:point];
        
        if(indexPath) [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        return YES;
    }];

    
    
    return (self.previousLayoutAttributes = [attributes allObjects]);
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if([self.delegate respondsToSelector:@selector(collectionView:layout:insetsForItemAtIndexPath:)])
        insets = [[self delegate] collectionView:[self collectionView] layout:self insetsForItemAtIndexPath:indexPath];
    
    
    CGRect frame = [self frameForIndexPath:indexPath];
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = UIEdgeInsetsInsetRect(frame, insets);
    return attributes;
}
#endif

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
#ifdef STICKY_HEADER
    return YES;
#else
    return !(CGSizeEqualToSize(newBounds.size, self.collectionView.frame.size));
#endif
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    for(UICollectionViewUpdateItem* item in updateItems) {
        if(item.updateAction == UICollectionUpdateActionInsert || item.updateAction == UICollectionUpdateActionMove) {
            [self fillInBlocksToIndexPath:item.indexPathAfterUpdate];
        }
    }
}

- (void) invalidateLayout {
    [super invalidateLayout];
    
    _furthestBlockPoint = CGPointZero;
    self.firstOpenSpace = CGPointZero;
    self.previousLayoutRect = CGRectZero;
    self.previousLayoutAttributes = nil;
    self.lastIndexPathPlaced = nil;
    [self clearPositions];
}

- (void) prepareLayout {
    [super prepareLayout];
    
    if (!self.delegate) return;
    
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    CGRect scrollFrame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    
    int unrestrictedRow = 0;
    if (isVert)
        unrestrictedRow = (CGRectGetMaxY(scrollFrame) / [self blockPixels].height)+1;
    else
        unrestrictedRow = (CGRectGetMaxX(scrollFrame) / [self blockPixels].width)+1;
    
    [self fillInBlocksToUnrestrictedRow:self.prelayoutEverything? INT_MAX : unrestrictedRow];
}

- (void) setDirection:(UICollectionViewScrollDirection)direction {
    _direction = direction;
    [self invalidateLayout];
}

- (void) setBlockPixels:(CGSize)size {
    _blockPixels = size;
    [self invalidateLayout];
}


#pragma mark private methods

- (void) fillInBlocksToUnrestrictedRow:(int)endRow {
    
    BOOL vert = self.direction == UICollectionViewScrollDirectionVertical;
    
    // we'll have our data structure as if we're planning
    // a vertical layout, then when we assign positions to
    // the items we'll invert the axis
    
    NSInteger numSections = [self.collectionView numberOfSections];
    for (NSInteger section=self.lastIndexPathPlaced.section; section<numSections; section++) {
        NSInteger numRows = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger row = (!self.lastIndexPathPlaced? 0 : self.lastIndexPathPlaced.row + 1); row<numRows; row++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            if([self placeBlockAtIndex:indexPath]) {
                self.lastIndexPathPlaced = indexPath;
            }
            
            // only jump out if we've already filled up every space up till the resticted row
            if((vert? self.firstOpenSpace.y : self.firstOpenSpace.x) >= endRow)
                return;
        }
    }
}

- (void) fillInBlocksToIndexPath:(NSIndexPath*)path {
    
    // we'll have our data structure as if we're planning
    // a vertical layout, then when we assign positions to
    // the items we'll invert the axis
    
    NSInteger numSections = [self.collectionView numberOfSections];
    for (NSInteger section=self.lastIndexPathPlaced.section; section<numSections; section++) {
        NSInteger numRows = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger row=(!self.lastIndexPathPlaced? 0 : self.lastIndexPathPlaced.row+1); row<numRows; row++) {
            
            // exit when we are past the desired row
            if(section >= path.section && row > path.row) { return; }
            
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            if([self placeBlockAtIndex:indexPath]) { self.lastIndexPathPlaced = indexPath; }
            
        }
    }
}

- (BOOL) placeBlockAtIndex:(NSIndexPath*)indexPath {
    CGSize blockSize = [self getBlockSizeForItemAtIndexPath:indexPath];
    BOOL vert = self.direction == UICollectionViewScrollDirectionVertical;
    
    
    return ![self traverseOpenTiles:^(CGPoint blockOrigin) {
        
        // we need to make sure each square in the desired
        // area is available before we can place the square
        
        BOOL didTraverseAllBlocks = [self traverseTilesForPoint:blockOrigin withSize:blockSize iterator:^(CGPoint point) {
            BOOL spaceAvailable = (BOOL)![self indexPathForPosition:point];
            BOOL inBounds = (vert? point.x : point.y) < [self restrictedDimensionBlockSize];
            BOOL maximumRestrictedBoundSize = (vert? blockOrigin.x : blockOrigin.y) == 0;
            
            if (spaceAvailable && maximumRestrictedBoundSize && !inBounds) {
                NSLog(@"%@: layout is not %@ enough for this piece size: %@! Adding anyway...", [self class], vert? @"wide" : @"tall", NSStringFromCGSize(blockSize));
                return YES;
            }
            
            return (BOOL) (spaceAvailable && inBounds);
        }];
        
        
        if (!didTraverseAllBlocks) { return YES; }
        
        // because we have determined that the space is all
        // available, lets fill it in as taken.
        
        [self setIndexPath:indexPath forPosition:blockOrigin];
        
        [self traverseTilesForPoint:blockOrigin withSize:blockSize iterator:^(CGPoint point) {
            [self setPosition:point forIndexPath:indexPath];
            
            self.furthestBlockPoint = point;
            
            return YES;
        }];
        
        return NO;
    }];
}

// returning no in the callback will
// terminate the iterations early
- (BOOL) traverseTilesBetweenUnrestrictedDimension:(int)begin and:(int)end iterator:(BOOL(^)(CGPoint))block {
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    // the double ;; is deliberate, the unrestricted dimension should iterate indefinitely
    for(int unrestrictedDimension = begin; unrestrictedDimension<end; unrestrictedDimension++) {
        for(int restrictedDimension = 0; restrictedDimension<[self restrictedDimensionBlockSize]; restrictedDimension++) {
            CGPoint point = CGPointMake(isVert? restrictedDimension : unrestrictedDimension, isVert? unrestrictedDimension : restrictedDimension);
            
            if(!block(point)) { return NO; }
        }
    }
    
    return YES;
}

// returning no in the callback will
// terminate the iterations early
- (BOOL) traverseTilesForPoint:(CGPoint)point withSize:(CGSize)size iterator:(BOOL(^)(CGPoint))block {
    for(int col=point.x; col<point.x+size.width; col++) {
        for (int row=point.y; row<point.y+size.height; row++) {
            if(!block(CGPointMake(col, row))) {
                return NO;
            }
        }
    }
    return YES;
}

// returning no in the callback will
// terminate the iterations early
- (BOOL) traverseOpenTiles:(BOOL(^)(CGPoint))block {
    BOOL allTakenBefore = YES;
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    // the double ;; is deliberate, the unrestricted dimension should iterate indefinitely
    for(int unrestrictedDimension = (isVert? self.firstOpenSpace.y : self.firstOpenSpace.x);; unrestrictedDimension++) {
        for(int restrictedDimension = 0; restrictedDimension<[self restrictedDimensionBlockSize]; restrictedDimension++) {
            
            CGPoint point = CGPointMake(isVert? restrictedDimension : unrestrictedDimension, isVert? unrestrictedDimension : restrictedDimension);
            
            if([self indexPathForPosition:point]) { continue; }
            
            if(allTakenBefore) {
                self.firstOpenSpace = point;
                allTakenBefore = NO;
            }
            
            if(!block(point)) {
                return NO;
            }
        }
    }
    
    NSAssert(0, @"Could find no good place for a block!");
    return YES;
}

- (void) clearPositions {
    self.indexPathByPosition = [NSMutableDictionary dictionary];
    self.positionByIndexPath = [NSMutableDictionary dictionary];
}

- (NSIndexPath*)indexPathForPosition:(CGPoint)point {
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    // to avoid creating unbounded nsmutabledictionaries we should
    // have the innerdict be the unrestricted dimension
    
    NSNumber* unrestrictedPoint = @(isVert? point.y : point.x);
    NSNumber* restrictedPoint = @(isVert? point.x : point.y);
    
    return self.indexPathByPosition[restrictedPoint][unrestrictedPoint];
}

- (void) setPosition:(CGPoint)point forIndexPath:(NSIndexPath*)indexPath {
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    // to avoid creating unbounded nsmutabledictionaries we should
    // have the innerdict be the unrestricted dimension
    
    NSNumber* unrestrictedPoint = @(isVert? point.y : point.x);
    NSNumber* restrictedPoint = @(isVert? point.x : point.y);
    
    NSMutableDictionary* innerDict = self.indexPathByPosition[restrictedPoint];
    if (!innerDict)
        self.indexPathByPosition[restrictedPoint] = [NSMutableDictionary dictionary];
    
    self.indexPathByPosition[restrictedPoint][unrestrictedPoint] = indexPath;
}


- (void) setIndexPath:(NSIndexPath*)path forPosition:(CGPoint)point {
    NSMutableDictionary* innerDict = self.positionByIndexPath[@(path.section)];
    if (!innerDict) self.positionByIndexPath[@(path.section)] = [NSMutableDictionary dictionary];
    
    self.positionByIndexPath[@(path.section)][@(path.row)] = [NSValue valueWithCGPoint:point];
}

- (CGPoint) positionForIndexPath:(NSIndexPath*)path {
    
    // if item does not have a position, we will make one!
    if(!self.positionByIndexPath[@(path.section)][@(path.row)])
        [self fillInBlocksToIndexPath:path];
    
    return [self.positionByIndexPath[@(path.section)][@(path.row)] CGPointValue];
}


- (CGRect) frameForIndexPath:(NSIndexPath*)path {
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    CGPoint position = [self positionForIndexPath:path];
    CGSize elementSize = [self getBlockSizeForItemAtIndexPath:path];
    
    CGRect contentRect = UIEdgeInsetsInsetRect(self.collectionView.frame, self.collectionView.contentInset);
    if (isVert) {
        float initialPaddingForContraintedDimension = (CGRectGetWidth(contentRect) - [self restrictedDimensionBlockSize]*self.blockPixels.width)/ 2;
        return CGRectMake(position.x*self.blockPixels.width + initialPaddingForContraintedDimension,
                          position.y*self.blockPixels.height,
                          elementSize.width*self.blockPixels.width,
                          elementSize.height*self.blockPixels.height);
    } else {
        float initialPaddingForContraintedDimension = (CGRectGetHeight(contentRect) - [self restrictedDimensionBlockSize]*self.blockPixels.height)/ 2;
        return CGRectMake(position.x*self.blockPixels.width,
                          position.y*self.blockPixels.height + initialPaddingForContraintedDimension,
                          elementSize.width*self.blockPixels.width,
                          elementSize.height*self.blockPixels.height);
    }
}


//This method is prefixed with get because it may return its value indirectly
- (CGSize)getBlockSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize blockSize = CGSizeMake(1, 1);
    if([self.delegate respondsToSelector:@selector(collectionView:layout:blockSizeForItemAtIndexPath:)])
        blockSize = [[self delegate] collectionView:[self collectionView] layout:self blockSizeForItemAtIndexPath:indexPath];
    return blockSize;
}


// this will return the maximum width or height the quilt
// layout can take, depending on we're growing horizontally
// or vertically

- (int) restrictedDimensionBlockSize {
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    CGRect contentRect = UIEdgeInsetsInsetRect(self.collectionView.frame, self.collectionView.contentInset);
    int size = isVert? CGRectGetWidth(contentRect) / self.blockPixels.width : CGRectGetHeight(contentRect) / self.blockPixels.height;
    
    if(size == 0) {
        static BOOL didShowMessage;
        if(!didShowMessage) {
            NSLog(@"%@: cannot fit block of size: %@ in content rect %@!  Defaulting to 1", [self class], NSStringFromCGSize(self.blockPixels), NSStringFromCGRect(contentRect));
            didShowMessage = YES;
        }
        return 1;
    }
    
    return size;
}

- (void) setFurthestBlockPoint:(CGPoint)point {
    _furthestBlockPoint = CGPointMake(MAX(self.furthestBlockPoint.x, point.x), MAX(self.furthestBlockPoint.y, point.y));
}

@end
