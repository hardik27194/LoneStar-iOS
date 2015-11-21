
#import <UIKit/UIKit.h>
#import "TextView.h"
#import "HRColorMapView.h"

typedef struct HRColorPickerStyle HRColorPickerStyle;

@protocol HRColorMapView;
@protocol HRBrightnessSlider;
@protocol HRColorInfoView;

@interface HRColorPickerView : UIControl <HRColorMapViewDelegate>

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) IBOutlet UIView <HRColorInfoView> *colorInfoView;
@property (nonatomic, strong) IBOutlet UIControl <HRColorMapView> *colorMapView;
@property (nonatomic, strong) IBOutlet UIControl <HRBrightnessSlider> *brightnessSlider;
@property (nonatomic, retain) IBOutlet UILabel  *sampleTextLabel;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;

@property (nonatomic, retain) TextView *activeTextView;

- (void) touchesBegan;
- (void) touchesEnded;

@end
