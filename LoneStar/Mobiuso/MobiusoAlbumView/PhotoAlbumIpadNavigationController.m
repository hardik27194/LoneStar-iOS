//
//  AlbumsiPadViewController.m
//  
//
//  Created by Sandeep Shah on 01/04/2015.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PhotoAlbumIpadNavigationController.h"
//#import "FolderDetailViewController.h"

#import "AppDelegate.h"
// #import "DataLoader.h"
#import "PhotoObject.h"
#import "PhotoCell.h"

// #import "ADVTheme.h"



typedef enum {
    LayoutVersion1 = 1,
    LayoutVersion2,
    LayoutVersion3,
    LayoutVersionCount
} LayoutVersion;



@interface PhotoAlbumIpadNavigationController ()

@property (nonatomic, strong) PhotoObject *currentItem;
@property (nonatomic, assign) NSInteger  layoutType;


@end




@implementation PhotoAlbumIpadNavigationController

@dynamic collectionView;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.title = @"Issues";
    
    
    UIButton *layoutButton = [[UIButton alloc] initWithFrame:(CGRect){0,0,40,30}];
    [layoutButton setImage:[UIImage imageNamed:@"navigation-item-right"] forState:UIControlStateNormal];
    [layoutButton addTarget:self action:@selector(switchLayout:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *layoutButtonItem = [[UIBarButtonItem alloc] initWithCustomView:layoutButton];
    self.navigationItem.rightBarButtonItem = layoutButtonItem;
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self switchLayout:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    id<ADVTheme> theme = [ADVThemeManager sharedTheme];
    [self arrangeCollectionView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}


- (void)arrangeCollectionView {
    CGFloat width = 340;
    NSInteger colCount = 2;
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(20, 40, 20, 40);
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        width = 320;
        colCount = 3;
        sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    }
//    RFQuiltLayout *layout = (RFQuiltLayout *)self.collectionView.collectionViewLayout;
    [self.collectionView reloadData];
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self arrangeCollectionView];
}




#pragma mark - Visual stuff


- (void)loadDataIntoView:(NSArray *)items {
    
    [self.collectionView reloadData];
}

#pragma mark - Actions

- (void)actionShowElem:(id)sender {
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"]; // @"ElemNav"
    nav.transitioningDelegate = self;
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)switchLayout:(id)sender {
    _layoutType++;
    if (_layoutType == LayoutVersionCount) {
        _layoutType = LayoutVersion1;
    }
    
    MobiusoQuiltLayout* layout = (id)self.collectionView.collectionViewLayout;
    layout.direction = UICollectionViewScrollDirectionVertical;
    
    switch (_layoutType) {
        case LayoutVersion1:
            // [ADVThemeManager customizeView:self.view];
            layout.blockPixels = CGSizeMake(488, 508);
            break;
        case LayoutVersion2:
            // [ADVThemeManager customizeView:self.view];
            layout.blockPixels = CGSizeMake(216, 226);
            break;
        case LayoutVersion3:
            // [ADVThemeManager customizePatternView:self.view];
            layout.blockPixels = CGSizeMake(209, 218);
            break;
    }
    
    // self.items = [DataLoader layoutForVersion:_layoutType];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Datasource
#ifdef NOTNOW
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier;
    switch (_layoutType) {
        case LayoutVersion1:
            CellIdentifier = @"IssueCell";
            break;
        case LayoutVersion2:
            if (indexPath.row == 0) {
                CellIdentifier = @"XLargeIssueCell";
            } else {
                CellIdentifier = @"SmallIssueCell";
            }
            break;
        case LayoutVersion3:
            if (indexPath.row == 0 || indexPath.row == 4) {
                CellIdentifier = @"LargeIssueCell";
            } else {
                CellIdentifier = @"CondIssueCell";
            }
            break;
        default:
            break;
    }
    
    IssueCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    IssueItem *item = self.items[indexPath.row];
    
    cell.item = item;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //_currentItem = _items[indexPath.row];
    //[self performSegueWithIdentifier:@"showDetail" sender:self];
}
#endif


#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (_layoutType) {
        case LayoutVersion1: {
            return CGSizeMake(1, 1);
            break;
        }
        case LayoutVersion2: {
            if (indexPath.row == 0) {
                return CGSizeMake(4, 2);
            }
            return CGSizeMake(1, 1);
            break;
        }
        case LayoutVersion3: {
            if (indexPath.row == 0 || indexPath.row == 4) {
                return CGSizeMake(2, 2);
            }
            return CGSizeMake(1, 1);
            break;
        }
        default:
            return CGSizeMake(1, 1);
            break;
    }
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (_layoutType) {
        case LayoutVersion2: {
            return UIEdgeInsetsMake(8, 8, 8, 8);
            break;
        }
        case LayoutVersion3: {
            return UIEdgeInsetsMake(5, 5, 5, 5);
            break;
        }
        default:
            return UIEdgeInsetsMake(12, 12, 12, 12);
            break;
    }
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"showDetail"]) {
//        FolderDetailViewController *controller = segue.destinationViewController;
        
//        controller.item = _currentItem;
//    }
}


@end
