//
//  MoWelcomeViewController.h
//  Mobiuso
//
//

#import <UIKit/UIKit.h>
#import "PagedScrollView.h"

#define kWelcomeDefaultHasRunFlowKeyName       @"SettingWelcomeDefaultHasRunFlow"

@interface MoWelcomeViewController : UIViewController <PagedScrollViewDelegate, UIGestureRecognizerDelegate>
@property IBOutlet PagedScrollView *pageScrollView;
@property (nonatomic, retain) UIView *welcomeScreen;
@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, retain) UIButton *skipButton;
@property (nonatomic, assign) NSInteger imagesCount;

+ (BOOL) shouldRunWelcomeFlow;
+ (void) setShouldRunWelcomeFlow:(BOOL)should;

@end
