//
//  StacksLayout.h
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StacksLayout : UICollectionViewLayout

@property (nonatomic, assign) NSInteger pinchedStackIndex;
@property (nonatomic, assign) CGFloat pinchedStackScale;
@property (nonatomic, assign) CGPoint pinchedStackCenter;
@property (nonatomic, assign, getter = isCollapsing) BOOL collapsing;

@end

