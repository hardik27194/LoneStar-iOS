//
//  PhotoCell.h
//  
//
//  Created by Sandeep Shah on 01/04/2015.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "MoArcMenu.h"

@class PhotoObject;
@class MoRippleTap;

@interface PhotoCell : UICollectionViewCell

@property (strong, nonatomic) PhotoObject           *item;

@property (strong, nonatomic) IBOutlet UIImageView  *imageView;
@property (strong, nonatomic) IBOutlet UIView       *shimView;

@property (strong, nonatomic) IBOutlet UILabel      *fileNameLabel;
@property (strong, nonatomic) IBOutlet UILabel      *fileSizeLabel;

@property (strong, nonatomic) IBOutlet UIButton     *infoButton;

@property (strong, nonatomic) IBOutlet MoRippleTap  *markButton;

@property (strong, nonatomic) IBOutlet MoRippleTap  *selectButton;


@property (strong, nonatomic) IBOutlet UIView       *menu;

//@property (strong, nonatomic) IBOutlet UISwitch *customSwitch;

@end
