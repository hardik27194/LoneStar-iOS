//
//  MoElasticViewNew.h
//  WaveToolBar
//
//  Based on Harvindar WaveToolbar (WaveCustomView) design - modified by Sandeep Dec 2013.
//  Copyright 2012-2014 Mobiuso. All rights reserved.
//

#import <UIKit/UIKit.h>


//#define CONTROLCOUNT    4
#define MAXCONTROLWIDTH 48
#define MAXCONTROLHEIGHT 48
#define MARGIN          6
#define FONTSIZE        16

@class CAShapeLayer;
@class CATextLayer;


@protocol MoElasticMenuDelegateNew

- (NSInteger)menuItemCount;
- (id)menuItemImageForIndex:(NSInteger)index;
- (id)menuItemHighlightImageForIndex:(NSInteger)index;
- (void)didSelectMenuItem:(NSInteger)index;
- (NSString *)menuItemTitleForIndex:(NSInteger)index;
@end


@interface MoElasticMenuItem : NSObject

@property (nonatomic,assign) NSString *menuTitle;
@property (nonatomic,assign) NSString *menuImageName;
@property (nonatomic,assign) NSString *menuHighlightImageName;
@property (nonatomic,assign) UIImage *defaultImage;
@property (nonatomic,assign) BOOL shouldVisible;
@property (nonatomic,assign) SEL action;
@property (nonatomic,assign) id target;
@property (nonatomic,assign) NSInteger vertualIndex;

@end



@interface MoElasticViewNew : UIView

@property (nonatomic,assign)CGPoint touchBeginCordinates;
@property (nonatomic,assign)NSInteger controlsCount;
@property (nonatomic,assign)NSInteger controlBackWidth;
@property (nonatomic,retain)NSMutableArray *controlsFrameArray;
@property (nonatomic,retain)NSMutableArray *controlsHighlightFrameArray;
@property (nonatomic,retain)NSMutableArray *controlsNameArray;
@property (nonatomic,assign)NSInteger maxWidth;
@property (nonatomic,assign)NSInteger maxHeight;
@property (nonatomic,assign)NSInteger currentIndex;

@property (nonatomic,retain) CAShapeLayer *firstLayer;
@property (nonatomic,retain) CALayer *bubbleLayer;
@property (nonatomic,retain) CATextLayer *bubbleTextLayer;
@property (nonatomic,retain) UIFont *font;
@property (nonatomic,assign) BOOL isActive;
@property (nonatomic,retain) CALayer *baseLayer;
@property (nonatomic,assign) CGRect   baseFrame;
@property (nonatomic,assign) BOOL menuExpended;

@property(assign)id<MoElasticMenuDelegateNew> delegate;

@property (nonatomic, retain) UIImageView *elasticMenuPopImage;    // sandeep

@property (nonatomic,retain) NSArray *menuItems;

- (id)initWithFrame:(CGRect)frame withDelegate:(id)del;
- (id)initWithFrame:(CGRect)frame withMenuItems:(NSArray *)menuItemsArray;

- (void)reconfigure;

@end
