//
//  StylizedTextView.h
//  LoneStar
//
//  Created by sandeep on 11/15/15.
//  Copyright © 2015 Medpresso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StringRendering.h"

@interface StylizedTextView : UIView

- (id) initWithAttributedString: (NSAttributedString *) aString;

@property (nonatomic, strong) NSAttributedString *string;

@end
