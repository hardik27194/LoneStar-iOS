//
//  CocoaConf.m
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "MoShelfPlusDataSource.h"
#import "ModuleType.h"
#import "ShelfItemCell.h"
#import "ModuleTypeHeader.h"
#import "StarRatingFooter.h"
#import "NSDate+Helpers.h"
#import "NSDate+Compare.h"
#import "Theme.h"
#import "UIImage+RemapColor.h"
#import "LightBoxManager.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "GridLayout.h"
#import "MoShelfPlusStickyHeader.h"
#import "MoShelfPlusViewController.h"
#import "MobiusoToast.h"
#import "MoProgressView.h"
#import "HomeVC.h"

@interface MoShelfPlusDataSource()
{
    NSTimer *searchToFireTimer;
    BOOL    autoSearch;
}

@property (nonatomic, strong) UIImage                   *iconWhite;
@property  (nonatomic, retain) MoShelfPlusStickyHeader  *stickyHeaderCell;



@end

static id allModules;

@implementation MoShelfPlusDataSource

- (id)initWithShelfItemsBySections:(NSArray *)arrayOfSectionDictionary
{
    self = [super init];
    if (self)
    {
        _shelfItemsBySections = arrayOfSectionDictionary;
        _title = @"Default Title";
        _filteredIndexArray = nil;
        // do the following to avoid remapping for every cell... not necessary right now
//        _iconWhite = [UIImage RemapColor:[UIColor whiteColor] maskImage:[UIImage imageNamed:@"camera.png"]];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return (_filteredIndexArray? 1 : [self.shelfItemsBySections count]);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section < 0 || section >= self.shelfItemsBySections.count)
        return 0;
    
    return (_filteredIndexArray? [_filteredIndexArray count] : [[self.shelfItemsBySections[section] shelfItems] count]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShelfItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kShelfItemCellID forIndexPath:indexPath];
    
    NSInteger section, row;
    if (_filteredIndexArray) {
        assert(indexPath.section == 0);
        NSUInteger codedIndex = [_filteredIndexArray[indexPath.row] integerValue];
        section = codedIndex >> 12;
        row = codedIndex & 0xfff;
    } else {
        section = indexPath.section;
        row = indexPath.row;
    }
    
    // Color will be set based on the image
    cell.moduleColor = [Theme colorForIndex:section];
    
    NSDictionary *moduleInfo = [self.shelfItemsBySections[section] shelfItems][row];
    
    SnapType imageType = (SnapType)[[moduleInfo objectForKey:@"type"] integerValue];
    NSString *imgName = @"library";
    switch (imageType) {
        case SnapCamera:
            imgName = @"camera";
            break;
            
        case SnapSnaptica:
            imgName = @"drawer";    // later on change this to small Snaptica Icon
            break;
            
        default:
            break;
    }
    cell.overlayImage = [UIImage imageNamed:imgName];
    cell.moduleName = [moduleInfo objectForKey:@"name"];
    cell.authorLabel.text = [moduleInfo objectForKey:@"author"];
    cell.moduleTitle.text = [moduleInfo objectForKey:@"title"];
    UIImage *img = [moduleInfo objectForKey:@"image"];
    if (!img) {
        img = [LightBoxManager loadImage:moduleInfo];
    }
    MLog(@">>>>Img size: %@", [HomeVC displayMemory: CGImageGetHeight(img.CGImage) * CGImageGetBytesPerRow(img.CGImage)]);
    cell.moduleImage.image = img;
    cell.moduleImage.clipsToBounds = YES;
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;


    // Check the kind if it's GridLayoutHeaderParallaxHeader
    if ([kind isEqualToString:GridLayoutHeaderStickyHeader]) {
        
        MoShelfPlusStickyHeader *cell = (MoShelfPlusStickyHeader *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"header"
                                                                                                     forIndexPath:indexPath]; // Was UICollectionReusableView
        
        cell.titleLabel.text = _title;
        NSUInteger count = (self.filteredIndexArray? 1 : [_shelfItemsBySections count]);
        NSUInteger itemCount = self.filteredIndexArray? [_filteredIndexArray count] : [self count];
        cell.supplementaryInfoLabel2.text = cell.supplementaryInfoLabel.text = (count>1)?[NSString stringWithFormat:@"%ld items [%ld sections]", (unsigned long)itemCount, (unsigned long)count] :
        [NSString stringWithFormat:@"%ld items%@", (unsigned long)itemCount, (self.filteredIndexArray ? @" (Clear)" : @"")];
        UITapGestureRecognizer* clearTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(tappedOnClearSearchLabel:)];
        UITapGestureRecognizer* clearTap2 = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(tappedOnClearSearchLabel:)];
        clearTap.numberOfTapsRequired = 1;
        if (self.filteredIndexArray) {
            cell.supplementaryInfoLabel.layer.borderWidth = cell.supplementaryInfoLabel2.layer.borderWidth = 1.0f;
            [cell.supplementaryInfoLabel2 addGestureRecognizer:clearTap2];
            [cell.supplementaryInfoLabel addGestureRecognizer:clearTap];
        } else {
            cell.supplementaryInfoLabel.layer.borderWidth = cell.supplementaryInfoLabel2.layer.borderWidth = 0.0;
            [cell.supplementaryInfoLabel2 removeGestureRecognizer:clearTap2];
            [cell.supplementaryInfoLabel removeGestureRecognizer:clearTap];
        }
        
        if (self.viewController) {
            cell.delegate = (UIViewController <MoShelfPlusStickyHeaderDelegate> *)self.viewController;
            if ([(NSObject <MoShelfPlusDataSourceDelegate> *)self.viewController respondsToSelector: @selector(dataSources)] &&
                [(NSObject <MoShelfPlusDataSourceDelegate> *)self.viewController respondsToSelector: @selector(setSwitchControl:)])
            {
                
                [(NSObject <MoShelfPlusDataSourceDelegate> *)self.viewController setSwitchControl:cell.selectorControl];
                
            }
            cell.searchBar.delegate = self;
        }
        [cell.selectorButton setTitle:self.shortTitle forState:UIControlStateNormal];
        
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(tappedOnStickyHeader:)];
        singleTap.numberOfTapsRequired = 1;
        [cell addGestureRecognizer:singleTap];
        autoSearch = NO;
        _stickyHeaderCell = cell;
        return cell;
        
    } else

        if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        StarRatingFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kStarRatingFooterID forIndexPath:indexPath];
        return footer;
    }
    
    BOOL isSmall = [kind isEqualToString:[SmallModuleTypeHeader kind]];
    ModuleTypeHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:isSmall? kShelfSectionHeaderSmallID : kShelfSectionHeaderID forIndexPath:indexPath];
    
    if (_filteredIndexArray) {
        [header setConference:@"Search Results"];
    } else {
        ModuleType *m = self.shelfItemsBySections[section];
        [header setConference: m.name];
    }
    
#ifdef SHELFPLUS_DEBUG
    BOOL isHeader = [kind isEqualToString:[MoShelfPlusStickyHeader kind]];
    if (isHeader) {
        DLog(@"Header encountered");
    }
#endif
    
    return header;
}

#pragma mark - SearchBar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar     // called when keyboard search button pressed
{
    if (searchToFireTimer) {
        [searchToFireTimer invalidate];
        searchToFireTimer = nil;
    }
    NSString *textFilterString = [searchBar text];
#ifdef SEARCH_DEBUG
    DLog(@"Search start - %@", textFilterString);
    [MobiusoToast toast: @"Searching" inView: self.viewController.view];
#endif
    

    __block MoProgressView *hud = [[MoProgressView alloc] initWithView:self.viewController.view];
    [self.viewController.view addSubview:hud];
    [hud show:TRUE];

    if (!autoSearch) {
        [_stickyHeaderCell.searchBar resignFirstResponder];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
#ifdef SIMULATE_DELAY
        [NSThread sleepForTimeInterval:15.0f];
#endif
       
        // Go through the items and short list it..
        _filteredIndexArray = [[NSMutableArray alloc] init];
        BOOL found = NO;
        NSUInteger section=0;
        for (ModuleType *module in _shelfItemsBySections) {
            if (IS_SUBSTRING(module.name, textFilterString)) {
                
                found = YES;
            } else {
                found = NO;
            }
            NSUInteger row = 0;
            for (NSDictionary *item in module.shelfItems) {
                BOOL doit=found;
                if (!found) {
                    for (id key in item) {
                        id element = [item objectForKey:key];
                        if ([element isKindOfClass: [NSString class]]) {
                            NSString *elementStr = (NSString *) element;
                            if (IS_SUBSTRING(elementStr, textFilterString) ) {
                                doit = YES;
                                break;
                            }
                        }
                    }
                }
                if (doit) {
                    [_filteredIndexArray addObject: [NSNumber numberWithInteger:((section << 12) | (row & 0xfff))] ];
                }
                row++;
            }
            section++;
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.viewController reload];
            [hud hide:NO];
            [hud removeFromSuperview];
        });
    });
    


}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar     // called when cancel button pressed
{
#ifdef SEARCH_DEBUG
    DLog(@"Search Cancelled");
#endif
    _filteredIndexArray = nil;
    [_stickyHeaderCell.searchBar resignFirstResponder];

}

- (void)searchBar:(UISearchBar *)searchBar  textDidChange:(NSString *)searchText
{
#ifdef SEARCH_DEBUG
    DLog(@"Search text: %@", searchText);
#endif
    if (searchToFireTimer) {
        [searchToFireTimer invalidate];
    }
    // Put a delay of 3 seconds
    // Fire IAP timer
    searchToFireTimer = [NSTimer scheduledTimerWithTimeInterval:3.0  target:self selector:@selector(searchToFire:)  userInfo:nil repeats:NO];
    
}

- (void) searchToFire: (NSTimer *) timer
{
    autoSearch = YES;
    if ((!_stickyHeaderCell.searchBar.text) || (_stickyHeaderCell.searchBar.text.length == 0)) return;
    [self searchBarSearchButtonClicked: _stickyHeaderCell.searchBar];
    searchToFireTimer = nil;
}
- (void) tappedOnStickyHeader: (id) sender
{
    [_stickyHeaderCell.searchBar resignFirstResponder];
    autoSearch = NO;
}

- (void) tappedOnClearSearchLabel: (id) sender
{
    [_stickyHeaderCell.searchBar resignFirstResponder];
    _filteredIndexArray = nil;
    _stickyHeaderCell.searchBar.text = @"";
    [self.viewController reload];
    
}

#ifdef NOTNOW
#pragma mark - Segment View Delegate
- (void) segmentValueChanged: (ADVSegmentedControl *) sender
{
    DLog(@"Segment Value: %ld", (long) [sender selectedIndex]);
    if (self.viewController) {
        if ([(MoShelfPlusViewController *)self.viewController respondsToSelector: @selector(setupDataSourceAtIndex:)])
        {
            [(MoShelfPlusViewController *)self.viewController setupDataSourceAtIndex:[sender selectedIndex]];
        }
    }
    
}
#endif

// Get Module Details - r
- (NSDictionary *) itemAtIndexPath: (NSIndexPath *) indexPath
{
    // Here we decode the indexPath if needed
    NSInteger section, row;
    if (_filteredIndexArray) {
        assert(indexPath.section == 0);
        NSUInteger codedIndex = [_filteredIndexArray[indexPath.row] integerValue];
        section = codedIndex >> 12;
        row = codedIndex & 0xfff;
    } else {
        section = indexPath.section;
        row = indexPath.row;
    }
    
    return [_shelfItemsBySections[section] shelfItems][row];
}

// Remapped Index if search is active
- (NSDictionary *) itemAtSection: (NSUInteger) section andRow: (NSUInteger) row
{
    return [_shelfItemsBySections[section] shelfItems][row];
}

- (void) replaceItemAtIndexPath: (NSIndexPath *) indexPath withObject: (NSDictionary *) item
{
    [[_shelfItemsBySections[indexPath.section] shelfItems] replaceObjectAtIndex:indexPath.item withObject:item];
}


- (void) refresh
{
    
}

#pragma mark - Private Class Methods


+ (ModuleType *)shared
{
    return [ModuleType moduleWithName:@"Shared Modules" publicationDate:[NSDate dateWithYear:2013 month:3 day:21] author:3 modules:@[]];
}

+ (ModuleType *)downloaded
{
    
//    NSArray *filteredArray = [ContentManager modulesForUser:(isAnonymous?nil:userId) ofType: ModuleTypeDownloaded];
    return [ModuleType moduleWithName:@"Downloaded" publicationDate:[NSDate dateWithYear:2013 month:4 day:4] author:3 modules:@[@{ @"name":@"One"}, @{ @"name":@"Two"}, @{ @"name":@"three"}]];
}

+ (ModuleType *)builtin
{
//    NSArray *filteredArray = [ContentManager modulesForUser:nil ofType: ModuleTypeBuiltIn];
    return [ModuleType moduleWithName:@"Recently Added" publicationDate:[NSDate dateWithYear:2013 month:4 day:21] author:3 modules: @[@{ @"name":@"One"}, @{ @"name":@"Two"}, @{ @"name":@"three"}]];
}

+ (NSArray *) names: (NSArray *) arrayOfDictItems
{
    __block NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    [arrayOfDictItems enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            [filteredArray addObject:[item objectForKey:@"name"]];
    }];
    return filteredArray;
}

#pragma mark - Class Methods

+ (instancetype)combined
{
    static dispatch_once_t once;
    static id combinedCocoaConfs;
    dispatch_once(&once, ^{
        combinedCocoaConfs = [[self alloc] initWithShelfItemsBySections:@[[ModuleType moduleWithName:@"MoShelfPlusDataSource" publicationDate:[NSDate dateWithYear:2011 month:8 day:11] author:3 modules:@[@"Module 1", @"Module 2", @"Module 3", @"Module 4"]]]];
    });
    
    return combinedCocoaConfs;
}

+ (instancetype)all
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        allModules = [[self alloc] initWithShelfItemsBySections:@[[self builtin] , [self downloaded] , [self shared] ]];
    });
    
    return allModules;
}

+ (instancetype) instance
{
    if (allModules == nil) {
        [self all];
    }
    return allModules;
}

+ (void) purge
{
    allModules = nil;
    
}

- (NSInteger) count
{
    NSInteger mcount = 0;
    for (ModuleType *mt in self.shelfItemsBySections) {
        mcount += [mt.shelfItems count];
    }
    return mcount;
}

+ (instancetype)currentModuleType
{
    static dispatch_once_t once;
    static id current;
    dispatch_once(&once, ^{
        current = [[self alloc] initWithShelfItemsBySections:@[[self shared]]];
    });
    
    return current;
}

// Alow other ways to sort (recent is not current functional)
+ (instancetype)recent
{
    static dispatch_once_t once;
    static id recentCocoaConfs;
    dispatch_once(&once, ^{
        recentCocoaConfs = [[self alloc] initWithShelfItemsBySections:@[[self shared], [self downloaded]]];
    });
    
    return recentCocoaConfs;
}


+ (NSString *)smallHeaderReuseID
{
    return kShelfSectionHeaderSmallID;
}

- (BOOL)deleteModuleAtPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < 0 || indexPath.section >= self.shelfItemsBySections.count)
        return NO;

    ModuleType* conference = self.shelfItemsBySections[indexPath.section];
    return [conference deleteSpeakerAtIndex:indexPath.item];
}

- (BOOL)restoreModuleInSection:(int)section
{
    if (section < 0 || section >= self.shelfItemsBySections.count)
        return NO;
    
    ModuleType* conference = self.shelfItemsBySections[section];
    return [conference restoreSpeaker];
}


@end
