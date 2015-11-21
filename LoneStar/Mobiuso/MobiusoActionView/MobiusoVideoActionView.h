//
//  MobiusoVideoActionView.h
//  SkillsApp
//
//  Created by sandeep on 4/15/15.
//  Copyright (c) 2015 Skyscape. All rights reserved.
//

#import "MobiusoActionView.h"

// Background of a Video (passed as an MP4 file or some such) or PNG/JPG file
@interface MobiusoVideoActionView : MobiusoActionView

@property (nonatomic, retain) NSString *backgroundPath;

- (id) initWithTitle: (NSString *) title
            delegate: (id<MobiusoActionViewDelegate>) delegate
          andMessage: (NSString *) message
     placeholderText: (NSString *) suggestion
   cancelButtonTitle: (NSString *) cancelButtonTitle
   otherButtonTitles: (NSArray *) buttonTitleArray
               color: (UIColor *) color
          background: (NSString *) backgroundFile;

@end
