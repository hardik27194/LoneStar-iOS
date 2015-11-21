//
//  StylizedTextView.m
//  LoneStar
//
//  Created by sandeep on 11/15/15.
//  Copyright © 2015 Medpresso. All rights reserved.
//

#import "StylizedTextView.h"

@interface StylizedTextView ()
{
    StringRendering *renderer;
}
@end


@implementation StylizedTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWithAttributedString: (NSAttributedString *) aString
{
    if (!(self = [super initWithFrame:CGRectZero])) return self;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.string = aString;
    
    return self;
}

- (void) setString:(NSAttributedString *)string
{
    _string = string;
    renderer = [StringRendering rendererForView:self string:string];
}

- (void) drawLine
{
    CGPathRef spiralPath = [self spiralPath]
    .CGPath;
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(c, [UIColor grayColor].CGColor);
    //	CGContextSetRGBStrokeColor(c, 0.0, 0.0, 0.0, 1.0);	// black
    CGContextSetLineWidth(c, 1.0);
    CGContextAddPath(c, spiralPath);
    CGContextStrokePath(c);
    CGPathRelease(spiralPath);
    
    
    
    
    
    
    
    
    
#if 0
    CAShapeLayer *insideTrack = [CAShapeLayer layer];
    // insideTrack.delegate = self;
    insideTrack.path = spiralPath.CGPath;
    insideTrack.strokeColor = [UIColor grayColor].CGColor ; // self.anchorColor.CGColor;
    insideTrack.fillColor = [UIColor clearColor].CGColor;
    insideTrack.lineWidth = 4.0f;
#if TRACK_DOTTED_INSIDE
    insideTrack.lineDashPattern = [NSArray arrayWithObjects: [NSNumber numberWithInt:10], [NSNumber numberWithInt:5], nil];
#endif
    insideTrack.opacity = 0.0f;
#if TRACK_SHADOW
    insideTrack.shadowColor = [UIColor blackColor].CGColor;
    insideTrack.shadowOffset = CGSizeMake(0, 1);
    insideTrack.shadowOpacity = 0.7f;
    insideTrack.shadowRadius = 1.0f;
#endif
    [self.layer addSublayer:insideTrack];
#endif
    
}

- (UIBezierPath *) circlePath
{
    float cX = CGRectGetMidX(self.bounds);
    float cY = CGRectGetMidY(self.bounds);
    
    float inset = IS_IPAD ? 30.0f : 20.0f;
    
    float radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0f) - inset;
    
    float dTheta = 2 * M_PI / 60.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
#if 1
    CGFloat firstPoint = cX + radius;
    CGFloat startAngle = dTheta;
#define ENDCONDITION    (theta < (2 * M_PI - dTheta))
#else
    // THe following does not work because the renderer makes assumptions about the path length
    CGFloat firstPoint = cX - radius;
    CGFloat startAngle = - M_PI + dTheta;
#define ENDCONDITION    (theta <  M_PI - dTheta))
#endif
    
    [path moveToPoint:CGPointMake(firstPoint, cY)];

    for (float theta = startAngle; theta < (2 * M_PI - dTheta); theta += dTheta)
    {
        float dx = radius * cos(theta);
        float dy = radius * sin(theta);
        [path addLineToPoint:CGPointMake(cX + dx, cY + dy)];
    }
    
    return path;
}

- (UIBezierPath *) spiralPath
{
    float cX = CGRectGetMidX(self.bounds);
    float cY = CGRectGetMidY(self.bounds);
    
    float radius = IS_IPAD ? 60.0f : 30.0f;
    float dRadius = 1.0f;
    
    float dTheta = 2 * M_PI / radius; //  60.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(cX + radius, cY)];
    
    for (float theta = dTheta; theta < 8 * M_PI; theta += dTheta)
    {
        radius += dRadius;
        float dx = radius * cos(theta);
        float dy = radius * sin(theta);
        [path addLineToPoint:CGPointMake(cX + dx, cY + dy)];
    }
    NSLog(@"Bezier Point Count: %ld", (unsigned long) (8 * M_PI /dTheta));
    
    return path;
}


// Draw text using Core Text
- (void) drawRect:(CGRect)rect
{
    [renderer prepareContextForCoreText];
    
    // Draw into rect
    // renderer.inset = 30.0f;
    // [renderer drawInRect:self.bounds];
    
    // Draw onto circle
    [renderer drawOnBezierPath:[self circlePath]];
    
    // Draw onto spiral
    //    SS [renderer drawOnBezierPath:[self spiralPath]];
    
    //    [self drawLine];
    
}

@end
