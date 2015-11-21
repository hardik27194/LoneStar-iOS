//
//  MoArcMenuItem.m
//  MoArcMenu
//
//  Created by sandeep on 01/10/13.
//  Copyright (c) 2013 Mobiuso. All rights reserved.
//
//  Updated 20150921
//

#import "MoArcMenuItem.h"

static inline CGRect ScaleRect(CGRect rect, float n) {return CGRectMake((rect.size.width - rect.size.width * n)/ 2, (rect.size.height - rect.size.height * n) / 2, rect.size.width * n, rect.size.height * n);}


@interface MoArcMenuItem ()
{
    UIImageView *_contentImageView;
    CGPoint _startPoint;
    CGPoint _endPoint;
    CGPoint _nearPoint; // near
    CGPoint _farPoint; // far
    UIColor *_anchorColor;
    
}
@end

@implementation MoArcMenuItem

@synthesize hint;

#pragma mark - initialization & cleaning up
- (id)  initWithImage:(UIImage *)img 
     highlightedImage:(UIImage *)himg
         ContentImage:(UIImage *)cimg
    highlightedContentImage:(UIImage *)hcimg
        anchorColor: (UIColor *) color
{
    if (self = [self initWithImage:img highlightedImage:himg ContentImage:cimg highlightedContentImage:hcimg anchorColor:color diameter:48])
    {
    }
    return self;
}

- (id)  initWithImage:(UIImage *)img
     highlightedImage:(UIImage *)himg
         ContentImage:(UIImage *)cimg
highlightedContentImage:(UIImage *)hcimg
          anchorColor: (UIColor *) color
             diameter: (CGFloat) diameter
{
    if (self = [super init])
    {
        self.userInteractionEnabled = YES;
        self.image = (img==nil)?[UIImage imageNamed:@"bg-transparent.png"]:img;
        self.highlightedImage = (himg==nil)?[UIImage imageNamed:@"bg-transparent.png"]:himg;
        _contentImageView = [[UIImageView alloc] initWithImage:cimg];
        _contentImageView.highlightedImage = hcimg;
        _buttonDiameter = diameter;
//        self.bounds = _contentImageView.bounds = CGRectMake(0, 0, diameter, diameter);
        self.anchorColor = color;
        [self addSubview:_contentImageView];
    }
    return self;
}

- (void)dealloc
{
    //[_contentImageView release];
    //[super dealloc];
}


#pragma mark - UIView's methods
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    float width = _buttonDiameter; // _contentImageView.image.size.width;
    float height = _buttonDiameter; // _contentImageView.image.size.height;
    float outerw = _buttonDiameter; // self.image.size.width;
    float outerh = _buttonDiameter; // self.image.size.height;
    // If the size is greater than 32, try to minimize it...
#ifdef NOTNOW
    if (width > 32) { width /= 2.0; height /= 2.0; outerw /= 2.0; outerh /= 2.0;}
#endif
    self.bounds = CGRectMake(0, 0, outerw, outerh);
    
    _contentImageView.frame = CGRectMake(self.bounds.size.width/2 - width/2, self.bounds.size.height/2 - height/2, width, height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = YES;

    if ([_delegate respondsToSelector:@selector(MoArcMenuItemTouchesBegan:)])
    {
       [_delegate MoArcMenuItemTouchesBegan:self];
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if move out of 2x rect, cancel highlighted.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        self.highlighted = NO;
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    // if stop in the area of 2x rect, response to the touches event.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        if ([_delegate respondsToSelector:@selector(MoArcMenuItemTouchesEnd:)])
        {
            [_delegate MoArcMenuItemTouchesEnd:self];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

#pragma mark - instant methods
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [_contentImageView setHighlighted:highlighted];
}


@end
