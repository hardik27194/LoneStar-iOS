//
//  MoArcBackground.h
//  
//
//  Created by sandeep on 1/13/13.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoArcBackground : UIView

@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, retain) UIColor *anchorColor;
@property (nonatomic, retain) UIBezierPath* aPath;
@property (nonatomic, retain) UIBezierPath* bPath;
@property (nonatomic, assign) CGFloat repeatCount;

- (void) loadView: (CGFloat) start spanAngle: (CGFloat) span;

@end
