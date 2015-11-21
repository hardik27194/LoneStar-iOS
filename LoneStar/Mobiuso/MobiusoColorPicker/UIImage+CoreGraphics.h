

#import <Foundation/Foundation.h>

typedef void(^renderToContext)(CGContextRef, CGRect);

@interface UIImage (CoreGraphics)

+ (UIImage *)hr_imageWithSize:(CGSize)size renderer:(renderToContext)renderer;

+ (UIImage *)hr_imageWithSize:(CGSize)size opaque:(BOOL)opaque renderer:(renderToContext)renderer;

+ (UIImage *)hr_imageWithSize:(CGSize)size rectOffset: (CGPoint) origin opaque:(BOOL)opaque renderer:(renderToContext)renderer;

@end