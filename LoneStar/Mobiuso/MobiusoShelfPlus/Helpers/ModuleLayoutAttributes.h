//
//  ConferenceLayoutAttributes.h
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModuleLayoutAttributes : UICollectionViewLayoutAttributes

// whether header view (ModuleTypeHeader class) should align label left or center (default = left)
@property (nonatomic, assign) NSTextAlignment headerTextAlignment;

// shadow opacity for the shadow on the Picture in ShelfItemCell (default = 0.5)
@property (nonatomic, assign) CGFloat shadowOpacity;

@end
