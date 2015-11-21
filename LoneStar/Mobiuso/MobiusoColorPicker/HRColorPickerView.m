

#import "HRColorPickerView.h"
#import <sys/time.h>
#import "HRColorMapView.h"
#import "HRBrightnessSlider.h"
#import "HRColorInfoView.h"
#import "HRHSVColorUtil.h"

typedef struct timeval timeval;

@interface HRColorPickerView () {
    BOOL adjustedPositions;
}

@end

@implementation HRColorPickerView {
    UIView <HRColorInfoView> *_colorInfoView;
    UIControl <HRColorMapView> *_colorMapView;
    UIControl <HRBrightnessSlider> *_brightnessSlider;

    HRHSVColor _currentHsvColor;

    timeval _lastDrawTime;
    timeval _waitTimeDuration;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor purpleColor];
        [self _init];
        adjustedPositions = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init {
    gettimeofday(&_lastDrawTime, NULL);

    _waitTimeDuration.tv_sec = (__darwin_time_t) 0.0;
    _waitTimeDuration.tv_usec = (__darwin_suseconds_t) (1000000.0 / 15.0);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
}

- (UIColor *)color {
    return [UIColor colorWithHue:_currentHsvColor.h
                      saturation:_currentHsvColor.s
                      brightness:_currentHsvColor.v
                           alpha:1];
}

- (void)setColor:(UIColor *)color {
    HSVColorFromUIColor(color, &_currentHsvColor);
    if (_brightnessSlider) self.brightnessSlider.color = self.color;
    if (_colorInfoView) self.colorInfoView.color = self.color;
    if (_colorMapView) {
        self.colorMapView.color = self.color;
        self.colorMapView.brightness = _currentHsvColor.v;
    }
}

- (UIView <HRColorInfoView> *)colorInfoView {
    if (!_colorInfoView) {
        _colorInfoView = [[HRColorInfoView alloc] init];
        _colorInfoView.color = self.color;
        [self addSubview:self.colorInfoView];
    }
    return _colorInfoView;
}

- (void)setColorInfoView:(UIView <HRColorInfoView> *)colorInfoView {
    _colorInfoView = colorInfoView;
    _colorInfoView.color = self.color;
}

- (UIControl <HRBrightnessSlider> *)brightnessSlider {
    if (!_brightnessSlider) {
        _brightnessSlider = [[HRBrightnessSlider alloc] init];
        _brightnessSlider.brightnessLowerLimit = @0.0;
        _brightnessSlider.color = self.color;
        [_brightnessSlider addTarget:self
                              action:@selector(brightnessChanged:)
                    forControlEvents:UIControlEventValueChanged];
        [self addSubview:_brightnessSlider];
    }
    return _brightnessSlider;
}

- (void)setBrightnessSlider:(UIControl <HRBrightnessSlider> *)brightnessSlider {
    _brightnessSlider = brightnessSlider;
    _brightnessSlider.color = self.color;
    [_brightnessSlider addTarget:self
                          action:@selector(brightnessChanged:)
                forControlEvents:UIControlEventValueChanged];
}

- (UIControl <HRColorMapView> *)colorMapView {
    if (!_colorMapView) {
        HRColorMapView *colorMapView;
        colorMapView = [HRColorMapView colorMapWithFrame:CGRectZero
                                    saturationUpperLimit:1.0];
        colorMapView.tileSize = @16;
        _colorMapView = colorMapView;

        _colorMapView.brightness = _currentHsvColor.v;
        _colorMapView.color = self.color;
        [_colorMapView addTarget:self
                          action:@selector(colorMapColorChanged:)
                forControlEvents:UIControlEventValueChanged];
        _colorMapView.backgroundColor = [UIColor redColor];
        [self addSubview:_colorMapView];
    }
    return _colorMapView;
}

- (void)setColorMapView:(UIControl <HRColorMapView> *)colorMapView {
    _colorMapView = colorMapView;
    _colorMapView.brightness = _currentHsvColor.v;
    _colorMapView.color = self.color;
    [_colorMapView addTarget:self
                      action:@selector(colorMapColorChanged:)
            forControlEvents:UIControlEventValueChanged];
}

- (void)brightnessChanged:(UIControl <HRBrightnessSlider> *)slider {
    _currentHsvColor.v = slider.brightness.floatValue;
    self.colorMapView.brightness = _currentHsvColor.v;
    self.colorMapView.color = self.color;
    self.colorInfoView.color = self.color;
    self.sampleTextLabel.textColor = self.color;
    if (self.activeTextView) self.activeTextView.fillColor = self.color;
    
    [self sendActions];
}

- (void)colorMapColorChanged:(UIControl <HRColorMapView> *)colorMapView {
    HSVColorFromUIColor(colorMapView.color, &_currentHsvColor);
    self.brightnessSlider.color = colorMapView.color;
    self.colorInfoView.color = self.color;
    self.sampleTextLabel.textColor = self.color;
    if (self.activeTextView) self.activeTextView.fillColor = self.color;
    [self sendActions];
}

- (void)sendActions {
    timeval now, diff;
    gettimeofday(&now, NULL);
            timersub(&now, &_lastDrawTime, &diff);
    if (timercmp(&diff, &_waitTimeDuration, >)) {
        _lastDrawTime = now;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (BOOL)usingAutoLayout {
    return self.constraints && self.constraints.count > 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!adjustedPositions) {
        adjustedPositions = YES;
        CGRect frame = self.colorInfoView.frame;
        frame.origin.y =  -64;
        self.colorInfoView.frame = frame;
        _colorMapView.colorMapViewDelegate = self;
        frame = self.sampleTextLabel.frame;
        frame.origin.y = -64;
        self.sampleTextLabel.frame = frame;
    }

#if 0
    if (self.usingAutoLayout) {
        return;
    }

    CGFloat headerHeight = (20 + 44) * 1.625;
    self.colorMapView.frame = CGRectMake(
            0, headerHeight,
            CGRectGetWidth(self.frame),
            MAX(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - headerHeight)
    );
    // use intrinsicContentSize for 3.5inch screen
    CGRect colorMapFrame = (CGRect) {
            .origin = CGPointZero,
            .size = self.colorMapView.intrinsicContentSize
    };
    colorMapFrame.origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(colorMapFrame);
    self.colorMapView.frame = colorMapFrame;
    headerHeight = CGRectGetMinY(colorMapFrame);

    self.colorInfoView.frame = CGRectMake(8, (headerHeight - 84) / 2.0f, 66, 84);

    CGFloat hexLabelHeight = 18;
    CGFloat sliderHeight = 11;
    CGFloat brightnessPickerTop = CGRectGetMaxY(self.colorInfoView.frame) - hexLabelHeight - sliderHeight;

    CGRect brightnessPickerFrame = CGRectMake(
            CGRectGetMaxX(self.colorInfoView.frame) + 9,
            brightnessPickerTop,
            CGRectGetWidth(self.frame) - CGRectGetMaxX(self.colorInfoView.frame) - 9 * 2,
            sliderHeight);

    self.brightnessSlider.frame = [self.brightnessSlider frameForAlignmentRect:brightnessPickerFrame];
#endif
}


#pragma mark - MapViewDelegate Methods to hide controls when panning
- (void) touchesBegan
{
    DLog(@"Begin Tapping");
    self.brightnessSlider.alpha = 0.0;
    self.closeButton.alpha = 0.0;
}

- (void) touchesEnded
{
    DLog(@"End Tapping");
    self.brightnessSlider.alpha = 1.0;
    self.closeButton.alpha = 1.0;
}

- (IBAction)pushedCloseButton:(id)sender
{
    [self removeFromSuperview];
}

@end

