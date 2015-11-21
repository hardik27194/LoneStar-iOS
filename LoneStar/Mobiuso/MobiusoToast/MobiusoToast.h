//
//  MobiusoToast.h
//
//

#define MoToastMessageShortDuration     1.0
#define MoToastMessageDefaultDuration   2.0
#define MoToastMessageLongDuration      3.0

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "NSString+StringSizeWithFont.h"


@interface MobiusoToast : UIView
{
    UILabel *_label;
}

@property (assign) CGFloat  duration;
@property (copy)   NSString *text;

+ (void)toast:      (NSString *)aString;
+ (void)toast:      (NSString *)aString inView:  (UIView *)view;
+ (void)toast:  (NSString *)aString  forDuration: (CGFloat)aDuration;
+ (void)toast:  (NSString *)aString  inView: (UIView *)view forDuration: (CGFloat)aDuration;

//- (id)initWithText:         (NSString *)aString;
- (id)initWithDuration:     (CGFloat)aDuration  andText: (NSString *)aString;

- (void)display;
- (void)displayInView:      (UIView *)view;
- (void)displayInView:(UIView *)view atCenter: (CGPoint) point;
- (void) setLabel:(NSString *)text;

@end
