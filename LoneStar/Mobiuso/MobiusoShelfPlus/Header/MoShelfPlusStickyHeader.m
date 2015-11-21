//
//  CSAlwaysOnTopHeader.m
//  CSStickyHeaderFlowLayoutDemo
//
//

#import "MoShelfPlusStickyHeader.h"
#import "MoShelfPlusStickyHeaderFlowLayoutAttributes.h"
#import "Utilities.h"

@implementation MoShelfPlusStickyHeader

NSString *kTopHeaderKind = @"ModuleTypeHeaderTop";

- (void)awakeFromNib
{
    CGRect frame =  self.selectorButton.bounds;
    self.selectorButton.layer.cornerRadius = frame.size.height / 2.0f; // Setting a larger number like 90 creates an interesting corner
    

}

- (void) setDelegate:(NSObject<MoShelfPlusStickyHeaderDelegate> *)delegate
{
    if ([delegate respondsToSelector: @selector(stickyHeaderCell)])
    {
        delegate.stickyHeaderCell = self;
    }
    _delegate = delegate;
}

- (void)applyLayoutAttributes:(MoShelfPlusStickyHeaderFlowLayoutAttributes *)layoutAttributes {

    [UIView beginAnimations:@"" context:nil];

    
#ifdef TitleLabelSwap
    UILabel *label = self.titleLabel;
#else
    UILabel *label = self.supplementaryInfoLabel;
#endif
    // Use the following to adjust the views according to the amount of scrolling...
    if (layoutAttributes.progressiveness <= 0.58) {
        label.alpha = 0;
        self.supplementaryInfoLabel2.alpha = 1.0;
#if 0
        CGRect frame = label.frame;
        CGSize size = [self bounds].size;
        frame.origin.y = size.height - 32;
        label.frame = frame;
#endif
//        self.titleLabel.hidden = NO;
        self.infoButton.hidden = YES;
        self.searchButton.hidden = NO;
    } else {
        label.alpha = 1;
        self.supplementaryInfoLabel2.alpha = 0.0;
        self.infoButton.hidden = NO;
        self.searchButton.hidden = YES;
    }
    self.supplementaryInfoLabel2.layer.borderColor = self.supplementaryInfoLabel.layer.borderColor = COLORFROMHEX(0x80ffffff).CGColor;
    self.supplementaryInfoLabel2.layer.cornerRadius = self.supplementaryInfoLabel.layer.cornerRadius = 12.0f;
    self.supplementaryInfoLabel2.userInteractionEnabled = self.supplementaryInfoLabel.userInteractionEnabled = YES;
    
    if (layoutAttributes.progressiveness >= 1) {  // Was 1
        self.searchBar.alpha = 1;
    } else {
        self.searchBar.alpha = 0;
    }

    [UIView commitAnimations];
    // Apply the gesture
    UITapGestureRecognizer* searchTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(searchButtonPressed:)];
    searchTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:searchTap];

}

- (IBAction) infoButtonPressed: (id) sender
{
    if (_delegate) {
        [_delegate infoButtonPressed: sender];
    }
}

- (IBAction) searchButtonPressed: (id) sender
{
    if (_delegate) {
        [_delegate searchButtonPressed: sender];
    }
}

- (IBAction)selectorControlTapped:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(selectorControlTapped:)]) {
        [_delegate selectorControlTapped: sender];
    }
    
}

+ (NSString *)kind
{
    return (NSString *)kTopHeaderKind;
}

+ (CGFloat) maxHeight
{
    return 186; // was 426
}

+ (CGFloat) minHeight
{
    return 110; // was 426
}


@end
