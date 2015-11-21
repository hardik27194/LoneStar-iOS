//
//  PagedScrollView.h
//
//  Modified from https://github.com/jianpx/ios-cabin/tree/master/PagedImageScrollView
//

#import <UIKit/UIKit.h>

enum PageControlPosition {
    PageControlPositionRightCorner = 0,
    PageControlPositionCenterBottom = 1,
    PageControlPositionLeftCorner = 2,
};

@protocol PagedScrollViewDelegate;

@interface PagedScrollView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) enum PageControlPosition pageControlPos; //default is PageControlPositionRightCorner
@property (nonatomic, retain) id<PagedScrollViewDelegate> delegate;

- (void)setScrollViewContents: (NSArray *)views;
- (void)setScrollViewContents: (NSArray *)views atPage: (int) page;
- (void) jumpToPage: (NSInteger) page;
@end

@protocol PagedScrollViewDelegate <NSObject>

@optional
- (void) pageChanged: (int) newPage;
-(void) scrollStarted;
-(void)scrollEnded;

@end
