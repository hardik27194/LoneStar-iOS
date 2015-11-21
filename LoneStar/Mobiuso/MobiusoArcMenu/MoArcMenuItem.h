//
//  MoArcMenuItem.h
//  MoArcMenu
//
//  Created by sandeep on 01/10/13.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//
//  Updated 20150921
//

#import <UIKit/UIKit.h>
#import "MobiusoToast.h"

@protocol MoArcMenuItemDelegate;

@interface MoArcMenuItem : UIImageView

@property (nonatomic, retain) UIImageView *contentImageView;

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint nearPoint;
@property (nonatomic) CGPoint farPoint;
@property (nonatomic, retain) UIColor *anchorColor;
@property (nonatomic, retain) NSString *hint;
@property (nonatomic, assign) CGFloat buttonDiameter;

@property (nonatomic, assign) id<MoArcMenuItemDelegate> delegate;

- (id)initWithImage:(UIImage *) img     // background of the menu item
   highlightedImage:(UIImage *) himg    // in the background when highlighted
       ContentImage:(UIImage *) cimg    // Real Image to be seen
highlightedContentImage:(UIImage *) hcimg   // highlighted version
        anchorColor: (UIColor *) color;

- (id)  initWithImage:(UIImage *)img
     highlightedImage:(UIImage *)himg
         ContentImage:(UIImage *)cimg
highlightedContentImage:(UIImage *)hcimg
          anchorColor: (UIColor *) color
             diameter: (CGFloat) diameter;

- (void) setHighlighted:(BOOL)highlighted;

@end

@protocol MoArcMenuItemDelegate <NSObject>
- (void)MoArcMenuItemTouchesBegan:(MoArcMenuItem *)item;
- (void)MoArcMenuItemTouchesEnd:(MoArcMenuItem *)item;
@end