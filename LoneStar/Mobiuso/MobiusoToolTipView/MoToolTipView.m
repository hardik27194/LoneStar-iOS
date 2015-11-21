//
//  MoTooltipView.h
//
//  Created by Sandeep Shah 03/12/2015
//  Updated to combine with Welcome View and added border and other enhancements (20150712)
//  - inspired by Chris Miles' CMPopup bubbles implementation
//
//
//

#import "MoToolTipView.h"
#import "Theme.h"
#import "Utilities.h"

@interface MoToolTipView ()
@property (nonatomic, retain, readwrite)	id	targetObject;
@end


@implementation MoToolTipView

@synthesize backgroundColor;
@synthesize delegate;
@synthesize message;
@synthesize customView;
@synthesize targetObject;
@synthesize textColor;
@synthesize textFont;
@synthesize textAlignment;
@synthesize animation;
@synthesize maxWidth;
@synthesize disableTapToDismiss;

// Each screen will have 1 or more tooltips implemented - (if they are avaialble, then this will be used)
// The screen can implement displaying tooltip according to any logi - it is not necessary that it will be cycled immediately

+ (NSInteger) shouldRunTooltip: (NSString *) screenID {
    //You will get 0 (the first tool tip) if nothing has been set up yet
    NSString *key = [NSString stringWithFormat: @"kToolTip%@", screenID];
    NSInteger screenIndex = [[NSUserDefaults standardUserDefaults]  integerForKey: key];
        
    return screenIndex;
}

+ (void) setShouldRunTooltip: (NSString *) screenID toolTipIndex: (NSInteger) index
{
    NSString *key = [NSString stringWithFormat: @"kToolTip%@", screenID];
    [[NSUserDefaults standardUserDefaults] setInteger: index forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (MoToolTipView *) showInView: (UIView *) container withItem: (NSDictionary *) dict
{
    MoToolTip *tooltip = [[MoToolTip alloc] initWithDict:dict];
    
    
    MoToolTipView *popTipView = [[MoToolTipView alloc] initWithMessage:[dict objectForKey:@"message"]];
    popTipView.delegate = tooltip.delegate;
    popTipView.disableTapToDismiss = NO;
    popTipView.backgroundColor = tooltip.color;
    popTipView.textColor = tooltip.textColor;
    popTipView.textFont = tooltip.textFont;
    popTipView.animation = tooltip.animation;
    popTipView.geometry = tooltip.geometry;

    // Figure out if the Item is a special class (like on the Navigation Bar)
    if ([tooltip.target isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButtonItem = (UIBarButtonItem *)tooltip.target;
        [popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
    } else {
        UIView *targetView = tooltip.target;
        [popTipView presentPointingAtView:targetView inView:container animated:YES];
    }
    
    return popTipView;
}

+ (MoToolTipView *) showInView: (UIView *) container withTooltip: (MoToolTip *) tooltip
{
    
    
    MoToolTipView *popTipView = [[MoToolTipView alloc] initWithMessage:tooltip.message];
    popTipView.delegate = tooltip.delegate;
    popTipView.disableTapToDismiss = NO;
    popTipView.backgroundColor = tooltip.color;
    popTipView.textColor = tooltip.textColor;
    popTipView.textFont = tooltip.textFont;
    popTipView.animation = tooltip.animation;
    popTipView.geometry = tooltip.geometry;
    
    
    // Figure out if the Item is a special class (like on the Navigation Bar)
    if ([tooltip.target isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButtonItem = (UIBarButtonItem *)tooltip.target;
        [popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
    } else {
        UIView *targetView = tooltip.target;
        [popTipView presentPointingAtView:targetView inView:container animated:YES];
    }
    
    return popTipView;
}


#pragma mark - Frames etc
- (CGRect)bubbleFrame {
	CGRect bubbleFrame;
	if (pointDirection == PointDirectionUp) {
		bubbleFrame = CGRectMake(2.0, targetPoint.y+pointerSize, bubbleSize.width, bubbleSize.height);
	}
	else {
		bubbleFrame = CGRectMake(2.0, targetPoint.y-pointerSize-bubbleSize.height, bubbleSize.width, bubbleSize.height);
	}
	return bubbleFrame;
}

- (CGRect)contentFrame {
	CGRect bubbleFrame = [self bubbleFrame];
	CGRect contentFrame = CGRectMake(bubbleFrame.origin.x + cornerRadius,
									 bubbleFrame.origin.y + cornerRadius,
									 bubbleFrame.size.width - cornerRadius*2,
									 bubbleFrame.size.height - cornerRadius*2);
	return contentFrame;
}

- (void)layoutSubviews {
	if (self.customView) {
		
		CGRect contentFrame = [self contentFrame];
        [self.customView setFrame:contentFrame];
    }
}

- (void)drawRect:(CGRect)rect {
	
	CGRect bubbleRect = [self bubbleFrame];
	
	CGContextRef c = UIGraphicsGetCurrentContext(); 
    CGContextSetStrokeColorWithColor(c, backgroundColor.CGColor);
//	CGContextSetRGBStrokeColor(c, 0.0, 0.0, 0.0, 1.0);	// black
	CGContextSetLineWidth(c, 1.0);
    
	CGMutablePathRef bubblePath = CGPathCreateMutable();
    
#ifdef REGULARBUBBLE
    CGFloat pointer = pointerSize;
#else
    CGFloat pointer = 0;
#endif
    
	if (pointDirection == PointDirectionUp) {
		CGPathMoveToPoint(bubblePath, NULL, targetPoint.x, targetPoint.y+ (pointerSize-pointer));
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x+pointer/2, targetPoint.y+(pointerSize-pointer));
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x+bubbleRect.size.width-cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y,
							bubbleRect.origin.x+cornerRadius, bubbleRect.origin.y,
							cornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x-pointer/2, targetPoint.y+(pointerSize-pointer));
	}
	else {
		CGPathMoveToPoint(bubblePath, NULL, targetPoint.x, targetPoint.y-(pointerSize-pointer));
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x-pointer/2, targetPoint.y-(pointerSize-pointer));
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y,
							bubbleRect.origin.x+cornerRadius, bubbleRect.origin.y,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x+bubbleRect.size.width-cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
							cornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x+pointer/2, targetPoint.y-(pointerSize-pointer));
	}
    
	CGPathCloseSubpath(bubblePath);
    
    
	// Draw shadow
	CGContextAddPath(c, bubblePath);
    CGContextSaveGState(c);
	CGContextFillPath(c);
    CGContextRestoreGState(c);
    
    CGContextSetFillColorWithColor(c, backgroundColor.CGColor);
    
    CGContextAddPath(c, bubblePath);
    CGContextDrawPath(c, kCGPathFillStroke);
	CGPathRelease(bubblePath);

    // Draw a dashed line to point
    //
    //
    CGMutablePathRef linePath = CGPathCreateMutable();
    

    CGPathMoveToPoint(linePath, NULL, targetPoint.x+((pointDirection == PointDirectionUp)?0:lineSlant/10), targetPoint.y - ((pointDirection == PointDirectionUp)?0:pointerSize));
    CGPathAddLineToPoint(linePath, NULL, targetPoint.x + ((pointDirection == PointDirectionUp)?lineSlant/10:0), targetPoint.y+pointerSize);
    CGContextAddPath(c, linePath);
        CGContextSetLineWidth(c, 3);
        CGFloat lengths[] = {3, 3};
        CGContextSetLineDash(c, 0, lengths, 2);

    CGContextStrokePath(c);
    CGPathRelease(linePath);

	// Draw text
	
	if (self.message) {
		[textColor set];
		CGRect textFrame = [self contentFrame];
#ifdef GETRIDOFTHIS
        [self.message drawInRect:textFrame
                        withFont:textFont
                   lineBreakMode:NSLineBreakByWordWrapping
                       alignment:NSTextAlignmentCenter];
#endif
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment                = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary* attribs = @{NSFontAttributeName:textFont, NSParagraphStyleAttributeName: paragraphStyle};
        [self.message drawInRect:textFrame withAttributes:attribs];
    }
}

// Add a large rectangle and make a circular 'hole' in it.  Animate it with a slide.
- (void) addPunchedHole: (UIView *) view inView: (UIView *) containerView
{
    holeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10000, 10000)];
    holeView.userInteractionEnabled = YES;
    holeView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    holeView.autoresizingMask = 0;
    holeView.tag = 131036;

    // Navigation Bar tap action
    UITapGestureRecognizer* tapRecon = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(tapped:)];
    tapRecon.numberOfTapsRequired = 1;
    [holeView addGestureRecognizer:tapRecon];
    
    [containerView addSubview:holeView];
    
    [self addMaskToHoleView: view];

    CGRect viewFrame = view.frame;
    CGFloat centerX = viewFrame.origin.x + viewFrame.size.width/2;
    CGFloat centerY = viewFrame.origin.y + viewFrame.size.height/2;
    
    if (centerY<50) {
        // Get it from left or right (instead of top)
        holeView.center = CGPointMake((centerX<50)?containerView.bounds.size.width:0, centerY);
    } else {
        // Move it from the top
        holeView.center = CGPointMake(centerX, 0);
    }
        [UIView animateWithDuration:1.0f
                              delay:0.0f
             usingSpringWithDamping:0.7f
              initialSpringVelocity:8.0f
                            options:UIViewAnimationOptionCurveEaseIn
                                        /* |UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse */
                         animations:^{
            
                                    holeView.center = CGPointMake(centerX, centerY);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:1.0f
                                  delay:0.0f
                 usingSpringWithDamping:0.7f
                  initialSpringVelocity:8.0f
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 view.layer.borderWidth = 2;
                             } completion:^(BOOL finished) {
                             }];
            DLog(@"Done animation");
        }];
    

}

#define GEOMETRY_CIRCLE     0
#define GEOMETRY_RECTANGLE  1
#define GEOMETRY_ROUNDED    2


- (void)addMaskToHoleView: (UIView *) view
{
    CGRect bounds = holeView.bounds;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = CGRectZero;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    
//    static CGFloat const kRadius = 100;
    CGRect const circleRect = CGRectMake(CGRectGetMidX(bounds) - view.frame.size.width/2,
                                         CGRectGetMidY(bounds) - view.frame.size.height/2,
                                         view.frame.size.width, view.frame.size.height);
    int geometry = IS_EQUAL(@"circle", self.geometry) ? GEOMETRY_CIRCLE : (IS_EQUAL(@"rounded", self.geometry) ?
                                                                            GEOMETRY_ROUNDED   :
                                                                            GEOMETRY_RECTANGLE);
    
    UIBezierPath *path = (geometry == GEOMETRY_CIRCLE) ?
                                    [UIBezierPath bezierPathWithOvalInRect:circleRect] :
                                    ((geometry == GEOMETRY_ROUNDED) ?
                                        [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:12.0f]   :
                                        [UIBezierPath bezierPathWithRect:circleRect]);
    [path appendPath:[UIBezierPath bezierPathWithRect:bounds]];
    
    self.origBorderColor = view.layer.borderColor;
    self.origBorderWidth = view.layer.borderWidth;
    self.origCornerRadius = view.layer.cornerRadius;
    
//    view.layer.borderWidth = 2;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.cornerRadius = (geometry == GEOMETRY_CIRCLE) ? view.frame.size.width/2 :
                                ((geometry == GEOMETRY_ROUNDED) ? 12 : 0);
    

    
    maskLayer.path = path.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    
    holeView.layer.mask = maskLayer;
}

//
//
// Set up the Tooltip
- (void)presentPointingAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated {
	if (!self.targetObject) {
		self.targetObject = targetView;
	}
	
    
	// Size of rounded rect
	CGFloat rectWidth;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // iPad
        if (maxWidth) {
            if (maxWidth < containerView.frame.size.width) {
                rectWidth = maxWidth;
            }
            else {
                rectWidth = containerView.frame.size.width - 20;
            }
        }
        else {
            rectWidth = (int)(containerView.frame.size.width/3);
        }
    }
    else {
        // iPhone
        if (maxWidth) {
            if (maxWidth < containerView.frame.size.width) {
                rectWidth = maxWidth;
            }
            else {
                rectWidth = containerView.frame.size.width - 10;
            }
        }
        else {
            rectWidth = (int)(containerView.frame.size.width*2/3);
        }
    }

	CGSize textSize;
    
    if (self.message!=nil) {
#if 0
        textSize= [self.message sizeWithFont:textFont
                           constrainedToSize: CGSizeMake(rectWidth, 99999.0)
                               lineBreakMode: NSLineBreakByWordWrapping];
#endif
        
        NSDictionary* attribs = @{NSFontAttributeName:textFont};
        
        textSize = [self.message boundingRectWithSize:CGSizeMake(rectWidth, 99999.0) options:NSStringDrawingUsesLineFragmentOrigin  attributes:attribs context:nil].size;

    }
    if (self.customView != nil) {
        textSize = self.customView.frame.size;
    }
    
	bubbleSize = CGSizeMake(textSize.width + cornerRadius*2, textSize.height + 5 + cornerRadius*2);
	
	CGPoint targetRelativeOrigin    = [targetView.superview convertPoint:targetView.frame.origin toView:containerView.superview];
	CGPoint containerRelativeOrigin = [containerView.superview convertPoint:containerView.frame.origin toView:containerView.superview];
    
	CGFloat pointerY;	// Y coordinate of pointer target (within containerView)
	
	if (targetRelativeOrigin.y+targetView.bounds.size.height < containerRelativeOrigin.y) {
		pointerY = 0.0;
		pointDirection = PointDirectionUp;
	}
	else if (targetRelativeOrigin.y > containerRelativeOrigin.y+containerView.bounds.size.height) {
		pointerY = containerView.bounds.size.height;
		pointDirection = PointDirectionDown;
	}
	else {
		CGPoint targetOriginInContainer = [targetView convertPoint:CGPointMake(0.0, 0.0) toView:containerView];
		CGFloat sizeBelow = containerView.bounds.size.height - targetOriginInContainer.y;
		if (sizeBelow > targetOriginInContainer.y) {
			pointerY = targetOriginInContainer.y + targetView.bounds.size.height;
			pointDirection = PointDirectionUp;
		}
		else {
			pointerY = targetOriginInContainer.y;
			pointDirection = PointDirectionDown;
		}
	}
	
	CGFloat W = containerView.frame.size.width;
	
	CGPoint p = [targetView.superview convertPoint:targetView.center toView:containerView];
	CGFloat x_p = p.x;
	CGFloat x_b = x_p - roundf(bubbleSize.width/2);
	if (x_b < sidePadding) {
		x_b = sidePadding;
	}
	if (x_b + bubbleSize.width + sidePadding > W) {
		x_b = W - bubbleSize.width - sidePadding;
	}
	if (x_p - pointerSize < x_b + cornerRadius) {
		x_p = x_b + cornerRadius + pointerSize;
	}
	if (x_p + pointerSize > x_b + bubbleSize.width - cornerRadius) {
		x_p = x_b + bubbleSize.width - cornerRadius - pointerSize;
	}
	
	CGFloat fullHeight = bubbleSize.height + pointerSize + 10.0;
	CGFloat y_b;
	if (pointDirection == PointDirectionUp) {
		y_b = topMargin + pointerY;
		targetPoint = CGPointMake(x_p-x_b, 0);
	}
	else {
		y_b = pointerY - fullHeight;
		targetPoint = CGPointMake(x_p-x_b, fullHeight-2.0);
	}
	
	CGRect finalFrame = CGRectMake(x_b-sidePadding,
								   y_b,
								   bubbleSize.width+sidePadding*2,
								   fullHeight);
    
   	DLog(@"Final frame: (%.f, %.f, %.f, %.f)", finalFrame.origin.x, finalFrame.origin.y, finalFrame.size.width, finalFrame.size.height);
    lineSlant = W/2 - (finalFrame.origin.x + finalFrame.size.width/2);
    if (lineSlant > 0) {
        DLog(@"point slanting to left");
    } else {
        DLog(@"point slanting to right");
    }
    
    [self addPunchedHole: targetView inView: containerView];
    [containerView addSubview:self];

	if (animated) {
        if (animation == CMPopTipAnimationSlide) {
            self.alpha = 0.0;
            CGRect startFrame = finalFrame;
            startFrame.origin.y += 10;
            self.frame = startFrame;
        }
		else if (animation == CMPopTipAnimationPop) {
            self.frame = finalFrame;
            self.alpha = 0.5;
            
            // start a little smaller
            self.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
            
            // animate to a bigger size
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(popAnimationDidStop:finished:context:)];
            [UIView setAnimationDuration:0.15f];
            self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
            self.alpha = 1.0;
            [UIView commitAnimations];
        }
		
		[self setNeedsDisplay];
		
		if (animation == CMPopTipAnimationSlide) {
			[UIView beginAnimations:nil context:nil];
			self.alpha = 1.0;
			self.frame = finalFrame;
			[UIView commitAnimations];
		}
 

	}
	else {
		// Not animated
		[self setNeedsDisplay];
		self.frame = finalFrame;
	}

    

    
    self.clipsToBounds = NO;
    
}

- (void)presentPointingAtBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated {
	UIView *targetView = (UIView *)[barButtonItem performSelector:@selector(view)];
	UIView *targetSuperview = [targetView superview];
	UIView *containerView = nil;
	if ([targetSuperview isKindOfClass:[UINavigationBar class]]) {
		UINavigationController *navController = (UINavigationController *)[(UINavigationBar *)targetSuperview delegate];
		containerView = [[navController topViewController] view];
	}
	else if ([targetSuperview isKindOfClass:[UIToolbar class]]) {
		containerView = [targetSuperview superview];
	}
	
	if (nil == containerView) {
		DLog(@"Cannot determine container view from UIBarButtonItem: %@", barButtonItem);
		self.targetObject = nil;
		return;
	}
	
	self.targetObject = barButtonItem;
	
	[self presentPointingAtView:targetView inView:containerView animated:animated];
}

- (void)finalizeDismiss {
	[self removeFromSuperview];
    [holeView removeFromSuperview];
    if (self.targetObject) {
        UIView *view = self.targetObject;
        // restore original parameters...
        view.layer.borderColor = self.origBorderColor ;
        view.layer.borderWidth = self.origBorderWidth ;
        view.layer.cornerRadius = self.origCornerRadius ;

    }
	self.targetObject = nil;
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self finalizeDismiss];
}

- (void)dismissAnimated:(BOOL)animated {
	
	if (animated) {
		CGRect frame = self.frame;
		frame.origin.y += 10.0;
		
		[UIView beginAnimations:nil context:nil];
		self.alpha = 0.0;
		self.frame = frame;
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
	else {
		[self finalizeDismiss];
	}
}


- (void) tapped: (id) sender
{
    highlight = YES;
    [self setNeedsDisplay];
    
    [self dismissAnimated:YES];
    
    if (delegate && [delegate respondsToSelector:@selector(toolTipViewDismissed:)]) {
        [delegate toolTipViewDismissed:self];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.disableTapToDismiss) {
		[super touchesBegan:touches withEvent:event];
		return;
	}
	
    [self tapped: nil];
}

- (void)popAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // at the end set to normal size
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.opaque = NO;
		
		cornerRadius = 6.0;
		topMargin = 2.0;
		pointerSize = 18.0;
		sidePadding = 2.0;
		
		self.textFont = [UIFont boldSystemFontOfSize:14.0];
		self.textColor = [UIColor whiteColor];
		self.textAlignment = NSTextAlignmentCenter;
		self.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:60.0/255.0 blue:154.0/255.0 alpha:1.0];
        self.animation = CMPopTipAnimationSlide;
    }
    return self;
}

- (PointDirection) getPointDirection {
  return pointDirection;
}

- (instancetype) initWithTooltip: (MoToolTip *) tooltip
{
    if ((self = [self initWithMessage:tooltip.message])) {
        self.delegate = (id<MoToolTipViewDelegate>)tooltip.delegate;
        self.disableTapToDismiss = NO;
        self.backgroundColor = tooltip.color;
        self.textColor = tooltip.textColor;
        self.textFont = tooltip.textFont;
        self.animation = tooltip.animation;

    }
    return self;
}

- (id)initWithMessage:(NSString *)messageToShow {
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.message = messageToShow;
	}
	return self;
}

- (id)initWithCustomView:(UIView *)aView {
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.customView = aView;
        [self addSubview:self.customView];
	}
	return self;
}


@end
