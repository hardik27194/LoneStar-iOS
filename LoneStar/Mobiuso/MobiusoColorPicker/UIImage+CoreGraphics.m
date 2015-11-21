

#import "UIImage+CoreGraphics.h"


@implementation UIImage (CoreGraphics)

+ (UIImage *)hr_imageWithSize:(CGSize)size renderer:(renderToContext)renderer {
    return [UIImage hr_imageWithSize:size opaque:NO renderer:renderer];
}

+ (UIImage *)hr_imageWithSize:(CGSize)size opaque:(BOOL)opaque renderer:(renderToContext)renderer
{
#if 0
    UIImage *image;

    UIGraphicsBeginImageContextWithOptions(size, opaque, 0);

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect imageRect = CGRectMake(0.f, 0.f, size.width, size.height);

    renderer(context, imageRect);

    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
#endif
    return [self hr_imageWithSize:size rectOffset:CGPointMake(0.0f, 0.0f) opaque:opaque renderer:renderer];
}

+ (UIImage *)hr_imageWithSize:(CGSize)size rectOffset: (CGPoint) origin opaque:(BOOL)opaque renderer:(renderToContext)renderer {
    UIImage *image;
    
    UIGraphicsBeginImageContextWithOptions(size, opaque, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect imageRect = CGRectMake(origin.x, origin.y, size.width, size.height);
    
    renderer(context, imageRect);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end