//
//  ConferenceHeader.h
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModuleType;
@interface ModuleTypeHeader : UICollectionReusableView

- (void)setConference:(NSString *)title;

@end

@interface SmallModuleTypeHeader: ModuleTypeHeader

+ (NSString *)kind;

@end
