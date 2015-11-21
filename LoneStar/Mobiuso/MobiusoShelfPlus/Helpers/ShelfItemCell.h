//
//  ShelfItemCell.h
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoRippleTap.h"
#import "MoShelfPlusDataSource.h"


@interface ShelfItemCell : UICollectionViewCell <MoShelfPlusSelectionDelegate>

@property (nonatomic, copy) NSString *moduleName;
@property (weak, nonatomic) IBOutlet UIColor *moduleColor;

@property (retain, nonatomic) IBOutlet UIImageView *overlayImageView;
@property (retain, nonatomic) IBOutlet UIImageView *reminderImageView;
@property (strong, nonatomic) UIImage *overlayImage;

@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *moduleTitle;
@property (weak, nonatomic) IBOutlet UIImageView *moduleImage;
@property (weak, nonatomic) IBOutlet UIImageView *moduleBorderImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (retain, nonatomic) id itemReference;
@property (retain, nonatomic) MoRippleTap *selectButton;
@end
