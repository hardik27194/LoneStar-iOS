//
//  SplashTransition
//  Snaptica Pro
//
//  Created by Sandeep on 6/16/2015.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashTransitionViewController : UIViewController <UIGestureRecognizerDelegate>

+ (void)addHorizontalTilt:(CGFloat)x verticalTilt:(CGFloat)y ToView:(UIView *)view;

// Push or Pop (if pushed on the stack, we want to vanish)
@property (nonatomic, retain) UIViewController *nextController;
@property (nonatomic, assign) CGFloat           splashDuration;

@property (nonatomic, retain) IBOutlet UIImageView           *signatureImageView;
@property (retain, nonatomic) IBOutlet UILabel               *aboutTitle;
@property (nonatomic, retain) NSString                        *moreInformation;



@end
