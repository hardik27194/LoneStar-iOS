//
//  SettingsTextCell.m
//  SnapticaToo
//
//  Created by sandeep on 1/22/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "SettingsTextCell.h"

#import "SettingsBackgroundView.h"

#import "Constants.h"

#import "Utilities.h"

@implementation SettingsTextCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    [_inputText setDelegate:self];
    _inputText.layer.borderColor=[[UIColor clearColor] CGColor];
    _inputText.layer.borderWidth = 0.0f;
    _inputText.layer.shadowColor=[[UIColor clearColor] CGColor];
    _inputText.layer.masksToBounds = YES;
    _inputText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:(self.settingsItem.placeholder?self.settingsItem.placeholder:@"") attributes:@{NSForegroundColorAttributeName: [UIColor yellowColor]}];
    _inputText.font = [UIFont fontWithName: @"Avenir-Book" size: 16];
    
    

    UIView *bgView = [[SettingsBackgroundView alloc] init] ;
    bgView.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = bgView;

    self.iconImageView.layer.cornerRadius = 18;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    UIView *bgView = [[SettingsBackgroundView alloc] init] ;
    bgView.backgroundColor = /*selected? COLORFROMHEX(0x800080b0):*/ [UIColor clearColor];
    
    self.backgroundView = bgView;

    if (selected) {
        [_inputText becomeFirstResponder];
    } else {
        [_inputText resignFirstResponder];
    }
}


-(BOOL) textFieldShouldEndEditing: (UITextField *)textFld
{
    // validate
    if(self.delegate && [self.delegate conformsToProtocol:@protocol(UITextFieldDelegate)]) {
        return [(id<UITextFieldDelegate>)self.delegate textFieldShouldEndEditing:textFld];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textFld;
{
    if(self.delegate && [self.delegate conformsToProtocol:@protocol(UITextFieldDelegate)]) {
        return [(id<UITextFieldDelegate>)self.delegate textFieldShouldReturn:textFld];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textFld
{
    if(self.delegate && [self.delegate conformsToProtocol:@protocol(UITextFieldDelegate)]) {
        [(id<UITextFieldDelegate>)self.delegate textFieldDidBeginEditing:textFld];
    }
    [self animateTitleLabel];
}


- (void) animateTitleLabel
{
    // Animate the Title Label below the line
    //    [self slideDownTitle:self.titleLabel delta:24];
    CGPoint center = self.titleLabel.center;
    // revert back to the normal state.
    center.y += 60;
    DLog(@"Center: %.1f, %.1f\n", center.x, center.y);
    //    DLog(@"Frame: %.1f, %.1f, %.1f, %.1f\n", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:4.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.titleLabel.center = center;
        
        
    } completion:^(BOOL finished) {
        
        //        [transitionContext completeTransition:YES];
    }];
    
    // For now just hide it
//    self.titleLabel.hidden = YES;
}

-(void) textFieldDidEndEditing: (UITextField *)textFld
{
    NSString *text = [textFld text];
    if ((text != nil) && ([text length] > 0)){
        self.settingsItem.value = textFld.text;
        [self animateTitleLabel];
    }
    if(self.delegate && [self.delegate conformsToProtocol:@protocol(UITextFieldDelegate)]) {
        [(id<UITextFieldDelegate>)self.delegate textFieldDidEndEditing:textFld];
    }
    
}


@end
