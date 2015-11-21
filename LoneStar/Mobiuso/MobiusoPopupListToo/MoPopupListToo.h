//
//  MoPopupListToo.h
//
//

#import <UIKit/UIKit.h>

@class MoPopupListToo;

@protocol MoPopupListTooViewDataSource <NSObject>

@required
/* number of items for picker */
- (NSInteger)numberOfRowsInPickerView:(MoPopupListToo *)pickerView;

@optional
/*
 Implement at least one of the following method,
 popupList:(popupListToo *)pickerView
 attributedTitleForRow:(NSInteger)row has higer priority
*/

/* attributed picker item title for each row */
- (NSAttributedString *)popupList:(MoPopupListToo *)pickerView
                            attributedTitleForRow:(NSInteger)row;

/* picker item title for each row */
- (NSString *)popupList:(MoPopupListToo *)pickerView
                            titleForRow:(NSInteger)row;

@end

@protocol MoPopupListTooViewDelegate <NSObject>

@optional

/** delegate method for picking one item */
- (void)popupList:(MoPopupListToo *)pickerView
          didConfirmWithItemAtRow:(NSInteger)row;

/*
 delegate method for picking multiple items,
 implement this method if allowMultipleSelection is YES,
 rows is an array of NSNumbers
 */
- (void)popupList:(MoPopupListToo *)pickerView
          didConfirmWithItemsAtRows:(NSArray *)rows;

/** delegate method for canceling */
- (void)popupListDidClickCancelButton:(MoPopupListToo *)pickerView;
@end

@interface MoPopupListToo : UIView<UITableViewDataSource, UITableViewDelegate>

/** Initialize the picker view with titles
 @param headerTitle The title of header
 @param cancelButtonTitle The title for cancelButton
 @param confirmButtonTitle The title for confirmButton
 */
- (id)initWithHeaderTitle:(NSString *)headerTitle
        cancelButtonTitle:(NSString *)cancelButtonTitle
       confirmButtonTitle:(NSString *)confirmButtonTitle;

/** show the picker */
- (void)show;

@property id<MoPopupListTooViewDelegate> delegate;

@property id<MoPopupListTooViewDataSource> dataSource;

/** whether to show footer (including confirm and cancel buttons), default NO */
@property BOOL needFooterView;

/** whether allow tap background to dismiss the picker, default YES */
@property BOOL tapBackgroundToDismiss;

/** whether allow selection of multiple items/rows, default NO, if this
 property is YES, then footerView will be shown */
@property BOOL allowMultipleSelection;

/** picker header background color */
@property (nonatomic, strong) UIColor *headerBackgroundColor;

/** picker header title color */
@property (nonatomic, strong) UIColor *headerTitleColor;

/** picker cancel button background color */
@property (nonatomic, strong) UIColor *cancelButtonBackgroundColor;

/** picker cancel button normal state color */
@property (nonatomic, strong) UIColor *cancelButtonNormalColor;

/** picker cancel button highlighted state color */
@property (nonatomic, strong) UIColor *cancelButtonHighlightedColor;

/** picker confirm button background color */
@property (nonatomic, strong) UIColor *confirmButtonBackgroundColor;

/** picker confirm button normal state color */
@property (nonatomic, strong) UIColor *confirmButtonNormalColor;

/** picker confirm button highlighted state color */
@property (nonatomic, strong) UIColor *confirmButtonHighlightedColor;

@end
