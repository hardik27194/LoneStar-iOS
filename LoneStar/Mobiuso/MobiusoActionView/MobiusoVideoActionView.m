//
//  MobiusoVideoActionView.m
//  SkillsApp
//
//  Created by sandeep on 4/15/15.
//  Copyright (c) 2015 Skyscape. All rights reserved.
//

#import "MobiusoVideoActionView.h"
#import "MoRippleTap.h"
#import "Theme.h"
@import AVFoundation;

@interface MobiusoVideoActionView () {
    NSTimer *timer;
    MoRippleTap *_infoButton;
}

@end

@implementation MobiusoVideoActionView

#define HD_WIDTH    1920
#define HD_HEIGHT   1200


// Init
- (id) initWithTitle: (NSString *) title
            delegate: (id<MobiusoActionViewDelegate>) delegate
          andMessage: (NSString *) message
     placeholderText: (NSString *) suggestion
   cancelButtonTitle: (NSString *) cancelButtonTitle
   otherButtonTitles: (NSArray *) buttonTitleArray
               color: (UIColor *) color
          background: (NSString *) backgroundFile
{
    if (self = [super initWithTitle:title delegate:delegate andMessage:message placeholderText:suggestion cancelButtonTitle:cancelButtonTitle otherButtonTitles:buttonTitleArray color:color]) {
        _backgroundPath = backgroundFile;
        self.buttonTextColor = color;
        self.paneColor = color;
    }
    return self;
}

- (void) show
{
    [super show];
    [self performSelector:@selector(addRipple) withObject:nil afterDelay:2.0];
}

- (CGSize) optimalAssetSize: (CGSize) childSize withContainerSize: (CGSize) parentSize
{
//    CGRect bounds = self.bounds;
    // First we determine what is the size of the movie to be played
//    CGSize childSize = assetSize; // CGSizeMake(HD_WIDTH, HD_HEIGHT); // get this dynamically
//    CGSize parentSize = bounds.size;
    CGFloat ratioHeight = (parentSize.height) / childSize.height;  // remove +64 when you obtain the correct height of the asset
    CGFloat ratioWidth = (parentSize.width) / childSize.width;
    
#ifdef ASPECTFIT
    // For aspect Fit
    CGFloat ratioToUse = (ratioHeight < ratioWidth)? ratioHeight:ratioWidth;
#else
    // For aspect Fill
    CGFloat ratioToUse = (ratioHeight > ratioWidth)? ratioHeight:ratioWidth;
#endif
    
    CGFloat childHeight = round(childSize.height * ratioToUse);
    CGFloat childWidth = round(childSize.width * ratioToUse);

    return CGSizeMake(childWidth, childHeight);
}

- (UIView *) setupBackgroundView
{

    // Start with a generic UIView and add it to the ViewController view
    UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
    bgView.backgroundColor = [UIColor clearColor];
    
    if ((_backgroundPath != nil)  &&
        ([_backgroundPath hasSuffix:@"mp4"])) {
        NSURL *videoURL = [[NSBundle mainBundle]
                           URLForResource:_backgroundPath
                           withExtension:nil];
        
        AVPlayer *player = [[AVPlayer alloc] initWithURL:videoURL];
        // To loop the video - following does not work
        //    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        //    __weak typeof(self) weakSelf = self; // prevent memory cycle
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                          object:nil // any object can send
                                                           queue:nil // the queue of the sending
                                                      usingBlock:^(NSNotification *note) {
                                                          // holding a pointer to avPlayer to reuse it
                                                          [player seekToTime:kCMTimeZero];
                                                          [player play];
                                                      }];
        [player play];
        
        AVPlayerItem *playerItem = [player currentItem];
        AVAsset *asset = [playerItem asset];
#ifdef OLD
        CGSize assetSize = [asset naturalSize];
#endif
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        CGSize assetSize;
        if ([tracks count] > 0) {
            assetSize = [tracks[0] naturalSize];
        } else {
            // Not sure what to do
            assetSize = CGSizeMake(HD_WIDTH, HD_HEIGHT); // make up
        }

        
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer: player];
        
        
        CGRect bounds = self.bounds;
        // First we determine what is the size of the movie to be played
        CGSize parentSize = bounds.size;
        CGSize layerSize = [self optimalAssetSize:assetSize withContainerSize:parentSize];
        CGFloat childHeight = layerSize.height;
        CGFloat childWidth = layerSize.width;
        layer.frame = CGRectMake((parentSize.width-childWidth)/2, (parentSize.height - childHeight)/2, childWidth, childHeight);
        [bgView.layer addSublayer:layer];
    } else {
        CALayer *layer = [CALayer layer];
        CGRect bounds = self.bounds;
        UIImage *image = [UIImage imageNamed:_backgroundPath];
        CGSize assetSize = image.size;
        // First we determine what is the size of the movie to be played
        CGSize parentSize = bounds.size;
        CGSize layerSize = [self optimalAssetSize:assetSize withContainerSize:parentSize];
        CGFloat childHeight = layerSize.height;
        CGFloat childWidth = layerSize.width;
        layer.frame = CGRectMake((parentSize.width-childWidth)/2, (parentSize.height - childHeight)/2, childWidth, childHeight);
        layer.contents = (__bridge id)(image.CGImage);
        [bgView.layer addSublayer:layer];
    }
    
    CALayer *shimLayer = [CALayer layer];
    shimLayer.backgroundColor = [UIColor blackColor].CGColor;
    shimLayer.opacity = 0.5;
    shimLayer.frame = self.bounds;
    [bgView.layer addSublayer:shimLayer];
    
    self.paneColor = [UIColor clearColor];


    return bgView;
}

- (void) setPaneColor:(UIColor *)paneColor
{
    
    self.pane.backgroundColor = [UIColor clearColor];
    
//    [self setTextColor:paneColor];
#if 0
    // Ignore it
    self.buttonTextColor = paneColor;
    // adjust the textcolors as well
    for (int i=0; i<=[self.buttonArray count]; i++) {
        UILabel *label = (UILabel *)[self.shadedView viewWithTag:(BUTTON_TITLE_TAG_BASE+i)];
        label.textColor = paneColor;
    }
#endif
    
}

- (void) addRipple
{
    CGRect frame = [self.pane frame];
    _infoButton = [[MoRippleTap alloc]
                                initWithFrame:CGRectMake(CGRectGetMidX(frame), frame.origin.y, 16, 16)
                   andImage: nil // [UIImage imageNamed:@"info_Button.png"]
                                andTarget:nil
                                andBorder:NO
                                delegate:self
                                ];
    _infoButton.rippleOn = YES;
    _infoButton.rippleColor = [UIColor whiteColor];
    _infoButton.rippleWidth = 1.0f;
    _infoButton.rippleRadius = 12.0f;
    _infoButton.rippleDuration = 2.5f;

    [self addSubview: _infoButton];

    timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(randomize) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer: timer forMode:NSRunLoopCommonModes];

}

- (void) randomize
{
    CGFloat random1 = (CGFloat)arc4random()/0xFFFFFFFF;  // between 0 & 1
    CGFloat random2 = (CGFloat)arc4random()/0xFFFFFFFF;  // between 0 & 1
    CGRect frame = [self bounds];
    _infoButton.center = CGPointMake(random1 * frame.size.width, random2 * frame.size.height);
    [_infoButton handle: nil];
}

- (void)didTap:(UITapGestureRecognizer *)tapRecognizer
{
    [super didTap: tapRecognizer];
    // turn off the timer
    if (timer) [timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:AVPlayerItemDidPlayToEndTimeNotification];
}


@end
