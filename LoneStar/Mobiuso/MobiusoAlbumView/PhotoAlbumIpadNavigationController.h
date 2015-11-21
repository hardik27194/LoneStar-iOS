//
//  PhotoAlbumIPadViewController.h
//
//
//  Created by Sandeep Shah on 01/04/2015.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobiusoQuiltLayout.h"
#import "PhotoAlbumNavigationController.h"

@interface PhotoAlbumIpadNavigationController : PhotoAlbumNavigationController

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic, strong) NSArray* photosEtc;


@end