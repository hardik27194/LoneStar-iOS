

#import <Foundation/Foundation.h>

@protocol HRColorMapViewDelegate

@optional
- (void) touchesBegan;
- (void) touchesEnded;

@end

@protocol HRColorMapView

@required
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CGFloat brightness;

@optional
@property (nonatomic) NSNumber *saturationUpperLimit;
@property (nonatomic, retain) NSObject <HRColorMapViewDelegate> *colorMapViewDelegate;

@end


@interface HRColorMapView : UIControl <HRColorMapView>

+ (HRColorMapView *)colorMapWithFrame:(CGRect)frame;
+ (HRColorMapView *)colorMapWithFrame:(CGRect)frame saturationUpperLimit:(CGFloat)saturationUpperLimit;

@property (nonatomic) NSNumber *tileSize;
@property (nonatomic, retain) NSObject <HRColorMapViewDelegate> *colorMapViewDelegate;

@end