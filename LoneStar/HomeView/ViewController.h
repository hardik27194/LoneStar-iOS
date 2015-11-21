//
//  ViewController.h
//  LoneStar
//
//  Created by sandeep on 10/30/15.
//  Copyright © 2015 Medpresso. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookPortalView;

@interface ViewController : UIViewController

@property (nonatomic, retain) UIGestureRecognizer *recognizer;
@property (strong, nonatomic) IBOutlet BookPortalView *ipv;

@end

